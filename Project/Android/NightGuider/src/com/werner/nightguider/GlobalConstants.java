package com.werner.nightguider;

import java.util.Date;
import java.util.List;

import android.graphics.Typeface;
import android.view.MotionEvent;
import android.view.View;

import com.parse.ParseGeoPoint;

public class GlobalConstants {

	public static String PARSEAPPID = "Jy3BtpqGCsg2Wa6tFM1XpJRN76MRjOPG2oEGCGjB";
	public static String PARSECLIENTKEY = "GUgJ6gEU3R8GgvN3ZZJWek6xixQ9Tr9z6txQVJg4";
	public static String FACEBOOK_APPID = "198963183581189";
	
	public static int refreshEventsCount = 50;
	public static int refreshQueryMaxCount = 999999;
	
	public static String PREF_FACEBOOK_USERNAME = "facebook_username";
	public static String PREF_SETTINGS_POST = "settings_post";
	
	public static String PREF_CITY_NAME = "city_name";
	public static String PREF_CITY_PICK = "city_pick";
	public static String PREF_SEARCH_SEARCHDATE = "search_date";
	
	public static String PARSE_KEY_HOST = "host";
	public static String PARSE_KEY_EVENTNAME = "name";
	public static String PARSE_KEY_EVENTEID = "eid";
	public static String PARSE_KEY_EVENTDESCRIPTION = "description";
	public static String PARSE_KEY_EVENTPICSMALL = "image";
	public static String PARSE_KEY_EVENTPICBIG = "pic_big";
	public static String PARSE_KEY_EVENTSTARTTIME = "start_time";
	public static String PARSE_KEY_EVENTENDTIME = "end_time";
	public static String PARSE_KEY_EVENTENTRANCEPRICE = "entrancePrice";
	public static String PARSE_KEY_EVENTSPECIAL = "special";
	public static String PARSE_KEY_FBLINK = "fb_link";
	public static String PARSE_KEY_STREET = "street";
	public static String PARSE_KEY_LOCATION = "location";
	
	public static String PARSE_KEY_CITYNAME = "name";
	
	public static String PARSE_KEY_CLUBNAME = "name";
	public static String PARSE_KEY_CLUBURL = "url";
	public static String PARSE_KEY_CLUBFACEBOOK = "fb_link";
	public static String PARSE_KEY_CLUBPHONE = "phone";
	public static String PARSE_KEY_CLUBPICSMALL = "pic_Small";
	public static String PARSE_KEY_CLUBPICBIG = "pic_Big";
	public static String PARSE_KEY_CLUBDESCRIPTION = "description";
	public static String PARSE_KEY_CLUBSTREET = "street";
	public static String PARSE_KEY_CLUBLOCATION = "location";
	
	public static int EVENTS_ACTIVITY_COUNT = 0;
	public static int CLUBS_ACTIVITY_COUNT = 0;
	public static int SEARCH_ACTIVITY_COUNT = 0;
	public static int KARTE_ACTIVITY_COUNT = 0;
	public static int FAVORITES_ACTIVITY_COUNT = 0;
	
	public static String Activity_EVENTS="EventsActivity";
	public static String Activity_CLUBS="ClubsActivity";
	public static String Activity_SEARCH="SearchActivity";
	public static String Activity_KARTE="KarteActivity";
	public static String Activity_FAVORITE="FavoriteActivity";
	
	public static Typeface fontAller;
	public static ParseGeoPoint currentLocation;
	
	public static String searchDate;

	public static String BUNDLE_EVENT_HOST = "event_host";
	public static String BUNDLE_EVENT_ID = "event_id";
	public static String BUNDLE_EVENT_EID = "event_eid";
	public static String BUNDLE_EVENT_NAME = "event_name";
	public static String BUNDLE_EVENT_DESCRIPTION = "event_description";
	public static String BUNDLE_EVENT_PICSMALL = "event_picsmall";
	public static String BUNDLE_EVENT_PICBIG = "event_picbig";
	public static String BUNDLE_EVENT_STARTTIME = "event_starttime";
	public static String BUNDLE_EVENT_ENDTIME = "event_endtime";
	public static String BUNDLE_EVENT_ENTRANCEPRICE = "event_entrance";
	public static String BUNDLE_EVENT_FBLINK = "fb_link";
	public static String BUNDLE_EVENT_STREET = "street";
	public static String BUNDLE_EVENT_LATITUDE = "latitude";
	public static String BUNDLE_EVENT_LONGITUDE = "longitude";
	
	public static String BUNDLE_CLUB_ID = "club_id";
	public static String BUNDLE_CLUB_HOST = "club_host";
	public static String BUNDLE_CLUB_DESCRIPTION = "club_description";
	public static String BUNDLE_CLUB_URL = "club_url";
	public static String BUNDLE_CLUB_FACEBOOK = "club_facebook";
	public static String BUNDLE_CLUB_PHONENUMBER = "club_phonenumber";
	public static String BUNDLE_CLUB_NAME = "club_name";
	public static String BUNDLE_CLUB_THUMBNAIL = "club_thumbnail";
	public static String BUNDLE_CLUB_PICBIG = "club_picbig";
	public static String BUNDLE_CLUB_STREET = "club_street";
	public static String BUNDLE_CLUB_LATITUDE = "club_latitude";
	public static String BUNDLE_CLUB_LONGITUDE = "club_longitude";
	public static String BUNDLE_CLUB_DISTANCE = "club_distance";
	
	public static String fromActivity;
	public static boolean isNewSearch = true;
//	public static boolean isEventsDataLoading =false;

	public static List<ListClubsModel> mClubsList = null;
	public static List<ListClubsModel> listOrderedByDist = null;
	
	public static boolean isNearestFromHere = true;
	
	public static List<ListEventsModel> mEventsList = null;
	
	////////////
	
	public static List<ListEventsModel> mEventListForSearch = null;
	public static List<ListClubsModel> mClubListForSearch = null;
	
	///////////
	
	
//	public static List<ListEventsModel> allEventsList = null;
	public static List<ListEventsModel> searchList = null;
	public static List<ListEventsModel> eventsOfClubList = null;
	public static List<String> mGroupKeyList = null;

	public static View.OnTouchListener touchListener = new View.OnTouchListener() {
		@Override
		public boolean onTouch(View v, MotionEvent event) {
			if (event.getAction() == MotionEvent.ACTION_DOWN)
				v.getBackground().setAlpha(130);
			else if (event.getAction() == MotionEvent.ACTION_UP)
				v.getBackground().setAlpha(255);
			return false;
		}
	};
	
	@SuppressWarnings("deprecation")
	public static String dateToString(Date date)
	{
		String dayOfWeek = "";
		switch(date.getDay())
		{
			case 0:
				dayOfWeek = "Sun";
				break;
			case 1:
				dayOfWeek = "Mon";
				break;
			case 2:
				dayOfWeek = "Tue";
				break;
			case 3:
				dayOfWeek = "Wed";
				break;
			case 4:
				dayOfWeek = "Thu";
				break;
			case 5:
				dayOfWeek = "Fri";
				break;
			case 6:
				dayOfWeek = "Sat";
				break;
		}
		String str = dayOfWeek + ", " + date.getDate() + "." + String.valueOf(date.getMonth()+1) + "." +  date.getYear()%100  ;
		return str;
	}
	
    
	public static double distanceBetween(double currentLat2, double currentLong2, double mallLat2, double mallLong2) {
		double pk = 180 / Math.PI;
		double a1 = currentLat2 / pk;
		double a2 = currentLong2 / pk;
		double b1 = mallLat2 / pk;
		double b2 = mallLong2 / pk;

		double t1 = Math.cos(a1) * Math.cos(a2) * Math.cos(b1) * Math.cos(b2);
		double t2 = Math.cos(a1) * Math.sin(a2) * Math.cos(b1) * Math.sin(b2);
		double t3 = Math.sin(a1) * Math.sin(b1);
		double tt = Math.acos(t1 + t2 + t3);

		return 6366000 * tt;
	}
	
	public static void goNextActivity()
	{
		
	}
	
	
}
