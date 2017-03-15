package com.werner.nightguider;

public class ListClubsModel{
	private String clubName = "";
	private String thumbnail = "";
	private String banner = "";
	private String description = "";
	private String street = "";
	private String distance="";
	private String url = "";
	private String facebook = "";
	private String phoneNumber = "";
	private double latitude = 0;
	private double longtitude = 0;
	private String club_id = "";
	private double fDistance = 0;
	
	public void setDistanceWithDouble(double dist) {
		fDistance = dist;
	}
	
	public double getDistanceWithDouble() {
		return fDistance;
	}
	
	public void setClubId(String clubid)
	{
		this.club_id = clubid;
	}
	
	public void setClubName(String clubName) {
		this.clubName = clubName;
	}

	public String getClubName() {
		return this.clubName;
	}
	
	public void setThumbnail(String thumbnail) {
		this.thumbnail = thumbnail;
	}

	public String getThumbnail() {
		return this.thumbnail;
	}
	
	public void setBanner(String banner) {
		this.banner = banner;
	}

	public String getBanner() {
		return this.banner;
	}
	
	public void setDescription(String description) {
		this.description = description;
	}

	public String getClubId()
	{
		return club_id;
	}
	
	public String getDescription() {
		return this.description;
	}
	
	public void setFacebook(String facebook) {
		this.facebook = facebook;
	}

	public String getFacebook() {
		return this.facebook;
	}
	
	public void setPhoneNumber(String phoneNumber) {
		this.phoneNumber = phoneNumber;
	}

	public String getPhoneNumber() {
		return this.phoneNumber;
	}
	
	public void setUrl(String url) {
		this.url = url;
	}

	public String getUrl() {
		return this.url;
	}
	
	public void setStreet(String street) {
		this.street = street;
	}

	public String getStreet() {
		return this.street;
	}
	
	public void setDistance(String distance) {
		this.distance = distance;
	}

	public String getDistance() {
		return this.distance;
	}
	
	public void setLatitude(double latitude) {
		this.latitude = latitude;
	}

	public double getLatitude() {
		return this.latitude;
	}
	
	public void setLongtitude(double longtitude) {
		this.longtitude = longtitude;
	}

	public double getLongtitude() {
		return this.longtitude;
	}
}
