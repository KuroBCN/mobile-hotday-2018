package com.dynatrace.easytravel.android.interfaces;

import com.dynatrace.easytravel.android.data.Journey;

public interface OnJourneySelectedListener {

    /**
     * A journey entry was selected in the recycler view
     *
     * @param _journey Journey which was selected
     */
    public void onJourneySelected(Journey _journey);

}
