package com.werner.nightguider;

import java.util.Arrays;
import java.util.List;

import org.json.JSONObject;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.net.Uri;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.TextView;
import android.widget.ToggleButton;

import com.facebook.Request;
import com.facebook.Response;
import com.facebook.Session;
import com.facebook.SessionState;
import com.facebook.model.GraphObject;
import com.facebook.model.GraphUser;
import com.parse.LogInCallback;
import com.parse.ParseException;
import com.parse.ParseFacebookUtils;
import com.parse.ParseInstallation;
import com.parse.ParseUser;
import com.parse.SaveCallback;

public class SettingActivity extends Activity implements OnClickListener{
	
    // Declare Variables
	public static final String TAG = "SettingActivity";
	
	ToggleButton mFacebookToggleButton;
	ToggleButton mPostToggleButton;
	TextView mFacebookUserNameTextView;
	
//	private final List<String> PERMISSIONS = Arrays.asList("rsvp_event");
	boolean bAllowPermission = false;
	boolean bCallMain = false;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_setting);
        
        Button btn_region = (Button) this.findViewById(R.id.btn_region);
        btn_region.setOnClickListener(this);
        
        Button btn_about = (Button) this.findViewById(R.id.btn_about);
        btn_about.setOnClickListener(this);
        
        Button btn_feedback = (Button) this.findViewById(R.id.btn_feedback);
        btn_feedback.setOnClickListener(this);
        
        Button policyButton = (Button) this.findViewById(R.id.btn_policy);
        policyButton.setOnClickListener(this);
        
        mFacebookUserNameTextView = (TextView) this.findViewById(R.id.tvFacebookUserName);
        
        mFacebookToggleButton = (ToggleButton) findViewById(R.id.togglebtn_facebook);
        mFacebookToggleButton.setOnClickListener(this);

        mPostToggleButton = (ToggleButton) findViewById(R.id.togglebtn_post);
        mPostToggleButton.setOnClickListener(this);
    }

	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		Intent intent;
		switch(v.getId())
		{
			case R.id.btn_region:
				intent = new Intent(SettingActivity.this, SelectCityActivity.class);
				intent.putExtra("From Setting", true);
				this.startActivity(intent);
				break;
			
			case R.id.btn_about:
				intent = new Intent(SettingActivity.this, AboutActivity.class);
				this.startActivity(intent);
				break;
				
			case R.id.btn_feedback:
				Intent email = new Intent(Intent.ACTION_SEND);
				email.putExtra(Intent.EXTRA_EMAIL, new String[]{"info@nightguider.de"});		  
				email.putExtra(Intent.EXTRA_SUBJECT, "Supportnachricht");
				email.putExtra(Intent.EXTRA_TEXT, "Sent from my mobile device" );
				email.setType("message/rfc822");
				startActivity(Intent.createChooser(email, "Choose an Email client :"));
				break;
				
			case R.id.togglebtn_facebook:
				if(mFacebookToggleButton.isChecked()){
                	bAllowPermission = false;
                	loginToFacebook();
                }
                else
                {
                	if(ParseFacebookUtils.getSession() != null)
                		ParseFacebookUtils.getSession().closeAndClearTokenInformation();
                	if(Session.getActiveSession() != null)
                		Session.getActiveSession().closeAndClearTokenInformation();
                	ParseUser.logOut();
                	
                   	mFacebookUserNameTextView.setText("");
                }
				break;
				
			case R.id.togglebtn_post:
				SharedPreferences pref = PreferenceManager.getDefaultSharedPreferences(SettingActivity.this);
                Editor edit = pref.edit();
				if(mPostToggleButton.isChecked()){
					edit.putBoolean(GlobalConstants.PREF_SETTINGS_POST, true);
                }
                else
                {
                	edit.putBoolean(GlobalConstants.PREF_SETTINGS_POST, false);
                }
				edit.commit();
				break;
				
			case R.id.btn_policy:
				Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse("http://nightguider.de/datenschutzerklaerung"));
				startActivity(browserIntent);
				break;
		}
	}

	public void loginToFacebook()
	{
		Session.insideTabGroup = false;
		List<String> permissions = Arrays.asList("user_birthday", "user_relationships");
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
	
	protected Session.StatusCallback _callback = new Session.StatusCallback() {
        @Override
        public void call(Session session, SessionState state, Exception exception) {
        	if(bCallMain == false)
        	{
        		ParseFacebookUtils.saveLatestSessionData(ParseUser.getCurrentUser());
        		saveUserDataToParse(session);
        		bCallMain = true;
        	}
        }
    };
    	
	@Override
	public void onActivityResult(int requestCode, int resultCode, Intent data) {
	    super.onActivityResult(requestCode, resultCode, data);
	    ParseFacebookUtils.finishAuthentication(requestCode, resultCode, data);
	}

	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();
		
		SharedPreferences pref = PreferenceManager.getDefaultSharedPreferences(SettingActivity.this);
		//set facebook toggle button state
		Session session = ParseFacebookUtils.getSession();
		if(session != null && session.isOpened()==true)
		{
			mFacebookToggleButton.setChecked(true);
//			Request request = Request.newMeRequest(session, new Request.GraphUserCallback() {
//		            @Override
//		            public void onCompleted(GraphUser user, Response response) {
//		                Log.i("fb", "fb user: "+ user.toString());
//		                mFacebookUserNameTextView.setText(user.getName());
//		            }
//			 });
//			request.executeAsync();
			
			mFacebookUserNameTextView.setText(pref.getString(GlobalConstants.PREF_FACEBOOK_USERNAME, ""));
			
		}
		else
        	mFacebookToggleButton.setChecked(false);
		
		//set post toggle button state
		if(pref.getBoolean(GlobalConstants.PREF_SETTINGS_POST, true) == true){
			mPostToggleButton.setChecked(true);
		}else{
			mPostToggleButton.setChecked(false);
		}
		
	}

	public void saveUserDataToParse(final Session session)
	{
	
		Request request = Request.newMeRequest(session, new Request.GraphUserCallback() {
            @Override
            public void onCompleted(GraphUser user, Response response) {
//                Log.i("fb", "fb user: "+ user.toString());

               
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
                SharedPreferences pref = PreferenceManager.getDefaultSharedPreferences(SettingActivity.this);
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
               
        		SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(SettingActivity.this);
        		final String cityPick = prefs.getString(GlobalConstants.PREF_CITY_PICK, "");
                if(cityPick !=null) parseUser.put("city", cityPick);
                if(parseUser.isNew()){
	                if(name != null) parseUser.setUsername(name);
	                parseUser.setPassword("");
                }
//                ParseQuery<ParseUser> query = ParseUser.getQuery();
//                query.whereEqualTo("username", name);
//                query.findInBackground(new FindCallback<ParseUser>(){
//
//					@Override
//					public void done(List<ParseUser> arg0, ParseException e) {
//						// TODO Auto-generated method stub
//						if(e != null) return;
//						
//						if(arg0.size() ==0){
							parseUser.saveInBackground(new SaveCallback(){
								
								@Override
								public void done(ParseException arg0) {
									// TODO Auto-generated method stub
									if(arg0==null){
										 ParseInstallation installation = ParseInstallation.getCurrentInstallation();
										 installation.put("city", cityPick);
										 installation.put("user", parseUser);
										 installation.saveEventually();
										 
										 if (!ParseFacebookUtils.isLinked(parseUser)) {
											 ParseFacebookUtils.link(parseUser, SettingActivity.this, new SaveCallback(){
												
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
							
//						}
//						else{
//							ParseUser.logInInBackground(name, "", new LogInCallback(){
//
//								@Override
//								public void done(ParseUser arg0, ParseException arg1) {
//									// TODO Auto-generated method stub
//									ParseInstallation installation = ParseInstallation.getCurrentInstallation();
//									 installation.put("city", cityName);
//									 if(parseUser != null) installation.put("user", parseUser);
//									 installation.saveEventually();
//								 
//									 ParseFacebookUtils.initialize(getResources().getString(R.string.facebook_app_id));
//									 if (!ParseFacebookUtils.isLinked(parseUser)) {
//										 ParseFacebookUtils.link(parseUser, SettingActivity.this, new SaveCallback(){
//											
//											@Override
//											public void done(ParseException err) {
//												// TODO Auto-generated method stub
//												if(ParseFacebookUtils.isLinked(parseUser)){
//													Log.d("Wooho", "user logged in with Facebook");
//												}
//											}
//											
//										});
//									 } 
//								}
//		                		
//		                	});
//						}
						
						
//					}
//                });
              
//				if(session != null && session.isOpened()==true)
//				{
//					mFacebookToggleButton.setChecked(true);
//					mFacebookUserNameTextView.setText(pref.getString(GlobalConstants.PREF_FACEBOOK_USERNAME, ""));
//				}
//				else
//		        	mFacebookToggleButton.setChecked(false);
				
            }
        });
		
		request.executeAsync();
	}
}
 