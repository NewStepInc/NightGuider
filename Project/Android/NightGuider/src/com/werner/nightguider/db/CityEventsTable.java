package com.werner.nightguider.db;

public class CityEventsTable {

	String objectId;
	String eventId;
	String eventName;
	String startDay;
	String startTime;
	String endDay;
	String endTime;
	String entrancePrice;
	String eventHost;
	String description;
	String fbLink;
	int special;
	String picSmall;
	String picBig;

	public CityEventsTable() {

	}

	/**
	 * @param objectId
	 * @param eventId
	 * @param eventName
	 * @param startDay
	 * @param startTime
	 * @param endDay
	 * @param endTime
	 * @param entrancePrice
	 * @param eventHost
	 * @param description
	 * @param fbLink
	 * @param special
	 */
	public CityEventsTable(String objectId, String eventId, String eventName, String startDay, String startTime, String endDay, String endTime, String entrancePrice,
			String eventHost, String description, String fbLink, int special, String picSmall, String picBig) {
		super();
		this.objectId = objectId;
		this.eventId = eventId;
		this.eventName = eventName;
		this.startDay = startDay;
		this.startTime = startTime;
		this.endDay = endDay;
		this.endTime = endTime;
		this.entrancePrice = entrancePrice;
		this.eventHost = eventHost;
		this.description = description;
		this.fbLink = fbLink;
		this.special = special;
		this.picSmall = picSmall;
		this.picBig = picBig;
	}
	
	/**
	 * @return the objectId
	 */
	public String getEventId() {
		return eventId;
	}

	/**
	 * @param objectId
	 *            the objectId to set
	 */
	public void setObjectId(String objectId) {
		this.objectId = objectId;
	}


	/**
	 * @return the eventId
	 */
	public String getObjectId() {
		return objectId;
	}

	/**
	 * @param eventId
	 *            the eventId to set
	 */
	public void setEventId(String eventId) {
		this.eventId = eventId;
	}

	/**
	 * @return the eventName
	 */
	public String getEventName() {
		return eventName;
	}

	/**
	 * @param eventName
	 *            the eventName to set
	 */
	public void setEventName(String eventName) {
		this.eventName = eventName;
	}

	/**
	 * @return the startDay
	 */
	public String getStartDay() {
		return startDay;
	}

	/**
	 * @param startDay
	 *            the startDay to set
	 */
	public void setStartDay(String startDay) {
		this.startDay = startDay;
	}

	/**
	 * @return the startTime
	 */
	public String getStartTime() {
		return startTime;
	}

	/**
	 * @param startTime
	 *            the startTime to set
	 */
	public void setStartTime(String startTime) {
		this.startTime = startTime;
	}

	/**
	 * @return the endDay
	 */
	public String getEndDay() {
		return endDay;
	}

	/**
	 * @param endDay
	 *            the endDay to set
	 */
	public void setEndDay(String endDay) {
		this.endDay = endDay;
	}

	/**
	 * @return the endTime
	 */
	public String getEndTime() {
		return endTime;
	}

	/**
	 * @param endTime
	 *            the endTime to set
	 */
	public void setEndTime(String endTime) {
		this.endTime = endTime;
	}

	/**
	 * @return the entrancePrice
	 */
	public String getEntrancePrice() {
		return entrancePrice;
	}

	/**
	 * @param entrancePrice
	 *            the entrancePrice to set
	 */
	public void setEntrancePrice(String entrancePrice) {
		this.entrancePrice = entrancePrice;
	}

	/**
	 * @return the eventHost
	 */
	public String getEventHost() {
		return eventHost;
	}

	/**
	 * @param eventHost
	 *            the eventHost to set
	 */
	public void setEventHost(String eventHost) {
		this.eventHost = eventHost;
	}

	/**
	 * @return the description
	 */
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
	 * @return the fbLink
	 */
	public String getFbLink() {
		return fbLink;
	}

	/**
	 * @param fbLink
	 *            the fbLink to set
	 */
	public void setFbLink(String fbLink) {
		this.fbLink = fbLink;
	}

	/**
	 * @return the special
	 */
	public int getSpecial() {
		return special;
	}

	/**
	 * @param special
	 *            the special to set
	 */
	public void setSpecial(int special) {
		this.special = special;
	}

	/**
	 * @return pic small
	 */
	public String getPicSmall() {
		return picSmall;
	}

	/**
	 * @param image
	 *            the image to set
	 */
	public void setPicSmall(String picSmall) {
		this.picSmall = picSmall;
	}
	
	/**
	 * @return pic big
	 */
	public String getPicBig() {
		return picBig;
	}

	/**
	 * @param image
	 *            the image to set
	 */
	public void setPicBig(String picBig) {
		this.picBig = picBig;
	}
}
