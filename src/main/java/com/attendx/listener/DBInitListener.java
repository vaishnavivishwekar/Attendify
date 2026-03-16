package com.attendx.listener;

import com.attendx.dao.AdminDAO;
import com.attendx.dao.SettingsDAO;
import com.attendx.model.Settings;
import com.attendx.util.DBConnection;
import com.attendx.util.PasswordUtil;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import java.sql.Connection;
import java.sql.Statement;
import java.sql.Time;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebListener
public class DBInitListener implements ServletContextListener {

    private static final Logger LOG = Logger.getLogger(DBInitListener.class.getName());

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        try {
            createTablesIfNeeded();
            createDefaultAdminIfAbsent();
            createDefaultSettingsIfAbsent();
            LOG.info("AttendX: database initialisation complete.");
        } catch (Exception e) {
            LOG.log(Level.SEVERE, "AttendX: database initialisation failed", e);
        }
    }

    private void createTablesIfNeeded() throws Exception {
        String[] ddl = {
            "CREATE TABLE IF NOT EXISTS admin ("
                + "id INT PRIMARY KEY AUTO_INCREMENT,"
                + "username VARCHAR(50) NOT NULL UNIQUE,"
                + "password_hash VARCHAR(255) NOT NULL,"
                + "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)",

            "CREATE TABLE IF NOT EXISTS settings ("
                + "id INT PRIMARY KEY AUTO_INCREMENT,"
                + "school_name VARCHAR(200) DEFAULT 'My School',"
                + "school_lat DECIMAL(10,8) DEFAULT 0.0,"
                + "school_long DECIMAL(11,8) DEFAULT 0.0,"
                + "allowed_radius INT DEFAULT 100,"
                + "morning_in_time TIME DEFAULT '07:30:00',"
                + "lunch_time TIME DEFAULT '12:00:00',"
                + "out_time TIME DEFAULT '16:30:00')",

            "CREATE TABLE IF NOT EXISTS teachers ("
                + "teacher_id INT PRIMARY KEY AUTO_INCREMENT,"
                + "name VARCHAR(100) NOT NULL,"
                + "email VARCHAR(150) NOT NULL UNIQUE,"
                + "phone VARCHAR(20),"
                + "department VARCHAR(100),"
                + "password_hash VARCHAR(255) NOT NULL,"
                + "face_descriptor MEDIUMTEXT NULL,"
                + "is_active BOOLEAN DEFAULT TRUE,"
                + "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)",

            "CREATE TABLE IF NOT EXISTS reg_tokens ("
                + "id INT PRIMARY KEY AUTO_INCREMENT,"
                + "token VARCHAR(255) NOT NULL UNIQUE,"
                + "is_active BOOLEAN DEFAULT TRUE,"
                + "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)",

            "CREATE TABLE IF NOT EXISTS qr_sessions ("
                + "id INT PRIMARY KEY AUTO_INCREMENT,"
                + "token VARCHAR(255) NOT NULL UNIQUE,"
                + "session_date DATE NOT NULL,"
                + "in_time TIME,"
                + "lunch_time TIME,"
                + "out_time TIME,"
                + "school_lat DECIMAL(10,8),"
                + "school_long DECIMAL(11,8),"
                + "is_active BOOLEAN DEFAULT TRUE,"
                + "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)",

            "CREATE TABLE IF NOT EXISTS attendance ("
                + "id INT PRIMARY KEY AUTO_INCREMENT,"
                + "teacher_id INT NOT NULL,"
                + "attendance_date DATE NOT NULL,"
                + "in_time DATETIME,"
                + "out_time DATETIME,"
                + "location_lat DECIMAL(10,8),"
                + "location_long DECIMAL(11,8),"
                + "status ENUM('PRESENT','ABSENT','HALF_DAY') DEFAULT 'PRESENT',"
                + "remarks VARCHAR(255),"
                + "UNIQUE KEY uk_teacher_date (teacher_id, attendance_date),"
                + "FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id) ON DELETE CASCADE)"
        };

        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement()) {
            for (String sql : ddl) {
                st.execute(sql);
            }
        }
    }

    private void createDefaultAdminIfAbsent() throws Exception {
        AdminDAO dao = new AdminDAO();
        if (!dao.exists()) {
            String hash = PasswordUtil.hashPassword("Admin@123");
            dao.create("admin", hash);
            LOG.info("AttendX: default admin created  (username: admin, password: Admin@123) — change this after first login.");
        }
    }

    private void createDefaultSettingsIfAbsent() throws Exception {
        SettingsDAO dao = new SettingsDAO();
        if (dao.get() == null) {
            Settings s = new Settings();
            s.setSchoolName("My School");
            s.setSchoolLat(0.0);
            s.setSchoolLong(0.0);
            s.setAllowedRadius(100);
            s.setMorningInTime(Time.valueOf("07:30:00"));
            s.setLunchTime(Time.valueOf("12:00:00"));
            s.setOutTime(Time.valueOf("16:30:00"));
            dao.save(s);
        }
    }
}
