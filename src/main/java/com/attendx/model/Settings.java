package com.attendx.model;

import java.sql.Time;

public class Settings {
    private int id;
    private String schoolName;
    private double schoolLat;
    private double schoolLong;
    private int allowedRadius;
    private Time morningInTime;
    private Time lunchTime;
    private Time outTime;

    public Settings() {}

    public int getId()                          { return id; }
    public void setId(int id)                   { this.id = id; }
    public String getSchoolName()               { return schoolName; }
    public void setSchoolName(String s)         { this.schoolName = s; }
    public double getSchoolLat()                { return schoolLat; }
    public void setSchoolLat(double lat)        { this.schoolLat = lat; }
    public double getSchoolLong()               { return schoolLong; }
    public void setSchoolLong(double lon)       { this.schoolLong = lon; }
    public int getAllowedRadius()               { return allowedRadius; }
    public void setAllowedRadius(int r)        { this.allowedRadius = r; }
    public Time getMorningInTime()             { return morningInTime; }
    public void setMorningInTime(Time t)       { this.morningInTime = t; }
    public Time getLunchTime()                 { return lunchTime; }
    public void setLunchTime(Time t)           { this.lunchTime = t; }
    public Time getOutTime()                   { return outTime; }
    public void setOutTime(Time t)             { this.outTime = t; }
}
