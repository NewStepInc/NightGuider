package com.werner.nightguider;

import java.util.List;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;
import android.widget.TextView;

import com.parse.FindCallback;
import com.parse.ParseException;
import com.parse.ParseInstallation;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;
import com.werner.nightguider.adapter.ListCitysAdapter;
import com.werner.nightguider.db.DatabaseHelper;

public class SelectCityActivity extends Activity {

	private TextView mSelectCity;
	private TextView mLoading;

//	private int noOfCities = 0;
//	private List<ParseObject> arrCity;
	DatabaseHelper db;
	Context context;
	ListView listview;
	
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_select_city);

		context = this;
//		GlobalConstants.fontAller = Typeface.createFromAsset(getAssets(),
//				"font/Aller.ttf");
		db = new DatabaseHelper(getApplicationContext());

		mLoading = (TextView) findViewById(R.id.tv_loading);
//		mHeading = (TextView) findViewById(R.id.heading);
		mSelectCity = (TextView) findViewById(R.id.tv_selectcity);
		mLoading.setTypeface(GlobalConstants.fontAller);
//		mHeading.setTypeface(GlobalConstants.fontAller);
		mSelectCity.setTypeface(GlobalConstants.fontAller);

//		arrCity = new ArrayList<ParseObject>();
		
//		db.DropDataBase();
//		db.deleteCityTable();
//		db.deleteClubTable();
//		db.deleteEventTable();
		
		getAvailableCities();

	}

	private void getAvailableCities() {
		ParseQuery<ParseObject> query = ParseQuery.getQuery("Cities");
		query.orderByAscending(GlobalConstants.PARSE_KEY_CITYNAME);
		query.setLimit(GlobalConstants.refreshQueryMaxCount);
		query.findInBackground(new FindCallback<ParseObject>() {
			public void done(final List<ParseObject> citiesList, ParseException e) {
				if (e == null) {
//					noOfCities = citiesList.size();
//					for (int i = 0; i < noOfCities; i++) {
//						System.out.println("Cities Name " + i + "= "
//								+ citiesList.get(i).getString("name"));
////						CitiesTable cities = new CitiesTable();
////						cities.setCity(citiesList.get(i).getString("city"));
////						cities.setName(citiesList.get(i).getString("name"));
////						db.enterCities(cities);
//						
//						arrCity.add(citiesList.get(i).getString(GlobalConstants.PARSE_KEY_CITYNAME));
//						System.out.println("Cities Entered in Local DB = " + noOfCities);
//					}
					
					
					listview = (ListView) findViewById(R.id.listView_city);
			        // Pass the results into ListViewAdapter.java
			        ListCitysAdapter adapter = new ListCitysAdapter(SelectCityActivity.this,
			        		citiesList);
			        // Binds the Adapter to the ListView
			        
			        listview.setOnItemClickListener(new OnItemClickListener() {

						@Override
						public void onItemClick(AdapterView<?> adapter, View parent,
								int position, long rowId) {
							// TODO Auto-generated method stub
						
							if(GlobalConstants.mEventsList != null)
								GlobalConstants.mEventsList.clear();
							if(GlobalConstants.mClubsList != null)
								GlobalConstants.mClubsList.clear();
			                
			            	Bundle bundle = getIntent().getExtras();
			            	if(bundle != null && bundle.getBoolean("From Setting")==true)
			            	{
			            		SharedPreferences pref = PreferenceManager.getDefaultSharedPreferences(SelectCityActivity.this);
				                Editor edit = pref.edit();
				                edit.putString(GlobalConstants.PREF_CITY_NAME, citiesList.get(position).getString("name"));
				                edit.putString(GlobalConstants.PREF_CITY_PICK, citiesList.get(position).getString("city"));
				                edit.commit();
				                
				                ParseUser currentUser = ParseUser.getCurrentUser();
				                currentUser.put("city", citiesList.get(position).getString("city"));
				                currentUser.saveEventually();
				                
				                ParseInstallation currentInstallation = ParseInstallation.getCurrentInstallation();
				                currentInstallation.put("city", citiesList.get(position).getString("city"));
				                currentInstallation.saveEventually();
				                
				             	Intent iTabsIntent = new Intent(SelectCityActivity.this, TabsActivity.class);
			               		startActivity(iTabsIntent);
			            	}
			            	else
			            	{
				            	Intent intent = new Intent(SelectCityActivity.this, FacebookLoginActivity.class);
								intent.putExtra("city_name", citiesList.get(position).getString("name"));
								intent.putExtra("city_pick", citiesList.get(position).getString("city"));
								startActivity(intent);
			            	}
						}
					});
			        
			        listview.setAdapter(adapter);
			        
			        mLoading.setVisibility(View.INVISIBLE);
			        listview.setVisibility(View.VISIBLE);
				} else {
					Log.d("score", "Error: " + e.getMessage());
				}
			}

			
		});

	}


	

	
	@Override
	public void onPause()
	{
		db.closeDB();
		super.onPause();
	}
	
	@Override
	protected void onResume() {
	    
	    super.onResume();
	}
	
}
