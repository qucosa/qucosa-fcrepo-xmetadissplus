package de.qucosa.xmetadissplus;

import java.io.ByteArrayInputStream;
import java.io.StringWriter;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.TransformerFactoryConfigurationError;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

import org.apache.commons.lang3.text.StrSubstitutor;
import org.w3c.dom.Document;

public class XMetaDissMapper {
    private Document metsDoc = null;

    private String transferUrlPattern;

    private boolean transferUrlPidencode;

    @SuppressWarnings({ "serial", "unused" })
    private Map<String, String> agentNameSubstitutions = new HashMap<String, String>() {
        {
            put("ubc", "monarch");
        }
        {
            put("ubl", "ul");
        }
    };
    
    public XMetaDissMapper(String transferUrlPattern, String agentNameSubstitutions, boolean transferUrlPidencode) {
        this.transferUrlPattern = transferUrlPattern;
        this.transferUrlPidencode = transferUrlPidencode;
        this.agentNameSubstitutions = decodeSubstitutions(agentNameSubstitutions);
    }

    @SuppressWarnings("serial")
    public Document transformXmetaDissplus(Document metsDoc, StreamSource xslSource) throws TransformerFactoryConfigurationError, Exception, XPathExpressionException {
        this.metsDoc = metsDoc;
        Transformer transformer = null;
        StringWriter stringWriter = new StringWriter();
        StreamResult streamResult = new StreamResult(stringWriter);
        Document xmetadiss = null;
        
        String agentName = extractAgent();
        String pid = extractPid();
        
        Map<String, String> values = new LinkedHashMap<String, String>() {
            {
                put("AGENT", agentName);
            }
            {
                put("PID", pid);
            }
        };
        
        StrSubstitutor substitutor = new StrSubstitutor(values, "##", "##");
        String transferUrl = substitutor.replace(transferUrlPattern);
        
        transformer = TransformerFactory.newInstance().newTransformer(xslSource);
        transformer.setParameter("transfer_url", transferUrl);
        transformer.transform(new DOMSource(this.metsDoc), streamResult);

        DocumentBuilderFactory builderFactory = DocumentBuilderFactory.newInstance();
        builderFactory.setNamespaceAware(true);
        DocumentBuilder documentBuilder = builderFactory.newDocumentBuilder();
        xmetadiss = documentBuilder.parse(new ByteArrayInputStream(stringWriter.toString().getBytes("UTF-8")));

        return xmetadiss;
    }
    
    public String pid() throws XPathExpressionException {
        return extractPid();
    }
    
    public String lastModeDate() throws XPathExpressionException {
        return extractLastModDate();
    }
    
    public String agent() throws XPathExpressionException {
        return extractAgent();
    }

    private String extractAgent() throws XPathExpressionException {
        String agent = null;
        XPath xPath = xpath();
        agent = (String) xPath.compile("//mets:agent[@ROLE='EDITOR' and @TYPE='ORGANIZATION']/mets:name[1]")
                .evaluate(metsDoc, XPathConstants.STRING);
        return agent;
    }

    private String extractPid() throws XPathExpressionException {
        String pid = null;
        
        if (transferUrlPidencode) {
            XPath xPath = xpath();
            pid = (String) xPath.compile("//mets:mets/@OBJID").evaluate(metsDoc, XPathConstants.STRING);
        }
        
        return pid;
    }
    
    private String extractLastModDate() throws XPathExpressionException {
        String date = null;
        XPath xPath = xpath();
        date = (String) xPath.compile("//mets:mets/mets:metsHdr/@LASTMODDATE").evaluate(metsDoc, XPathConstants.STRING);
        return date;
    }
    
    private Map<String, String> decodeSubstitutions(String parameterValue) {
        HashMap<String, String> result = new HashMap<String, String>();

        if (parameterValue != null && !parameterValue.isEmpty()) {

            for (String substitution : parameterValue.split(";")) {
                String[] s = substitution.split("=");
                result.put(s[0].trim(), s[1].trim());
            }
        }

        return result;
    }

    @SuppressWarnings("serial")
    private XPath xpath() {
        XPath xPath = XPathFactory.newInstance().newXPath();
        xPath.setNamespaceContext(new SimpleNamespaceContext(new HashMap<String, String>() {
            {
                put("mets", "http://www.loc.gov/METS/");
            }
        }));
        return xPath;
    }
}
