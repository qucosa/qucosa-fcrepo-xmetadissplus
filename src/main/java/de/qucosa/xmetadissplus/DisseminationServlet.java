/*
 * Copyright 2017 Saxon State and University Library Dresden (SLUB)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package de.qucosa.xmetadissplus;

import org.apache.commons.pool2.BasePooledObjectFactory;
import org.apache.commons.pool2.PooledObject;
import org.apache.commons.pool2.impl.DefaultPooledObject;
import org.apache.commons.pool2.impl.GenericObjectPool;
import org.apache.commons.text.StringSubstitutor;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.http.impl.conn.PoolingHttpClientConnectionManager;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.Document;

import javax.servlet.ServletConfig;
import javax.servlet.ServletRequest;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.net.URI;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;

import static javax.servlet.http.HttpServletResponse.SC_BAD_REQUEST;
import static javax.servlet.http.HttpServletResponse.SC_INTERNAL_SERVER_ERROR;
import static javax.servlet.http.HttpServletResponse.SC_NOT_FOUND;
import static javax.servlet.http.HttpServletResponse.SC_OK;

public class DisseminationServlet extends HttpServlet {

    private static final String REQUEST_PARAM_METS_URL = "metsurl";
    private static final String PARAM_TRANSFER_URL_PATTERN = "transfer.url.pattern";
    private static final String PARAM_TRANSFER_URL_PIDENCODE = "transfer.url.pidencode";
    private static final String PARAM_AGENT_NAME_SUBSTITUTIONS = "agent.substitutions";

    private final Logger log = LoggerFactory.getLogger(this.getClass());

    private CloseableHttpClient closeableHttpClient;
    private GenericObjectPool<Transformer> transformerPool;

    private String transferUrlPattern;
    private Map<String, String> agentNameSubstitutions;
    private boolean transferUrlPidencode = false;

    private XPathExpression XPATH_AGENT;

    @Override
    public void init() {

        XPath xPath = XPathFactory.newInstance().newXPath();
        xPath.setNamespaceContext(new SimpleNamespaceContext(new HashMap<String, String>() {{
            put("mets", "http://www.loc.gov/METS/");
        }}));

        try {
            XPATH_AGENT = xPath.compile("//mets:agent[@ROLE='EDITOR' and @TYPE='ORGANIZATION']/mets:name[1]");
        } catch (XPathExpressionException e) {
            throw new IllegalStateException(e);
        }

        closeableHttpClient = HttpClientBuilder.create()
                        .setConnectionManager(new PoolingHttpClientConnectionManager())
                        .build();

        ServletConfig servletConfig = getServletConfig();

        transferUrlPidencode = Boolean.parseBoolean(
                getParameterValue(servletConfig, PARAM_TRANSFER_URL_PIDENCODE,
                        System.getProperty(PARAM_TRANSFER_URL_PIDENCODE, "false")));

        transferUrlPattern = getParameterValue(servletConfig, PARAM_TRANSFER_URL_PATTERN,
                System.getProperty(PARAM_TRANSFER_URL_PATTERN, ""));

        agentNameSubstitutions = decodeSubstitutions(
                getParameterValue(servletConfig, PARAM_AGENT_NAME_SUBSTITUTIONS,
                        System.getProperty(PARAM_AGENT_NAME_SUBSTITUTIONS, "")));

        transformerPool = new GenericObjectPool<>(new BasePooledObjectFactory<Transformer>() {
            @Override
            public Transformer create() throws Exception {
                StreamSource source = new StreamSource(getClass().getResourceAsStream("/mets2xmetadissplus.xsl"));
                return TransformerFactory.newInstance().newTransformer(source);
            }

            @Override
            public PooledObject<Transformer> wrap(Transformer transformer) {
                return new DefaultPooledObject<>(transformer);
            }
        });

        log.info("Started XMetaDissPlus Dissemination...");
    }

    @Override
    public void destroy() {
        try {
            closeableHttpClient.close();
        } catch (IOException e) {
            log.warn("Problem closing HTTP client: " + e.getMessage());
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        try {
            final URI metsDocumentUri = URI.create(getRequiredRequestParameterValue(req, REQUEST_PARAM_METS_URL));

            try (CloseableHttpResponse response = closeableHttpClient.execute(new HttpGet(metsDocumentUri))) {
                if (SC_OK == response.getStatusLine().getStatusCode()) {

                    InputStream metsDocumentInputStream = response.getEntity().getContent();

                    DocumentBuilderFactory documentBuilderFactory = DocumentBuilderFactory.newInstance();
                    documentBuilderFactory.setNamespaceAware(true);
                    Document metsDocument = documentBuilderFactory.newDocumentBuilder().parse(metsDocumentInputStream);

                    String agentName = extractAgentName(metsDocument);
                    String pid = extractObjectPID(metsDocument, transferUrlPidencode);

                    Map<String, String> valuesMap = new LinkedHashMap<>();
                    valuesMap.put("AGENT", agentName);
                    valuesMap.put("PID", pid);

                    StringSubstitutor substitutor = new StringSubstitutor(valuesMap, "##", "##");
                    final String transferUrl = substitutor.replace(transferUrlPattern);

                    ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();

                    Transformer transformer = transformerPool.borrowObject();
                    transformer.setParameter("transfer_url", transferUrl);
                    transformer.transform(
                            new DOMSource(metsDocument),
                            new StreamResult(byteArrayOutputStream));
                    transformerPool.returnObject(transformer);

                    resp.setStatus(SC_OK);
                    resp.setContentType("application/xml");
                    byteArrayOutputStream.writeTo(resp.getOutputStream());

                } else {
                    sendError(resp, SC_NOT_FOUND, "Cannot obtain METS document at " + metsDocumentUri.toASCIIString());
                }
            }
        } catch (MissingRequiredParameter | IllegalArgumentException e) {
            sendError(resp, SC_BAD_REQUEST, e.getMessage());
        } catch (Throwable anythingElse) {
            log.warn("Internal server error", anythingElse);
            sendError(resp, SC_INTERNAL_SERVER_ERROR);
        }
    }

    private void sendError(HttpServletResponse resp, int status) throws IOException {
        sendError(resp, status, null);
    }

    private void sendError(HttpServletResponse resp, int status, String msg) throws IOException {
        if (!resp.isCommitted()) {
            resp.setStatus(status);
            resp.setContentType("text/plain");
            if (msg != null && !msg.isEmpty()) {
                resp.setContentLength(msg.getBytes().length);
                resp.getWriter().print(msg);
            }
        } else {
            log.warn(String.format("Response already committed. Cannot send error '%s' (%d)", msg, status));
        }
    }

    private String getRequiredRequestParameterValue(ServletRequest request, String name)
            throws MissingRequiredParameter {
        final String v = request.getParameter(name);
        if (v == null || v.isEmpty()) {
            throw new MissingRequiredParameter("Missing parameter '" + REQUEST_PARAM_METS_URL + "'");
        }
        return v;
    }

    private String getParameterValue(ServletConfig config, String name, String defaultValue) {
        String v = config.getServletContext().getInitParameter(name);
        return v == null ? defaultValue : v;
    }

    private Map<String, String> decodeSubstitutions(String parameterValue) {
        LinkedHashMap<String, String> result = new LinkedHashMap<>();
        if (parameterValue != null && !parameterValue.isEmpty()) {
            for (String substitution : parameterValue.split(";")) {
                String[] s = substitution.split("=");
                result.put(s[0].trim(), s[1].trim());
            }
        }
        return result;
    }

    private String extractAgentName(Document metsDocument) throws XPathExpressionException {
        String agentNameElement = XPATH_AGENT.evaluate(metsDocument);
        if (agentNameElement != null) {
            String agentName = agentNameElement.trim();
            return agentNameSubstitutions.getOrDefault(agentName, agentName);
        }
        return null;
    }

    private String extractObjectPID(Document metsDocument, boolean encodePid) {
        String pid = metsDocument.getDocumentElement().getAttribute("OBJID");
        if (pid != null && !pid.isEmpty() && encodePid) {
            try {
                pid = URLEncoder.encode(pid, "UTF-8");
            } catch (UnsupportedEncodingException e) {
                // UTF-8 is always supported, unless the JVM runtime changes this
                throw new RuntimeException(e);
            }
        }
        return pid;
    }

}
