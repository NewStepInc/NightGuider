package com.werner.nightguider.db;

public class CitiesTable {

	String name;
	String city;

	public CitiesTable() {

	}

	public CitiesTable(String name) {
		this.name = name;
	}

	public CitiesTable(String name, String city) {
		this.name = name;
		this.city = city;
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
}
