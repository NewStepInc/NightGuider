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

import com.facebook.Request;
import com.facebook.Response;
import com.facebook.Session;
import com.facebook.model.GraphObject;
import com.facebook.model.GraphUser;
import com.parse.LogInCallback;
import com.parse.ParseException;
import com.parse.ParseFacebookUtils;
import com.parse.ParseInstallation;
import com.parse.ParseUser;
import com.parse.SaveCallback;

public class FacebookLoginActivity extends Activity implements OnClickListener{
    // Declare Variables
      
	public static final String TAG = "FacebookLoginActivity";
	
	private Button btnLogin;
	private TextView tvCancel;
	private String cityName ="";
	private String cityPick ="";
	
	boolean bAllowPermission = false;
	boolean bCallMain = false;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_login_facebook);
        
        btnLogin = (Button) this.findViewById(R.id.btn_login);
        btnLogin.setOnClickListener(this);
        
        Button policyButton = (Button) this.findViewById(R.id.btn_policy);
        policyButton.setOnClickListener(this);
        
        tvCancel = (TextView) this.findViewById(R.id.tv_cancel);
        tvCancel.setOnClickListener(this);
        
        Bundle bundle = getIntent().getExtras();
        cityName = bundle.getString("city_name");
        cityPick = bundle.getString("city_pick");
    }

	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		switch(v.getId())
		{
			case R.id.btn_login:
				//if session is valid, logout
				if(ParseFacebookUtils.getSession() != null){
					ParseFacebookUtils.getSession().closeAndClearTokenInformation();
				}
				
				loginToFacebook();
				
//				try {
//		        PackageInfo info = getPackageManager().getPackageInfo(
//		                "com.werner.nightguider", 
//		                PackageManager.GET_SIGNATURES);
//		        for (Signature signature : info.signatures) {
//		            MessageDigest md = MessageDigest.getInstance("SHA");
//		            md.update(signature.toByteArray());
//		            String strHashKey = Base64.encodeToString(md.digest(), Base64.DEFAULT);
//		            Log.e("Testing:", "Hi key ::  "+ strHashKey);
//		            
//		            AlertDialog.Builder builder1 = new AlertDialog.Builder(this);
//		    		builder1.setIcon(android.R.drawable.ic_dialog_info);
//		    		builder1.setTitle("HashKey");
//		            builder1.setMessage("App Hashkey is " + strHashKey);
//		            builder1.setCancelable(true);
//		            builder1.setPositiveButton("OK",
//		                    new DialogInterface.OnClickListener() {
//		                public void onClick(DialogInterface dialog, int id) {
//		                    
//		                }
//		            });
//		            
//		            AlertDialog alert11 = builder1.create();
//		            alert11.show();
//		            }
//		    } catch (NameNotFoundException e) {
//	
//		    } catch (NoSuchAlgorithmException e) {
//	
//		    }
				break;
				
			case R.id.btn_policy:
				Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse("http://nightguider.de/datenschutzerklaerung"));
				startActivity(browserIntent);
				break;
				
			case R.id.tv_cancel:
				startTabActivity();
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
					saveUserDataToParse(ParseFacebookUtils.getSession());
	      			startTabActivity();
				}
			}
			
		});		
	}
		
	public void startTabActivity()
	{
		ParseInstallation installation = ParseInstallation.getCurrentInstallation();
		installation.put("city", cityPick);
		installation.saveInBackground();
		
		//save select city name
    	SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(this);
    	Editor edit = preferences.edit();
        edit.putString(GlobalConstants.PREF_CITY_NAME, cityName);
        edit.putString(GlobalConstants.PREF_CITY_PICK, cityPick);
    	edit.commit();
       	
    	Intent iTabsIntent = new Intent(FacebookLoginActivity.this,	TabsActivity.class);
		startActivity(iTabsIntent);
		finish();
		
	}

	public void saveUserDataToParse(Session session)
	{    
		if(session == null || session.isOpened()==false) return;
		
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
                SharedPreferences pref = PreferenceManager.getDefaultSharedPreferences(FacebookLoginActivity.this);
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
                if(cityPick !=null)	parseUser.put("city", cityPick);      
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
							installation.put("city", cityPick);
							installation.put("user", parseUser);
							installation.saveEventually();
							
							if (!ParseFacebookUtils.isLinked(parseUser)) {
								ParseFacebookUtils.link(parseUser, FacebookLoginActivity.this, new SaveCallback(){
									
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
	
	@Override
	public void onActivityResult(int requestCode, int resultCode, Intent data) {
	    super.onActivityResult(requestCode, resultCode, data);
	    if(data != null)
	    	ParseFacebookUtils.finishAuthentication(requestCode, resultCode, data);
	}
}
 