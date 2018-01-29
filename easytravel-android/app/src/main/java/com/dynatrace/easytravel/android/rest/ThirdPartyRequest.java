package com.dynatrace.easytravel.android.rest;

import android.os.AsyncTask;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.MalformedURLException;
import java.net.ProtocolException;
import java.net.URL;

import javax.net.ssl.HttpsURLConnection;

public class ThirdPartyRequest extends AsyncTask<String, String, String> {

    @Override
    protected String doInBackground(String... params) {

        try {
            // Creating & connection Connection with url and required Header.
            URL url = new URL(params[0]);
            HttpsURLConnection urlConnection = (HttpsURLConnection) url.openConnection();
            int statusCode = urlConnection.getResponseCode();
            String statusMsg = urlConnection.getResponseMessage();

            // Connection success. Proceed to fetch the response.
            if (statusCode == 200) {
                InputStream it = new BufferedInputStream(urlConnection.getInputStream());
                InputStreamReader read = new InputStreamReader(it);
                BufferedReader buff = new BufferedReader(read);
                StringBuilder data = new StringBuilder();
                String chunks;
                while ((chunks = buff.readLine()) != null) {
                    data.append(chunks);
                }
                String result = data.toString();
                return result;
            } else {
                //Handle else case
            }
        } catch (ProtocolException e) {
            e.printStackTrace();
        } catch (MalformedURLException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}