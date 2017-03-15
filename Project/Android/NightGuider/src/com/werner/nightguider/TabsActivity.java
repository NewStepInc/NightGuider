package com.werner.nightguider;

import android.app.TabActivity;
import android.content.Intent;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.Window;
import android.widget.ImageView;
import android.widget.TabHost;
import android.widget.TabHost.OnTabChangeListener;
import android.widget.TextView;

import com.werner.nightguider.activitygroup.ActivityClubsStack;
import com.werner.nightguider.activitygroup.ActivityEventsStack;
import com.werner.nightguider.activitygroup.ActivityKarteStack;
import com.werner.nightguider.activitygroup.ActivitySearchStack;
import com.werner.nightguider.activitygroup.ActivityTopsStack;
import com.werner.nightguider.db.DatabaseHelper;

@SuppressWarnings("deprecation")
public class TabsActivity extends TabActivity implements OnTabChangeListener {

	DatabaseHelper db;
	TabHost tabHost;
	
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.tabsactivity);

//		db = new DatabaseHelper(getApplicationContext());

//		Bundle bundle = getIntent().getExtras();
//		cityName = bundle.getString("cityname");
//		Toast.makeText(this, cityName, Toast.LENGTH_SHORT).show();
		
		setTabs();
	}

	private void setTabs() {
		addTab("Events", R.drawable.tab_events, ActivityEventsStack.class);
		addTab("Clubs", R.drawable.tab_clubs, ActivityClubsStack.class);
		addTab("Suche", R.drawable.tab_suche, ActivitySearchStack.class);
		addTab("Karte", R.drawable.tab_karte, ActivityKarteStack.class);
		addTab("Fav", R.drawable.tab_favoriten, ActivityTopsStack.class);
	}

	private void addTab(String labelId, int drawableId, Class<?> c) {
		tabHost = getTabHost();
		Intent intent = new Intent(this, c);
		TabHost.TabSpec spec = tabHost.newTabSpec("tab" + labelId);

		View tabIndicator = LayoutInflater.from(this).inflate(R.layout.tab_indicator, getTabWidget(), false);
		TextView title = (TextView) tabIndicator.findViewById(R.id.title);
		title.setText(labelId);
		title.setTypeface(GlobalConstants.fontAller);
		ImageView icon = (ImageView) tabIndicator.findViewById(R.id.icon);
		icon.setImageResource(drawableId);

		spec.setIndicator(tabIndicator);
		spec.setContent(intent);
		tabHost.addTab(spec);
		
//		view = new TabView(this, R.drawable.tabbar_icon_more,  
//                R.drawable.tabbar_icon_more_selecotr);  
//        view.setBackgroundDrawable(this.getResources().getDrawable(  
//                R.drawable.footer_view_selector));  
//        intent = new Intent(MainActivity.this, HomeActivity.class);  
//        spec = tabHost.newTabSpec("num4").setIndicator(view).setContent(intent);  
//        tabHost.addTab(spec);  
		
//		spec = tabHost.newTabSpec("albums").setIndicator("Albums",
//				res.getDrawable(R.drawable.ic_tab_albums))
//			.setContent(intent);
//	tabHost.addTab(spec);
	}
	
	@Override
	public void onTabChanged(String tabId) {
		// TODO Auto-generated method stub
//		 TabHost tabHost = getTabHost();
//		 for(int i=0;i<tabHost.getTabWidget().getChildCount();i++) 
//         { 
//             TextView tv = (TextView) tabHost.getTabWidget().getChildAt(i).findViewById(android.R.id.title); //Unselected Tabs
//             tv.setTextColor(Color.BLUE);
//         } 
//         TextView tv = (TextView) tabHost.getCurrentTabView().findViewById(android.R.id.title); //for Selected Tab
//         tv.setTextColor(Color.YELLOW);
	}
}
