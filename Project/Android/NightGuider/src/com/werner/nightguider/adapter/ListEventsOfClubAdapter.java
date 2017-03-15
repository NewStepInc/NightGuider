package com.werner.nightguider.adapter;

import java.text.SimpleDateFormat;
import java.util.List;

import android.content.Context;
import android.graphics.Color;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.koushikdutta.urlimageviewhelper.UrlImageViewHelper;
import com.werner.nightguider.GlobalConstants;
import com.werner.nightguider.ListEventsModel;
import com.werner.nightguider.R;
import com.werner.nightguider.ui.custom.RoundedImageView;

 
public class ListEventsOfClubAdapter extends BaseAdapter {
 
    // Declare Variables
    Context context;
    LayoutInflater inflater;
    public List<ListEventsModel> eventslist = null;

    public ListEventsOfClubAdapter(Context context,
            List<ListEventsModel> eventslist) {
        this.context = context;
        this.eventslist = eventslist;
        inflater = LayoutInflater.from(context);
        
        //show info button
        View view = inflater.inflate(R.layout.activity_events, null);
        ImageView btn_info =(ImageView) view.findViewById(R.id.btn_infomation);
        if(GlobalConstants.fromActivity == GlobalConstants.Activity_EVENTS)
        	btn_info.setVisibility(View.VISIBLE);
        else
        	btn_info.setVisibility(View.INVISIBLE);
    }
 
//    public void initData(){  
//    
//        DatabaseHelper db = new DatabaseHelper(context);
//        groupkey = db.getAllDates();
//        
//        for(int i= 0 ;i <eventslist.size(); i++)
//            listdates.add(eventslist.get(i).getStartTime());
//        
//        listdates.addAll(groupkey);
//    }  
    
    public class ViewHolder {
    	TextView text1;
		TextView textWide;
		TextView textTime;
		RoundedImageView image;
    }
 
    @Override
    public int getCount() {
        return eventslist.size();
    }
 
    @Override
    public Object getItem(int position) {
        return eventslist.get(position);
    }
 
    @Override
    public long getItemId(int position) {
        return position;
    }
 
   
    public View getView(final int position, View convertview, ViewGroup parent) {
    	
    	View view = convertview;
    	    
    	    ViewHolder holder;
//	        if (view == null) {
	            holder = new ViewHolder();
	            view = inflater.inflate(R.layout.list_eventsrow, null);
	            // Locate the TextViews in listview_item.xml
	            holder.text1 = (TextView) view.findViewById(R.id.title);
//	            holder.text1.setTypeface(GlobalConstants.fontAller);
				holder.textWide = (TextView) view.findViewById(R.id.host);
//				holder.textWide.setTypeface(GlobalConstants.fontAller);
				holder.textTime = (TextView) view.findViewById(R.id.text_starttime);
//				holder.textTime.setTypeface(GlobalConstants.fontAller);
				holder.image = (RoundedImageView) view.findViewById(R.id.list_image);
	            // Locate the ImageView in listview_item.xml
	            view.setTag(holder);
//	        } else {
//	            holder = (ViewHolder) view.getTag();
//	        }
		        // Set the results into TextViews
		            
		   try{
		        String strTemp;
		        holder.text1.setText(eventslist.get(position).getEventName());
	      
		        strTemp = eventslist.get(position).getStartTime();
		              	
		        String s[] = strTemp.split("_");
//		        strStartTime = s[1];
		        holder.textWide.setText(s[0]);
		        
	        	strTemp = eventslist.get(position).getEndTime();
//			    String s1[] = strTemp.split("_");
//			    strEndTime = s1[1];
	        	
			    SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy_H:mm");
	        	SimpleDateFormat newSdf = new SimpleDateFormat("H:mm");
	          	holder.textTime.setText(newSdf.format(sdf.parse(eventslist.get(position).getStartTime())) + " - " + 
	          			newSdf.format(sdf.parse(eventslist.get(position).getEndTime())));
	          			     
		        ImageView ivArrow = (ImageView) view.findViewById(R.id.imageView_arrow);
		        if(eventslist.get(position).getSpecial()==true)
		        {
		        	view.setBackgroundColor(Color.parseColor("#ed8f00"));
		        	holder.text1.setTextColor(Color.WHITE);
		        	holder.textTime.setTextColor(Color.WHITE);
		        	holder.textWide.setTextColor(Color.WHITE);
		        	ivArrow.setBackgroundResource(R.drawable.arrow_sel);
		        }
		        // Set the results into ImageView
		        UrlImageViewHelper.setUrlDrawable(holder.image, eventslist.get(position).getPicSmall());
			        
	        }catch(Exception e)
	        {
	        	return view;
	        }
     
        	
        return view;
       
    }
 
}