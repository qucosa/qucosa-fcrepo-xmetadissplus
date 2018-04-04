package de.qucosa.xmetadissplus;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.StringWriter;
import java.io.UnsupportedEncodingException;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.TransformerFactoryConfigurationError;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.w3c.dom.Document;
import org.xml.sax.SAXException;

public class XMetaDissMapper {
    private Document metsDoc = null;
    
    private StreamSource xslSource = null;
    
    public XMetaDissMapper(Document metsDoc, StreamSource xslSource) {
        this.metsDoc = metsDoc;
        this.xslSource = xslSource;
    }
    
    public Document transformXmetaDissplus() throws TransformerFactoryConfigurationError, TransformerException, ParserConfigurationException, UnsupportedEncodingException, SAXException, IOException {
        Transformer transformer = null;
        StringWriter stringWriter = new StringWriter();
        StreamResult streamResult = new StreamResult(stringWriter);
        Document xmetadiss = null;
        transformer = TransformerFactory.newInstance().newTransformer(xslSource);
        transformer.setParameter("transfer_url", null);
        transformer.transform(new DOMSource(metsDoc), streamResult);
        
        DocumentBuilderFactory builderFactory = DocumentBuilderFactory.newInstance();
        builderFactory.setNamespaceAware(true);
        DocumentBuilder documentBuilder = builderFactory.newDocumentBuilder();
        xmetadiss = documentBuilder.parse(new ByteArrayInputStream(stringWriter.toString().getBytes("UTF-8")));
        
        return xmetadiss;
    }
}
