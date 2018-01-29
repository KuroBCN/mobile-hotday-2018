package com.dynatrace.easytravel.android.fragments;


import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.dynatrace.easytravel.android.R;
import com.dynatrace.easytravel.android.application.EasyTravelApplication;
import com.dynatrace.easytravel.android.crash.Crash;
import com.dynatrace.easytravel.android.rest.RestLogin;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;


public class UserFragment extends Fragment {

    // UI elements
    @BindView(R.id.editUser)
    EditText mEditUser;
    @BindView(R.id.editPassword)
    EditText mEditPassword;
    @BindView(R.id.resultLogin)
    TextView mResultLogin;
    @BindView(R.id.buttonLogin)
    Button mButtonLogin;
    @BindView(R.id.loginProgress)
    ProgressBar mProgressLogin;

    /**
     * Application link
     */
    private EasyTravelApplication mApp;

    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View v = inflater.inflate(R.layout.fragment_user, container, false);
        ButterKnife.bind(this, v);

        // Hide the progress bar and the results message before the login
        mProgressLogin.setVisibility(View.GONE);
        mResultLogin.setVisibility(View.GONE);

        mApp = (EasyTravelApplication) getActivity().getApplication();

        return v;
    }

    @OnClick(R.id.buttonLogin)
    public void onClickLogin(Button _btn) {
        // Check if username and password is not empty
        if (mEditPassword.getText().toString().length() != 0 && mEditUser.getText().toString().length() != 0) {
            // Show loading
            mResultLogin.setVisibility(View.GONE);
            mProgressLogin.setVisibility(View.VISIBLE);

            // Execute login
            new AsyncLogin().execute();
        }
    }

    /**
     * Async task which is performing a login
     */
    private class AsyncLogin extends AsyncTask<Void, Void, Integer> {

        String mUser;
        String mPassword;

        @Override
        protected void onPreExecute() {
            super.onPreExecute();

            mUser = mEditUser.getText().toString();
            mPassword = mEditPassword.getText().toString();
        }

        @Override
        protected Integer doInBackground(Void... params) {
            RestLogin restLogin = new RestLogin(mApp.getServerHost(), mApp.getServerPort(), mUser, mPassword);

            try {
                restLogin.execute();

                if (restLogin.isSuccessful()) {
                    mApp.setLoggedInUser(mUser);
                    return 1;
                } else {
                    if (restLogin.getResponseCode() == 200) {
                        return 200;
                    } else {
                        return 0;
                    }
                }
            } finally {
                if (mApp.isCrashOnLogin()) {
                    new Crash().boom();
                }
            }
        }

        @Override
        protected void onPostExecute(Integer aVoid) {
            super.onPostExecute(aVoid);

            mResultLogin.setVisibility(View.VISIBLE);

            if (aVoid == 1) {
                // Login Success
                mResultLogin.setText("The login was successful!");
                // TODO (5) identify user
                //Dynatrace.identifyUser(mUser);
            } else if (aVoid == 200) {
                // Login Failed
                mResultLogin.setText("Username or password wrong!");
                // TODO (9) report an error if the user could not log in
                // Dynatrace.reportError("The user " + mUser + " could not log in.", 0);
            } else {
                // Login Failed
                mResultLogin.setText("Connection to server failed!");
                // TODO (10) report an error if the server connection failed
                // Dynatrace.reportError("Could not connect to server. User " + mUser + " could not get logged in.", 0);
            }
            mProgressLogin.setVisibility(View.GONE);
        }
    }
}
