/**
 *
 */
package com.dynatrace.easytravel.android.application;

import android.app.Application;
import android.content.SharedPreferences;

import com.dynatrace.easytravel.android.data.Journey;

import java.util.Vector;

public class EasyTravelApplication extends Application {
    public static final String SOAP_NAMESPACE = "http://webservice.business.easytravel.dynatrace.com";
    public static final String PREFS_NAME = "easyTravelPreferences1";
    private static final String DEFAULT_SERVER_HOSTNAME = "ec2-35-168-8-170.compute-1.amazonaws.com";
    private static final int DEFAULT_SERVER_PORT = 8079;
    private static final String SERVER_HOST_PROPERTY = "serverHost";
    private static final String SERVER_PORT_PROPERTY = "port";
    private static final String USERNAME_PROPERTY = "username";
    private static final String PASSWORD_PROPERTY = "password";
    private static final String FIRST_LAUCH_PROPERTY = "firstLaunch";
    private static final String CRASH_ON_LOGIN_PROPERTY = "crashOnLogin";
    private static final String ERRORS_ON_SEARCH_AND_BOOKING_PROPERTY = "errorsOnSearchAndBooking";
    private static final String FRONTEND_NOT_REACHABLE_PROPERTY = "frontendNotReachable";
    public Vector<Journey> results;
    private String serverHostName = DEFAULT_SERVER_HOSTNAME;
    private int serverPort = DEFAULT_SERVER_PORT;
    private boolean isFirstLaunch = true;
    private boolean crashOnLogin = false;
    private boolean errorsOnSearchAndBooking = false;
    private boolean frontendNotReachable = false;
    private String loggedInUser = null;
    private String userText = "maria";
    private String passwordText = "maria";

    public EasyTravelApplication() {
        super();
    }

    public void setEasyTravelSettings(String serverHost, int serverPort) {
        this.serverHostName = serverHost;
        this.serverPort = serverPort;
        this.isFirstLaunch = false;    //set to false on first time settings are persisted!
    }

    public boolean isFirstLaunch() {
        return isFirstLaunch;
    }

    public String getServerHost() {
        return serverHostName;
    }

    public int getServerPort() {
        if (isFrontendNotReachable()) {
            return serverPort + 123;
        } else {
            return serverPort;
        }
    }

    public int getRealServerPort() {
        return serverPort;
    }

    public boolean isCrashOnLogin() {
        return crashOnLogin;
    }

    public void setCrashOnLogin(boolean crashOnLogin) {
        this.crashOnLogin = crashOnLogin;
    }

    public boolean isErrorsOnSearchAndBooking() {
        return errorsOnSearchAndBooking;
    }

    public void setErrorsOnSearchAndBooking(boolean errorsOnSearchAndBooking) {
        this.errorsOnSearchAndBooking = errorsOnSearchAndBooking;
    }

    public boolean isFrontendNotReachable() {
        return frontendNotReachable;
    }

    public void setFrontendNotReachable(boolean frontendNotReachable) {
        this.frontendNotReachable = frontendNotReachable;
    }

    public String getSoapURI(String path) {
        if (isFrontendNotReachable()) {
            int notReachablePort = 12345 + serverPort;
            return "http://" + serverHostName + ":" + notReachablePort + path;
        }
        return "http://" + serverHostName + ":" + serverPort + path;
    }

    public String getFullActionName(String path) {
        return SOAP_NAMESPACE + path;
    }

    public void restorePreferences() {
        SharedPreferences settings = getSharedPreferences(EasyTravelApplication.PREFS_NAME, 0);
        userText = settings.getString(USERNAME_PROPERTY, userText);
        passwordText = settings.getString(PASSWORD_PROPERTY, passwordText);
        serverHostName = settings.getString(SERVER_HOST_PROPERTY, serverHostName);
        serverPort = settings.getInt(SERVER_PORT_PROPERTY, serverPort);
        isFirstLaunch = settings.getBoolean(FIRST_LAUCH_PROPERTY, true);
        crashOnLogin = settings.getBoolean(CRASH_ON_LOGIN_PROPERTY, false);
        frontendNotReachable = settings.getBoolean(FRONTEND_NOT_REACHABLE_PROPERTY, false);
        errorsOnSearchAndBooking = settings.getBoolean(ERRORS_ON_SEARCH_AND_BOOKING_PROPERTY, false);
    }

    public void storePreferences() {
        SharedPreferences settings = getSharedPreferences(PREFS_NAME, 0);
        SharedPreferences.Editor editor = settings.edit();
        editor.putString(USERNAME_PROPERTY, userText);
        editor.putString(PASSWORD_PROPERTY, passwordText);
        editor.putString(SERVER_HOST_PROPERTY, serverHostName);
        editor.putString(SERVER_HOST_PROPERTY, serverHostName);
        editor.putInt(SERVER_PORT_PROPERTY, serverPort);
        editor.putBoolean(FIRST_LAUCH_PROPERTY, isFirstLaunch);
        editor.putBoolean(CRASH_ON_LOGIN_PROPERTY, crashOnLogin);
        editor.putBoolean(FRONTEND_NOT_REACHABLE_PROPERTY, frontendNotReachable);
        editor.putBoolean(ERRORS_ON_SEARCH_AND_BOOKING_PROPERTY, errorsOnSearchAndBooking);
        editor.commit();
    }

    @Override
    public void onCreate() {
        super.onCreate();
        restorePreferences();
    }

    @Override
    public void onTerminate() {
        super.onTerminate();
    }

    public String getLoggedInUser() {
        return loggedInUser;
    }

    public void setLoggedInUser(String user) {
        loggedInUser = user;
    }

    public String getUserText() {
        return userText;
    }

    public void setUserText(String user) {
        this.userText = user;
    }

    public String getPasswordText() {
        return passwordText;
    }

    public void setPasswordText(String password) {
        this.passwordText = password;
    }

    // TODO (7) provide a getter/setter for the currently open custom user action
    //DTXAction mCurrentAction;
    //public void setCurrentAction(DTXAction action) {
    //    this.mCurrentAction = action;
    //}
    //public DTXAction getCurrentAction() {
    //    return mCurrentAction;
    //}
}
