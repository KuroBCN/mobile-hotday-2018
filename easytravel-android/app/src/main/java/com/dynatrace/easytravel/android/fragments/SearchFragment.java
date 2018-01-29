package com.dynatrace.easytravel.android.fragments;

import android.app.DatePickerDialog;
import android.content.Context;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v7.widget.CardView;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.dynatrace.easytravel.android.R;
import com.dynatrace.easytravel.android.application.EasyTravelApplication;
import com.dynatrace.easytravel.android.data.Journey;
import com.dynatrace.easytravel.android.interfaces.OnResultsReturnedListener;
import com.dynatrace.easytravel.android.other.SuggestionAdapter;
import com.dynatrace.easytravel.android.rest.RestJourney;
import com.dynatrace.easytravel.android.rest.RestSearch;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.Vector;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;

public class SearchFragment extends Fragment implements ListView.OnItemClickListener {

    private static final String NO_JOURNEYS_FOUND_ACTION_NAME = "NoJourneysFound";
    private static final String JOURNEYS_FOUND_ACTION_NAME = "JourneysFound";
    private static final String SEARCH_JOURNEY_ACTION_NAME = "searchJourney";

    @BindView(R.id.buttonSearchDest)
    Button mButtonSearch;

    @BindView(R.id.buttonFrom)
    Button mButtonFrom;

    @BindView(R.id.buttonTo)
    Button mButtonTo;

    @BindView(R.id.editDestination)
    EditText mEditDestination;

    @BindView(R.id.searchResults)
    ListView mListResults;

    @BindView(R.id.searchProgress)
    ProgressBar mProgressSearch;

    @BindView(R.id.cardSuggestions)
    CardView mCardSuggestions;

    @BindView(R.id.resultMessage)
    TextView mResultMessage;
    SuggestionAdapter mSuggestionAdapter;
    Calendar mCal;
    OnResultsReturnedListener mCallback;
    private EasyTravelApplication mApp;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View root = inflater.inflate(R.layout.fragment_search, null);
        //ButterKnife.setDebug(true);
        ButterKnife.bind(this, root);

        mApp = (EasyTravelApplication) getActivity().getApplication();

        // Set Date in Button Title
        mCal = Calendar.getInstance();
        mButtonFrom.setText(String.format("%02d", mCal.get(Calendar.DAY_OF_MONTH)) + "." + String.format("%02d", (mCal.get(Calendar.MONTH) + 1)) + "." + mCal.get(Calendar.YEAR));
        mButtonTo.setText(String.format("%02d", mCal.get(Calendar.DAY_OF_MONTH)) + "." + String.format("%02d", (mCal.get(Calendar.MONTH) + 1)) + "." + (mCal.get(Calendar.YEAR) + 1));

        mListResults.setOnItemClickListener(this);

        mEditDestination.addTextChangedListener(new TextWatcher() {

            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
            }

            @Override
            public void afterTextChanged(Editable s) {
                // Start Suggestions Task
                new AsyncSuggestions(s.toString()).execute();
            }
        });

        return root;
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);

        try {
            mCallback = (OnResultsReturnedListener) context;
        } catch (ClassCastException e) {
            throw new ClassCastException(context.toString()
                    + " must implement OnResultsReturnedListener");
        }
    }

    @Override
    public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
        TextView tvName = (TextView) view.findViewById(R.id.suggestionEntry);
        // Set Suggestion in Textfield
        mEditDestination.setText(tvName.getText());
        // Set Cursor to the End
        mEditDestination.setSelection(mEditDestination.getText().length());
    }

    @OnClick({R.id.buttonFrom, R.id.buttonTo})
    public void openDatePicker(final Button _btn) {
        if (getActivity() != null) {
            InputMethodManager imm = (InputMethodManager) getActivity().getSystemService(Context.INPUT_METHOD_SERVICE);
            imm.hideSoftInputFromWindow(getActivity().getCurrentFocus().getWindowToken(), 0);
        }

        DatePickerDialog datePickerDialog = new DatePickerDialog(getActivity(), new DatePickerDialog.OnDateSetListener() {
            @Override
            public void onDateSet(DatePicker view, int year,
                                  int monthOfYear, int dayOfMonth) {
                _btn.setText(String.format("%02d", dayOfMonth) + "." + String.format("%02d", (monthOfYear + 1)) + "." + year);
            }
        }, mCal.get(Calendar.YEAR), mCal.get(Calendar.MONTH), mCal.get(Calendar.DAY_OF_MONTH));
        datePickerDialog.show();
    }

    @OnClick(R.id.buttonSearchDest)
    public void searchDestination(Button _btn) {
        // Turn On Progress Bar
        mProgressSearch.setVisibility(View.VISIBLE);
        new AsyncResults().execute();
    }

    private class AsyncResults extends AsyncTask<Void, Void, Vector<Journey>> {

        String mSuggestedDestination;
        String mDestination;
        Date mDateFrom;
        Date mDateTo;

        @Override
        protected void onPreExecute() {
            super.onPreExecute();

            String dateStrFrom = mButtonFrom.getText().toString();
            String dateStrTo = mButtonTo.getText().toString();

            SimpleDateFormat format = new SimpleDateFormat("dd.MM.yyyy");

            try {
                mDateFrom = format.parse(dateStrFrom);
                mDateTo = format.parse(dateStrTo);
            } catch (ParseException e) {
                e.printStackTrace();
            }


            mDestination = mEditDestination.getText().toString();
            mSuggestedDestination = mSuggestionAdapter.getItem(0);
        }

        @Override
        protected Vector<Journey> doInBackground(Void... params) {
            if (mDateFrom != null && mDateTo != null) {
                RestJourney journey = new RestJourney(mApp.getServerHost(), mApp.getServerPort(), mDestination, mDateFrom.getTime(), mDateTo.getTime());
                ArrayList<RestJourney.JourneyRecord> records = journey.performSearch();
                if (records.size() == 0) {
                    journey = new RestJourney(mApp.getServerHost(), mApp.getServerPort(), mSuggestedDestination, mDateFrom.getTime(), mDateTo.getTime());
                    records = journey.performSearch();
                }

                if (mApp.isErrorsOnSearchAndBooking()) {
                    try {
                        throw new RuntimeException("Search failed with an exception");
                    } catch(Throwable t) {
                        // TODO (12) use the Dynatrace agent to report the exception
                        return null;
                    }
                }

                if (journey.hasError()) {
                    return null;
                } else if (records != null && records.size() > 0) {
                    final ArrayList<RestJourney.JourneyRecord> finalRecords = new ArrayList<RestJourney.JourneyRecord>(records);
                    Vector<Journey> dataJourneys = new Vector<Journey>();
                    for (RestJourney.JourneyRecord record : finalRecords) {
                        dataJourneys.add(new Journey(record));
                    }

                    return dataJourneys;
                } else {
                    return null;
                }
            } else {
                return null;
            }
        }

        @Override
        protected void onPostExecute(Vector<Journey> s) {
            super.onPostExecute(s);

            mProgressSearch.setVisibility(View.GONE);

            if (s == null) {
                // No Results
                mResultMessage.setVisibility(View.VISIBLE);
            } else if (s.size() > 0) {
                // Results
                mApp.results = s;
                mCallback.onResultsReturned(s);
                mResultMessage.setVisibility(View.GONE);
            }
        }
    }

    /**
     * Async Task which downloads Suggestions
     */
    private class AsyncSuggestions extends AsyncTask<Void, Void, String[]> {

        String mSuggestion;

        public AsyncSuggestions(String _suggestion) {
            mSuggestion = _suggestion;
        }

        @Override
        protected void onPreExecute() {
            super.onPreExecute();

            mProgressSearch.setVisibility(View.VISIBLE);
        }

        @Override
        protected String[] doInBackground(Void... params) {
            RestSearch search = new RestSearch(mApp.getServerHost(), mApp.getServerPort(), mSuggestion, true);
            ArrayList<RestSearch.SearchRecord> records = search.performSearch();

            String[] suggestions = new String[records.size()];
            for (int i = 0; i < records.size(); i++) {
                suggestions[i] = records.get(i).name;
            }

            return suggestions;
        }

        @Override
        protected void onPostExecute(String[] searchRecords) {
            super.onPostExecute(searchRecords);

            // List View
            if (getActivity() != null) {
                mSuggestionAdapter = new SuggestionAdapter(getActivity(), searchRecords);
                mListResults.setAdapter(mSuggestionAdapter);
                mCardSuggestions.setVisibility(View.VISIBLE);
            }

            if (searchRecords == null || searchRecords.length == 0) {
                mCardSuggestions.setVisibility(View.GONE);
            }

            mProgressSearch.setVisibility(View.GONE);
        }
    }
}
