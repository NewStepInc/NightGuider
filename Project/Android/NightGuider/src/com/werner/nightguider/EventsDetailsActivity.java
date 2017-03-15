package com.werner.nightguider;

import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Collection;
import java.util.Date;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.graphics.Bitmap;
import android.location.LocationListener;
import android.location.LocationManager;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.preference.PreferenceManager;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentTransaction;
import android.util.Log;
import android.view.Display;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.view.ViewTreeObserver.OnGlobalLayoutListener;
import android.view.Window;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.RadioGroup.OnCheckedChangeListener;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.facebook.FacebookException;
import com.facebook.FacebookOperationCanceledException;
import com.facebook.FacebookRequestError;
import com.facebook.HttpMethod;
import com.facebook.Request;
import com.facebook.RequestAsyncTask;
import com.facebook.Response;
import com.facebook.Session;
import com.facebook.SessionState;
import com.facebook.model.GraphObject;
import com.facebook.model.GraphUser;
import com.facebook.widget.WebDialog;
import com.facebook.widget.WebDialog.OnCompleteListener;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.LatLng;
import com.koushikdutta.urlimageviewhelper.UrlImageViewCallback;
import com.koushikdutta.urlimageviewhelper.UrlImageViewHelper;
import com.parse.GetCallback;
import com.parse.LogInCallback;
import com.parse.ParseException;
import com.parse.ParseFacebookUtils;
import com.parse.ParseGeoPoint;
import com.parse.ParseInstallation;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;
import com.parse.SaveCallback;
import com.werner.nightguider.activitygroup.ActivityClubsStack;
import com.werner.nightguider.activitygroup.ActivityEventsStack;
import com.werner.nightguider.activitygroup.ActivityKarteStack;
import com.werner.nightguider.activitygroup.ActivitySearchStack;
import com.werner.nightguider.activitygroup.ActivityTopsStack;
import com.werner.nightguider.db.CityEventsTable;
import com.werner.nightguider.db.DatabaseHelper;
import com.werner.nightguider.ui.custom.Blur;
import com.werner.nightguider.ui.custom.SegmentedGroup;


 
@SuppressWarnings("deprecation")
public class EventsDetailsActivity extends FragmentActivity implements OnClickListener, OnCheckedChangeListener{
	
	private static final String TAG = "EventsDetailActivity";
	private static final String TAG_MYMAPFRAGMENT = "TAG_MapFragment";
	
	WebDialog feedDialog;
	
	String mStrEventName;
	String mStrEventHost;
	String mStrEventStartTime;
	String mStrEventEndTime;
	String mStrEventPicSmall;
	String mStrEventPicBig;
	String mStrEventId;
	String mLEventEid;
	String mStrEventDescription;
	String mStrEventEntrancePrice;
	String mStrEventFBLink;
	
	String mStrCityPick;
	String mStrClubName;
	String mStrClubDescription;
	String mStrClubDistance;
	String mStrClubThumbnail;
	String mStrClubFacebook;
	String mStrClubUrl;
	String mStrClubPhoneNumber;
	String mStrClubStreet;
	double mDClubLatitude;
	double mDClubLongitude;
	
	DatabaseHelper db;
	Context context;
	
	TextView tvLocation;
	TextView tvInfo;
	TextView tvStreet;
	TextView tvDistance;
	
	private ParseObject mClub;
	private GoogleMap mEventMap;
	private SupportMapFragment mMapFragment;
	
	LocationManager lm;
	LocationListener ll;
	
	private Button btnFavour;
	private Button btnReminder;
	private Button btnShrink;
	
	private boolean isShrinkMode;
	private int realInfoHeight;
	private int defaultInfoHeight;
	
	private boolean mIsFirstSessionCallback;
	private int mFacebookEventType;
	private final int ATTENDING_EVENT = 0;
	private final int MAYBE_EVENT = 1;
	private final int DECLINE_EVENT = 2;
	
	RadioButton btnDecline;
	RadioButton btnMaybe;
	RadioButton btnAttend;
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_eventsdetail);
    
        context =  this;
        db = new DatabaseHelper(getApplicationContext());
        
        
        
        
        SharedPreferences pref = PreferenceManager.getDefaultSharedPreferences(this);
        mStrCityPick = pref.getString(GlobalConstants.PREF_CITY_PICK, "");
        
        Bundle bundle = getIntent().getExtras();
  		mStrEventName = bundle.getString(GlobalConstants.BUNDLE_EVENT_NAME);
        mStrEventHost = bundle.getString(GlobalConstants.BUNDLE_EVENT_HOST);
		mStrEventStartTime = bundle.getString(GlobalConstants.BUNDLE_EVENT_STARTTIME);
		mStrEventEndTime = bundle.getString(GlobalConstants.BUNDLE_EVENT_ENDTIME);
		mStrEventPicSmall = bundle.getString(GlobalConstants.BUNDLE_EVENT_PICSMALL);
		mStrEventPicBig = bundle.getString(GlobalConstants.BUNDLE_EVENT_PICBIG);
		mStrEventId = bundle.getString(GlobalConstants.BUNDLE_EVENT_ID);
		mLEventEid = bundle.getString(GlobalConstants.BUNDLE_EVENT_EID);
		mStrEventDescription = bundle.getString(GlobalConstants.BUNDLE_EVENT_DESCRIPTION);
		mStrEventEntrancePrice = bundle.getString(GlobalConstants.BUNDLE_EVENT_ENTRANCEPRICE);
		mStrEventFBLink = bundle.getString(GlobalConstants.BUNDLE_EVENT_FBLINK);
		mStrClubStreet = bundle.getString(GlobalConstants.BUNDLE_EVENT_STREET);
		mDClubLatitude = bundle.getDouble(GlobalConstants.BUNDLE_EVENT_LATITUDE);
		mDClubLongitude = bundle.getDouble(GlobalConstants.BUNDLE_EVENT_LONGITUDE);
			
		TextView tvName=(TextView) this.findViewById(R.id.textView_menutext);
        tvName.setText(mStrEventName);
        tvName.setTypeface(GlobalConstants.fontAller);
        
        TextView tvHost=(TextView) this.findViewById(R.id.host);
        tvHost.setText(mStrEventHost);
        tvHost.setTypeface(GlobalConstants.fontAller);
          
        TextView tvDate=(TextView) this.findViewById(R.id.date);
        tvDate.setTypeface(GlobalConstants.fontAller);
        
        //show start and end time
        TextView tvTime=(TextView) this.findViewById(R.id.time);


        String s[] = mStrEventStartTime.split("_");

        tvDate.setText(s[0]);
        
        SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy_H:mm");
    	SimpleDateFormat newSdf = new SimpleDateFormat("H:mm");
    	try {
			tvTime.setText(newSdf.format(sdf.parse(mStrEventStartTime)) + " - " + 
					newSdf.format(sdf.parse(mStrEventEndTime)));
			
		} catch (java.text.ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        
        tvTime.setTypeface(GlobalConstants.fontAller);
        
        ImageView imgView=(ImageView) this.findViewById(R.id.list_image);
        UrlImageViewHelper.setUrlDrawable(imgView, mStrEventPicSmall);
        imgView.setOnClickListener(this);
        
        ImageView bannerImageView=(ImageView) this.findViewById(R.id.imgView_banner);
        UrlImageViewHelper.setUrlDrawable(bannerImageView, mStrEventPicSmall, new UrlImageViewCallback() {
			
			@Override
			public void onLoaded(ImageView imgView, Bitmap bmp, String url, boolean arg3) {
				// TODO Auto-generated method stub
				imgView.setImageBitmap(Blur.fastblur(EventsDetailsActivity.this, bmp, 10));
			}
		});
        
        btnFavour = (Button) this.findViewById(R.id.btn_favour_event);
        btnFavour.setOnClickListener(this);
       
        btnReminder = (Button) this.findViewById(R.id.btn_reminder);
        btnReminder.setOnClickListener(this);
        
        btnShrink = (Button) this.findViewById(R.id.btn_shrink);
        btnShrink.setOnClickListener(this);
        
        Button btnShare = (Button) this.findViewById(R.id.btn_share);
        btnShare.setOnClickListener(this);
        SegmentedGroup segmentFacebook = (SegmentedGroup) this.findViewById(R.id.segment_facebook);
//        segmentFacebook.setOnCheckedChangeListener(this);
        
        btnAttend = (RadioButton) findViewById(R.id.btn_attend);
        btnAttend.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
//				SharedPreferences.Editor editor = getSharedPreferences("EventStore", MODE_PRIVATE).edit();
				 
				
				mIsFirstSessionCallback = true;
				mFacebookEventType = ATTENDING_EVENT;
//				editor.putInt(mStrEventName, 1);
				
				
//				editor.commit();
				
				Session.insideTabGroup = true;
				if(Session.getActiveSession() != null && Session.getActiveSession().isOpened())
					requestPermission(Session.getActiveSession(), Arrays.asList("rsvp_event", "publish_actions"));
				else
					loginToFacebook();
			}
		});
        btnMaybe = (RadioButton) findViewById(R.id.btn_maybe);
        btnMaybe.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
//				SharedPreferences.Editor editor = getSharedPreferences("EventStore", MODE_PRIVATE).edit();
				 
		
				
				mIsFirstSessionCallback = true;
				mFacebookEventType = MAYBE_EVENT;
//				editor.putInt(mStrEventName, 2);
				
				
//				editor.commit();
				
				Session.insideTabGroup = true;
				if(Session.getActiveSession() != null && Session.getActiveSession().isOpened())
					requestPermission(Session.getActiveSession(), Arrays.asList("rsvp_event", "publish_actions"));
				else
					loginToFacebook();
				
				
				
			}
		});
        btnDecline = (RadioButton) findViewById(R.id.btn_decline);
        btnDecline.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
//				SharedPreferences.Editor editor = getSharedPreferences("EventStore", MODE_PRIVATE).edit();
				 

				mIsFirstSessionCallback = true;
				mFacebookEventType = DECLINE_EVENT;
//				editor.putInt(mStrEventName, 3);
	
				
//				editor.commit();
				
				Session.insideTabGroup = true;
				if(Session.getActiveSession() != null && Session.getActiveSession().isOpened())
					requestPermission(Session.getActiveSession(), Arrays.asList("rsvp_event", "publish_actions"));
				else
					loginToFacebook();
			}
		});
        
       
        
        //display info
      	tvInfo=(TextView) this.findViewById(R.id.tv_content);
    	tvInfo.setTypeface(GlobalConstants.fontAller);
        tvInfo.setText(mStrEventDescription);
        isShrinkMode = true;
 		
        ViewTreeObserver vto = tvInfo.getViewTreeObserver(); 
        vto.addOnGlobalLayoutListener(new OnGlobalLayoutListener() { 
            @Override 
            public void onGlobalLayout() { 
       	
            	realInfoHeight = tvInfo.getHeight();
             	tvInfo.getViewTreeObserver().removeGlobalOnLayoutListener(this);
             	setInfoHeight(isShrinkMode);
            } 
        }); 
         
        tvLocation=(TextView) this.findViewById(R.id.tv_location);
    	tvLocation.setTypeface(GlobalConstants.fontAller);
        if(mStrEventHost == null || mStrEventHost =="")
        	tvLocation.setVisibility(View.INVISIBLE);
        tvLocation.setOnClickListener(this);
        
        TextView tvMoney=(TextView) this.findViewById(R.id.tv_money);
    	tvMoney.setTypeface(GlobalConstants.fontAller);
    	
        if(mStrEventEntrancePrice == null || mStrEventEntrancePrice =="")
        	tvMoney.setVisibility(View.INVISIBLE);
        else
        	tvMoney.setText(mStrEventEntrancePrice);
        
        
        
        mStrClubDistance = "Google location Service not allowed.";
        if(GlobalConstants.currentLocation!=null)
        {
            double distance = GlobalConstants.distanceBetween(GlobalConstants.currentLocation.getLatitude(), GlobalConstants.currentLocation.getLongitude(),
            		mDClubLatitude, mDClubLongitude)/1000.0f;
            mStrClubDistance = "Distanz :   " + String.format("%.2f", distance) + " km";
        }
        
        tvStreet=(TextView) this.findViewById(R.id.tv_street);
    	tvStreet.setTypeface(GlobalConstants.fontAller);
    	    	
    	tvDistance=(TextView) this.findViewById(R.id.tv_distance);
    	tvDistance.setTypeface(GlobalConstants.fontAller);
    	    	
        tvStreet.setText(mStrClubStreet);
        tvDistance.setText(mStrClubDistance);
        
        TextView tvRoute=(TextView) this.findViewById(R.id.tv_route);
    	tvRoute.setTypeface(GlobalConstants.fontAller);
    	tvRoute.setOnClickListener(this);
        	
    	
//For test 
    	
    	checkFBStatusRSVP();
    	//Test
    	
     }

    @Override
    protected void onPause() {
        super.onPause();

        try{
        	Fragment fragment = getSupportFragmentManager().findFragmentByTag(TAG_MYMAPFRAGMENT);
            FragmentTransaction ft = getSupportFragmentManager().beginTransaction();
            if(fragment.isAdded()){
	            ft.remove(fragment);
	            ft.commitAllowingStateLoss();
            }
        }catch(Exception e){
        	
        }    
    }

    @Override
	public void onActivityResult(int requestCode, int resultCode, Intent data) {
	    super.onActivityResult(requestCode, resultCode, data);
	    
	    if(Session.getActiveSession() != null)
	    	Session.getActiveSession().onActivityResult(this, requestCode, resultCode, data);
	    else
	    	ParseFacebookUtils.finishAuthentication(requestCode, resultCode, data);
	}
    
	@Override
    public void onResume()
    {
    	super.onResume();
    	
    	if(db.isFavourEvent(mStrEventId) == true)
        	btnFavour.setBackgroundResource(R.drawable.star_white_filled);
        else
        	btnFavour.setBackgroundResource(R.drawable.star_white_line);
	
        if(mStrEventHost != null){
        	ParseQuery<ParseObject> query = ParseQuery.getQuery("Clubs");
        	query.whereEqualTo("city_pick", mStrCityPick);
        	query.whereEqualTo("name", mStrEventHost);
        	query.getFirstInBackground(new GetCallback<ParseObject>(){

				@Override
				public void done(ParseObject clubObject, ParseException arg1) {
					// TODO Auto-generated method stub
					if(clubObject != null){
						mClub = clubObject;
						mStrClubDescription= mClub.getString(GlobalConstants.PARSE_KEY_CLUBDESCRIPTION);
						if(mClub.getParseFile(GlobalConstants.PARSE_KEY_CLUBPICBIG) != null)
							mStrClubThumbnail = mClub.getParseFile(GlobalConstants.PARSE_KEY_CLUBPICBIG).getUrl();
			            mStrClubName = mClub.getString(GlobalConstants.PARSE_KEY_CLUBNAME);
			            mStrClubStreet = mClub.getString(GlobalConstants.PARSE_KEY_CLUBSTREET);
			            mStrClubFacebook = mClub.getString(GlobalConstants.PARSE_KEY_CLUBFACEBOOK);
			            mStrClubUrl = mClub.getString(GlobalConstants.PARSE_KEY_CLUBURL);
			            mStrClubPhoneNumber = mClub.getString(GlobalConstants.PARSE_KEY_CLUBPHONE);
			            ParseGeoPoint geoPoint = mClub.getParseGeoPoint(GlobalConstants.PARSE_KEY_CLUBLOCATION);
			            if(geoPoint == null){
			            	mStrClubDistance = "";
			            }else{
				            mDClubLatitude = geoPoint.getLatitude();
				            mDClubLongitude = geoPoint.getLongitude();
			       
				            mStrClubDistance = "Google location Service not allowed.";
		                    if(GlobalConstants.currentLocation!=null)
		                    {
			                    double distance = GlobalConstants.distanceBetween(GlobalConstants.currentLocation.getLatitude(), GlobalConstants.currentLocation.getLongitude(),
			                    		mDClubLatitude, mDClubLongitude)/1000.0f;
			                    mStrClubDistance = "Distanz :   " + String.format("%.2f", distance) + " km";
		                    }
			            }
			            tvStreet.setText(mStrClubStreet);
			            tvDistance.setText(mStrClubDistance);
			            
					}else{
						tvLocation.setVisibility(View.INVISIBLE);
					}
					
					displayMap();
				}
        		
        	});
        }
    }
    
	public void displayMap(){
		try{
	        mMapFragment = SupportMapFragment.newInstance();
	   		FragmentTransaction fragmentTransaction = getSupportFragmentManager().beginTransaction();
			fragmentTransaction.add(R.id.eventMapcontainer, mMapFragment, TAG_MYMAPFRAGMENT);
			fragmentTransaction.commitAllowingStateLoss();
	
			final Handler handler = new Handler();
	        handler.postDelayed(new Runnable() {
	
	           @Override
	           public void run() {
	               mEventMap = mMapFragment.getMap();
	               if(mEventMap != null) {
	                   
	            	   setUpMapIfNeeded();         
	            	   mEventMap.moveCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(
	                		   mDClubLatitude, mDClubLongitude), 12.0f));
	                   handler.removeCallbacksAndMessages(null);
	               }
	
	               else {
	                    handler.postDelayed(this, 200);
	               }
	           }
	         }, 200);
		}catch(Exception e){
			
		}
	}
	
    private void deleteEvent(String eid)
    {
    	db.deleteEvent(eid);
    }
	private void addEvent() {
	
		CityEventsTable events = new CityEventsTable();
		
		events.setObjectId(mStrEventId);
		events.setEventId(mLEventEid);
		events.setEventName(mStrEventName);
		events.setEventHost(mStrEventHost);
		events.setEntrancePrice(mStrEventEntrancePrice);
		events.setDescription(mStrEventDescription);
		events.setStartTime(mStrEventStartTime);
		events.setEndTime(mStrEventEndTime);
		events.setPicSmall(mStrEventPicSmall);
		events.setPicBig(mStrEventPicBig);
		db.enterEvents(events);
					

	}
	
	private void setUpMapIfNeeded() {
	       
        if (mEventMap == null) {
            return;
        }
       
        // Initialize map options. For example:
        mEventMap.setMapType(GoogleMap.MAP_TYPE_NORMAL);
        
   
    }
	
	@SuppressLint("InlinedApi")
	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		
		
		switch (v.getId()) {
			case R.id.list_image:
				
				Intent intent = new Intent();
				intent.putExtra(GlobalConstants.BUNDLE_EVENT_NAME, mStrEventName);
				intent.putExtra(GlobalConstants.BUNDLE_EVENT_PICBIG, mStrEventPicBig);
                intent.setClass( getParent(), EventsLargeImageActivity.class);
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
				break;
				
			case R.id.btn_favour_event:
				
				if(db.isFavourEvent(mStrEventId) == true)
				{
		        	btnFavour.setBackgroundResource(R.drawable.star_white_line);
		        	deleteEvent(mStrEventId);
				}
				else
				{
					btnFavour.setBackgroundResource(R.drawable.star_white_filled);
					addEvent();
				}
		        	
		        break;
				
			case R.id.btn_reminder:
				 SimpleDateFormat df = new SimpleDateFormat("MMM dd, yyyy_H:mm");
                 Date startTime = new Date();
                 Date endTime = new Date();
                 try{
                	 startTime = df.parse(mStrEventStartTime);
                	 endTime = df.parse(mStrEventEndTime);
                 }catch(Exception e){
                	 e.printStackTrace();
                	 Toast.makeText(this, "Event konnte dem Kalender leider nicht hinzugef�gt werden", Toast.LENGTH_SHORT);
                	 return;
                 }

				intent = new Intent(Intent.ACTION_EDIT);
				intent.setType("vnd.android.cursor.item/event");
				intent.putExtra("beginTime", startTime.getTime());
				intent.putExtra("allDay", true);
				intent.putExtra("rrule", "FREQ=YEARLY");
				intent.putExtra("endTime", endTime.getTime());
				intent.putExtra("title", mStrEventHost);
				startActivity(intent);

				Toast.makeText(this, "Event wurde dem Kalender hinzugef�gt", Toast.LENGTH_SHORT);
				break;
					
			case R.id.btn_shrink:
				
				isShrinkMode = ! isShrinkMode;
				setInfoHeight(isShrinkMode);
				break;
			case R.id.tv_location:
		           
		           	intent = new Intent();
		            intent.putExtra(GlobalConstants.BUNDLE_CLUB_DESCRIPTION, mStrClubDescription);
	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_PICBIG, mStrClubThumbnail);
	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_NAME, mStrClubName);
	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_STREET, mStrClubStreet);
	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_URL, mStrClubUrl);
	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_FACEBOOK, mStrClubFacebook);
	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_PHONENUMBER, mStrClubPhoneNumber);
	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_LATITUDE, mDClubLatitude);
	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_LONGITUDE, mDClubLongitude);
	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_DISTANCE, mStrClubDistance);
		           	intent.putExtra(GlobalConstants.BUNDLE_CLUB_HOST, mStrEventHost);
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
			        else if(GlobalConstants.fromActivity == GlobalConstants.Activity_FAVORITE)
			        {
			        	 ActivityTopsStack activityStack = (ActivityTopsStack) getParent();
			        	 activityStack.push("FavoirtesActivity" + ++GlobalConstants.FAVORITES_ACTIVITY_COUNT, intent);
			        }
					break;
				
			case R.id.tv_route:
				double sLatitude = 0.0;
				double sLongitude = 0.0;
				double dLatitude = 0.0;
				double dLongitude = 0.0;
				
				if(GlobalConstants.currentLocation != null){
					sLatitude = GlobalConstants.currentLocation.getLatitude();
					sLongitude = GlobalConstants.currentLocation.getLongitude();
				}
				
				ParseGeoPoint geoPoint = mClub.getParseGeoPoint(GlobalConstants.PARSE_KEY_CLUBLOCATION);
				if(mClub != null){
					dLatitude = geoPoint.getLatitude();
					dLongitude = geoPoint.getLongitude();
				}
				
				intent = new Intent(Intent.ACTION_VIEW, Uri.parse("http://maps.google.com/maps?" + "saddr="+ sLatitude + "," +  sLongitude + "&daddr=" + dLatitude + "," + dLongitude));
			    intent.setClassName("com.google.android.apps.maps","com.google.android.maps.MapsActivity");
			        
//				String uri = "geo:"+ String.valueOf(club.getLatitude()) + "," + String.valueOf(club.getLongtitude());
//				intent = new Intent(Intent.ACTION_VIEW);
//				intent.setData(Uri.parse(uri));
//	            intent.setData(Uri.parse("geo:0,0?q=" + ("40.7890011, -124.1719112")));
	            try {
	                startActivity(intent);
	            } catch (Exception e) {
	                e.printStackTrace();
	            }
				break;
			case R.id.btn_share:
				// Creating dialog box to choose SortByCategory Option
				AlertDialog.Builder buildSingle = new AlertDialog.Builder(getParent());
				//buildSingle.setIcon(R.drawable.market_icon);
				buildSingle.setTitle("Teilen");
				final ArrayAdapter<String> aAdapter = new ArrayAdapter<String>(getParent(),
						android.R.layout.select_dialog_item);
				aAdapter.add("via Facebook");
				aAdapter.add("via Email");
				aAdapter.add("via SMS");

				buildSingle.setNegativeButton("Cancel",
						new DialogInterface.OnClickListener() {

							@Override
							public void onClick(DialogInterface dialog, int which) {
								// TODO Auto-generated method stub
								dialog.dismiss();
							}
						});

				buildSingle.setAdapter(aAdapter,
						new DialogInterface.OnClickListener() {

							@Override
							public void onClick(DialogInterface dialog, int which) {
								// TODO Auto-generated method stub
								String strOptionChosen = aAdapter.getItem(which)
										.toString();
								if (strOptionChosen.equals("via Facebook")) {
									
									publishFeedDialog();
									
								}else if (strOptionChosen.equals("via Email")) {
									
									Intent email = new Intent(Intent.ACTION_SEND);
									email.putExtra(Intent.EXTRA_EMAIL, new String[]{"youremail@yahoo.com"});		  
									email.putExtra(Intent.EXTRA_SUBJECT, "subject");
									email.putExtra(Intent.EXTRA_TEXT, mStrEventName +"\n\n via NightGuider" + "\n\n Sent from my mobile device" );
									email.setType("message/rfc822");
									startActivity(Intent.createChooser(email, "Choose an Email client :"));
									
								}else if (strOptionChosen.equals("via SMS")) {
									
					                try{
										startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("sms:"
						                        + mStrClubPhoneNumber)));
									}catch(Exception e)
									{
										Toast.makeText(EventsDetailsActivity.this, "You can't send sms message now.", Toast.LENGTH_LONG).show();
									}
								}
							}
						});
				buildSingle.show();
				break;				
		}
	}
	
//	public void loginToFacebook() {
//		mPrefs = getPreferences(MODE_PRIVATE);
//		String access_token = mPrefs.getString("access_token", null);
//		long expires = mPrefs.getLong("access_expires", 0);
//
//		if (access_token != null) {
//			facebook.setAccessToken(access_token);
//		}
//
//		if (expires != 0) {
//			facebook.setAccessExpires(expires);
//		}
//
//		if (!facebook.isSessionValid()) {
//			facebook.authorize(getParent(),
//					new String[] { "email", "publish_stream", "publish_actions", "rsvp_event" }, Facebook.FORCE_DIALOG_AUTH,
//					new DialogListener() {
//
//						@Override
//						public void onCancel() {
//							// Function to handle cancel event
//						}
//
//						@Override
//						public void onComplete(Bundle values) {
//							// Function to handle complete event
//							// Edit Preferences and update facebook acess_token
//							SharedPreferences.Editor editor = mPrefs.edit();
//							editor.putString("access_token",
//									facebook.getAccessToken());
//							editor.putLong("access_expires",
//									facebook.getAccessExpires());
//							editor.commit();
//							
//							postToWall();
//						}
//
//						@Override
//						public void onError(DialogError error) {
//							// Function to handle error
//
//						}
//
//						@Override
//						public void onFacebookError(FacebookError fberror) {
//							// Function to handle Facebook errors
//
//						}
//
//					});
//		}
//		else
//			postToWall();
//	}
//	
//	
//	private UiLifecycleHelper uiHelper;
//	private Session.StatusCallback callback = new Session.StatusCallback() {
//	    @Override
//	    public void call(final Session session, final SessionState state, final Exception exception) {
//	        onSessionStateChange(session, state, exception);
//	    }
//	};
//	
//	private void onSessionStateChange(Session session, SessionState state, Exception exception) {
//	    if (state.isOpened()) {
//	    	if (pendingPublishReauthorization && 
//	    	        state.equals(SessionState.OPENED_TOKEN_UPDATED)) {
//	    	    pendingPublishReauthorization = false;
//	    	    publishStory();
//	    	}
//	    } else if (state.isClosed()) {
//	        
//	    }
//	}
	
//	@Override
//	public void onSaveInstanceState(Bundle outState) {
//	    super.onSaveInstanceState(outState);
//	    outState.putBoolean(PENDING_PUBLISH_KEY, pendingPublishReauthorization);
////	    uiHelper.onSaveInstanceState(outState);
//	}
	

		
//	    Session session = Session.getActiveSession();
//
//	    if (session != null){
//
//	        // Check for publish permissions    
//	        List<String> permissions = session.getPermissions();
//	        if (!isSubsetOf(PERMISSIONS, permissions)) {
//	            pendingPublishReauthorization = true;
//	            Session.NewPermissionsRequest newPermissionsRequest = new Session
//	                    .NewPermissionsRequest(this, PERMISSIONS);
//	        session.requestNewPublishPermissions(newPermissionsRequest);
//	            return;
//	        }
//
//	        Bundle postParams = new Bundle();
//	        postParams.putString("name", "Facebook SDK for Android");
//	        postParams.putString("caption", "Build great social apps and get more installs.");
//	        postParams.putString("description", "The Facebook SDK for Android makes it easier and faster to develop Facebook integrated Android apps.");
//	        postParams.putString("link", "https://developers.facebook.com/android");
//	        postParams.putString("picture", "https://raw.github.com/fbsamples/ios-3.x-howtos/master/Images/iossdk_logo.png");
//
//	        Request.Callback callback= new Request.Callback() {
//	            public void onCompleted(Response response) {
//	                JSONObject graphResponse = response
//	                                           .getGraphObject()
//	                                           .getInnerJSONObject();
//	                String postId = null;
//	                try {
//	                    postId = graphResponse.getString("id");
//	                } catch (JSONException e) {
//	                    Log.i(TAG,
//	                        "JSON error "+ e.getMessage());
//	                }
//	                FacebookRequestError error = response.getError();
//	                if (error != null) {
//	                    Toast.makeText(getApplicationContext(),
//	                         error.getErrorMessage(),
//	                         Toast.LENGTH_SHORT).show();
//	                    } else {
//	                        Toast.makeText(getApplicationContext(), 
//	                             postId,
//	                             Toast.LENGTH_LONG).show();
//	                }
//	            }
//	        };
//
//	        Request request = new Request(session, "me/feed", postParams, 
//	                              HttpMethod.POST, callback);
//
//	        RequestAsyncTask task = new RequestAsyncTask(request);
//	        task.execute();
//	    }

		
	private void postEvent(final String kind, final String paramsMessage) {
		
//		mProgressDialog = new ProgressDialog(getParent());
//        // Set progressdialog title
//        mProgressDialog.setTitle("Please wait...");
//        // Set progressdialog message
//        mProgressDialog.setMessage("Posting...");
//        mProgressDialog.setIndeterminate(false);
//        mProgressDialog.show();
        
//		Session.insideTabGroup = true;
		final Session session = ParseFacebookUtils.getSession();
		if(session != null && session.isOpened() ==true ){
	      			    
	    	       Request.Callback callback= new Request.Callback() {
	    	            public void onCompleted(Response response) {
	    	            
	    	                FacebookRequestError error = response.getError();
	    	                if (error != null) {
	    	                    Toast.makeText(getApplicationContext(),
	    	                        error.getErrorMessage(),
	    	                        Toast.LENGTH_SHORT).show();
	    	                    } else {
	    	                    	
	    	                    	if(!kind.equalsIgnoreCase("declined")){
	    	                    		SharedPreferences pref = PreferenceManager.getDefaultSharedPreferences(EventsDetailsActivity.this);
	    	                    		if(pref.getBoolean(GlobalConstants.PREF_SETTINGS_POST, true))
	    	                    			publishStory(session, paramsMessage);
	    	                    	}
	    	                }
	    	            }
	    	        };
	    
	    	        Request request = new Request(session, String.valueOf(mLEventEid) + "/" + kind, null, 
	    	                              HttpMethod.POST, callback);
	    	        RequestAsyncTask task = new RequestAsyncTask(request);
	    	        task.execute();
		}else{
			Toast.makeText(getApplicationContext(),
                    "Please go to setting and login to Facebook",
                    Toast.LENGTH_SHORT).show();
		}
		
		
		

	}
	private int stateOfEvent = 0;
	static String currentFacebookID;
//	static ProgressDialog mProgress;
	private void checkFBStatusRSVP()
	{
		final Session session = ParseFacebookUtils.getSession();
		
		SharedPreferences shredValues = getSharedPreferences("EventStore", MODE_PRIVATE); 
		currentFacebookID = shredValues.getString("FacebookID", "");
		
		
//		mProgress = new ProgressDialog(this);
//		mProgress.setTitle("Please wait...");
//		mProgress.setMessage("Loading...");
//		mProgress.setIndeterminate(false);
//		mProgress.setCancelable(true);
//		mProgress.show();
		
		
		Request request = new Request(session, String.valueOf(mLEventEid) + "/" + "attending", null, 
                HttpMethod.GET, new Request.Callback() {
//		Request request = new Request(session, "/me/events/maybe", null, 
//                HttpMethod.GET, new Request.Callback() {
					
					@Override
					public void onCompleted(Response response) {
						// TODO Auto-generated method stub
//						Log.v("%s", response.toString());
						if (response.getError() != null)
						{
							return;
						}
						JSONObject objJson;
					
						objJson = response.getGraphObject().getInnerJSONObject();
						JSONArray aryJsonData = objJson.optJSONArray("data");
						
						stateOfEvent = 0;
						
						for (int i = 0; i < aryJsonData.length(); i++) {
							try {
								JSONObject curJsonObj = aryJsonData.getJSONObject(i);
								String strCurID = curJsonObj.optString("id");
								if (currentFacebookID.equals(strCurID)) {
									stateOfEvent = 1;
									btnAttend.setChecked(true);	
//									mProgress.dismiss();
									break;
								} 
							} catch (JSONException e) {
								// TODO Auto-generated catch block
								e.printStackTrace();
							}
							
						}
						if (stateOfEvent == 0) {
							Request subRequest = new Request(session, String.valueOf(mLEventEid) + "/" + "maybe", null, 
					                HttpMethod.GET, new Request.Callback() {
	
										@Override
										public void onCompleted(Response response) {
											// TODO Auto-generated method stub
											
												JSONObject objJson;
												objJson = response.getGraphObject().getInnerJSONObject();
												JSONArray aryJsonData = objJson.optJSONArray("data");
												for (int i = 0; i < aryJsonData.length(); i++) {
													try {
														JSONObject curJsonObj = aryJsonData.getJSONObject(i);
														String strCurID = curJsonObj.optString("id");
														if (currentFacebookID.equals(strCurID)) {
															stateOfEvent = 2;
															btnMaybe.setChecked(true);
//															mProgress.dismiss();
															break;
														} 
													} catch (JSONException e) {
														// TODO Auto-generated catch block
														e.printStackTrace();
													}
													
												}
											if (stateOfEvent == 0 || stateOfEvent == 1) {
												Request sub2dRequest = new Request(session, String.valueOf(mLEventEid) + "/" + "declined", null,
										                HttpMethod.GET, new Request.Callback() {
		
															@Override
															public void onCompleted(Response response) {
																// TODO Auto-generated method stub
																JSONObject objJson;
																objJson = response.getGraphObject().getInnerJSONObject();
																JSONArray aryJsonData = objJson.optJSONArray("data");
																for (int i = 0; i < aryJsonData.length(); i++) {
																	try {
																		JSONObject curJsonObj = aryJsonData.getJSONObject(i);
																		String strCurID = curJsonObj.optString("id");
																		if (currentFacebookID.equals(strCurID)) {
																			stateOfEvent = 3;
																			btnDecline.setChecked(true);
//																			mProgress.dismiss();
																			break;
																		} 
																	} catch (JSONException e) {
																		// TODO Auto-generated catch block
																		e.printStackTrace();
																	}
																}
																
															}
															
													
												});
												
												
												RequestAsyncTask sub2dTask = new RequestAsyncTask(sub2dRequest);
												sub2dTask.execute();
											}
											else {
//												mProgress.dismiss();
											}
								        		
											
										}	
							});	
							if (stateOfEvent == 1 ) {
								btnAttend.setChecked(true);
							} else if(stateOfEvent == 2) {
								btnMaybe.setChecked(true);
							} else if(stateOfEvent == 3) {
								btnDecline.setChecked(true);
							}
							RequestAsyncTask subTask = new RequestAsyncTask(subRequest);
							subTask.execute();
							}
						}
				});
		RequestAsyncTask task = new RequestAsyncTask(request);
		task.execute();
		
//		if(session != null && session.isOpened() ==true ){
//		/* make the API call */
//		new Request(
//		    session,
//		    "/me/events",
//		    null,
//		    HttpMethod.GET,
//		    new Request.Callback() {
//		        public void onCompleted(Response response) {
//		            /* handle the result */
//		        	
//		        	Log.v("%s", "fsadfasdf");
//		        }
//		    }
//		).executeAsync();
//	}
	}

	public void publishStory(Session session, String paramMessage)
	{
		 Bundle postParams = new Bundle();
	     postParams.putString("message", paramMessage);
	     postParams.putString("name", mStrEventName);
	     postParams.putString("caption", "Dein Guide f�r alle Partys immer und �berall.");
	     postParams.putString("description", mStrEventDescription);
	     postParams.putString("link", "http://nightguider.de/download");
	     postParams.putString("picture", mStrEventPicBig);
	     /* make the API call */
	     new Request(
	    		    session,
	    		    "me/feed",
	    		    postParams,
	    		    HttpMethod.POST,
	    		    new Request.Callback() {
	    		        public void onCompleted(Response response) {
	    		            /* handle the result */
	    		        	FacebookRequestError error = response.getError();
	    	                if (error != null) {
	    	                    Toast.makeText(getApplicationContext(),
	    	                         error.getErrorMessage(),
	    	                         Toast.LENGTH_SHORT).show();
	    	                } else {
//	    	                	mProgressDialog.dismiss();
    	                    	Toast.makeText(getApplicationContext(), 
       	                             "Posted successfully",
       	                             Toast.LENGTH_LONG).show();
	    	                }
	    		        	 
	    		        }
	    		    }
	    		).executeAsync();
	}
		
	private void setInfoHeight(boolean shrink)
	{
        //get Info textview default height
        RelativeLayout layout_top  = (RelativeLayout) this.findViewById(R.id.layout_title);
		ViewGroup.LayoutParams paramsTitle =(ViewGroup.LayoutParams) layout_top.getLayoutParams();
		RelativeLayout layout_header  = (RelativeLayout) this.findViewById(R.id.layout_header);
		ViewGroup.LayoutParams paramsHeader =(ViewGroup.LayoutParams) layout_header.getLayoutParams();
		LinearLayout layout_segment  = (LinearLayout) this.findViewById(R.id.layout_segment);
		ViewGroup.LayoutParams paramsSegments =(ViewGroup.LayoutParams) layout_segment.getLayoutParams();
		RelativeLayout layout_bottom  = (RelativeLayout) this.findViewById(R.id.layout_bottom);
		ViewGroup.LayoutParams paramsBottom =(ViewGroup.LayoutParams) layout_bottom.getLayoutParams();
		RelativeLayout layout_map  = (RelativeLayout) this.findViewById(R.id.eventMapcontainer);
		ViewGroup.LayoutParams paramsMap =(ViewGroup.LayoutParams) layout_map.getLayoutParams();
		Display display = getWindowManager().getDefaultDisplay();
		int screenHeight = display.getHeight();
		
		defaultInfoHeight = (int) (screenHeight - (paramsTitle.height + paramsHeader.height + paramsSegments.height + paramsBottom.height + paramsMap.height + getResources().getDimension(R.dimen.tabbar_height) + 25 * 1.5));
		
		ViewGroup.LayoutParams params1 =(ViewGroup.LayoutParams) tvInfo.getLayoutParams();
		if(shrink == false)
		{
	       	params1.height = Math.max(realInfoHeight, defaultInfoHeight);
	       	btnShrink.setBackgroundResource(R.drawable.up_button);
    	}
		else
		{
        	params1.height = defaultInfoHeight;
        	btnShrink.setBackgroundResource(R.drawable.down_button);
    	}
		tvInfo.setLayoutParams(params1);
	}
	
	private void publishFeedDialog() {
		
	    final Bundle postParams = new Bundle();
	    String paramMessage = mStrEventName + "\n" + mStrEventFBLink;
//	    postParams.putString("message", paramMessage);
	    postParams.putString("name", "Nightguider");
	    postParams.putString("caption", paramMessage);
	    postParams.putString("description", "Mit NightGuider hast du die M�glichkeit auf neue Events aufmerksam gemacht zu werden, Informationen und viele weitere Funktionen zu erhalten UND es ist kostenlos.");
	    postParams.putString("link", "http://nightguider.de/download");
	    postParams.putString("picture", "http://nightguider.de/wp-content/uploads/2013/03/appicon-website-mask.png");
  
	    Session session = ParseFacebookUtils.getSession();
//	    Session.insideTabGroup = true;
//	    final Session session = ParseFacebookUtils.getSession();
//		if(session != null && session.isOpened() ==true ){
//			Session.openActiveSession(this, true, new Session.StatusCallback() {
//	
//				@Override
//		        public void call(final Session session, SessionState state, Exception exception) {
//		      	  
//					Log.d("Testing", "session opened  "+session.isOpened());
//		      		Log.d("Testing", "session closed  "+session.isClosed());
		  	      		
		      		if (session != null && session.isOpened()) {
		      		    WebDialog feedDialog = (
		      			        new WebDialog.FeedDialogBuilder(getParent(),
		      			            session,
		      			            postParams))
		      			        .setOnCompleteListener(new OnCompleteListener() {
	
		      			            @Override
		      			            public void onComplete(Bundle values,
		      			                FacebookException error) {
		      			                if (error == null) {
		      			                    // When the story is posted, echo the success
		      			                    // and the post Id.
		      			                    final String postId = values.getString("post_id");
		      			                    if (postId != null) {
		      			                        Toast.makeText(getParent(),
		      			                            "Posted successfully",
		      			                            Toast.LENGTH_SHORT).show();
		      			                    } else {
		      			                        // User clicked the Cancel button
		      			                        Toast.makeText(getParent().getApplicationContext(), 
		      			                            "Publish cancelled", 
		      			                            Toast.LENGTH_SHORT).show();
		      			                    }
		      			                } else if (error instanceof FacebookOperationCanceledException) {
		      			                    // User clicked the "x" button
		      			                    Toast.makeText(getParent().getApplicationContext(), 
		      			                        "Publish cancelled", 
		      			                        Toast.LENGTH_SHORT).show();
		      			                } else {
		      			                    // Generic, ex: network error
		      			                    Toast.makeText(getParent().getApplicationContext(), 
		      			                        "Error posting story", 
		      			                        Toast.LENGTH_SHORT).show();
		      			                }
		      			            }
		      			        })
		      			        .build();
		      			    feedDialog.show();
		           }
		      		
//		        }
//			}, Arrays.asList("publish_actions"));
//			
//		}
//		else{
//			Toast.makeText(getApplicationContext(),
//                    "Please go to setting and login to Facebook",
//                    Toast.LENGTH_SHORT).show();
//		}
	}

	protected Session.StatusCallback _callback = new Session.StatusCallback() {
        @Override
        public void call(Session session, SessionState state, Exception exception) {
        	if(mIsFirstSessionCallback == true)
        	{
        		excuteFacebookAction();
        		mIsFirstSessionCallback = false;
        	}
        }
    };
    
	private void requestPermission(Session session, List<String> requestPermissions)
	{
		if (session != null){
	      	
	        // Check for publish permissions    
	        List<String> permissions = session.getPermissions();
	        if (!isSubsetOf(requestPermissions, permissions)) {
	        	session.addCallback(_callback);
	            Session.NewPermissionsRequest newPermissionsRequest = new Session.NewPermissionsRequest(this, requestPermissions);
	            session.requestNewPublishPermissions(newPermissionsRequest);
	            
	        }else{
	        	excuteFacebookAction();
	        }
  		}
		
	}
	
	public void excuteFacebookAction(){
		switch(mFacebookEventType){
			case ATTENDING_EVENT:
				postEvent("attending", "Ich gehe zu " + mStrEventName
    	        		+ "\nWer hat Lust mitzukommen?");
				break;
			case MAYBE_EVENT:
				postEvent("maybe", "Ich gehe vielleicht zu " + mStrEventName
    	        		+ "\nWer hat Lust mitzukommen?");
				break;
				
			case DECLINE_EVENT:
				postEvent("declined", null);
				break;
		}
	}
	
	private boolean isSubsetOf(Collection<String> subset, Collection<String> superset) {
	    for (String string : subset) {
	        if (!superset.contains(string)) {
	            return false;
	        }
	    }
	    return true;
	}
	
	public static boolean isSessionActive()
	{
		Session session = Session.getActiveSession();
		if(session != null && session.isOpened() ==true )
			return true;

		return false;
	}

	@Override
	public void onCheckedChanged(RadioGroup group, int checkedId) {
		// TODO Auto-generated method stub
		
//		SharedPreferences.Editor editor = getSharedPreferences("EventStore", MODE_PRIVATE).edit();	
//		switch (checkedId) {
//			case R.id.btn_attend:
//				mIsFirstSessionCallback = true;
//				mFacebookEventType = ATTENDING_EVENT;
////				 editor.putInt(mStrEventName, 1);
//				 
//				break;
//				
//			case R.id.btn_maybe:
//				mIsFirstSessionCallback = true;
//				mFacebookEventType = MAYBE_EVENT;
////				editor.putInt(mStrEventName, 2);
//				break;
//				
//			case R.id.btn_decline:
//				mIsFirstSessionCallback = true;
//				mFacebookEventType = DECLINE_EVENT;
////				editor.putInt(mStrEventName, 3);
//				break;
//		}
//		
////		editor.commit();
//		
//		Session.insideTabGroup = true;
//		if(Session.getActiveSession() != null && Session.getActiveSession().isOpened())
//			requestPermission(Session.getActiveSession(), Arrays.asList("rsvp_event", "publish_actions"));
//		else
//			loginToFacebook();
	}
	
	public void loginToFacebook()
	{
		List<String> permissions = Arrays.asList("user_birthday", "user_relationships", "user_events");
		ParseFacebookUtils.logIn(permissions, this, new LogInCallback(){

			@Override
			public void done(ParseUser user, ParseException err) {
				// TODO Auto-generated method stub
				if(user == null){
					Log.d(TAG, "Uh. The user cancelled the Facebook login.");
				}else{
					ParseFacebookUtils.saveLatestSessionData(ParseUser.getCurrentUser());
	        		saveUserDataToParse(ParseFacebookUtils.getSession());
				}
			}
			
		});
	}
	
	public void saveUserDataToParse(final Session session)
	{
	
		Request request = Request.newMeRequest(session, new Request.GraphUserCallback() {
            @Override
            public void onCompleted(GraphUser user, Response response) {
                Log.i("fb", "fb user: "+ user.toString());

               
               	GraphObject ob = response.getGraphObject();
                JSONObject jobj = ob.getInnerJSONObject();
                JSONObject locationJObj = null;
				try {
					locationJObj = (JSONObject) jobj.get("location");
				} catch (Exception e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				}
                
				String userID = jobj.optString("id");
				
				SharedPreferences.Editor editor = getSharedPreferences("EventStore", MODE_PRIVATE).edit();
				
				editor.putString("FacebookID", userID);
				
				editor.commit();
				
                String name = user.getName();
                SharedPreferences pref = PreferenceManager.getDefaultSharedPreferences(EventsDetailsActivity.this);
                Editor edit = pref.edit();
                edit.putString(GlobalConstants.PREF_FACEBOOK_USERNAME, name);
                edit.commit();
                
                String gender = user.asMap().get("gender").toString();
//                String email = user.asMap().get("email").toString(); 
                String birthday = user.getBirthday();
                String first_name = user.getFirstName();
                String last_name = user.getLastName();
               
                String location = null;
				try {
					if(locationJObj != null)
						location = locationJObj.getString("name");
				} catch (Exception e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				}
                String relationship=null;
                try{
                	relationship = jobj.get("relationship_status").toString();
                }catch(Exception e)
                {
                	e.printStackTrace();
                }
                
                final ParseUser parseUser = ParseUser.getCurrentUser();
          
                if(gender!=null) parseUser.put("gender", gender);
                if(birthday!=null) parseUser.put("birthday", birthday);
                if(relationship!=null) parseUser.put("relationship", relationship);
                if(location!=null) parseUser.put("location", location);
                if(first_name!=null) parseUser.put("first_name", first_name);
                if(last_name!=null) parseUser.put("last_name", last_name);
               
        		SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(EventsDetailsActivity.this);
        		final String cityName = prefs.getString(GlobalConstants.PREF_CITY_NAME, "");
                if(cityName !=null) parseUser.put("city", cityName);
                if(parseUser.isNew()){
	                if(name != null) parseUser.setUsername(name);
	                parseUser.setPassword("");
                }

				parseUser.saveInBackground(new SaveCallback(){
					
					@Override
					public void done(ParseException arg0) {
						// TODO Auto-generated method stub
						if(arg0==null){
							 ParseInstallation installation = ParseInstallation.getCurrentInstallation();
							 installation.put("city", cityName);
							 installation.put("user", parseUser);
							 installation.saveEventually();
							 
							 requestPermission(Session.getActiveSession(), Arrays.asList("rsvp_event", "publish_actions"));
							 
							 if (!ParseFacebookUtils.isLinked(parseUser)) {
								 ParseFacebookUtils.link(parseUser, EventsDetailsActivity.this, new SaveCallback(){
									
									@Override
									public void done(ParseException arg0) {
										// TODO Auto-generated method stub
										if(ParseFacebookUtils.isLinked(parseUser)){
											Log.d("Wooho", "user logged in with Facebook");
										}
									}
									
								});
							 } 
						}
						
				
					}
                	
                });
				
				
            }
        });
		
		request.executeAsync();
	}
}