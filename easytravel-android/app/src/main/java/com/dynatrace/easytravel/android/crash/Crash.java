package com.dynatrace.easytravel.android.crash;

import java.util.Calendar;
import java.util.GregorianCalendar;

public class Crash {
    private boolean crash;

    public Crash() {
    }

    public void boom() {
        crash = true;
        generateException();
    }

    public void pop() {
        crash = false;
        generateException();
    }

    private void generateException() {
        findAll();
    }

    private void findAll() {
        findAllImpl();
    }

    private void findAllImpl() {
        compare();
    }

    private void compare() {
        getValue();
    }

    private void getValue() {
        getValueImpl();
    }

    private void getValueImpl() {
        if (crash) {
            genCrashNow();
        } else {
            genErrorNow();
        }
    }

    private void genErrorNow() {
        String[] array = new String[]{"easyTravel"};
        array[1].length();
    }

    private void genCrashNow() {
        throw new RuntimeException("Intentionally triggered crash! ID: " + GregorianCalendar.getInstance().get(Calendar.HOUR_OF_DAY));    //only use hours value, to create new original crashes after an hour!
    }
}
