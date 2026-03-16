package com.attendx.model;

import java.sql.Timestamp;

public class Teacher {
    private int teacherId;
    private String name;
    private String email;
    private String phone;
    private String department;
    private String passwordHash;
    private boolean active;
    private String faceDescriptor;
    private Timestamp createdAt;

    public Teacher() {}

    public Teacher(String name, String email, String phone, String department, String passwordHash) {
        this.name = name;
        this.email = email;
        this.phone = phone;
        this.department = department;
        this.passwordHash = passwordHash;
    }

    public int getTeacherId()                   { return teacherId; }
    public void setTeacherId(int teacherId)     { this.teacherId = teacherId; }
    public String getName()                     { return name; }
    public void setName(String name)            { this.name = name; }
    public String getEmail()                    { return email; }
    public void setEmail(String email)          { this.email = email; }
    public String getPhone()                    { return phone; }
    public void setPhone(String phone)          { this.phone = phone; }
    public String getDepartment()               { return department; }
    public void setDepartment(String department){ this.department = department; }
    public String getPasswordHash()             { return passwordHash; }
    public void setPasswordHash(String h)       { this.passwordHash = h; }
    public boolean isActive()                   { return active; }
    public void setActive(boolean active)       { this.active = active; }
    public String getFaceDescriptor()           { return faceDescriptor; }
    public void setFaceDescriptor(String fd)    { this.faceDescriptor = fd; }
    public Timestamp getCreatedAt()             { return createdAt; }
    public void setCreatedAt(Timestamp t)       { this.createdAt = t; }
}
