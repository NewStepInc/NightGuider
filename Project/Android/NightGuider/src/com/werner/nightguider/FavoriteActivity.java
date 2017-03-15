package com.werner.nightguider;

import java.util.ArrayList;
import java.util.List;

import android.app.Activity;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;

import com.werner.nightguider.activitygroup.ActivityClubsStack;
import com.werner.nightguider.activitygroup.ActivityEventsStack;
import com.werner.nightguider.activitygroup.ActivityKarteStack;
import com.werner.nightguider.activitygroup.ActivitySearchStack;
import com.werner.nightguider.activitygroup.ActivityTopsStack;
import com.werner.nightguider.adapter.ListClubsAdapter;
import com.werner.nightguider.adapter.ListEventsAdapter;
import com.werner.nightguider.db.CityClubsTable;
import com.werner.nightguider.db.CityEventsTable;
import com.werner.nightguider.db.DatabaseHelper;

public class FavoriteActivity extends Activity {

	ListView list;
	ListEventsAdapter adapter_event;
	ListClubsAdapter adapter_club;
	DatabaseHelper db;
	public FavoriteActivity CustomListView = null;
	public ArrayList<ListEventsModel> CustomListViewValuesArrEvent = new ArrayList<ListEventsModel>();
	public ArrayList<ListClubsModel> CustomListViewValuesArrClub = new ArrayList<ListClubsModel>();
//	RadioButton segEventBtn;
	
	LinearLayout tabEvent, tabClub, tabEventWhite, tabClubWhite;
	TextView txtEventTab, txtClubTab;
	
	boolean isEventSelected = true;
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_favorites);
		
		tabEvent = (LinearLayout) findViewById(R.id.tab_favo_event);
		tabClub = (LinearLayout) findViewById(R.id.tab_favo_club);
		tabEventWhite = (LinearLayout) findViewById(R.id.tab_favo_event_whitebar);
		tabClubWhite = (LinearLayout) findViewById(R.id.tab_favo_club_whitebar);
		
		txtEventTab = (TextView) findViewById(R.id.tab_favo_event_txt);
		txtClubTab = (TextView) findViewById(R.id.tab_favo_club_txt);
		
		tabEvent.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB) {
					txtEventTab.setAlpha(1);
					txtClubTab.setAlpha((float)0.5);
				}
				tabEventWhite.setVisibility(View.VISIBLE);
				tabClubWhite.setVisibility(View.GONE);
				isEventSelected = true;
				
				list.setAdapter(adapter_event);
				adapter_event.notifyDataSetChanged();
			}
		});
		
		tabClub.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB) {
					txtClubTab.setAlpha(1);
					txtEventTab.setAlpha((float)0.5);
				}
				tabClubWhite.setVisibility(View.VISIBLE);
				tabEventWhite.setVisibility(View.GONE);
				isEventSelected = false;
				
				list.setAdapter(adapter_club);
				adapter_club.notifyDataSetChanged();
			}
		});
		
		db = new DatabaseHelper(getApplicationContext());

		TextView tv = (TextView) this.findViewById(R.id.textView_menutext);
		tv.setText("Favoriten");
		tv.setTypeface(GlobalConstants.fontAller);
		//CustomListView = this;
		
		list = (ListView) findViewById(R.id.list_favorites);
		adapter_event = new ListEventsAdapter(FavoriteActivity.this, CustomListViewValuesArrEvent, null);
		adapter_club = new ListClubsAdapter(FavoriteActivity.this, CustomListViewValuesArrClub);

		list.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> adapter, View parent,
					int position, long rowId) {
				// TODO Auto-generated method stub
				if (isEventSelected)
				{
					Intent intent = new Intent();
	                intent.putExtra(GlobalConstants.BUNDLE_EVENT_ID, CustomListViewValuesArrEvent.get(position).getObjectId());
	                intent.putExtra(GlobalConstants.BUNDLE_EVENT_EID, CustomListViewValuesArrEvent.get(position).getEId());
	                intent.putExtra(GlobalConstants.BUNDLE_EVENT_NAME, CustomListViewValuesArrEvent.get(position).getEventName());
	                intent.putExtra(GlobalConstants.BUNDLE_EVENT_HOST, CustomListViewValuesArrEvent.get(position).getHost());
	                intent.putExtra(GlobalConstants.BUNDLE_EVENT_DESCRIPTION, CustomListViewValuesArrEvent.get(position).getDescription());
	                intent.putExtra(GlobalConstants.BUNDLE_EVENT_ENTRANCEPRICE, CustomListViewValuesArrEvent.get(position).getEntrancePrice());
	                intent.putExtra(GlobalConstants.BUNDLE_EVENT_STARTTIME, CustomListViewValuesArrEvent.get(position).getStartTime());
	                intent.putExtra(GlobalConstants.BUNDLE_EVENT_ENDTIME, CustomListViewValuesArrEvent.get(position).getEndTime());
	                intent.putExtra(GlobalConstants.BUNDLE_EVENT_PICSMALL, CustomListViewValuesArrEvent.get(position).getPicSmall());
	                intent.putExtra(GlobalConstants.BUNDLE_EVENT_PICBIG, CustomListViewValuesArrEvent.get(position).getPicBig());
	                
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
	                
				} else {
					Intent intent = new Intent();
					intent.putExtra(GlobalConstants.BUNDLE_CLUB_ID, CustomListViewValuesArrClub.get(position).getClubId());
	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_DESCRIPTION, CustomListViewValuesArrClub.get(position).getDescription());
	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_THUMBNAIL, CustomListViewValuesArrClub.get(position).getThumbnail());
	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_PICBIG, CustomListViewValuesArrClub.get(position).getBanner());
	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_NAME, CustomListViewValuesArrClub.get(position).getClubName());
	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_STREET, CustomListViewValuesArrClub.get(position).getStreet());
	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_URL, CustomListViewValuesArrClub.get(position).getUrl());
	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_FACEBOOK, CustomListViewValuesArrClub.get(position).getFacebook());
	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_PHONENUMBER, CustomListViewValuesArrClub.get(position).getPhoneNumber());
	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_LATITUDE, CustomListViewValuesArrClub.get(position).getLatitude());
	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_LONGITUDE, CustomListViewValuesArrClub.get(position).getLongtitude());
	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_DISTANCE, CustomListViewValuesArrClub.get(position).getDistance());
	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_HOST, CustomListViewValuesArrClub.get(position).getClubName());
	   	      
	   	            intent.setClass( getParent(), ClubsDetailsActivity.class);
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
	   	            
//	   	            ActivityClubsStack activityStack = (ActivityClubsStack) getParent();
//	  	            activityStack.push("ClubsActivity" + ++GlobalConstants.CLUBS_ACTIVITY_COUNT, intent);
				}
			}
		});
		if (isEventSelected) {
			list.setAdapter(adapter_event);
		} else {
			list.setAdapter(adapter_club);
		}
		
	
//		ImageView btn_info = (ImageView) findViewById(R.id.btn_infomation);
//		if(btn_info !=null)
//		{
//			btn_info.setVisibility(View.INVISIBLE);
//		}
	}
	
	@Override
	public void onPause()
	{
		db.closeDB();
		super.onPause();
	}
	
	@Override
	public void onResume()
	{
		super.onResume();
		fetchEventsfromLocalDB();
		fetchClubsFromLocalDB();
		if (isEventSelected) {
			adapter_event.notifyDataSetChanged();
		} else {
			adapter_club.notifyDataSetChanged();
		}
	}
	
	private void fetchEventsfromLocalDB() {
		CustomListViewValuesArrEvent.clear();
		List<CityEventsTable> events = db.getAllEvents();
		for (int i = 0; i < events.size(); i++) {
			ListEventsModel map = new ListEventsModel();
        	
			map.setObjectId(events.get(i).getObjectId());
			map.setEId(events.get(i).getEventId());
			map.setEventName(events.get(i).getEventName());
            map.setPicSmall(events.get(i).getPicSmall());
            map.setPicBig(events.get(i).getPicBig());   
            map.setHost(events.get(i).getEventHost());
            map.setDescription(events.get(i).getDescription());
            map.setEntrancePrice(events.get(i).getEntrancePrice());
            map.setStartTime(events.get(i).getStartTime());   
            map.setEndTime(events.get(i).getEndTime());
            int flag = events.get(i).getSpecial();
            if(flag == 1)
            	map.setSpecial(true);
            else
            	map.setSpecial(false);
            CustomListViewValuesArrEvent.add(map);
		}
	}

	private void fetchClubsFromLocalDB() {
		CustomListViewValuesArrClub.clear();
		List<CityClubsTable> clubs = db.getAllClubs();
		for (int i = 0; i < clubs.size(); i++) {
			ListClubsModel map = new ListClubsModel();
			
			map.setClubId(clubs.get(i).getObjectId());
			map.setClubName(clubs.get(i).getName());
			map.setDescription(clubs.get(i).getDescription());
			map.setLatitude(clubs.get(i).getLatitude());
			map.setLongtitude(clubs.get(i).getLongitude());
			map.setPhoneNumber(clubs.get(i).getPhoneNumber());
			map.setStreet(clubs.get(i).getStreet());
			map.setThumbnail(clubs.get(i).getThumbnail());
			map.setUrl(clubs.get(i).getUrl());
			
			map.setBanner(clubs.get(i).getBanner());
				
//			map.setBanner(clubs.get(i).);
			CustomListViewValuesArrClub.add(map);
		}
	}
	
	@Override
	public void onBackPressed() {
		// TODO Auto-generated method stub
		Intent intent = new Intent(Intent.ACTION_MAIN);
		intent.addCategory(Intent.CATEGORY_HOME);
		intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		startActivity(intent);
	}
}

