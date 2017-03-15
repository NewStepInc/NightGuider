package com.werner.nightguider.activitygroup;

import java.util.Stack;

import android.app.Activity;
import android.app.ActivityGroup;
import android.app.LocalActivityManager;
import android.content.Intent;
import android.os.Bundle;
import android.view.Window;

import com.facebook.Session;
import com.parse.ParseFacebookUtils;
import com.werner.nightguider.GlobalConstants;
import com.werner.nightguider.FavoriteActivity;

@SuppressWarnings("deprecation")
public class ActivityTopsStack extends ActivityGroup {

  private Stack<String> stack;

  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    if (stack == null) stack = new Stack<String>();
    //start default activity
    push("TopstStackActivity", new Intent(this, FavoriteActivity.class));
  }

  @Override
  public void finishFromChild(Activity child) {
    pop();
  }

  @Override
  public void onBackPressed() {
    pop();
  }

  @Override
  public void onResume()
  {
	  super.onResume();
	  GlobalConstants.fromActivity = GlobalConstants.Activity_FAVORITE;
  }
  
  public void push(String id, Intent intent) {
    Window window = getLocalActivityManager().startActivity(id, intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP));
    if (window != null) {
      stack.push(id);
      setContentView(window.getDecorView());
    }
  }

  public void pop() {
    if (stack.size() == 1) finish();
    LocalActivityManager manager = getLocalActivityManager();
    manager.destroyActivity(stack.pop(), true);
    if (stack.size() > 0) {
      Intent lastIntent = manager.getActivity(stack.peek()).getIntent();
      Window newWindow = manager.startActivity(stack.peek(), lastIntent);
      setContentView(newWindow.getDecorView());
    }
  }
  
  @Override
	public void onActivityResult(int requestCode, int resultCode, Intent data) {
	    super.onActivityResult(requestCode, resultCode, data);
	    if(Session.getActiveSession() != null)
	    	Session.getActiveSession().onActivityResult(this, requestCode, resultCode, data);
	    else
	    	ParseFacebookUtils.finishAuthentication(requestCode, resultCode, data);
	}
}