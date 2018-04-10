package de.qucosa.xmetadissplus.date.tests;

import java.sql.Timestamp;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.GregorianCalendar;

import javax.xml.datatype.DatatypeConfigurationException;
import javax.xml.datatype.DatatypeFactory;
import javax.xml.datatype.XMLGregorianCalendar;

import org.junit.Test;

public class XmlDateMappingTests {
    @Test
    public void xmlGregorianMapping_Test() throws DatatypeConfigurationException {
        String metsDate = "2017-06-01T10:59:29.128+00:00";
        XMLGregorianCalendar xmlGregorianCalendar = DatatypeFactory.newInstance().newXMLGregorianCalendar(metsDate);
        DateFormat  df = new SimpleDateFormat("yyyy-MM-dd'T'hh:mm:ss'Z'");
        GregorianCalendar gc = xmlGregorianCalendar.toGregorianCalendar();
        Date date = gc.getTime();
        Timestamp ts = new Timestamp(date.getTime());
    }
}
