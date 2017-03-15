package com.werner.nightguider;

import android.app.Application;

import com.parse.LocationCallback;
import com.parse.Parse;
import com.parse.ParseACL;
import com.parse.ParseException;
import com.parse.ParseFacebookUtils;
import com.parse.ParseGeoPoint;
import com.parse.ParseUser;
import com.parse.PushService;

public class ParseApplication extends Application {

	@Override
	public void onCreate() {
		
		super.onCreate();

		// Add your initialization code here
		Parse.initialize(this, GlobalConstants.PARSEAPPID,
				GlobalConstants.PARSECLIENTKEY);
		ParseFacebookUtils.initialize(getResources().getString(R.string.facebook_app_id));
		
		ParseUser.enableAutomaticUser();
		ParseACL defaultACL = new ParseACL();

		// If you would like all objects to be private by default, remove this
		// line.
		defaultACL.setPublicReadAccess(true);

		ParseACL.setDefaultACL(defaultACL, true);
		
		
		// Specify a Activity to handle all pushes by default.
		PushService.setDefaultPushCallback(this, EventsActivity.class);
		
//		// Save the current installation.
//		ParseInstallation.getCurrentInstallation().saveInBackground();
		
		ParseGeoPoint.getCurrentLocationInBackground(5000, new LocationCallback() {

			@Override
			public void done(ParseGeoPoint point, ParseException err) {
				// TODO Auto-generated method stub
				if(err == null){
					GlobalConstants.currentLocation = point;
				}
			}
        	
        });
	}
}