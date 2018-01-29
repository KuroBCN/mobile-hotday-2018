package com.dynatrace.easytravel.android.fragments;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.Switch;

import com.dynatrace.easytravel.android.R;
import com.dynatrace.easytravel.android.application.EasyTravelApplication;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;

public class SettingsFragment extends Fragment {

    // UI elements
    @BindView(R.id.editHost)
    EditText mEditHost;
    @BindView(R.id.editPort)
    EditText mEditPort;
    @BindView(R.id.switchCrash)
    Switch mSwitchCrash;
    @BindView(R.id.switchError)
    Switch mSwitchError;
    @BindView(R.id.switchNotReachable)
    Switch mSwitchNotReachable;

    EasyTravelApplication mApp;

    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View v = inflater.inflate(R.layout.fragment_settings, container, false);
        ButterKnife.bind(this, v);
        mApp = (EasyTravelApplication) getActivity().getApplication();
        mEditHost.setText(mApp.getServerHost());
        mEditPort.setText(String.valueOf(mApp.getRealServerPort()));
        mSwitchCrash.setChecked(mApp.isCrashOnLogin());
        mSwitchError.setChecked(mApp.isErrorsOnSearchAndBooking());
        mSwitchNotReachable.setChecked(mApp.isFrontendNotReachable());
        return v;
    }

    @OnClick(R.id.buttonSaveSettings)
    public void savePreferences() {
        // Save Host and Port
        if (mEditPort.getText().length() != 0 && mEditHost.getText().length() != 0) {
            mApp.setEasyTravelSettings(mEditHost.getText().toString(), Integer.parseInt(mEditPort.getText().toString()));
        }
        // Save Switches
        mApp.setCrashOnLogin(mSwitchCrash.isChecked());
        mApp.setFrontendNotReachable(mSwitchNotReachable.isChecked());
        mApp.setErrorsOnSearchAndBooking(mSwitchError.isChecked());
        mApp.storePreferences();
    }
}
