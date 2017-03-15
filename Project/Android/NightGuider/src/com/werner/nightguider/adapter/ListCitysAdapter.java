package com.werner.nightguider.adapter;

import java.util.List;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.parse.ParseObject;
import com.werner.nightguider.GlobalConstants;
import com.werner.nightguider.R;
 
public class ListCitysAdapter extends BaseAdapter {
 
    // Declare Variables
    Context context;
    LayoutInflater inflater;
    private List<ParseObject> cityslist = null;
 
//    private Facebook facebook;
////	private AsyncFacebookRunner mAsyncRunner;
//	private SharedPreferences mPrefs;
	
    
	public ListCitysAdapter(Context context,
            List<ParseObject> cityslist) {
        this.context = context;
        this.cityslist = cityslist;
        inflater = LayoutInflater.from(context);
        
//        facebook = new Facebook(GlobalConstants.FACEBOOK_APPID);
//        mAsyncRunner = new AsyncFacebookRunner(facebook);
    }
 
    public class ViewHolder {
    	TextView textview_city;
    }
    
    @Override
    public int getCount() {
        return cityslist.size();
    }
 
    @Override
    public Object getItem(int position) {
        return cityslist.get(position);
    }
 
    @Override
    public long getItemId(int position) {
        return position;
    }
 
    public View getView(final int position, View view, ViewGroup parent) {
        final ViewHolder holder;
    
        if (view == null) {
            holder = new ViewHolder();
            view = inflater.inflate(R.layout.list_citysrow, null);
     
            holder.textview_city = (TextView) view.findViewById(R.id.textView_city);
            holder.textview_city.setTypeface(GlobalConstants.fontAller);
            view.setTag(holder);
        } else {
            holder = (ViewHolder) view.getTag();
        }
        
        ParseObject city = cityslist.get(position);
        holder.textview_city.setText(city.getString("name"));
        // Listen for ListView Item Click
//        view.setOnClickListener(new OnClickListener() {
// 
//            @Override
//            public void onClick(View arg0) {
//            	
//            	//save select city name
//            	SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(context);;
//            	Editor edit = preferences.edit();
//                edit.putString(GlobalConstants.CITY_NAME, cityslist.get(position));
//                edit.commit();
//                
//            	if(position == 0)
//            	{
//	            	Intent iTabsIntent = new Intent(context,
//	    					TabsActivity.class);
//	            	GlobalConstants.cityName =  cityslist.get(position);
//	    			context.startActivity(iTabsIntent);
//            	}
//            	else
//            	{
////            		Intent fbIntent = new Intent(context, FacebookLogin.class);
////            		context.startActivity(fbIntent);
//            		loginToFacebook();
//            		
//            		
//            	}
//            }
//        });
        return view;
    }
 
//	@SuppressWarnings({ "deprecation", "static-access" })
//	public void loginToFacebook() {
//		mPrefs = ((Activity) context).getPreferences(Context.MODE_PRIVATE);
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
//			facebook.authorize((Activity) context,
//					new String[] { "email", "publish_stream"},facebook.FORCE_DIALOG_AUTH,
//					new DialogListener() {
//
//						@Override
//						public void onCancel() {
//							// Function to handle cancel event
//					
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
//
//						}
//
//						@Override
//						public void onFacebookError(FacebookError fberror) {
//							// Function to handle Facebook errors
//		
//
//						}
//
//					});
//		}
//		else
//		{
//			postToWall();
//		}
//	}
//	
//	@SuppressWarnings("deprecation")
//	public void postToWall() {
//		// post on user's wall.
//		facebook.dialog(context, "feed", new DialogListener() {
//
//			@Override
//			public void onFacebookError(FacebookError e) {
//			}
//
//			@Override
//			public void onError(DialogError e) {
//			}
//
//			@Override
//			public void onComplete(Bundle values) {
//			}
//
//			@Override
//			public void onCancel() {
//			}
//		});
//
//	}
}