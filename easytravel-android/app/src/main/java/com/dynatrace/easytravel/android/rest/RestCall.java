package com.dynatrace.easytravel.android.rest;

import android.util.Log;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.StringTokenizer;

public abstract class RestCall {

    protected static final String HTTP_PREFIX = "http://";
    protected static final String SERVICES_PATH = "/services";
    protected static final String HTTP_POST = "POST";
    protected static final String CONTENT_TYPE = "Content-type";
    protected static final String RETURN = "return";
    protected static final String REST_CALL_ACTION_NAME = "RESTCall ";
    protected static final String NETWORK_ERROR = "Network Error";
    protected static final String NAMESPACE_URL_BUSINESS_JPA = "http://business.jpa.easytravel.dynatrace.com/xsd";  //currently xmlns:ax212
    protected static final String NAMESPACE_URL_JPA = "http://jpa.easytravel.dynatrace.com/xsd";   //currently xmlns:ax213
    protected static final String NAMESPACE_URL_TRANSFEROBJ_WEBSERVICE_BUSINESS = "http://transferobj.webservice.business.easytravel.dynatrace.com/xsd";   //currently xmlns:ax216
    protected static final String NAMESPACE_URL_WEBSERVICE_BUSINESS = "http://webservice.business.easytravel.dynatrace.com";   //xmlns:ns
    protected static final String PREFIX_XMLNS = "xmlns:";
    private static final String LOGTAG = RestCall.class.getSimpleName();
    protected static String nsBusinessJpaPrefix;
    protected static String nsJpaPrefix;
    protected static String nsTransferObjWebserviceBusinessPrefix;
    protected static String nsWebserviceBusinessPrefix;
    protected String host;
    protected Integer port;
    protected int responseCode = -1;

    public RestCall(String requestHost, Integer requestPort) {
        host = requestHost;
        port = requestPort;
    }

    protected static String getParamString(HashMap<String, String> parameters) {
        StringBuilder sb = new StringBuilder();

        sb.append("?");

        String prefix = "";

        for (Map.Entry<String, String> entry : parameters.entrySet()) {
            sb.append(prefix);
            prefix = "&";
            sb.append(URLEncoder.encode(entry.getKey()));
            sb.append("=");
            sb.append(URLEncoder.encode(entry.getValue()));
        }

        return sb.toString();
    }

    protected static void parseNamespacePrefix(Map<String, String> attributeMap) {
        //need to parse every time - e.g. if user changes easyTravel host while app is running
        for (Map.Entry entry : attributeMap.entrySet()) {
            String value = (String) entry.getValue();
            String key = (String) entry.getKey();
            if (value.equalsIgnoreCase(NAMESPACE_URL_BUSINESS_JPA)) {
                nsBusinessJpaPrefix = key.substring(PREFIX_XMLNS.length()) + ":";
                Log.i(LOGTAG, "setting namspace prefix: " + nsBusinessJpaPrefix);
            } else if (value.equalsIgnoreCase(NAMESPACE_URL_JPA)) {
                nsJpaPrefix = key.substring(PREFIX_XMLNS.length()) + ":";
                Log.i(LOGTAG, "setting namspace prefix: " + nsJpaPrefix);
            } else if (value.equalsIgnoreCase(NAMESPACE_URL_TRANSFEROBJ_WEBSERVICE_BUSINESS)) {
                nsTransferObjWebserviceBusinessPrefix = key.substring(PREFIX_XMLNS.length()) + ":";
                Log.i(LOGTAG, "setting namspace prefix: " + nsTransferObjWebserviceBusinessPrefix);
            } else if (value.equalsIgnoreCase(NAMESPACE_URL_WEBSERVICE_BUSINESS)) {
                nsWebserviceBusinessPrefix = key.substring(PREFIX_XMLNS.length()) + ":";
                Log.i(LOGTAG, "setting namspace prefix: " + nsWebserviceBusinessPrefix);
            }
        }
    }

    protected void doNetworkConnection() {

        URL url = buildUrl();

        String line;
        HttpURLConnection conn;
        BufferedReader input = null;
        StringBuilder response = new StringBuilder();

        try {
            conn = (HttpURLConnection) url.openConnection();
            conn.setConnectTimeout(10000);
            conn.setRequestMethod(HTTP_POST);
            conn.setDoOutput(true);
            responseCode = conn.getResponseCode();
            input = new BufferedReader(new InputStreamReader(conn.getInputStream()));
            while ((line = input.readLine()) != null) {
                response.append(line);
            }
            input.close();
        } catch (IOException e) {
            Log.e(LOGTAG, "Unable to do network connection.", e);
        }

        String responseString = response.toString();
        //response example <ns:findLocationsResponse xmlns:ns="http://webservice.business.easytravel.dynatrace.com" xmlns:ax216="http://transferobj.webservice.business.easytravel.dynatrace.com/xsd" xmlns:ax212="http://business.jpa.easytravel.dynatrace.com/xsd" xmlns:ax213="http://jpa.easytravel.dynatrace.com/xsd"><ns:return ... returned data ... </ns:return></ns:findLocationsResponse>
        HashMap<String, String> namespacesMap = new HashMap<String, String>(8);
        if (responseString.indexOf("><") != -1) {
            String namespaceString = responseString.substring(0, responseString.indexOf("><"));
            StringTokenizer tk1 = new StringTokenizer(namespaceString, " ");
            ArrayList<String> namespaceKV = new ArrayList<String>(8);
            while (tk1.hasMoreElements()) {
                namespaceKV.add(tk1.nextToken());
            }
            namespaceKV.remove(0);    //first element is no key=value mapping
            for (String kv : namespaceKV) {
                int index = kv.indexOf('=');
                String key = kv.substring(0, index);
                String value = kv.substring(index + 2, kv.length() - 1);    //remove leading and trailing "
                namespacesMap.put(key, value);
            }

            parseNamespacePrefix(namespacesMap);    //need to parse every time - e.g. if user changes easyTravel host while app is running
            parseXML(responseString);
        }
    }

    public int getResponseCode() {
        return responseCode;
    }

    protected abstract void execute();

    protected abstract URL buildUrl();

    protected abstract void parseXML(String response);

    protected String nsReturn() {
        return nsWebserviceBusinessPrefix + RETURN;
    }
}
