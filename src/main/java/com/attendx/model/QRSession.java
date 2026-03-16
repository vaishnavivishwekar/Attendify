package com.attendx.model;

import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;

public class QRSession {
    private int id;
    private String token;
    private Date sessionDate;
    private Time inTime;
    private Time lunchTime;
    private Time outTime;
    private Double schoolLat;
    private Double schoolLong;
    private boolean active;
    private Timestamp createdAt;

    public QRSession() {}

    public int getId()                      { return id; }
    public void setId(int id)               { this.id = id; }
    public String getToken()                { return token; }
    public void setToken(String token)      { this.token = token; }
    public Date getSessionDate()            { return sessionDate; }
    public void setSessionDate(Date d)      { this.sessionDate = d; }
    public Time getInTime()                 { return inTime; }
    public void setInTime(Time inTime)      { this.inTime = inTime; }
    public Time getLunchTime()              { return lunchTime; }
    public void setLunchTime(Time lt)       { this.lunchTime = lt; }
    public Time getOutTime()                { return outTime; }
    public void setOutTime(Time outTime)    { this.outTime = outTime; }
    public Double getSchoolLat()            { return schoolLat; }
    public void setSchoolLat(Double lat)    { this.schoolLat = lat; }
    public Double getSchoolLong()           { return schoolLong; }
    public void setSchoolLong(Double lon)   { this.schoolLong = lon; }
    public boolean isActive()              { return active; }
    public void setActive(boolean active)  { this.active = active; }
    public Timestamp getCreatedAt()        { return createdAt; }
    public void setCreatedAt(Timestamp t)  { this.createdAt = t; }
}
