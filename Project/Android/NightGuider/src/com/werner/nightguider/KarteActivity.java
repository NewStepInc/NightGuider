package com.werner.nightguider;

import java.util.ArrayList;
import java.util.List;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.location.LocationListener;
import android.location.LocationManager;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.preference.PreferenceManager;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentTransaction;
import android.view.Window;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.TextView;

import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.GoogleMap.OnInfoWindowClickListener;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;
import com.parse.FindCallback;
import com.parse.ParseException;
import com.parse.ParseGeoPoint;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.werner.nightguider.activitygroup.ActivityClubsStack;
import com.werner.nightguider.activitygroup.ActivityKarteStack;



public class KarteActivity extends FragmentActivity {
    private GoogleMap mKarteMap;
    private SupportMapFragment mMapFragment;
    LocationManager lm;
    private final int INSTALL_PLAYSERVICES = 1;
    LocationListener ll;
    private static final String TAG_MYMAPFRAGMENT = "TAG_MapFragment";
    
    List<ParseObject> mClubsList;
    
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        
//        // Getting status
//        int status = GooglePlayServicesUtil.isGooglePlayServicesAvailable(getBaseContext());
//        
//        // Showing status
//        if(status==ConnectionResult.SERVICE_MISSING || status==ConnectionResult.SERVICE_INVALID || status==ConnectionResult.SERVICE_DISABLED)
//        {
////        	final String appName = "com.google.android.gms";
////        	Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse("http://play.google.com/store/apps/details?id="+appName));
////        	try {
////        		startActivityForResult(intent, INSTALL_PLAYSERVICES);
//////        	    startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id="+appName)));
////        	} catch (android.content.ActivityNotFoundException anfe) {
//////        		startActivityForResult(intent, INSTALL_PLAYSERVICES);
////        	}
//        	Dialog dialog = GooglePlayServicesUtil.getErrorDialog(status, this, 10);
//            dialog.show();
////        	finish();
//        }
//        else
        {
        	resumeCreate();
        }
    }

    public void setCityMarker()
    {  	  	
//    	for(int i=0;i<GlobalConstants.clubsList.size();i++)
//        {
//    		 try {
//    			 
//    			 double latitude = GlobalConstants.clubsList.get(i).getLatitude();
//    			 double longitude = GlobalConstants.clubsList.get(i).getLongtitude();
//    			 mKarteMap.addMarker(new MarkerOptions()
//	              .position(new LatLng(latitude, longitude))
//	              .title(GlobalConstants.clubsList.get(i).getClubName() + " Club"));
//    		 } catch (Exception e) {
//    			 Log.e("Error", e.getMessage());
//    	         e.printStackTrace();
//    	         continue;
//    	     }
//        }
	
    	SharedPreferences pref = PreferenceManager.getDefaultSharedPreferences(this);
    	String cityPick = pref.getString(GlobalConstants.PREF_CITY_PICK, "");
        ParseQuery<ParseObject> query = new ParseQuery<ParseObject>("Clubs");
        query.whereEqualTo("city_pick", cityPick);
        query.setLimit(GlobalConstants.refreshQueryMaxCount);
        
        query.findInBackground(new FindCallback<ParseObject>(){

			@Override
			public void done(List<ParseObject> objects, ParseException error) {
				// TODO Auto-generated method stub
				if(error == null && objects != null){
					mClubsList = new ArrayList<ParseObject>();
					mClubsList.addAll(objects);
					
					for (ParseObject club : objects) {
						try{
			            	ParseGeoPoint location = (ParseGeoPoint) club.getParseGeoPoint(GlobalConstants.PARSE_KEY_CLUBLOCATION);
			            	mKarteMap.addMarker(new MarkerOptions()
				              .position(new LatLng(location.getLatitude(), location.getLongitude()))
				              .title(club.getString(GlobalConstants.PARSE_KEY_CLUBNAME) + " Club"));
						}catch(Exception e){
							continue;
						}
		            }    
				}
			}
        	
        });
    }
    
    @Override
    protected void onResume() {
    	super.onResume();
           
    	try{
	        //Control map for TabActivity
	        mMapFragment = SupportMapFragment.newInstance();
	      	        
	   		FragmentTransaction fragmentTransaction = getSupportFragmentManager().beginTransaction();
			fragmentTransaction.add(R.id.karteMapContainer, mMapFragment, TAG_MYMAPFRAGMENT);
			fragmentTransaction.commitAllowingStateLoss();
	
			final Handler handler = new Handler();
	        handler.postDelayed(new Runnable() {
	
	           @Override
	           public void run() {
	//               GoogleMap googleMap = SupportMapFragment.newInstance(new GoogleMapOptions().zOrderOnTop(true)).getMap();
	               mKarteMap = mMapFragment.getMap();
	               if(mKarteMap != null) {
	            	             
	            	   
	            	   setUpMapIfNeeded();
	                   
	            	   setCityMarker();
	            	   if(GlobalConstants.currentLocation != null){
		            	   mKarteMap.addMarker(new MarkerOptions()
		            	   	.position(
		                         new LatLng(GlobalConstants.currentLocation.getLatitude(), GlobalConstants.currentLocation
		                                 .getLongitude()))
		                    .title("my position")
		                    .icon(BitmapDescriptorFactory
		                         .defaultMarker(BitmapDescriptorFactory.HUE_AZURE)));
		
		            	   mKarteMap.moveCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(
		            			   GlobalConstants.currentLocation.getLatitude(), GlobalConstants.currentLocation.getLongitude()), 12.0f));
	            	   }
	                   
	                   handler.removeCallbacksAndMessages(this);
	               }
	
	               else {
	                    handler.postDelayed(this, 200);
	               }
	           }
	         }, 200);
			
    	}catch(Exception e){
    		
    	}
    }
 
    @SuppressWarnings("unused")
	public boolean isNumeric(String str)  
    {  
	      try  
	      {  
	        double d = Double.parseDouble(str);  
	      }  
	      catch(NumberFormatException nfe)  
	      {  
	        return false;  
	      }  
	      return true;  
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
    
    private void setUpMapIfNeeded() {
       
//        mKarteMap = ((SupportMapFragment) getSupportFragmentManager().findFragmentById(R.id.map_karte)).getMap();
        if (mKarteMap == null) {
            return;
        }
        // Initialize map options. For example:
        mKarteMap.setMapType(GoogleMap.MAP_TYPE_NORMAL);
               
        mKarteMap.setOnInfoWindowClickListener(new OnInfoWindowClickListener(){

			@Override
			public void onInfoWindowClick(Marker marker) {
				// TODO Auto-generated method stub
	
				for(final ParseObject club : mClubsList){
					if((club.getString(GlobalConstants.PARSE_KEY_CLUBNAME) + " Club").equalsIgnoreCase(marker.getTitle())){
						showOption(marker, club);
						return;
					}
				}
				
			}
        });        
    }
    
    public void goClubDetail(ParseObject club){
    	Intent intent = new Intent();
    	intent.putExtra(GlobalConstants.BUNDLE_CLUB_DESCRIPTION, club.getString(GlobalConstants.PARSE_KEY_CLUBDESCRIPTION));
	    intent.putExtra(GlobalConstants.BUNDLE_CLUB_THUMBNAIL, club.getString(GlobalConstants.PARSE_KEY_CLUBPICSMALL));
	    intent.putExtra(GlobalConstants.BUNDLE_CLUB_PICBIG, club.getParseFile(GlobalConstants.PARSE_KEY_CLUBPICBIG).getUrl());
	    intent.putExtra(GlobalConstants.BUNDLE_CLUB_NAME, club.getString(GlobalConstants.PARSE_KEY_CLUBNAME));
	    intent.putExtra(GlobalConstants.BUNDLE_CLUB_STREET, club.getString(GlobalConstants.PARSE_KEY_CLUBSTREET));
	    intent.putExtra(GlobalConstants.BUNDLE_CLUB_URL, club.getString(GlobalConstants.PARSE_KEY_CLUBURL));
	    intent.putExtra(GlobalConstants.BUNDLE_CLUB_FACEBOOK, club.getString(GlobalConstants.PARSE_KEY_CLUBFACEBOOK));
	    intent.putExtra(GlobalConstants.BUNDLE_CLUB_PHONENUMBER, club.getString(GlobalConstants.PARSE_KEY_CLUBPHONE));
	    ParseGeoPoint geoPoint = club.getParseGeoPoint(GlobalConstants.PARSE_KEY_CLUBLOCATION);
	    intent.putExtra(GlobalConstants.BUNDLE_CLUB_LATITUDE, geoPoint.getLatitude());
	    intent.putExtra(GlobalConstants.BUNDLE_CLUB_LONGITUDE, geoPoint.getLongitude());
	   	    
	    String strDist="Google location Service not allowed.";
        if(GlobalConstants.currentLocation!=null)
        {
            double distance = GlobalConstants.distanceBetween(GlobalConstants.currentLocation.getLatitude(), GlobalConstants.currentLocation.getLongitude(),
            		geoPoint.getLatitude(), geoPoint.getLongitude())/1000.0f;
            strDist = "Distanz :   " + String.format("%.2f", distance) + " km";
        }
        intent.putExtra(GlobalConstants.BUNDLE_CLUB_DISTANCE, strDist);
        intent.putExtra(GlobalConstants.BUNDLE_CLUB_HOST, club.getString(GlobalConstants.PARSE_KEY_CLUBNAME));
     
        intent.setClass(getParent(), ClubsDetailsActivity.class);
		ActivityClubsStack activityStack = (ActivityClubsStack) getParent();
		activityStack.push("ClubsActivity" + ++GlobalConstants.CLUBS_ACTIVITY_COUNT, intent);
    }
    
    public void showOption(final Marker marker, final ParseObject club){
    	AlertDialog.Builder buildSingle = new AlertDialog.Builder(getParent());
		final ArrayAdapter<String> adapter = new ArrayAdapter<String>(getParent(),
				R.layout.item_dialog_row);
		adapter.add(getResources().getString(R.string.route_anzeigen));
		adapter.add(getResources().getString(R.string.details_anzeigen));
	
		buildSingle.setNegativeButton(getResources().getString(R.string.cancel),
				new DialogInterface.OnClickListener() {

					@Override
					public void onClick(DialogInterface dialog, int which) {
						// TODO Auto-generated method stub
						dialog.dismiss();
					}
				});
		buildSingle.setAdapter(adapter,
				new DialogInterface.OnClickListener() {

					@Override
					public void onClick(DialogInterface dialog, int which) {
						// TODO Auto-generated method stub
						String chosen = adapter.getItem(which)
								.toString();
						if (chosen.equals(getResources().getString(R.string.route_anzeigen))) {
							marker.hideInfoWindow();
							new Handler().postDelayed(new Runnable() {
					            @Override
					            public void run() {
					            	double sLatitude = 0;
					            	double sLongitude = 0;
					            	if(GlobalConstants.currentLocation != null){
										sLatitude = GlobalConstants.currentLocation.getLatitude();
										sLongitude = GlobalConstants.currentLocation.getLongitude();
									}
									
									ParseGeoPoint geoPoint = club.getParseGeoPoint(GlobalConstants.PARSE_KEY_CLUBLOCATION);
									double dLatitude = geoPoint.getLatitude();
									double dLongitude = geoPoint.getLongitude();
	
									
									Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse("http://maps.google.com/maps?" + "saddr="+ sLatitude + "," +  sLongitude + "&daddr=" + dLatitude + "," + dLongitude));
								    intent.setClassName("com.google.android.apps.maps","com.google.android.maps.MapsActivity");
								    startActivity(intent);
					            }
							}, 50);
										            
						} else if (chosen.equals(getResources().getString(R.string.details_anzeigen))) {
							marker.hideInfoWindow();
						    // Set some variable here so you know which one was clicked
							new Handler().postDelayed(new Runnable() {
					            @Override
					            public void run() {
					            	goClubDetail(club);
					            }
							}, 50);
					
						} else if (chosen.equals(getResources().getString(R.string.cancel))) {
							dialog.dismiss();
						} 
					}
				});
		AlertDialog a = buildSingle.create();
		a.show();
		Button bq = a.getButton(DialogInterface.BUTTON_NEGATIVE);
		bq.setTextColor(Color.GRAY);
    }
    
    @Override
	public void onDetachedFromWindow() {
		// TODO Auto-generated method stub
		super.onDetachedFromWindow();
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data)
	{
    	super.onActivityResult(requestCode, resultCode, data);
	
	    switch (requestCode) {
			case INSTALL_PLAYSERVICES:
				if(resultCode == RESULT_OK)
			    {
			        resumeCreate();
			    }
				
//			default:
//				resumeCreate();
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

	public void resumeCreate()
    {
	
		setContentView(R.layout.activity_karte);
			
  		TextView tv = (TextView) this.findViewById(R.id.textView_menutext);
  		tv.setText("Karte");
  		tv.setTypeface(GlobalConstants.fontAller);

    }

}