package com.werner.nightguider;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentTransaction;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.LatLng;
import com.koushikdutta.urlimageviewhelper.UrlImageViewHelper;
import com.werner.nightguider.activitygroup.ActivityClubsStack;
import com.werner.nightguider.activitygroup.ActivityEventsStack;
import com.werner.nightguider.activitygroup.ActivityKarteStack;
import com.werner.nightguider.activitygroup.ActivitySearchStack;
import com.werner.nightguider.activitygroup.ActivityTopsStack;
import com.werner.nightguider.db.CityClubsTable;
import com.werner.nightguider.db.CityEventsTable;
import com.werner.nightguider.db.DatabaseHelper;
 
public class ClubsDetailsActivity extends FragmentActivity implements OnClickListener{
	
	private static final String TAG_CLUBSMAPFRAGMENT = "TAG_ClubsMapFragment";
	
	String mStrClubId;
	String mStrName;
	String mStrHost;
	String mStrDistance;
	String mStrThumbnail;
	String mStrBanner;
	String mStrFacebook;
	String mStrUrl;
	String mStrPhoneNumber;
	String mStrStreet;
	String mStrInfo;
	double mDLatitude;
	double mDLongitude;
	
	
	DatabaseHelper db;
	
	private Button btnFavour;
	private GoogleMap mEventMap;
	private SupportMapFragment mMapFragment;
		
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_clubsdetail);
        
        
        db = new DatabaseHelper(getApplicationContext());
        
        Bundle bundle = getIntent().getExtras();
        
        mStrClubId = bundle.getString(GlobalConstants.BUNDLE_CLUB_ID);
  		mStrName = bundle.getString(GlobalConstants.BUNDLE_CLUB_NAME);
		mStrDistance = bundle.getString(GlobalConstants.BUNDLE_CLUB_DISTANCE);
		mStrThumbnail = bundle.getString(GlobalConstants.BUNDLE_CLUB_THUMBNAIL);
		mStrBanner = bundle.getString(GlobalConstants.BUNDLE_CLUB_PICBIG);
		mStrStreet = bundle.getString(GlobalConstants.BUNDLE_CLUB_STREET);
		mStrInfo = bundle.getString(GlobalConstants.BUNDLE_CLUB_DESCRIPTION);
		mStrUrl = bundle.getString(GlobalConstants.BUNDLE_CLUB_URL);
		mStrFacebook = bundle.getString(GlobalConstants.BUNDLE_CLUB_FACEBOOK);
		mStrPhoneNumber =bundle.getString(GlobalConstants.BUNDLE_CLUB_PHONENUMBER);
		mDLatitude = bundle.getDouble(GlobalConstants.BUNDLE_CLUB_LATITUDE);
		mDLongitude = bundle.getDouble(GlobalConstants.BUNDLE_CLUB_LONGITUDE);
		mStrHost = bundle.getString(GlobalConstants.BUNDLE_CLUB_HOST);
		 
		TextView tvName=(TextView) this.findViewById(R.id.textView_menutext);
        tvName.setText(mStrName);
        tvName.setTypeface(GlobalConstants.fontAller);
        
        TextView tvDistance = (TextView) this.findViewById(R.id.tv_event_distance);
        tvDistance.setText(mStrDistance);
        tvDistance.setTypeface(GlobalConstants.fontAller);
        
        ImageView imgView=(ImageView) this.findViewById(R.id.imgView);
        UrlImageViewHelper.setUrlDrawable(imgView, mStrBanner);
        
        //display detail layout
        TextView tvStreet=(TextView) this.findViewById(R.id.tv_event_street);
        tvStreet.setTypeface(GlobalConstants.fontAller);
        tvStreet.setText(mStrStreet);
        
        btnFavour = (Button) this.findViewById(R.id.btn_favour_club);
        btnFavour.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				if(db.isFavouriteClub(mStrClubId) == true)
				{
		        	btnFavour.setBackgroundResource(R.drawable.star_white_line);
		        	deleteClub(mStrClubId);
				}
				else
				{
					btnFavour.setBackgroundResource(R.drawable.star_white_filled);
					addClub();
				}
			}
		});
           
        TextView tvEventName=(TextView) this.findViewById(R.id.tv_event_name);
        tvEventName.setText(mStrName);
        
        Button btnFacebook= (Button) this.findViewById(R.id.btn_facebook);
        btnFacebook.setOnClickListener(this);
        
        Button btnWebsite= (Button) this.findViewById(R.id.btn_website);
        btnWebsite.setOnClickListener(this);
        
        TextView tvTel=(TextView) this.findViewById(R.id.tv_phone);
        if(mStrPhoneNumber != null)
        	tvTel.setText(mStrPhoneNumber);
        tvTel.setTypeface(GlobalConstants.fontAller);
        
    	TextView tvInfo=(TextView) this.findViewById(R.id.tv_detail);
        tvInfo.setText(mStrInfo);
        tvInfo.setTypeface(GlobalConstants.fontAller);
        
        RelativeLayout layout_distance = (RelativeLayout) this.findViewById(R.id.layout_distance);
        layout_distance.setOnClickListener(this);
        RelativeLayout layout_events = (RelativeLayout) this.findViewById(R.id.layout_events);
        layout_events.setOnClickListener(this);
        RelativeLayout layout_phone = (RelativeLayout) this.findViewById(R.id.layout_phone);
        layout_phone.setOnClickListener(this);
    }

    
	@Override
	public void onResume()
	{
		super.onResume();
		
		if(db.isFavouriteClub(mStrClubId) == true)
        	btnFavour.setBackgroundResource(R.drawable.star_white_filled);
        else
        	btnFavour.setBackgroundResource(R.drawable.star_white_line);

		displayMap();
	}

    @Override
    protected void onPause() {
        super.onPause();
        try{
			Fragment fragment = getSupportFragmentManager().findFragmentByTag(TAG_CLUBSMAPFRAGMENT);
			FragmentTransaction ft = getSupportFragmentManager().beginTransaction();
            if(fragment.isAdded()){
	            ft.remove(fragment);
	            ft.commitAllowingStateLoss();
            }
        }catch(Exception e){
        	
        }
         
    }
    
	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		Intent intent;
		switch(v.getId())
		{
			case R.id.layout_distance:
				double sLatitude = mDLatitude;
				double sLongitude = mDLongitude;
				if(GlobalConstants.currentLocation != null){
					sLatitude = GlobalConstants.currentLocation.getLatitude();
					sLongitude = GlobalConstants.currentLocation.getLongitude();
				}
						
				intent = new Intent(Intent.ACTION_VIEW, Uri.parse("http://maps.google.com/maps?" + "saddr="+ String.valueOf(sLatitude) + "," +  String.valueOf(sLongitude) + "&daddr=" + mDLatitude + "," + mDLongitude));
			    intent.setClassName("com.google.android.apps.maps","com.google.android.maps.MapsActivity");
			    startActivity(intent);
				break;
				
			case R.id.btn_facebook:
				if(mStrFacebook!=null && mStrFacebook.length()>0)
				{
					intent = new Intent(Intent.ACTION_VIEW, Uri.parse(mStrFacebook));
					startActivity(intent);
				}
				break;
				
			case R.id.layout_phone:
				if(mStrPhoneNumber!=null && mStrPhoneNumber.length()>0)
				{
					try{
						intent = new Intent(Intent.ACTION_DIAL);
						intent.setData(Uri.parse("tel:" + mStrPhoneNumber));
						startActivity(intent);

					}catch(Exception e)
					{
						e.printStackTrace();
					}
				}
				break;
				
			case R.id.btn_website:
				if(mStrUrl!=null && mStrUrl.length()>0)
				{
					try{
						intent = new Intent(Intent.ACTION_VIEW, Uri.parse(mStrUrl));
						startActivity(intent);
					}catch(Exception e)
					{
						e.printStackTrace();
					}
				}
				break;
				
			case R.id.layout_events:
								
				intent = new Intent();
	            intent.setClass(getParent(), EventsOfClubActivity.class);
	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_HOST, mStrHost);
		
//				GlobalConstants.isNewEventsOfClub = true;
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
                	activityStack.push("FavoirtesActivity" + ++GlobalConstants.FAVORITES_ACTIVITY_COUNT, intent);
                }
				break;
			
		}
	}
	
	private void addClub() {
		
		CityClubsTable clubs = new CityClubsTable();
		
		clubs.setObjectId(mStrClubId);
		clubs.setFblink(mStrFacebook);
		clubs.setHost(mStrHost);
		clubs.setLatitude(mDLatitude);
		clubs.setLongitude(mDLongitude);
		clubs.setName(mStrName);
		clubs.setPhoneNumber(mStrPhoneNumber);
		clubs.setStreet(mStrStreet);
		clubs.setThumbnail(mStrThumbnail);
		clubs.setUrl(mStrUrl);
		clubs.setBanner(mStrBanner);
		
		db.enterClubs(clubs);
	}
//	
	private void deleteClub(String cid)
    {
		db.deleteClub(cid);
    }
	
	public void displayMap(){
		try{
	        mMapFragment = SupportMapFragment.newInstance();
	   		FragmentTransaction fragmentTransaction = getSupportFragmentManager().beginTransaction();
			fragmentTransaction.add(R.id.layout_map, mMapFragment, TAG_CLUBSMAPFRAGMENT);
			fragmentTransaction.commitAllowingStateLoss();
	
			final Handler handler = new Handler();
	        handler.postDelayed(new Runnable() {
	
	           @Override
	           public void run() {
	               mEventMap = mMapFragment.getMap();
	               if(mEventMap != null) {
	                   
	            	   setUpMapIfNeeded();         
	            	   mEventMap.moveCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(
	            			   mDLatitude, mDLongitude), 12.0f));
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
	
	private void setUpMapIfNeeded() {
	       
        if (mEventMap == null) {
            return;
        }
       
        // Initialize map options. For example:
        mEventMap.setMapType(GoogleMap.MAP_TYPE_NORMAL);
        
   
    }
}