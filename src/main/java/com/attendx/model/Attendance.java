package com.attendx.model;

import java.sql.Date;
import java.sql.Timestamp;

public class Attendance {
    private int id;
    private int teacherId;
    private String teacherName;
    private String teacherDepartment;
    private Date attendanceDate;
    private Timestamp inTime;
    private Timestamp outTime;
    private Double locationLat;
    private Double locationLong;
    private String status;
    private String remarks;

    public Attendance() {}

    // Duration in minutes (null-safe)
    public long getDurationMinutes() {
        if (inTime == null || outTime == null) return 0;
        return (outTime.getTime() - inTime.getTime()) / 60000;
    }

    public int getId()                              { return id; }
    public void setId(int id)                       { this.id = id; }
    public int getTeacherId()                       { return teacherId; }
    public void setTeacherId(int teacherId)         { this.teacherId = teacherId; }
    public String getTeacherName()                  { return teacherName; }
    public void setTeacherName(String teacherName)  { this.teacherName = teacherName; }
    public String getTeacherDepartment()            { return teacherDepartment; }
    public void setTeacherDepartment(String d)      { this.teacherDepartment = d; }
    public Date getAttendanceDate()                 { return attendanceDate; }
    public void setAttendanceDate(Date d)           { this.attendanceDate = d; }
    public Timestamp getInTime()                    { return inTime; }
    public void setInTime(Timestamp inTime)         { this.inTime = inTime; }
    public Timestamp getOutTime()                   { return outTime; }
    public void setOutTime(Timestamp outTime)       { this.outTime = outTime; }
    public Double getLocationLat()                  { return locationLat; }
    public void setLocationLat(Double locationLat)  { this.locationLat = locationLat; }
    public Double getLocationLong()                 { return locationLong; }
    public void setLocationLong(Double locationLong){ this.locationLong = locationLong; }
    public String getStatus()                       { return status; }
    public void setStatus(String status)            { this.status = status; }
    public String getRemarks()                      { return remarks; }
    public void setRemarks(String remarks)          { this.remarks = remarks; }
}
