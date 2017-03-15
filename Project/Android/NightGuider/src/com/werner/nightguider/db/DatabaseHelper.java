package com.werner.nightguider.db;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import com.werner.nightguider.GlobalConstants;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.util.Log;

public class DatabaseHelper extends SQLiteOpenHelper {

	private static final String LOG = "DatabaseHelper";
	private static final int DATABASE_VERSION = 1;
	private static final String DATABASE_NAME = "clupDatabase";

	private static final String TABLE_CITIES = "cities";
	private static final String TABLE_CLUBS = "clubs";
	private static final String TABLE_EVENTS = "events";
	private static final String TABLE_FAVOUR_EVENTS = "favour_events";
	private static final String TABLE_DATES = "dates";

	private static final String KEY_DATES = "date";
	
	private static final String KEY_ID = "id";
	private static final String KEY_OBJECTID = "objectId";
	private static final String KEY_NAME = "name";
	private static final String KEY_CITY = "city";

	private static final String KEY_ADDRESS = "address";
	private static final String KEY_LATITUDE = "latitude";
	private static final String KEY_LONGITUDE = "longitude";
	private static final String KEY_CITYNAME = "cityname";
	private static final String KEY_COUNTRY = "country";
	private static final String KEY_FBLINK = "fblink";
	private static final String KEY_KINDOFPLACE = "kindofplace";
	private static final String KEY_CLUBNAME = "clubname";
	private static final String KEY_HOST = "host";
	private static final String KEY_PHONENUMBER = "phonenumber";
	private static final String KEY_RATING = "rating";
	private static final String KEY_STREET = "street";
	private static final String KEY_URL = "url";
	private static final String KEY_ZIP = "zip";
	private static final String KEY_THUMBNAIL = "thumbnail";
	private static final String KEY_BANNER = "banner";

	private static final String KEY_EVENTID = "eventId";
	private static final String KEY_EVENTNAME = "eventName";
	private static final String KEY_STARTDAY = "startDay";
	private static final String KEY_STARTTIME = "StartTime";
	private static final String KEY_ENDDAY = "endDay";
	private static final String KEY_ENDTIME = "endTime";
	private static final String KEY_ENTRANCEPRICE = "entrancePrice";
	private static final String KEY_EVENTHOST = "eventHost";
	private static final String KEY_DESCRIPTION = "description";
	private static final String KEY_EVENTFBLINK = "fbLink";
	private static final String KEY_SPECIAL = "special";
	private static final String KEY_PICSMALL = "picSmall";
	private static final String KEY_PICBIG = "picBig";
	
	private static final String CREATE_TABLE_CITIES = "CREATE TABLE " + TABLE_CITIES + "(" + KEY_ID + " INTEGER PRIMARY KEY," + KEY_NAME + " TEXT,"
			+ KEY_CITY + " INTEGER" + ")";

	private static final String CREATE_TABLE_CLUBS = "CREATE TABLE " + TABLE_CLUBS + "(" + KEY_ID + " INTEGER PRIMARY KEY," + KEY_ADDRESS + " TEXT,"
			+ KEY_OBJECTID + " TEXT," + KEY_LATITUDE + " FLOAT," + KEY_LONGITUDE + " FLOAT," + KEY_CITYNAME + " TEXT," + KEY_COUNTRY + " TEXT," + KEY_FBLINK + " TEXT,"
			+ KEY_KINDOFPLACE + " TEXT," + KEY_CLUBNAME + " TEXT," + KEY_HOST + " TEXT," + KEY_PHONENUMBER + " TEXT," + KEY_RATING + " INTEGER,"
			+ KEY_STREET + " TEXT," + KEY_URL + " TEXT," + KEY_ZIP + " TEXT," + KEY_THUMBNAIL + " TEXT," + KEY_BANNER + " TEXT" + ")";

	private static final String CREATE_TABLE_EVENTS = "CREATE TABLE " + TABLE_EVENTS + "(" + KEY_ID + " INTEGER PRIMARY KEY," + KEY_OBJECTID + " TEXT," + KEY_EVENTID
			+ " TEXT," + KEY_EVENTNAME + " TEXT," + KEY_STARTDAY + " TEXT," + KEY_STARTTIME + " TEXT," + KEY_ENDDAY + " TEXT," + KEY_ENDTIME
			+ " TEXT," + KEY_ENTRANCEPRICE + " TEXT," + KEY_EVENTHOST + " TEXT," + KEY_DESCRIPTION + " TEXT," + KEY_EVENTFBLINK + " INTEGER,"
			+ KEY_SPECIAL + " TEXT," +  KEY_PICSMALL + " TEXT," + KEY_PICBIG + " TEXT" + ")";
	
	private static final String CREATE_TABLE_FAVOUR_EVENTS = "CREATE TABLE " + TABLE_FAVOUR_EVENTS + "(" + KEY_ID + " INTEGER PRIMARY KEY," + KEY_OBJECTID + " TEXT," + KEY_EVENTID
			+ " TEXT," + KEY_EVENTNAME + " TEXT," + KEY_STARTDAY + " TEXT," + KEY_STARTTIME + " TEXT," + KEY_ENDDAY + " TEXT," + KEY_ENDTIME
			+ " TEXT," + KEY_ENTRANCEPRICE + " TEXT," + KEY_EVENTHOST + " TEXT," + KEY_DESCRIPTION + " TEXT," + KEY_EVENTFBLINK + " INTEGER,"
			+ KEY_SPECIAL + " TEXT," +  KEY_PICSMALL + " TEXT," + KEY_PICBIG + " TEXT" + ")";

	private static final String CREATE_TABLE_DATES = "CREATE TABLE " + TABLE_DATES + "(" + KEY_ID + " INTEGER PRIMARY KEY," + KEY_DATES + " TEXT"
			 + ")";
	
	public DatabaseHelper(Context context) {
		super(context, DATABASE_NAME, null, DATABASE_VERSION);
	}

	@Override
	public void onCreate(SQLiteDatabase db) {
		db.execSQL(CREATE_TABLE_CITIES);
		db.execSQL(CREATE_TABLE_CLUBS);
		db.execSQL(CREATE_TABLE_EVENTS);
		db.execSQL(CREATE_TABLE_FAVOUR_EVENTS);
		db.execSQL(CREATE_TABLE_DATES);
	}

	@Override
	public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
		db.execSQL("DROP TABLE IF EXISTS " + TABLE_CITIES);
		db.execSQL("DROP TABLE IF EXISTS " + TABLE_CLUBS);
		db.execSQL("DROP TABLE IF EXISTS " + TABLE_EVENTS);
		db.execSQL("DROP TABLE IF EXISTS " + TABLE_FAVOUR_EVENTS);
		db.execSQL("DROP TABLE IF EXISTS " + TABLE_DATES);
		onCreate(db);
	}

	public void enterCities(CitiesTable cities) {
		SQLiteDatabase db = this.getWritableDatabase();
		
		String selectQuery = "SELECT * FROM " + TABLE_CITIES + " WHERE " + KEY_NAME + "='" + cities.getName() +"'";
		Cursor c = db.rawQuery(selectQuery, null);
		if(c.getCount()==0)
		{
			ContentValues values = new ContentValues();
			values.put(KEY_NAME, cities.getName());
			values.put(KEY_CITY, cities.getCity());
			db.insert(TABLE_CITIES, null, values);
		}
		c.close();
		db.close();
	}

	public void enterDates(Date date) {
		SQLiteDatabase db = this.getWritableDatabase();
		
		String strDate = GlobalConstants.dateToString(date);
		String selectQuery = "SELECT * FROM " + TABLE_DATES + " WHERE " + KEY_DATES + "='" + strDate +"'";
		Cursor c = db.rawQuery(selectQuery, null);
		if(c.getCount()==0)
		{
			ContentValues v = new ContentValues();
			v.put(KEY_DATES, strDate);
			db.insert(TABLE_DATES, null, v);
		}
		c.close();
		db.close();
	}
	
	public void enterClubs(CityClubsTable clubs) {
		SQLiteDatabase db = this.getWritableDatabase();
		
		String selectQuery = "SELECT * FROM " + TABLE_CLUBS + " WHERE " + KEY_OBJECTID + "='" + clubs.getObjectId() +"'";
		Cursor c = db.rawQuery(selectQuery, null);
		if(c.getCount()==0)
		{
			ContentValues values = new ContentValues();
			values.put(KEY_OBJECTID, clubs.getObjectId());
			values.put(KEY_ADDRESS, clubs.getAddress());
			values.put(KEY_LATITUDE, clubs.getLatitude());
			values.put(KEY_LONGITUDE, clubs.getLongitude());
			values.put(KEY_CITYNAME, clubs.getCity());
			values.put(KEY_COUNTRY, clubs.getCountry());
			values.put(KEY_FBLINK, clubs.getFblink());
			values.put(KEY_KINDOFPLACE, clubs.getKindofplace());
			values.put(KEY_CLUBNAME, clubs.getName());
			values.put(KEY_HOST, clubs.getHost());
			values.put(KEY_PHONENUMBER, clubs.getPhoneNumber());
			values.put(KEY_RATING, clubs.getRating());
			values.put(KEY_STREET, clubs.getStreet());
			values.put(KEY_URL, clubs.getUrl());
			values.put(KEY_ZIP, clubs.getZip());
			values.put(KEY_THUMBNAIL, clubs.getThumbnail());
			values.put(KEY_BANNER, clubs.getBanner());
			
			db.insert(TABLE_CLUBS, null, values);
		}
		c.close();
		db.close();
	}

	public void enterEvents(CityEventsTable events) {
		SQLiteDatabase db = this.getWritableDatabase();
		
		String selectQuery = "SELECT * FROM " + TABLE_EVENTS + " WHERE " + KEY_OBJECTID + "='" + events.getObjectId() +"'";
		Cursor c = db.rawQuery(selectQuery, null);
		if(c.getCount()==0)
		{
			ContentValues values = new ContentValues();
			values.put(KEY_OBJECTID, events.getObjectId());
			values.put(KEY_EVENTID, events.getEventId());
			values.put(KEY_EVENTNAME, events.getEventName());
			values.put(KEY_STARTDAY, events.getStartDay());
			values.put(KEY_STARTTIME, events.getStartTime());
			values.put(KEY_ENDDAY, events.getEndDay());
			values.put(KEY_ENDTIME, events.getEndTime());
			values.put(KEY_ENTRANCEPRICE, events.getEntrancePrice());
			values.put(KEY_EVENTHOST, events.getEventHost());
			values.put(KEY_DESCRIPTION, events.getDescription());
			values.put(KEY_EVENTFBLINK, events.getFbLink());
			values.put(KEY_SPECIAL, events.getSpecial());
			values.put(KEY_PICSMALL, events.getPicSmall());
			values.put(KEY_PICBIG, events.getPicBig());
			db.insert(TABLE_EVENTS, null, values);
		}
		c.close();
		db.close();
	}

	public void enterFavourEvents(CityEventsTable events) {
		SQLiteDatabase db = this.getWritableDatabase();
		
		String selectQuery = "SELECT * FROM " + TABLE_FAVOUR_EVENTS + " WHERE " + KEY_OBJECTID + "='" + events.getObjectId() +"'";
		Cursor c = db.rawQuery(selectQuery, null);
		if(c.getCount()==0)
		{
			ContentValues values = new ContentValues();
			values.put(KEY_OBJECTID, events.getObjectId());
			values.put(KEY_EVENTID, events.getEventId());
			values.put(KEY_EVENTNAME, events.getEventName());
			values.put(KEY_STARTDAY, events.getStartDay());
			values.put(KEY_STARTTIME, events.getStartTime());
			values.put(KEY_ENDDAY, events.getEndDay());
			values.put(KEY_ENDTIME, events.getEndTime());
			values.put(KEY_ENTRANCEPRICE, events.getEntrancePrice());
			values.put(KEY_EVENTHOST, events.getEventHost());
			values.put(KEY_DESCRIPTION, events.getDescription());
			values.put(KEY_EVENTFBLINK, events.getFbLink());
			values.put(KEY_SPECIAL, events.getSpecial());
			values.put(KEY_PICSMALL, events.getPicSmall());
			values.put(KEY_PICBIG, events.getPicBig());
			db.insert(TABLE_EVENTS, null, values);
		}
		c.close();
		db.close();
	}
	
	public List<CityEventsTable> getAllEvents() {
		SQLiteDatabase db = this.getReadableDatabase();
		List<CityEventsTable> events = new ArrayList<CityEventsTable>();
		String selectQuery = "SELECT * FROM " + TABLE_EVENTS;
		Log.e(LOG, selectQuery);
		Cursor c = db.rawQuery(selectQuery, null);
		if (c.moveToFirst()) {
			do {
				CityEventsTable cityEvents = new CityEventsTable();
				
				cityEvents.setEventName(c.getString(c.getColumnIndex(KEY_EVENTNAME)));
				cityEvents.setStartDay(c.getString(c.getColumnIndex(KEY_STARTDAY)));
				cityEvents.setStartTime(c.getString(c.getColumnIndex(KEY_STARTTIME)));
				cityEvents.setEndDay(c.getString(c.getColumnIndex(KEY_ENDDAY)));
				cityEvents.setEndTime(c.getString(c.getColumnIndex(KEY_ENDTIME)));
				cityEvents.setEntrancePrice(c.getString(c.getColumnIndex(KEY_ENTRANCEPRICE)));
				cityEvents.setEventHost(c.getString(c.getColumnIndex(KEY_EVENTHOST)));
				cityEvents.setDescription(c.getString(c.getColumnIndex(KEY_DESCRIPTION)));
				cityEvents.setFbLink(c.getString(c.getColumnIndex(KEY_EVENTFBLINK)));
				cityEvents.setSpecial(c.getInt(c.getColumnIndex(KEY_SPECIAL)));
				cityEvents.setPicSmall(c.getString(c.getColumnIndex(KEY_PICSMALL)));
				cityEvents.setPicBig(c.getString(c.getColumnIndex(KEY_PICBIG)));
				cityEvents.setObjectId(c.getString(c.getColumnIndex(KEY_OBJECTID)));
				cityEvents.setEventId(c.getString(c.getColumnIndex(KEY_EVENTID)));
				
				events.add(cityEvents);
			} while (c.moveToNext());
		}

		c.close();
		db.close();
		
		return events;
	}

	public List<CityEventsTable> getAllFavourEvents() {
		SQLiteDatabase db = this.getReadableDatabase();
		List<CityEventsTable> events = new ArrayList<CityEventsTable>();
		String selectQuery = "SELECT * FROM " + TABLE_FAVOUR_EVENTS;
		Log.e(LOG, selectQuery);
		Cursor c = db.rawQuery(selectQuery, null);
		if (c.moveToFirst()) {
			do {
				CityEventsTable cityEvents = new CityEventsTable();
				
				cityEvents.setEventName(c.getString(c.getColumnIndex(KEY_EVENTNAME)));
				cityEvents.setStartDay(c.getString(c.getColumnIndex(KEY_STARTDAY)));
				cityEvents.setStartTime(c.getString(c.getColumnIndex(KEY_STARTTIME)));
				cityEvents.setEndDay(c.getString(c.getColumnIndex(KEY_ENDDAY)));
				cityEvents.setEndTime(c.getString(c.getColumnIndex(KEY_ENDTIME)));
				cityEvents.setEntrancePrice(c.getString(c.getColumnIndex(KEY_ENTRANCEPRICE)));
				cityEvents.setEventHost(c.getString(c.getColumnIndex(KEY_EVENTHOST)));
				cityEvents.setDescription(c.getString(c.getColumnIndex(KEY_DESCRIPTION)));
				cityEvents.setFbLink(c.getString(c.getColumnIndex(KEY_EVENTFBLINK)));
				cityEvents.setSpecial(c.getInt(c.getColumnIndex(KEY_SPECIAL)));
				cityEvents.setPicSmall(c.getString(c.getColumnIndex(KEY_PICSMALL)));
				cityEvents.setPicBig(c.getString(c.getColumnIndex(KEY_PICBIG)));
				cityEvents.setObjectId(c.getString(c.getColumnIndex(KEY_OBJECTID)));
				cityEvents.setEventId(c.getString(c.getColumnIndex(KEY_EVENTID)));
				
				events.add(cityEvents);
			} while (c.moveToNext());
		}

		c.close();
		db.close();
		
		return events;
	}
	
	public boolean isFavouriteClub(String clubId)
	{
		SQLiteDatabase db = this.getReadableDatabase();
		String selectQuery = "SELECT * FROM " + TABLE_CLUBS + " WHERE " + KEY_OBJECTID + "='" + clubId +"'";;
		Log.e(LOG, selectQuery);
		Cursor c = db.rawQuery(selectQuery, null);
	
		if (c.getCount()>0) {
			c.close();
			db.close();
			return true;
		}

		c.close();
		db.close();
		
		return false;
	}
	
	public boolean isFavourEvent(String eventId) {
		SQLiteDatabase db = this.getReadableDatabase();
		String selectQuery = "SELECT * FROM " + TABLE_EVENTS + " WHERE " + KEY_OBJECTID + "='" + eventId +"'";;
		Log.e(LOG, selectQuery);
		Cursor c = db.rawQuery(selectQuery, null);
	
		if (c.getCount()>0) {
			c.close();
			db.close();
			return true;
		}

		c.close();
		db.close();
		
		return false;
	}
	
	public void deleteClub(String cid)
	{
		SQLiteDatabase db = this.getReadableDatabase();
		String selectQuery = "DELETE FROM " + TABLE_CLUBS + " WHERE " + KEY_OBJECTID + "='" + cid +"'";
		
		Log.e(LOG, selectQuery);
		db.execSQL(selectQuery);
		db.close();
	}
	
	public void deleteEvent(String eid)
	{
		SQLiteDatabase db = this.getReadableDatabase();
		String selectQuery = "DELETE FROM " + TABLE_EVENTS + " WHERE " + KEY_OBJECTID + "='" + eid +"'";
		
		Log.e(LOG, selectQuery);
		db.execSQL(selectQuery);
		db.close();
	}
	
	public void deleteFavourEvent(String eid)
	{
		SQLiteDatabase db = this.getReadableDatabase();
		String selectQuery = "DELETE FROM " + TABLE_FAVOUR_EVENTS + " WHERE " + KEY_OBJECTID + "='" + eid +"'";
		
		Log.e(LOG, selectQuery);
		db.execSQL(selectQuery);
		db.close();
	}
	
	public void deleteDates()
	{
		SQLiteDatabase db = this.getReadableDatabase();
		String selectQuery = "DELETE FROM " + TABLE_EVENTS;
		
		Log.e(LOG, selectQuery);
		db.execSQL(selectQuery);
		db.close();
	}
	
	public void deleteEventTable()
	{
		SQLiteDatabase db = this.getReadableDatabase();
		String selectQuery = "DELETE FROM " + TABLE_EVENTS ;
		
		Log.e(LOG, selectQuery);
		db.execSQL(selectQuery);
		db.close();
	}
	
	public void deleteClubTable()
	{
		SQLiteDatabase db = this.getReadableDatabase();
		String selectQuery = "DELETE FROM " + TABLE_CLUBS ;
		
		Log.e(LOG, selectQuery);
		db.execSQL(selectQuery);
		db.close();
	}
	
	public void deleteCityTable()
	{
		SQLiteDatabase db = this.getReadableDatabase();
		String selectQuery = "DELETE FROM " + TABLE_CITIES ;
		
		Log.e(LOG, selectQuery);
		db.execSQL(selectQuery);
		db.close();
	}
	
	public List<CitiesTable> getAllCities() {
		SQLiteDatabase db = this.getReadableDatabase();
		List<CitiesTable> cities = new ArrayList<CitiesTable>();
		String selectQuery = "SELECT  * FROM " + TABLE_CITIES;
		Log.e(LOG, selectQuery);
		Cursor c = db.rawQuery(selectQuery, null);
		if (c.moveToFirst()) {
			do {
				CitiesTable citiesTable = new CitiesTable();
				citiesTable.setName((c.getString(c.getColumnIndex(KEY_NAME))));
				citiesTable.setCity((c.getString(c.getColumnIndex(KEY_CITY))));
				cities.add(citiesTable);
			} while (c.moveToNext());
		}

		c.close();
		db.close();
		return cities;
	}

	public List<String> getAllDates() {
		SQLiteDatabase db = this.getReadableDatabase();
		List<String> dates = new ArrayList<String>();
		String selectQuery = "SELECT  * FROM " + TABLE_DATES;
		Log.e(LOG, selectQuery);
		Cursor c = db.rawQuery(selectQuery, null);
		if (c.moveToFirst()) {
			do {
				dates.add(c.getString(c.getColumnIndex(KEY_DATES)));
			} while (c.moveToNext());
		}

		c.close();
		db.close();
		return dates;
	}
	
	public List<CityClubsTable> getAllClubs() {
		SQLiteDatabase db = this.getReadableDatabase();
		List<CityClubsTable> clubs = new ArrayList<CityClubsTable>();
		String selectQuery = "SELECT  * FROM " + TABLE_CLUBS;
		Log.e(LOG, selectQuery);
		Cursor c = db.rawQuery(selectQuery, null);
		if (c.moveToFirst()) {
			do {
				CityClubsTable cityClubs = new CityClubsTable();
				cityClubs.setObjectId((c.getString(c.getColumnIndex(KEY_OBJECTID))));
				cityClubs.setAddress((c.getString(c.getColumnIndex(KEY_ADDRESS))));
				cityClubs.setLatitude((c.getDouble(c.getColumnIndex(KEY_LATITUDE))));
				cityClubs.setLongitude((c.getDouble(c.getColumnIndex(KEY_LONGITUDE))));
				cityClubs.setCity((c.getString(c.getColumnIndex(KEY_CITYNAME))));
				cityClubs.setCountry((c.getString(c.getColumnIndex(KEY_COUNTRY))));
				cityClubs.setFblink((c.getString(c.getColumnIndex(KEY_FBLINK))));
				cityClubs.setKindofplace((c.getString(c.getColumnIndex(KEY_KINDOFPLACE))));
				cityClubs.setName((c.getString(c.getColumnIndex(KEY_CLUBNAME))));
				cityClubs.setHost((c.getString(c.getColumnIndex(KEY_HOST))));
				cityClubs.setPhoneNumber((c.getString(c.getColumnIndex(KEY_PHONENUMBER))));
				cityClubs.setRating((c.getString(c.getColumnIndex(KEY_RATING))));
				cityClubs.setStreet((c.getString(c.getColumnIndex(KEY_STREET))));
				cityClubs.setUrl((c.getString(c.getColumnIndex(KEY_URL))));
				cityClubs.setAddress((c.getString(c.getColumnIndex(KEY_ADDRESS))));
				cityClubs.setZip((c.getString(c.getColumnIndex(KEY_ZIP))));
				cityClubs.setThumbnail((c.getString(c.getColumnIndex(KEY_THUMBNAIL))));
				cityClubs.setBanner(c.getString(c.getColumnIndex(KEY_BANNER)));
				
				clubs.add(cityClubs);
			} while (c.moveToNext());
		}
		c.close();
		db.close();
		return clubs;
	}

	public CityClubsTable getClubByHost(String host) {
		SQLiteDatabase db = this.getReadableDatabase();
		CityClubsTable cityClubs = new CityClubsTable();
		String selectQuery = "SELECT * FROM " + TABLE_CLUBS + " WHERE " + KEY_HOST + "='" + host +"'";
//		String selectQuery = "SELECT * FROM " + TABLE_CLUBS + " WHERE " + KEY_HOST + "='Kesselhaus'";
		Log.e(LOG, selectQuery);
		Cursor c = db.rawQuery(selectQuery, null);
//		int x= c.getCount();
		
		if (c.moveToFirst()) { 
		
			cityClubs.setObjectId((c.getString(c.getColumnIndex(KEY_OBJECTID))));
			cityClubs.setAddress((c.getString(c.getColumnIndex(KEY_ADDRESS))));
			cityClubs.setLatitude((c.getInt(c.getColumnIndex(KEY_LATITUDE))));
			cityClubs.setLongitude((c.getInt(c.getColumnIndex(KEY_LONGITUDE))));
			cityClubs.setCity((c.getString(c.getColumnIndex(KEY_CITYNAME))));
			cityClubs.setCountry((c.getString(c.getColumnIndex(KEY_COUNTRY))));
			cityClubs.setFblink((c.getString(c.getColumnIndex(KEY_FBLINK))));
			cityClubs.setKindofplace((c.getString(c.getColumnIndex(KEY_KINDOFPLACE))));
			cityClubs.setName((c.getString(c.getColumnIndex(KEY_CLUBNAME))));
			cityClubs.setHost((c.getString(c.getColumnIndex(KEY_HOST))));
			cityClubs.setPhoneNumber((c.getString(c.getColumnIndex(KEY_PHONENUMBER))));
			cityClubs.setRating((c.getString(c.getColumnIndex(KEY_RATING))));
			cityClubs.setStreet((c.getString(c.getColumnIndex(KEY_STREET))));
			cityClubs.setUrl((c.getString(c.getColumnIndex(KEY_URL))));
			cityClubs.setAddress((c.getString(c.getColumnIndex(KEY_ADDRESS))));
			cityClubs.setZip((c.getString(c.getColumnIndex(KEY_ZIP))));
			cityClubs.setThumbnail((c.getString(c.getColumnIndex(KEY_THUMBNAIL))));
			cityClubs.setBanner(c.getString(c.getColumnIndex(KEY_BANNER)));
		}
		c.close();
		db.close();
		return cityClubs;
	}
	
	public void closeDB() {
		SQLiteDatabase db = this.getReadableDatabase();
		if (db != null && db.isOpen())
			db.close();
	}

	public void DropDataBase() {
		SQLiteDatabase db = this.getReadableDatabase();
		String dropCitiesTableQuery = "DROP TABLE " + TABLE_CITIES;
		String dropClubsTableQuery = "DROP TABLE " + TABLE_CLUBS;
		String dropEventsTableQuery = "DROP TABLE " + TABLE_EVENTS;
		String dropFavourEventsTableQuery = "DROP TABLE " + TABLE_FAVOUR_EVENTS;
		String dropDatesTableQuery = "DROP TABLE " + TABLE_DATES;
		db.rawQuery(dropCitiesTableQuery, null);
		db.rawQuery(dropClubsTableQuery, null);
		db.rawQuery(dropEventsTableQuery, null);
		db.rawQuery(dropFavourEventsTableQuery, null);
		db.rawQuery(dropDatesTableQuery, null);
		db.close();
	}
}
