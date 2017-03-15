package com.werner.nightguider;

import android.app.Activity;
import android.os.Bundle;
import android.view.Window;
import android.widget.ImageView;
import android.widget.TextView;

import com.koushikdutta.urlimageviewhelper.UrlImageViewHelper;

public class EventsLargeImageActivity extends Activity{

	String mStrEventName;
	String mStrEventImage;
	
	public EventsLargeImageActivity()
	{
		super();
		
	}
	
	 public void onCreate(Bundle savedInstanceState) {
	        super.onCreate(savedInstanceState);
	        requestWindowFeature(Window.FEATURE_NO_TITLE);
	        setContentView(R.layout.activity_eventslargeimage);
	        
	        Bundle bundle = getIntent().getExtras();
	        mStrEventName = bundle.getString(GlobalConstants.BUNDLE_EVENT_NAME);
	        mStrEventImage = bundle.getString(GlobalConstants.BUNDLE_EVENT_PICBIG);
	        
	        TextView tv = (TextView) this.findViewById(R.id.textView_menutext);
			tv.setText(mStrEventName);
			tv.setTypeface(GlobalConstants.fontAller);
	        ImageView imgView = (ImageView) this.findViewById(R.id.imgView);
	        UrlImageViewHelper.setUrlDrawable(imgView, mStrEventImage);
	        imgView.setDrawingCacheQuality(100);
	       
	 }
}
