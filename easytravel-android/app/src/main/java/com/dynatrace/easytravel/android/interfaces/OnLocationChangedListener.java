package com.dynatrace.easytravel.android.interfaces;

import android.location.Location;

public interface OnLocationChangedListener {

    /**
     * Notfiy others that the GPS location has changed
     *
     * @param _location New GPS location
     */
    public void locationChanged(Location _location);
}
