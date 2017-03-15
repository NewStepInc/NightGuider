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
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;

import com.parse.ParseException;
import com.parse.ParseFile;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.werner.nightguider.activitygroup.ActivityEventsStack;
import com.werner.nightguider.activitygroup.ActivitySearchStack;
import com.werner.nightguider.adapter.ListEventsAdapter;
 
public class SearchResultActivity extends Activity {
    // Declare Variables
    ListView listview;
    List<ParseObject> ob;
    ProgressDialog mProgressDialog;
    ListEventsAdapter adapter;
    private List<ListEventsModel> eventslist = null;
    private Context context;
    
    Date searchDate;
    
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_searchresult);
        
        Bundle bundle = getIntent().getExtras();
        searchDate = (Date) bundle.getSerializable(GlobalConstants.PREF_SEARCH_SEARCHDATE);
       
        context = getParent();
        // Execute RemoteDataTask AsyncTask
        if(GlobalConstants.isNewSearch ==true || GlobalConstants.searchList ==null)
        {
        	new RemoteDataTask().execute();
        	
        }
        else
        {  
        	showEvents(GlobalConstants.searchList);
        }
        
    }
 
    public void showEvents(final List<ListEventsModel> eventslist)
    {
        // Locate the listview in listview_main.xml
        listview = (ListView) findViewById(R.id.list_searchevents);
        // Pass the results into ListViewAdapter.java
        adapter = new ListEventsAdapter(SearchResultActivity.this,
        		eventslist, null);

        listview.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> adapter, View parent,
					int position, long rowId) {
				// TODO Auto-generated method stub
				
				Intent intent = new Intent();
                intent.putExtra(GlobalConstants.BUNDLE_EVENT_ID, GlobalConstants.searchList.get(position).getObjectId());
                intent.putExtra(GlobalConstants.BUNDLE_EVENT_EID, GlobalConstants.searchList.get(position).getEId());
                intent.putExtra(GlobalConstants.BUNDLE_EVENT_NAME, GlobalConstants.searchList.get(position).getEventName());
                intent.putExtra(GlobalConstants.BUNDLE_EVENT_HOST, GlobalConstants.searchList.get(position).getHost());
                intent.putExtra(GlobalConstants.BUNDLE_EVENT_DESCRIPTION, GlobalConstants.searchList.get(position).getDescription());
                intent.putExtra(GlobalConstants.BUNDLE_EVENT_ENTRANCEPRICE, GlobalConstants.searchList.get(position).getEntrancePrice());
                intent.putExtra(GlobalConstants.BUNDLE_EVENT_STARTTIME, GlobalConstants.searchList.get(position).getStartTime());
                intent.putExtra(GlobalConstants.BUNDLE_EVENT_ENDTIME, GlobalConstants.searchList.get(position).getEndTime());
                intent.putExtra(GlobalConstants.BUNDLE_EVENT_PICSMALL, GlobalConstants.searchList.get(position).getPicSmall());
                intent.putExtra(GlobalConstants.BUNDLE_EVENT_PICBIG, GlobalConstants.searchList.get(position).getPicBig());
                
	            intent.setClass( getParent(), EventsDetailsActivity.class);
                ActivityEventsStack activityStack = (ActivityEventsStack) getParent();
                activityStack.push("EventsActivity" + ++GlobalConstants.EVENTS_ACTIVITY_COUNT, intent);
	            GlobalConstants.isNewSearch = false;
                
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
    	
    	TextView tv = (TextView) this.findViewById(R.id.textView_menutext);
		tv.setText("Alle");
		tv.setTypeface(GlobalConstants.fontAller);
		
		ImageView btn_info = (ImageView) findViewById(R.id.btn_infomation);
		  if(btn_info !=null)
		  {
			  btn_info.setVisibility(View.INVISIBLE);
		  }
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
            // Show progressdialog
            mProgressDialog.show();
            
           
        }

		@Override
        protected Void doInBackground(Void... params) {
            // Create the array
            eventslist = new ArrayList<ListEventsModel>();
            try {
              
            	SharedPreferences pref = PreferenceManager.getDefaultSharedPreferences(SearchResultActivity.this);
            	String cityPick = pref.getString(GlobalConstants.PREF_CITY_PICK, "");
            	 
            	ParseQuery<ParseObject> query = new ParseQuery<ParseObject>("Events");
//                query.whereGreaterThan(GlobalConstants.PARSE_KEY_EVENTSTARTTIME, startDate);
//                query.whereLessThan(GlobalConstants.PARSE_KEY_EVENTENDTIME, endDate);
            	query.whereGreaterThan(GlobalConstants.PARSE_KEY_EVENTENDTIME, searchDate);
            	query.whereLessThanOrEqualTo(GlobalConstants.PARSE_KEY_EVENTSTARTTIME, searchDate);
                query.whereEqualTo("city_pick", cityPick);
                query.setLimit(GlobalConstants.refreshQueryMaxCount);
                query.orderByAscending(GlobalConstants.PARSE_KEY_EVENTSTARTTIME);
                query.orderByAscending("name");
                
                ob = query.find();
                for (ParseObject event : ob) {
                	
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
                    if(startDate == null) continue;
                    map.setStartTime(df.format(startDate));
                    Date endDate = (Date) event.get(GlobalConstants.PARSE_KEY_EVENTENDTIME);
                    if(endDate == null) continue;
                    map.setEndTime(df.format(endDate));
                    
                    eventslist.add(map);
                }
            } catch (ParseException e) {
                Log.e("Error", e.getMessage());
                e.printStackTrace();
            }
            return null;
        }
 
        @Override
        protected void onPostExecute(Void result) {
 
            // Binds the Adapter to the ListView
            mProgressDialog.dismiss();

            showEvents(eventslist);
            
            GlobalConstants.searchList = new ArrayList<ListEventsModel>();
            GlobalConstants.searchList.addAll(eventslist);
           
        }
    }
}