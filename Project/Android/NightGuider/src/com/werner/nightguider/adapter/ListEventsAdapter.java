package com.werner.nightguider.adapter;

import java.text.SimpleDateFormat;
import java.util.Date;
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

 
public class ListEventsAdapter extends BaseAdapter {
 
    // Declare Variables
    Context mContext;
    LayoutInflater mInflater;
    List<ListEventsModel> mEventsList = null;
    List<String> mGroupKeyList = null;  

    public ListEventsAdapter(Context context,
            List<ListEventsModel> eventslist, List<String> groupKeyList) {
        this.mContext = context;
        this.mEventsList = eventslist;
        this.mGroupKeyList = groupKeyList;
        mInflater = LayoutInflater.from(mContext);
        
        //show info button
        View view = mInflater.inflate(R.layout.activity_events, null);
        ImageView btn_info =(ImageView) view.findViewById(R.id.btn_infomation);
        if(GlobalConstants.fromActivity == GlobalConstants.Activity_EVENTS)
        	btn_info.setVisibility(View.VISIBLE);
        else
        	btn_info.setVisibility(View.INVISIBLE);
    }
 
    public class ViewHolder {
    	TextView text1;
		TextView textWide;
		TextView textTime;
		ImageView image;
    }
 
    @Override
    public int getCount() {
        return mEventsList.size();
    }
 
    @Override
    public Object getItem(int position) {
        return mEventsList.get(position);
    }
 
    @Override
    public long getItemId(int position) {
        return position;
    }
 
    @Override  
    public boolean isEnabled(int position) {  
        // TODO Auto-generated method stub  
    	if(mGroupKeyList==null) return true;
    	
    	ListEventsModel model = (ListEventsModel) getItem(position);
         if(mGroupKeyList.contains(model.getGroupName())){  
             return false;  
         }  
         return super.isEnabled(position);  
    } 
    
    public View getView(final int position, View convertview, ViewGroup parent) {
    	
    	View view = convertview;
    	ListEventsModel model = (ListEventsModel) getItem(position);
    	ViewHolder holder;
    	
        if(mGroupKeyList != null && mGroupKeyList.contains(model.getGroupName())){  

         	view = mInflater.inflate(R.layout.events_tag, null);
         	TextView tv=(TextView) view.findViewById(R.id.textView_groupdate);  
            tv.setText((CharSequence) model.getGroupName());
            tv.setTypeface(GlobalConstants.fontAller);
	          
        }else{
	        
//	        if (view == null) {
	            holder = new ViewHolder();
	            view = mInflater.inflate(R.layout.list_eventsrow, null);
	            // Locate the TextViews in listview_item.xml
	            holder.text1 = (TextView) view.findViewById(R.id.title);
//	            holder.text1.setTypeface(GlobalConstants.fontAller);
				holder.textWide = (TextView) view.findViewById(R.id.host);
//				holder.textWide.setTypeface(GlobalConstants.fontAller);
				holder.textTime = (TextView) view.findViewById(R.id.text_starttime);
//				holder.textTime.setTypeface(GlobalConstants.fontAller);
				holder.image = (ImageView) view.findViewById(R.id.list_image);
	            // Locate the ImageView in listview_item.xml
//	            view.setTag(holder);
//	        } else {
//	            holder = (ViewHolder) view.getTag();
//	        }

		            
		   try{
		        String strTemp;
		        holder.text1.setText(mEventsList.get(position).getEventName());
	      
		        strTemp = mEventsList.get(position).getStartTime();
                
		        if(GlobalConstants.fromActivity == GlobalConstants.Activity_EVENTS || GlobalConstants.fromActivity == GlobalConstants.Activity_FAVORITE
		        		|| GlobalConstants.fromActivity == GlobalConstants.Activity_CLUBS)
		        {
		        	holder.textWide.setText(mEventsList.get(position).getHost());
		        	SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy_H:mm");
		        	SimpleDateFormat newSdf = new SimpleDateFormat("H:mm");
		        	holder.textTime.setText(newSdf.format(sdf.parse(strTemp)));

		        }else{
		        	SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy_H:mm");
		        	Date startDate = sdf.parse(mEventsList.get(position).getStartTime());
		        	SimpleDateFormat newSdf = new SimpleDateFormat("M/d/yy");
		        	holder.textWide.setText(newSdf.format(startDate));
		           	
		        	SimpleDateFormat sdf1 = new SimpleDateFormat("MMM dd, yyyy_H:mm");
		        	SimpleDateFormat newSdf1 = new SimpleDateFormat("H:mm");
		          	holder.textTime.setText(newSdf1.format(sdf1.parse(mEventsList.get(position).getStartTime())) + " - " + 
		          			newSdf1.format(sdf1.parse(mEventsList.get(position).getEndTime())));
		        }
		     
		        ImageView ivArrow = (ImageView) view.findViewById(R.id.imageView_arrow);
		        if(mEventsList.get(position).getSpecial()==true)
		        {
		        	view.setBackgroundColor(Color.parseColor("#FFC107"));	//orange color
		        	holder.text1.setTextColor(Color.WHITE);
		        	holder.textTime.setTextColor(Color.WHITE);
		        	holder.textWide.setTextColor(Color.WHITE);
		        	ivArrow.setBackgroundResource(R.drawable.arrow_sel);
		        }
		        // Set the results into ImageView
		        UrlImageViewHelper.setUrlDrawable(holder.image, mEventsList.get(position).getPicSmall());
	        }catch(Exception e){
	        	return view;
	        }
        }
        return view;
    } 
}