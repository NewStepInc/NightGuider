package com.werner.nightguider;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.content.pm.Signature;
import android.os.Bundle;
import android.os.Handler;
import android.preference.PreferenceManager;
import android.util.Base64;
import android.util.Log;
import android.view.Window;

import com.parse.ParseAnalytics;

public class SplashActivity extends Activity {
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_splash);
		
		ParseAnalytics.trackAppOpened(getIntent());

		SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(this);
		final String cityName = prefs.getString(GlobalConstants.PREF_CITY_NAME, null);
		
//		GlobalConstants.currentLocation = getCurrentLocation();
//		Log.e("HASH:%s", printKeyHash(this));
		
		
		new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {

	            /* Create an intent that will start the main activity. */
	            Intent mainIntent;
	            
	            if(cityName != null)
	            {
	            	mainIntent = new Intent(SplashActivity.this,
	        	            TabsActivity.class);
	            	
	            }
	            else
	            {
	            	mainIntent = new Intent(SplashActivity.this,
	        	            SelectCityActivity.class);
	            }
	            
	            SplashActivity.this.startActivity(mainIntent);
	
	            /* Finish splash activity so user cant go back to it. */
	            SplashActivity.this.finish();
	
	           /* Apply our splash exit (fade out) and main
	           entry (fade in) animation transitions. */
	           //overridePendingTransition(R.anim.push_right_in,R.anim.push_right_out);
            }
		}, 1000);
	}
	
	public static String printKeyHash(Activity context) {
		PackageInfo packageInfo;
		String key = null;
		try {
			//getting application package name, as defined in manifest
			String packageName = context.getApplicationContext().getPackageName();

			//Retriving package info
			packageInfo = context.getPackageManager().getPackageInfo(packageName,
					PackageManager.GET_SIGNATURES);
				
			Log.e("Package Name=", context.getApplicationContext().getPackageName());
			
			for (Signature signature : packageInfo.signatures) {
				MessageDigest md = MessageDigest.getInstance("SHA");
				md.update(signature.toByteArray());
				key = new String(Base64.encode(md.digest(), 0));
			
				// String key = new String(Base64.encodeBytes(md.digest()));
				Log.e("Key Hash=", key);
			}
		} catch (NameNotFoundException e1) {
			Log.e("Name not found", e1.toString());
		}
		catch (NoSuchAlgorithmException e) {
			Log.e("No such an algorithm", e.toString());
		} catch (Exception e) {
			Log.e("Exception", e.toString());
		}

		return key;
	}
	
//	public Location getCurrentLocation()
//	{
//    	    	
//		LocationManager locationManager;
//	    locationManager = (LocationManager)getSystemService(Context.LOCATION_SERVICE);
//	   
//	    LocationListener mlocListener = new MyLocationListener();
//	    locationManager.requestLocationUpdates(                
//	             LocationManager.NETWORK_PROVIDER,0,0,(LocationListener) mlocListener);
//	    
//		Location location = locationManager.getLastKnownLocation(LocationManager.NETWORK_PROVIDER);
//	  
//	    return location;
//
//	}
//    
//	/* Class My Location Listener */
//    public class MyLocationListener implements LocationListener
//    {
//
//    	@Override
//    	public void onLocationChanged(Location loc)
//    	{
//
////		        String Text = "My current location is: " +
////		        "Latitud = " + loc.getLatitude() +
////		        "Longitud = " + loc.getLongitude();
////
////		        Toast.makeText( getApplicationContext(), Text, Toast.LENGTH_SHORT).show();
//    	}
//
//    	@Override
//    	public void onProviderDisabled(String provider)
//    	{
//    		Toast.makeText( getApplicationContext(), "Gps Disabled", Toast.LENGTH_SHORT ).show();
//    	}
//
//    	@Override
//    	public void onProviderEnabled(String provider)
//    	{
//    		Toast.makeText( getApplicationContext(), "Gps Enabled", Toast.LENGTH_SHORT).show();
//    	}
//
//    	@Override
//    	public void onStatusChanged(String provider, int status, Bundle extras)
//    	{
//
//    	}
//	
//    }
}
