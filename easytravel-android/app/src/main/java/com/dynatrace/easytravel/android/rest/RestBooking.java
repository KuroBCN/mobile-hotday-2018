package com.dynatrace.easytravel.android.rest;

import android.util.Log;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

import java.io.IOException;
import java.io.StringReader;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.HashMap;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

public class RestBooking extends RestCall {

    private static final String LOGTAG = RestCall.class.getSimpleName();
    // REST parameters
    private static final String JOURNEY_ID = "journeyId";
    private static final String USER_NAME = "userName";
    private static final String CREDIT_CARD = "creditCard";
    private static final String AMOUNT = "amount";
    // web services
    private static final String BOOKING_SERVICE = "BookingService";
    private static final String BOOKING_OPERATION = "storeBooking";
    public int BOOKING_SUCCESSFUL = 1;
    public int BOOKING_ERROR = 2;
    public int BOOKING_FAILED = 3;
    private HashMap<String, String> params = new HashMap<String, String>();
    // class-specific properties
    private String bookingId = "-1";
    private int responseStatus = BOOKING_FAILED;

    public RestBooking(String requestHost, Integer requestPort, String journey_id, String user, String card, String amt) {
        super(requestHost, requestPort);
        params.put(JOURNEY_ID, journey_id);
        params.put(USER_NAME, user);
        params.put(CREDIT_CARD, card);
        params.put(AMOUNT, amt);
    }

    public int doBooking() {
        execute();
        return responseStatus;
    }

    @Override
    protected void execute() {
        doNetworkConnection();
    }

    protected URL buildUrl() {
        URL url = null;
        String urlString = null;

        urlString = String.format("%s%s:%s%s/%s/%s%s", HTTP_PREFIX, host, port, SERVICES_PATH, BOOKING_SERVICE, BOOKING_OPERATION, getParamString(params));

        try {
            url = new URL(urlString);
        } catch (MalformedURLException e) {
            Log.e(LOGTAG, "Malformed URL : " + e.toString());
        }

        return url;
    }

    @Override
    protected void parseXML(String response) {
        DocumentBuilderFactory builderFactory = DocumentBuilderFactory.newInstance();
        DocumentBuilder builder = null;
        Document document = null;
        Element rootElement = null;

        InputSource is = new InputSource(new StringReader(response));

        try {
            builder = builderFactory.newDocumentBuilder();
            document = builder.parse(is);
            rootElement = document.getDocumentElement();
        } catch (SAXException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        } catch (ParserConfigurationException e) {
            e.printStackTrace();
        }

        if (rootElement == null) {
            responseStatus = BOOKING_ERROR;
            return;
        }

        NodeList nodelist = rootElement.getElementsByTagName(nsReturn());

        if (nodelist == null) {
            responseStatus = BOOKING_ERROR;
            return;
        }

        for (int i = 0; i < nodelist.getLength(); i++) {
            if (nodelist.item(i) instanceof Element) {
                if (nodelist.item(i).getNodeName().equalsIgnoreCase(nsReturn())) {
                    bookingId = nodelist.item(i).getTextContent();
                    responseStatus = BOOKING_SUCCESSFUL;
                }
            }
        }
    }

    public String getBookingId() {
        return bookingId;
    }
}
