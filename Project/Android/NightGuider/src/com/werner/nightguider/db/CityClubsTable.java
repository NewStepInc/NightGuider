package com.werner.nightguider.db;

public class CityClubsTable {

	String objectId;
	String address;
	double latitude;
	double longitude;
	String description;
	String city;
	String country;
	String fblink;
	String kindofplace;
	String name;
	String host;
	String phoneNumber;
	String rating;
	String street;
	String url;
	String zip;
	String thumbnail;
	String banner;
	/**
	 * @param address
	 * @param location
	 * @param description
	 * @param city
	 * @param country
	 * @param fblink
	 * @param kindofplace
	 * @param name
	 * @param host
	 * @param phoneNumber
	 * @param rating
	 * @param street
	 * @param url
	 * @param zip
	 */
	public CityClubsTable(String objectId, String address, double latitude, double longitude, String description,
			String city, String country, String fblink, String kindofplace,
			String name, String host, String phoneNumber, String rating,
			String street, String url, String zip, String thumbnail, String bannerUrl) {
		super();
		this.objectId = objectId;
		this.address = address;
		this.latitude = latitude;
		this.longitude = longitude;
		this.description = description;
		this.city = city;
		this.country = country;
		this.fblink = fblink;
		this.kindofplace = kindofplace;
		this.name = name;
		this.host = host;
		this.phoneNumber = phoneNumber;
		this.rating = rating;
		this.street = street;
		this.url = url;
		this.zip = zip;
		this.thumbnail = thumbnail;
		this.banner = bannerUrl;
	}

	public CityClubsTable() {

	}

	/**
	 * @return the objectId
	 */
	public String getObjectId() {
		return objectId;
	}

	/**
	 * @param address
	 *            the address to set
	 */
	public void setObjectId(String objectId) {
		this.objectId = objectId;
	}

	
	/**
	 * @return the address
	 */
	public String getAddress() {
		return address;
	}

	/**
	 * @param address
	 *            the address to set
	 */
	public void setAddress(String address) {
		this.address = address;
	}

	/**
	 * @return the latitude
	 */
	public double getLatitude() {
		return latitude;
	}

	/**
	 * @param latitude
	 *            the latitude to set
	 */
	public void setLatitude(double latitude) {
		this.latitude = latitude;
	}
	
	/**
	 * @return the longitude
	 */
	public double getLongitude() {
		return longitude;
	}

	/**
	 * @param latitude
	 *            the latitude to set
	 */
	public void setLongitude(double longitude) {
		this.longitude = longitude;
	}

	/**
	 * @return the description
	 */
	public void setBanner(String bannerUrl) {
		banner = bannerUrl;
	}
	
	public String getBanner() {
		return banner;
	}
	
	public String getDescription() {
		return description;
	}

	/**
	 * @param description
	 *            the description to set
	 */
	public void setDescription(String description) {
		this.description = description;
	}

	/**
	 * @return the city
	 */
	public String getCity() {
		return city;
	}

	/**
	 * @param city
	 *            the city to set
	 */
	public void setCity(String city) {
		this.city = city;
	}

	/**
	 * @return the country
	 */
	public String getCountry() {
		return country;
	}

	/**
	 * @param country
	 *            the country to set
	 */
	public void setCountry(String country) {
		this.country = country;
	}

	/**
	 * @return the fblink
	 */
	public String getFblink() {
		return fblink;
	}

	/**
	 * @param fblink
	 *            the fblink to set
	 */
	public void setFblink(String fblink) {
		this.fblink = fblink;
	}

	/**
	 * @return the kindofplace
	 */
	public String getKindofplace() {
		return kindofplace;
	}

	/**
	 * @param kindofplace
	 *            the kindofplace to set
	 */
	public void setKindofplace(String kindofplace) {
		this.kindofplace = kindofplace;
	}

	/**
	 * @return the name
	 */
	public String getName() {
		return name;
	}

	/**
	 * @param name
	 *            the name to set
	 */
	public void setName(String name) {
		this.name = name;
	}

	/**
	 * @return the host
	 */
	public String getHost() {
		return host;
	}

	/**
	 * @param host
	 *            the host to set
	 */
	public void setHost(String host) {
		this.host = host;
	}

	/**
	 * @return the phoneNumber
	 */
	public String getPhoneNumber() {
		return phoneNumber;
	}

	/**
	 * @param phoneNumber
	 *            the phoneNumber to set
	 */
	public void setPhoneNumber(String phoneNumber) {
		this.phoneNumber = phoneNumber;
	}

	/**
	 * @return the rating
	 */
	public String getRating() {
		return rating;
	}

	/**
	 * @param rating
	 *            the rating to set
	 */
	public void setRating(String rating) {
		this.rating = rating;
	}

	/**
	 * @return the street
	 */
	public String getStreet() {
		return street;
	}

	/**
	 * @param street
	 *            the street to set
	 */
	public void setStreet(String street) {
		this.street = street;
	}

	/**
	 * @return the url
	 */
	public String getUrl() {
		return url;
	}

	/**
	 * @param url
	 *            the url to set
	 */
	public void setUrl(String url) {
		this.url = url;
	}

	/**
	 * @return the zip
	 */
	public String getZip() {
		return zip;
	}

	/**
	 * @param zip
	 *            the zip to set
	 */
	public void setZip(String zip) {
		this.zip = zip;
	}

	/**
	 * @return the thumbnail
	 */
	public String getThumbnail() {
		return thumbnail;
	}

	/**
	 * @param thumbnail
	 *            the thumbnail to set
	 */
	public void setThumbnail(String thumbnail) {
		this.thumbnail = thumbnail;
	}

}
