package com.werner.nightguider;

import java.util.Calendar;
import java.util.Date;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.DatePicker.OnDateChangedListener;
import android.widget.TextView;
import android.widget.TimePicker;

import com.werner.nightguider.activitygroup.ActivityEventsStack;
import com.werner.nightguider.activitygroup.ActivitySearchStack;

public class SearchActivity extends Activity {


	int mYear;
	int mMonth;
	int mDay;

	static final int DATE_DIALOG_ID = 100;
	
	private DatePicker datePicker;
	private TimePicker timePicker;
	
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_search);
		
		datePicker = (DatePicker) this.findViewById(R.id.datePicker1);
		timePicker = (TimePicker) this.findViewById(R.id.timePicker1);
		timePicker.setIs24HourView(true);
		
		Calendar c = Calendar.getInstance();
		
		mYear = c.get(Calendar.YEAR);
	    mMonth = c.get(Calendar.MONTH);
	    mDay = c.get(Calendar.DAY_OF_MONTH);
		datePicker.init(mYear, mMonth, mDay, new OnDateChangedListener(){

			@Override
			public void onDateChanged(DatePicker arg0, int arg1, int arg2, int arg3) {
				// TODO Auto-generated method stub
				mYear = arg1;
				mMonth = arg2;
				mDay = arg3;
			}
			
		});
		
		Button btn_search = (Button) this.findViewById(R.id.btn_search);
		btn_search.setOnTouchListener(GlobalConstants.touchListener);
		btn_search.setOnClickListener(new OnClickListener() {
			
			@SuppressWarnings("deprecation")
			@Override
			public void onClick(final View arg0) {
			
//				showDatePickerDialog();
				
		        Date searchDate = new Date(mYear - 1900, mMonth, mDay, timePicker.getCurrentHour(), timePicker.getCurrentMinute());
						
				GlobalConstants.searchDate = String.valueOf(mYear) + "." + String.valueOf(mMonth+1) + "." +String.valueOf(mDay);
				
				Intent intent = new Intent();
				intent.setClass(getParent(), SearchResultActivity.class);
	            intent.putExtra(GlobalConstants.PREF_SEARCH_SEARCHDATE, searchDate);
				GlobalConstants.isNewSearch = true;
				ActivityEventsStack activityStack = (ActivityEventsStack) getParent();
				activityStack.push("EventsActivity" + ++GlobalConstants.EVENTS_ACTIVITY_COUNT, intent);
			}
		});
		
				
		
	}

//	public void showDatePickerDialog()
//	{
//		Calendar c = Calendar.getInstance();
//		int mYear = 0;
//		int mMonth;
//		int mDay;
//	
//		mYear = c.get(Calendar.YEAR);
//	    mMonth = c.get(Calendar.MONTH);
//	    mDay = c.get(Calendar.DAY_OF_MONTH);
//	
//	
//		try{
//			DatePickerDialog dialog = new DatePickerDialog(getParent(),
//		            new DateSetListener(), mYear, mMonth, mDay);
//		    dialog.show();
//		}catch(Exception e)
//		{
//			e.printStackTrace();
//		}
//	
//	}
//	
//	class DateSetListener implements DatePickerDialog.OnDateSetListener {
//
//	    @SuppressWarnings("deprecation")
//		@Override
//	    public void onDateSet(DatePicker view, int year, int monthOfYear,
//	            int dayOfMonth) {
//	        // TODO Auto-generated method stub
//	        // getCalender();
//	       
//	        Date startDate = new Date(year-1900, monthOfYear, dayOfMonth);
//			Date endDate = new Date(year-1900, monthOfYear, dayOfMonth+1);
//			
////	        String date = new StringBuilder()
////            // Month is 0 based so add 1
////            .append(String.format("%02d", mDay)).append("/").append(String.format("%02d", mMonth+1)).append("/")
////            .append(mYear).append(" ").toString();
//	        
//			GlobalConstants.searchDate = String.valueOf(year) + "." + String.valueOf(monthOfYear+1) + "." +String.valueOf(dayOfMonth);
//			
//			Intent intent = new Intent();
//            intent.setClass(getParent(), SearchResultActivity.class);
//            intent.putExtra(GlobalConstants.PREF_SEARCH_STARTDATE, startDate);
//			intent.putExtra(GlobalConstants.PREF_SEARCH_ENDDATE, endDate);
//			GlobalConstants.isNewSearch = true;
//            ActivitySearchStack activityStack = (ActivitySearchStack) getParent();
//            activityStack.push("SearchResultActivity", intent);
//	    }
//	}
	
	@Override
	public void onResume() {
		super.onResume();

		TextView tv = (TextView) this.findViewById(R.id.textView_menutext);
		tv.setText("Suche");
		

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
