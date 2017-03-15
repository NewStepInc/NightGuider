package com.werner.nightguider.adapter;

import java.util.List;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.koushikdutta.urlimageviewhelper.UrlImageViewHelper;
import com.werner.nightguider.GlobalConstants;
import com.werner.nightguider.ListClubsModel;
import com.werner.nightguider.R;

 
public class ListClubsAdapter extends BaseAdapter {
 
    // Declare Variables
    Context mContext;
    LayoutInflater mInflater;
    private List<ListClubsModel> mClubsList;

    public ListClubsAdapter(Context context,
            List<ListClubsModel> clubslist) {
        this.mContext = context;
        this.mClubsList = clubslist;
        mInflater = LayoutInflater.from(mContext);
    }
 
    public class ViewHolder {
    	TextView text1;
		TextView textWide;
		ImageView image;
    }
 
    @Override
    public int getCount() {
        return mClubsList.size();
    }
 
    @Override
    public Object getItem(int position) {
        return mClubsList.get(position);
    }
 
    @Override
    public long getItemId(int position) {
        return position;
    }
 
    public View getView(final int position, View view, ViewGroup parent) {
        final ViewHolder holder;
        if (view == null) {
            holder = new ViewHolder();
            view = mInflater.inflate(R.layout.list_clubsrow, null);
            holder.text1 = (TextView) view.findViewById(R.id.title);
			holder.textWide = (TextView) view.findViewById(R.id.artist);
			holder.image = (ImageView) view.findViewById(R.id.list_image);
            view.setTag(holder);
        } else {
            holder = (ViewHolder) view.getTag();
        }
        // Set the results into TextViews
        holder.text1.setText(mClubsList.get(position).getClubName());
        
//        Location location = GlobalConstants.currentLocation;
        String strDist;
	   	 if(GlobalConstants.currentLocation != null)
	   	 {
	   		 
	            double mLatitude = mClubsList.get(position).getLatitude();
	            double mLongtitude = mClubsList.get(position).getLongtitude();
	            double distance = GlobalConstants.distanceBetween(GlobalConstants.currentLocation.getLatitude(), GlobalConstants.currentLocation.getLongitude(),
	           		 mLatitude, mLongtitude);
	            strDist = "Distanz:" + String.format("%.2f", distance/1000.0f) + " km";
	   	 }
	   	 else
	   		strDist = "Google location Service not allowed.";
	   	 
        holder.textWide.setText(strDist);
       
        // Set the results into ImageView
        UrlImageViewHelper.setUrlDrawable(holder.image, mClubsList.get(position).getThumbnail());
  
        return view;
    }

}