package com.werner.nightguider;
 
import java.util.ArrayList;
import java.util.List;

import android.app.ActionBar;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.AsyncTask;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.inputmethod.EditorInfo;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.GridView;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.TextView.OnEditorActionListener;
import android.widget.Toast;

import com.handmark.pulltorefresh.library.PullToRefreshBase;
import com.handmark.pulltorefresh.library.PullToRefreshBase.OnRefreshListener2;
import com.handmark.pulltorefresh.library.PullToRefreshGridView;
import com.parse.ParseException;
import com.parse.ParseFile;
import com.parse.ParseGeoPoint;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.werner.nightguider.activitygroup.ActivityClubsStack;
import com.werner.nightguider.activitygroup.ActivityEventsStack;
import com.werner.nightguider.adapter.ListClubsAdapter;

public class ClubsActivity extends Activity {
	
    // Declare Variables
	private PullToRefreshGridView mPullRefreshGridView;
	private GridView mGridView;
    
    private ProgressDialog mProgressDialog;
    private ListClubsAdapter mAdapter;
    private Context mContext;
    private String mCityPick;
    private int mPulledCount;
    
    private boolean mIsAllClubsLoaded;
    
    
    private boolean mIsAllSearchClubLoaded = false;
    LinearLayout searchBar;
    List<ListClubsModel> aryListClub;
    List<ListClubsModel> arySearchedListClub;
    
    EditText txtSearchKey;
    
    private boolean isFilterSet = false;
    
    //Order
//    RadioButton segNameBtn;
    
    ActionBar actionBar;
    boolean isSelectNameTab = true;
    
    
    LinearLayout tabName;
    TextView txtNameInTab;
    LinearLayout tabNameWhiteBar;
    
    LinearLayout tabNearest;
    TextView txtNearestInTab;
    LinearLayout tabNearestWhiteBar;
    
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_clubs);

		mContext = getParent();
		
		
		//For ActionBar
		
//		actionBar = getS
		
		//ActionBar
		
		
		//SearchBar
        searchBar = (LinearLayout) findViewById(R.id.searchBarOnClub);
        searchBar.setVisibility(View.GONE);
        
        ImageButton btnSearch = (ImageButton) findViewById(R.id.imgBtnSearchOnClub);
		btnSearch.setOnTouchListener(GlobalConstants.touchListener);
        btnSearch.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// transit to Map view
				Intent intent = new Intent();
				intent.setClass( getParent(), KarteActivity.class);
				ActivityClubsStack activityStack = (ActivityClubsStack) getParent();
				activityStack.push("ClubsActivity" + ++GlobalConstants.CLUBS_ACTIVITY_COUNT, intent);

//				if (searchBar.getVisibility() == View.GONE) {
//					searchBar.setVisibility(View.VISIBLE);
//
//					isFilterSet = true;
//					new GetClubsAsyncTask().execute();
//				}
//				else
//					searchBar.setVisibility(View.GONE);
			}
		});
        aryListClub = null;
        
        txtSearchKey = (EditText) findViewById(R.id.txtSearchKeyClub);
        
        txtSearchKey.setOnEditorActionListener(new OnEditorActionListener() {
			
			@Override
			public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
				
				if((event!=null && (event.getKeyCode() == KeyEvent.ACTION_DOWN)) || actionId == EditorInfo.IME_ACTION_DONE){
					
					
					if (txtSearchKey.getText().toString().length() == 0) {
						isFilterSet = false;
						arySearchedListClub = GlobalConstants.mClubListForSearch;
						showClubs(isSelectNameTab, false);
						return true;
					}
					
					arySearchedListClub = null;
//					aryGroupDate = null;
					arySearchedListClub = new ArrayList<ListClubsModel>();
//					aryGroupDate = new ArrayList<String>();
					List<ListClubsModel> listClub = GlobalConstants.mClubListForSearch;
					
					if (listClub.size() == 0)
					{
						isFilterSet = false;
						return true;
					}
					isFilterSet = true;
					
//					if (!segNameBtn.isChecked()) {
//						listClub = GlobalConstants.listOrderedByDist;
//					} else
//					{
//						listClub = GlobalConstants.mClubsList;
//					}
					
//					if (!isSelectNameTab) {
//						listClub = GlobalConstants.listOrderedByDist;
//					} else {
						listClub = GlobalConstants.mClubListForSearch;
//					}
					for(int i = 0; i < listClub.size(); i++) {
						String strEventTitle = listClub.get(i).getClubName().toLowerCase().trim();
						String[] aryKeyComponent = txtSearchKey.getText().toString().toLowerCase().split(" ");
						
						boolean isFound = true;
						for (int j = 0; j < aryKeyComponent.length; j++) {
							if (!strEventTitle.contains(aryKeyComponent[j])) {
								isFound = false;
								break;
							}
						}
						if (isFound) {
							arySearchedListClub.add(listClub.get(i));
						}
						
					}
		        	
					showClubs(isSelectNameTab, false);
				}
				return false;
			}
		});
        
//        txtSearchKey.addTextChangedListener(new TextWatcher() {
//			
//			@Override
//			public void onTextChanged(CharSequence s, int start, int before, int count) {
//				
//				if (txtSearchKey.getText().toString().length() == 0) {
//					isFilterSet = false;
//					arySearchedListClub = GlobalConstants.mClubListForSearch;
//					showClubs(isSelectNameTab, false);
//					return;
//				}
//				
//				arySearchedListClub = null;
////				aryGroupDate = null;
//				arySearchedListClub = new ArrayList<ListClubsModel>();
////				aryGroupDate = new ArrayList<String>();
//				List<ListClubsModel> listClub = GlobalConstants.mClubListForSearch;
//				
//				if (listClub.size() == 0)
//				{
//					isFilterSet = false;
//					return;
//				}
//				isFilterSet = true;
//				
////				if (!segNameBtn.isChecked()) {
////					listClub = GlobalConstants.listOrderedByDist;
////				} else
////				{
////					listClub = GlobalConstants.mClubsList;
////				}
//				
////				if (!isSelectNameTab) {
////					listClub = GlobalConstants.listOrderedByDist;
////				} else {
//					listClub = GlobalConstants.mClubListForSearch;
////				}
//				for(int i = 0; i < listClub.size(); i++) {
//					String strEventTitle = listClub.get(i).getClubName().toLowerCase().trim();
//					String[] aryKeyComponent = txtSearchKey.getText().toString().toLowerCase().split(" ");
//					
//					boolean isFound = true;
//					for (int j = 0; j < aryKeyComponent.length; j++) {
//						if (!strEventTitle.contains(aryKeyComponent[j])) {
//							isFound = false;
//							break;
//						}
//					}
//					if (isFound) {
//						arySearchedListClub.add(listClub.get(i));
//					}
//					
//				}
//	        	
//				showClubs(isSelectNameTab, false);
//	        	
//			}
//			
//			@Override
//			public void beforeTextChanged(CharSequence s, int start, int count, int after) {
//				// TODO Auto-generated method stub
//				
//			}
//			
//			@Override
//			public void afterTextChanged(Editable s) {
//				// TODO Auto-generated method stub
//				
//			}
//		});
        Button btnCancel = (Button) findViewById(R.id.btnCancelSearchClub);
        btnCancel.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
//				aryListClub = GlobalConstants.mClubsList;
				if (isSelectNameTab) {
					aryListClub = GlobalConstants.mClubsList;
				} else {
					aryListClub = GlobalConstants.listOrderedByDist;
				}
				txtSearchKey.setText("");
				isFilterSet = false;
	        	showClubs(isSelectNameTab, true);
			}
		});
        
        //>SearchBar
		
		
		//Order Setting.
        
//        segNearestBtn.setChecked(true);
        
        tabName = (LinearLayout) findViewById(R.id.tab_club_name);
        txtNameInTab = (TextView) findViewById(R.id.tab_club_name_txt);
        tabNameWhiteBar = (LinearLayout) findViewById(R.id.tab_club_name_whitebar);
        
        tabNearest = (LinearLayout) findViewById(R.id.tab_club_nearest);
        txtNearestInTab = (TextView) findViewById(R.id.tab_club_nearest_txt);
        tabNearestWhiteBar = (LinearLayout) findViewById(R.id.tab_club_nearest_whitebar);
        
        isSelectNameTab = true;

        tabName.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				txtNameInTab.setAlpha(1);
				txtNearestInTab.setAlpha((float)0.5);
//				tabNameWhiteBar.setBackgroundColor(R.color.light_graycolor);
				tabNameWhiteBar.setVisibility(View.VISIBLE);
				tabNearestWhiteBar.setVisibility(View.GONE);
				isSelectNameTab = true;
//				tabNearestWhiteBar.setBackgroundColor(R.color.titlebar_bg);
				
				aryListClub = null;
				txtSearchKey.setText("");
				
				showClubs(true, true);
				GlobalConstants.isNearestFromHere = false;
			}
		});
        
        tabNearest.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				txtNameInTab.setAlpha((float) 0.5);
				txtNearestInTab.setAlpha(1);
//				tabNearestWhiteBar.setBackgroundColor(R.color.light_graycolor);
//				tabNameWhiteBar.setBackgroundColor(R.color.titlebar_bg);
				tabNearestWhiteBar.setVisibility(View.VISIBLE);
				tabNameWhiteBar.setVisibility(View.GONE);
				isSelectNameTab = false;
				
				aryListClub = null;
				txtSearchKey.setText("");
				showClubs(false, true);
				GlobalConstants.isNearestFromHere = true;
			}
		});
        
//        SegmentedGroup segmentClubSort = (SegmentedGroup) this.findViewById(R.id.segment_club_sort);
//        segmentClubSort.setOnCheckedChangeListener(new OnCheckedChangeListener() {
//			
//			@Override
//			public void onCheckedChanged(RadioGroup group, int checkedId) {
//				// 
//				aryListClub = null;
//				txtSearchKey.setText("");
//				switch (checkedId) {
//				case R.id.seg_sort_nearest:
//					
//					showClubs(false);
//					GlobalConstants.isNearestFromHere = true;
//					break;
//					
//				case R.id.seg_sort_name:
//					showClubs(true);
//					GlobalConstants.isNearestFromHere = false;
//					break;
//					
//				default:
//					break;
//			}
//			}
//		});
        //>Order Setting
		
		
		
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(this);
		mCityPick = prefs.getString(GlobalConstants.PREF_CITY_PICK, "");
        
        mPullRefreshGridView = (PullToRefreshGridView) findViewById(R.id.list_clubs);
        mGridView = mPullRefreshGridView.getRefreshableView();
        
        // Set a listener to be invoked when the list should be refreshed.
        mPullRefreshGridView.setOnRefreshListener(new OnRefreshListener2<GridView>() {

			@Override
			public void onPullDownToRefresh(PullToRefreshBase<GridView> refreshView) {
				
				GlobalConstants.mClubsList = new ArrayList<ListClubsModel>();
  	            mIsAllClubsLoaded = false;
  				mPulledCount = 0;
				new GetClubsAsyncTask().execute();
		
			}

			@Override
			public void onPullUpToRefresh(PullToRefreshBase<GridView> refreshView) {
				if(mIsAllClubsLoaded)
 				{
 					Toast.makeText(ClubsActivity.this, "No more clubs!", Toast.LENGTH_SHORT).show();
 					mPullRefreshGridView.onRefreshComplete();
 					return;
 				}
				
				mPulledCount++;
 				new GetClubsAsyncTask().execute();
			
			}

    	});
           
		mPullRefreshGridView.setOnItemClickListener(new OnItemClickListener() {

 			@Override
 			public void onItemClick(AdapterView<?> adapter, View parent,
 					int position, long rowId) {
 				// TODO Auto-generated method stub
 				    		          
 				 Intent intent = new Intent();
// 				if (segNearestBtn.isChecked())
// 				{
 				 if (isFilterSet) {
 					intent.putExtra(GlobalConstants.BUNDLE_CLUB_ID, arySearchedListClub.get(position).getClubId());
 	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_DESCRIPTION, arySearchedListClub.get(position).getDescription());
 	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_THUMBNAIL, arySearchedListClub.get(position).getThumbnail());
 	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_PICBIG, arySearchedListClub.get(position).getBanner());
 	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_NAME, arySearchedListClub.get(position).getClubName());
 	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_STREET, arySearchedListClub.get(position).getStreet());
 	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_URL, arySearchedListClub.get(position).getUrl());
 	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_FACEBOOK, arySearchedListClub.get(position).getFacebook());
 	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_PHONENUMBER, arySearchedListClub.get(position).getPhoneNumber());
 	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_LATITUDE, arySearchedListClub.get(position).getLatitude());
 	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_LONGITUDE, arySearchedListClub.get(position).getLongtitude());
 	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_DISTANCE, arySearchedListClub.get(position).getDistance());
 	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_HOST, arySearchedListClub.get(position).getClubName());
 	   	            
 				 } else {
 					intent.putExtra(GlobalConstants.BUNDLE_CLUB_ID, aryListClub.get(position).getClubId());
 	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_DESCRIPTION, aryListClub.get(position).getDescription());
 	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_THUMBNAIL, aryListClub.get(position).getThumbnail());
 	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_PICBIG, aryListClub.get(position).getBanner());
 	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_NAME, aryListClub.get(position).getClubName());
 	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_STREET, aryListClub.get(position).getStreet());
 	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_URL, aryListClub.get(position).getUrl());
 	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_FACEBOOK, aryListClub.get(position).getFacebook());
 	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_PHONENUMBER, aryListClub.get(position).getPhoneNumber());
 	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_LATITUDE, aryListClub.get(position).getLatitude());
 	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_LONGITUDE, aryListClub.get(position).getLongtitude());
 	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_DISTANCE, aryListClub.get(position).getDistance());
 	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_HOST, aryListClub.get(position).getClubName());
 				 }
// 	        	} else {
// 	        		intent.putExtra(GlobalConstants.BUNDLE_CLUB_ID, GlobalConstants.mClubsList.get(position).getClubId());
// 	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_DESCRIPTION, GlobalConstants.mClubsList.get(position).getDescription());
// 	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_THUMBNAIL, GlobalConstants.mClubsList.get(position).getThumbnail());
// 	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_PICBIG, GlobalConstants.mClubsList.get(position).getBanner());
// 	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_NAME, GlobalConstants.mClubsList.get(position).getClubName());
// 	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_STREET, GlobalConstants.mClubsList.get(position).getStreet());
// 	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_URL, GlobalConstants.mClubsList.get(position).getUrl());
// 	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_FACEBOOK, GlobalConstants.mClubsList.get(position).getFacebook());
// 	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_PHONENUMBER, GlobalConstants.mClubsList.get(position).getPhoneNumber());
// 	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_LATITUDE, GlobalConstants.mClubsList.get(position).getLatitude());
// 	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_LONGITUDE, GlobalConstants.mClubsList.get(position).getLongtitude());
// 	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_DISTANCE, GlobalConstants.mClubsList.get(position).getDistance());
// 	   	            intent.putExtra(GlobalConstants.BUNDLE_CLUB_HOST, GlobalConstants.mClubsList.get(position).getClubName());
// 	        	}
    
   	           
   	            
   	      
   	            intent.setClass( getParent(), ClubsDetailsActivity.class);
   	            ActivityClubsStack activityStack = (ActivityClubsStack) getParent();
  	            activityStack.push("ClubsActivity" + ++GlobalConstants.CLUBS_ACTIVITY_COUNT, intent);
 			}
 		});
		
        TextView tv = (TextView) this.findViewById(R.id.textView_menutext);
		tv.setText("Clubs");
		tv.setTypeface(GlobalConstants.fontAller);
				
		if(GlobalConstants.mClubsList == null || GlobalConstants.mClubsList.size() == 0)
        {   		
    		GlobalConstants.mClubsList = new ArrayList<ListClubsModel>();
    		mAdapter = new ListClubsAdapter(this, GlobalConstants.mClubsList);
	        mIsAllClubsLoaded = false;
	        mPulledCount = 0;
			new GetClubsAsyncTask().execute();
			
        }else{  
        	if (!isSelectNameTab)
        	{
        		showClubs(false, false);
        	} else {
        		showClubs(true, false);
        	}
        }
    }
    
    @Override
	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();
		
		if (searchBar.getVisibility() == View.GONE) {
			isFilterSet = false;
		} else {
			isFilterSet = true;
		}
	}
 
    public void showClubs(boolean isName, boolean isClickTap)
    {
        if(mPulledCount == 0){
        	if (!isFilterSet) {
        		if (aryListClub == null || isClickTap) {
    	    		if(isName)
    	    			aryListClub = GlobalConstants.mClubsList;
    	    		else
    	    			aryListClub = GlobalConstants.listOrderedByDist;
//    	    		isFilterSet = false;
            	}
        		mAdapter = new ListClubsAdapter(this, aryListClub);
          		mGridView.setAdapter(mAdapter);
        	} else {
//        		isFilterSet = false;
    			if (arySearchedListClub == null) {
    				arySearchedListClub = GlobalConstants.mClubListForSearch;
    			}
    			mAdapter = new ListClubsAdapter(this, arySearchedListClub);
    			mGridView.setAdapter(mAdapter);
        	}
        		
    	}else{
    		
    		if (isFilterSet) {
//    			mAdapter = new ListClubsAdapter(ClubsActivity.this, aryListClub);
//          		mGridView.setAdapter(mAdapter);
//    			isFilterSet = false;
    			if (arySearchedListClub == null) {
    				arySearchedListClub = GlobalConstants.mClubListForSearch;
    			}
    			mAdapter = new ListClubsAdapter(this, arySearchedListClub);
    			mGridView.setAdapter(mAdapter);
    		} else {
    			if (isClickTap) {
    				if(isName)
    	    			aryListClub = GlobalConstants.mClubsList;
    	    		else
    	    			aryListClub = GlobalConstants.listOrderedByDist;
//    	    		isFilterSet = false;
    				mAdapter = new ListClubsAdapter(ClubsActivity.this, aryListClub);
              		mGridView.setAdapter(mAdapter);
    			} else {
    				mAdapter.notifyDataSetChanged();
    			}
    		}
    	}
    }
    
//    
//    public void addClubs(ListClubsModel model) {
//    	
//		CityClubsTable clubs = new CityClubsTable();
//		
//		clubs.setName(model.getClubName());
//		clubs.setHost(model.getHost());
//		clubs.setDescription(model.getDescription());
//		clubs.setStreet(model.getStreet());
//		clubs.setThumbnail(model.getThumbnail());
//		clubs.setLatitude(model.getLatitude());
//		clubs.setLongitude(model.getLongtitude());
//		
//	    DatabaseHelper mDb = new DatabaseHelper(mContext);
//		mDb.enterClubs(clubs);
//	}
    
    private class GetClubsAsyncTask extends AsyncTask<Void, Void, Void> {
        @Override
        protected void onPreExecute() {
            super.onPreExecute();
            // Create a progressdialog
            mProgressDialog = new ProgressDialog(mContext);
            // Set progressdialog title
            mProgressDialog.setTitle("Please wait...");
            // Set progressdialog message
            mProgressDialog.setMessage("Loading...");
            mProgressDialog.setIndeterminate(false);
    
            // Show progressdialog
            if(mPulledCount == 0)
            	mProgressDialog.show();
        }
 
		@Override
        protected Void doInBackground(Void... params) {
        	
            try{
            	
            	
            	boolean isEnd = false;
            	
            	if (isFilterSet) {
            		int tmp_pulledCount = 0;
            		if (GlobalConstants.mClubListForSearch == null) {
        				GlobalConstants.mClubListForSearch = new ArrayList<ListClubsModel>();
        			} else {
        				if (mIsAllSearchClubLoaded)
        					return null;
        				else {
        					GlobalConstants.mClubListForSearch.clear();
        				}
        			} 
            		
            		while (!isEnd) {
            			ParseQuery<ParseObject> query = new ParseQuery<ParseObject>(
                                "Clubs");
                        query.whereEqualTo("city_pick", mCityPick);
                        query.setLimit(GlobalConstants.refreshEventsCount);
                        query.setSkip(tmp_pulledCount * GlobalConstants.refreshEventsCount);
                        tmp_pulledCount++;
                        query.orderByAscending(GlobalConstants.PARSE_KEY_CLUBNAME);
                        List<ParseObject> objectsList = query.find();
                        if(objectsList.size()<GlobalConstants.refreshEventsCount){
                        	isEnd = true;
                        	mIsAllSearchClubLoaded = true;
                        }
                        for (ParseObject club : objectsList) {
                        	try{
        	                	ParseFile image = (ParseFile) club.get(GlobalConstants.PARSE_KEY_CLUBPICSMALL);
        	                	ParseFile bigImage = (ParseFile) club.get(GlobalConstants.PARSE_KEY_CLUBPICBIG);
        	                	
        	                    ListClubsModel map = new ListClubsModel();
        	                    map.setClubId(club.getObjectId());
        	                    map.setClubName((String) club.get(GlobalConstants.PARSE_KEY_CLUBNAME));
        	                    map.setThumbnail(image.getUrl());
        	                    map.setBanner(bigImage.getUrl());
        	                    map.setDescription((String) club.get(GlobalConstants.PARSE_KEY_CLUBDESCRIPTION));
        	                    map.setStreet((String) club.get(GlobalConstants.PARSE_KEY_CLUBSTREET));
        	                    map.setUrl((String) club.get(GlobalConstants.PARSE_KEY_CLUBURL));
        	                    map.setFacebook((String) club.get(GlobalConstants.PARSE_KEY_CLUBFACEBOOK));
        	                    map.setPhoneNumber((String) club.get(GlobalConstants.PARSE_KEY_CLUBPHONE));
        	                    ParseGeoPoint userLocation = club.getParseGeoPoint(GlobalConstants.PARSE_KEY_CLUBLOCATION);
        	                    map.setLatitude(userLocation.getLatitude());
        	                    map.setLongtitude(userLocation.getLongitude());
        	                    
        	                    String strDist="Google location Service not allowed.";
        	                    if(GlobalConstants.currentLocation!=null)
        	                    {
        		                    double distance = GlobalConstants.distanceBetween(GlobalConstants.currentLocation.getLatitude(), GlobalConstants.currentLocation.getLongitude(),
        		                    		userLocation.getLatitude(), userLocation.getLongitude())/1000.0f;
        		                    strDist = "Distanz :   " + String.format("%.2f", distance) + " km";
        		                    map.setDistanceWithDouble(distance);
        	                    }
        	                    
        	                    map.setDistance(strDist);
//        	                    addClubs(map);
        	                    GlobalConstants.mClubListForSearch.add(map);
        	                    
                        	}catch(Exception e){
                        		continue;
                        	} 
                        }
            		}
            	} else {
            	
	//                GlobalConstants.mClubsList = new ArrayList<ListClubsModel>();
	                ParseQuery<ParseObject> query = new ParseQuery<ParseObject>(
	                        "Clubs");
	                query.whereEqualTo("city_pick", mCityPick);
	                query.setLimit(GlobalConstants.refreshEventsCount);
	                query.setSkip(mPulledCount * GlobalConstants.refreshEventsCount);
	                query.orderByAscending(GlobalConstants.PARSE_KEY_CLUBNAME);
	                List<ParseObject> objectsList = query.find();
	                if(objectsList.size()<GlobalConstants.refreshEventsCount){
	                	mIsAllClubsLoaded = true;
	                }
	                for (ParseObject club : objectsList) {
	                	try{
		                	ParseFile image = (ParseFile) club.get(GlobalConstants.PARSE_KEY_CLUBPICSMALL);
		                	ParseFile bigImage = (ParseFile) club.get(GlobalConstants.PARSE_KEY_CLUBPICBIG);
		                	
		                    ListClubsModel map = new ListClubsModel();
		                    map.setClubId(club.getObjectId());
		                    map.setClubName((String) club.get(GlobalConstants.PARSE_KEY_CLUBNAME));
		                    map.setThumbnail(image.getUrl());
		                    map.setBanner(bigImage.getUrl());
		                    map.setDescription((String) club.get(GlobalConstants.PARSE_KEY_CLUBDESCRIPTION));
		                    map.setStreet((String) club.get(GlobalConstants.PARSE_KEY_CLUBSTREET));
		                    map.setUrl((String) club.get(GlobalConstants.PARSE_KEY_CLUBURL));
		                    map.setFacebook((String) club.get(GlobalConstants.PARSE_KEY_CLUBFACEBOOK));
		                    map.setPhoneNumber((String) club.get(GlobalConstants.PARSE_KEY_CLUBPHONE));
		                    ParseGeoPoint userLocation = club.getParseGeoPoint(GlobalConstants.PARSE_KEY_CLUBLOCATION);
		                    map.setLatitude(userLocation.getLatitude());
		                    map.setLongtitude(userLocation.getLongitude());
		                    
		                    String strDist="Google location Service not allowed.";
		                    if(GlobalConstants.currentLocation!=null)
		                    {
			                    double distance = GlobalConstants.distanceBetween(GlobalConstants.currentLocation.getLatitude(), GlobalConstants.currentLocation.getLongitude(),
			                    		userLocation.getLatitude(), userLocation.getLongitude())/1000.0f;
			                    strDist = "Distanz :   " + String.format("%.2f", distance) + " km";
			                    map.setDistanceWithDouble(distance);
		                    }
		                    
		                    map.setDistance(strDist);
	//	                    addClubs(map);
		                    GlobalConstants.mClubsList.add(map);
		                    
	                	}catch(Exception e){
	                		continue;
	                	} 
	                }
            	}
            } catch (ParseException e) {
                Log.e("Error", e.getMessage());
                e.printStackTrace();
            }
         
            return null;
        }
 
        @Override
        protected void onPostExecute(Void result) {  	

        	if(mProgressDialog != null)
        		mProgressDialog.dismiss();
                       
        	makeReOrderedByDistance();
        	if (!isFilterSet) {
	        	if (!isSelectNameTab)
	        	{
	        		showClubs(false, false);
	        	} else {
	        		showClubs(true, false);
	        	}	     
        	}
            mPullRefreshGridView.onRefreshComplete();
        }
    }
    
    public void makeReOrderedByDistance()
    {
    	GlobalConstants.listOrderedByDist = null;
    	GlobalConstants.listOrderedByDist = new ArrayList<ListClubsModel>();
    	
    	for (int i = 0; i < GlobalConstants.mClubsList.size(); i++) {
    		if(i == 0) {
    			GlobalConstants.listOrderedByDist.add(GlobalConstants.mClubsList.get(i));
    		}
    		else {
    			for (int j = 0; j <= i; j++) {
    				if (GlobalConstants.listOrderedByDist.get(GlobalConstants.listOrderedByDist.size() - 1).getDistanceWithDouble() < GlobalConstants.mClubsList.get(i).getDistanceWithDouble()) {
    					GlobalConstants.listOrderedByDist.add(GlobalConstants.mClubsList.get(i));
    					break;
    				}
    				if (GlobalConstants.listOrderedByDist.get(j).getDistanceWithDouble() >= GlobalConstants.mClubsList.get(i).getDistanceWithDouble())
    				{
    					GlobalConstants.listOrderedByDist.add(j, GlobalConstants.mClubsList.get(i));
    					break;
    				}
    			}
    		}
    		
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
}