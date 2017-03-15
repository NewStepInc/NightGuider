package com.werner.nightguider;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.AsyncTask;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.view.View;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;

import com.parse.ParseException;
import com.parse.ParseFile;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.werner.nightguider.activitygroup.ActivityClubsStack;
import com.werner.nightguider.activitygroup.ActivityEventsStack;
import com.werner.nightguider.activitygroup.ActivityKarteStack;
import com.werner.nightguider.activitygroup.ActivitySearchStack;
import com.werner.nightguider.activitygroup.ActivityTopsStack;
import com.werner.nightguider.adapter.ListEventsOfClubAdapter;
 
public class EventsOfClubActivity extends Activity {
    // Declare Variables
    ListView listview;
    List<ParseObject> ob;
    ProgressDialog mProgressDialog;
    ListEventsOfClubAdapter adapter;
    private List<ListEventsModel> eventsList = null;
    private Context context;
    
    String mClubHost;
    
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_club_events);
        
        Bundle bundle = getIntent().getExtras();
        mClubHost = bundle.getString(GlobalConstants.BUNDLE_CLUB_HOST);
    
       
        context = getParent();
        // Execute RemoteDataTask AsyncTask

        new RemoteDataTask().execute();
       
    }
 
    public void showEvents(final List<ListEventsModel> eventslist)
    {
        // Locate the listview in listview_main.xml
        listview = (ListView) findViewById(R.id.list_searchevents);
        // Pass the results into ListViewAdapter.java
        adapter = new ListEventsOfClubAdapter(EventsOfClubActivity.this,
        		eventslist);

        listview.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> adapter, View parent,
					int position, long rowId) {
				// TODO Auto-generated method stub
				
				Intent intent = new Intent();
                intent.putExtra(GlobalConstants.BUNDLE_EVENT_ID, eventsList.get(position).getObjectId());
                intent.putExtra(GlobalConstants.BUNDLE_EVENT_EID, eventsList.get(position).getEId());
                intent.putExtra(GlobalConstants.BUNDLE_EVENT_NAME, eventsList.get(position).getEventName());
                intent.putExtra(GlobalConstants.BUNDLE_EVENT_HOST, eventsList.get(position).getHost());
                intent.putExtra(GlobalConstants.BUNDLE_EVENT_DESCRIPTION, eventsList.get(position).getDescription());
                intent.putExtra(GlobalConstants.BUNDLE_EVENT_ENTRANCEPRICE, eventsList.get(position).getEntrancePrice());
                intent.putExtra(GlobalConstants.BUNDLE_EVENT_STARTTIME, eventsList.get(position).getStartTime());
                intent.putExtra(GlobalConstants.BUNDLE_EVENT_ENDTIME, eventsList.get(position).getEndTime());
                intent.putExtra(GlobalConstants.BUNDLE_EVENT_PICSMALL, eventsList.get(position).getPicSmall());
                intent.putExtra(GlobalConstants.BUNDLE_EVENT_PICBIG, eventsList.get(position).getPicBig());

	            intent.setClass( getParent(), EventsDetailsActivity.class);
	            if(GlobalConstants.fromActivity == GlobalConstants.Activity_EVENTS)
                {
                	ActivityEventsStack activityStack = (ActivityEventsStack) getParent();
                	activityStack.push("EventsActivity" + ++GlobalConstants.EVENTS_ACTIVITY_COUNT, intent);
                }
                else if(GlobalConstants.fromActivity == GlobalConstants.Activity_SEARCH)
                {
                	ActivitySearchStack activityStack = (ActivitySearchStack) getParent();
                	activityStack.push("SearchActivity" + ++GlobalConstants.SEARCH_ACTIVITY_COUNT, intent);
                }
                else if(GlobalConstants.fromActivity == GlobalConstants.Activity_CLUBS)
                {
                	ActivityClubsStack activityStack = (ActivityClubsStack) getParent();
                	activityStack.push("ClubsActivity" + ++GlobalConstants.CLUBS_ACTIVITY_COUNT, intent);
                }
                else if(GlobalConstants.fromActivity == GlobalConstants.Activity_KARTE)
                {
                	ActivityKarteStack activityStack = (ActivityKarteStack) getParent();
                	activityStack.push("KarteActivity" + ++GlobalConstants.KARTE_ACTIVITY_COUNT, intent);
                }
                else
                {
                	ActivityTopsStack activityStack = (ActivityTopsStack) getParent();
                	activityStack.push("FavoritesActivity" + ++GlobalConstants.FAVORITES_ACTIVITY_COUNT, intent);
                }
//	            GlobalConstants.isNewEventsOfClub = true;
                
			}
		});
        // Binds the Adapter to the ListView
        listview.setAdapter(adapter);
        // Close the progressdialog
    }
  
    @Override
    public void onResume()
    {
    	super.onResume();
    	
    }
     
    // RemoteDataTask AsyncTask
    private class RemoteDataTask extends AsyncTask<Void, Void, Void> {
        @Override
        protected void onPreExecute() {
            super.onPreExecute();
            // Create a progressdialog
            mProgressDialog = new ProgressDialog(context);
            // Set progressdialog title
            mProgressDialog.setTitle("Please wait...");
            // Set progressdialog message
            mProgressDialog.setMessage("Loading...");
            mProgressDialog.setIndeterminate(false);
            mProgressDialog.setCancelable(true);
            // Show progressdialog
            mProgressDialog.show();
            
           
        }
 
		@Override
        protected Void doInBackground(Void... params) {
            // Create the array
            eventsList = new ArrayList<ListEventsModel>();
            
        	SharedPreferences pref = PreferenceManager.getDefaultSharedPreferences(EventsOfClubActivity.this);
        	String cityPick = pref.getString(GlobalConstants.PREF_CITY_PICK, "");
        	
        	ParseQuery<ParseObject> query = new ParseQuery<ParseObject>("Events");
            query.whereGreaterThan(GlobalConstants.PARSE_KEY_EVENTENDTIME, new Date());
            query.whereEqualTo("city_pick", cityPick);
            query.setLimit(GlobalConstants.refreshEventsCount);
            query.orderByAscending(GlobalConstants.PARSE_KEY_EVENTSTARTTIME);
 
            query.whereEqualTo(GlobalConstants.PARSE_KEY_HOST, mClubHost);
            try {
				ob = query.find();
			} catch (ParseException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
            
            for (ParseObject event : ob) {
            	
            	try {
                	ListEventsModel map = new ListEventsModel();
                	
                	map.setObjectId(event.getObjectId());
                    // Locate images in image column
                    ParseFile picSmall = (ParseFile) event.get(GlobalConstants.PARSE_KEY_EVENTPICSMALL);
                    map.setPicSmall(picSmall.getUrl());
                    ParseFile picBig = (ParseFile) event.get(GlobalConstants.PARSE_KEY_EVENTPICBIG);
                    map.setPicBig(picBig.getUrl());
                    
                    map.setEventName((String) event.get(GlobalConstants.PARSE_KEY_EVENTNAME));
                    map.setEId(String.valueOf(event.getLong(GlobalConstants.PARSE_KEY_EVENTEID)));
                    map.setHost((String) event.get(GlobalConstants.PARSE_KEY_HOST));
                    map.setDescription((String) event.get(GlobalConstants.PARSE_KEY_EVENTDESCRIPTION));
                    map.setEntrancePrice((String) event.get(GlobalConstants.PARSE_KEY_EVENTENTRANCEPRICE));
                    map.setSpecial( (Boolean) event.get(GlobalConstants.PARSE_KEY_EVENTSPECIAL));
                    
                    SimpleDateFormat df = new SimpleDateFormat("MMM dd, yyyy_H:mm");
                    Date startDate = (Date) event.get(GlobalConstants.PARSE_KEY_EVENTSTARTTIME);
                    if(startDate != null)
                    	map.setStartTime(df.format(startDate));
                    Date endDate = (Date) event.get(GlobalConstants.PARSE_KEY_EVENTENDTIME);
                    if(endDate != null)
                    	map.setEndTime(df.format(endDate));
                    
                    eventsList.add(map);
                    
            	} catch (Exception e) {
                    continue;
                }
            }
            
            return null;
        }
 
        @Override
        protected void onPostExecute(Void result) {
 
            // Binds the Adapter to the ListView
            mProgressDialog.dismiss();
            
            showEvents(eventsList);
            
            GlobalConstants.eventsOfClubList = new ArrayList<ListEventsModel>();
            GlobalConstants.eventsOfClubList.addAll(eventsList);
           
        }
    }
}