package de.qucosa.xmetadissplus;

import java.io.ByteArrayInputStream;
import java.io.StringWriter;
import java.util.HashMap;

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

import org.w3c.dom.Document;

public class XMetaDissMapper {
    private Document metsDoc = null;

    private StreamSource xslSource = null;

    private static final String TRANSFER_URL_PATTERN = "http://%s.example.com/%s/content.zip";

    public XMetaDissMapper(Document metsDoc, StreamSource xslSource) {
        this.metsDoc = metsDoc;
        this.xslSource = xslSource;
    }

    public Document transformXmetaDissplus() throws TransformerFactoryConfigurationError, Exception, XPathExpressionException {
        Transformer transformer = null;
        StringWriter stringWriter = new StringWriter();
        StreamResult streamResult = new StreamResult(stringWriter);
        Document xmetadiss = null;
        transformer = TransformerFactory.newInstance().newTransformer(xslSource);
        transformer.setParameter("transfer_url", String.format(TRANSFER_URL_PATTERN, extractAgent(), extractPid()));
        transformer.transform(new DOMSource(metsDoc), streamResult);

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
        XPath xPath = xpath();
        pid = (String) xPath.compile("//mets:mets/@OBJID").evaluate(metsDoc, XPathConstants.STRING);
        return pid;
    }
    
    private String extractLastModDate() throws XPathExpressionException {
        String date = null;
        XPath xPath = xpath();
        date = (String) xPath.compile("//mets:mets/mets:metsHdr/@LASTMODDATE").evaluate(metsDoc, XPathConstants.STRING);
        return date;
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
