package com.werner.nightguider;


public class ListEventsModel{
	private String eventName = "";
	private String host = "";
	private String startTime = "";
	private String endTime = "";
	private String objectId = "";
	private String picSmall = "";
	private String picBig = "";
	private String description = "";
	private String entrancePrice = "";
	private String groupName = "";
	private String fbLink = "";
	private String street = "";
	private double latitude;
	private double longitude;
	private String eId;
	private boolean special = false;

	public void setEventName(String eventName) {
		this.eventName = eventName;
	}
	
	public String getEventName() {
		return this.eventName;
	}
	
	public void setEId(String eId) {
		this.eId = eId;
	}
	
	public String getEId() {
		return this.eId;
	}
	
	public void setHost(String host) {
		this.host = host;
	}

	public String getHost() {
		return this.host;
	}
	
	public void setObjectId(String id) {
		this.objectId = id;
	}


	public String getObjectId() {
		return this.objectId;
	}

	public void setStartTime(String startTime) {
		this.startTime = startTime;
	}

	public String getStartTime() {
		return this.startTime;
	}
	
	public void setEndTime(String endTime) {
		this.endTime = endTime;
	}

	public String getEndTime() {
		return this.endTime;
	}
	
	public void setPicBig(String picBig) {
		this.picBig = picBig;
	}
	
	public String getPicBig() {
		return this.picBig;
	}

	public void setPicSmall(String picSmall) {
		this.picSmall = picSmall;
	}
	
	public String getPicSmall() {
		return this.picSmall;
	}
	
	public void setDescription(String description) {
		this.description = description;
	}

	public String getDescription() {
		return this.description;
	}
	
	public void setEntrancePrice(String price) {
		this.entrancePrice = price;
	}
	
	public String getEntrancePrice() {
		return this.entrancePrice;
	}
	
	public void setGroupName(String groupName) {
		this.groupName = groupName;
	}
	
	public String getGroupName() {
		return this.groupName;
	}
	
	public void setSpecial(boolean special) {
		this.special = special;
	}
	
	public boolean getSpecial() {
		return this.special;
	}
	
	public void setFBLink(String fbLink) {
		this.fbLink = fbLink;
	}
	
	public String getFBLink() {
		return this.fbLink;
	}
	
	public void setStreet(String street) {
		this.street = street;
	}
	
	public String getStreet() {
		return this.street;
	}
	
	public void setLatitude(double latitude) {
		this.latitude = latitude;
	}
	
	public double getLatitude() {
		return this.latitude;
	}
	
	public void setLongitude(double longitude) {
		this.longitude = longitude;
	}
	
	public double getLongitude() {
		return this.longitude;
	}
}
