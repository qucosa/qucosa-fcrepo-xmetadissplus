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
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.http.impl.conn.PoolingHttpClientConnectionManager;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.servlet.ServletRequest;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URI;

import static javax.servlet.http.HttpServletResponse.SC_BAD_REQUEST;
import static javax.servlet.http.HttpServletResponse.SC_INTERNAL_SERVER_ERROR;
import static javax.servlet.http.HttpServletResponse.SC_NOT_FOUND;
import static javax.servlet.http.HttpServletResponse.SC_OK;

public class DisseminationServlet extends HttpServlet {

    private static final String REQUEST_PARAM_METS_URL = "metsurl";

    private final Logger log = LoggerFactory.getLogger(this.getClass());

    private CloseableHttpClient closeableHttpClient;
    private GenericObjectPool<Transformer> transformerPool;

    @Override
    public void init() {
        closeableHttpClient = HttpClientBuilder.create()
                        .setConnectionManager(new PoolingHttpClientConnectionManager())
                        .build();

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

                    ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
                    transform(response.getEntity().getContent(), byteArrayOutputStream);

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
            sendError(resp, SC_INTERNAL_SERVER_ERROR, anythingElse.getMessage());
        }
    }

    private void sendError(HttpServletResponse resp, int status, String msg) throws IOException {
        resp.setStatus(status);
        resp.setContentType("text/plain");
        resp.setContentLength(msg.getBytes().length);
        resp.getWriter().print(msg);
    }

    private void transform(InputStream in, OutputStream out) throws Exception {
        Transformer transformer = transformerPool.borrowObject();
        transformer.transform(new StreamSource(in), new StreamResult(out));
        transformerPool.returnObject(transformer);
    }

    private String getRequiredRequestParameterValue(ServletRequest request, String name)
            throws MissingRequiredParameter {
        final String v = request.getParameter(name);
        if (v == null || v.isEmpty()) {
            throw new MissingRequiredParameter("Missing parameter '" + REQUEST_PARAM_METS_URL + "'");
        }
        return v;
    }

}
