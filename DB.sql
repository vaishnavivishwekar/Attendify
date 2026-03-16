-- ============================================================
--  AttendX – QR Code Teacher Attendance Management System
--  Database Schema
-- ============================================================

CREATE DATABASE IF NOT EXISTS attendx CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE attendx;

-- Admin accounts
CREATE TABLE IF NOT EXISTS admin (
    id           INT PRIMARY KEY AUTO_INCREMENT,
    username     VARCHAR(50)  NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- School-wide settings (single row)
CREATE TABLE IF NOT EXISTS settings (
    id              INT PRIMARY KEY AUTO_INCREMENT,
    school_name     VARCHAR(200) DEFAULT 'My School',
    school_lat      DECIMAL(10,8) DEFAULT 0.0,
    school_long     DECIMAL(11,8) DEFAULT 0.0,
    allowed_radius  INT          DEFAULT 100,
    morning_in_time TIME         DEFAULT '07:30:00',
    lunch_time      TIME         DEFAULT '12:00:00',
    out_time        TIME         DEFAULT '16:30:00'
);

-- Teachers
CREATE TABLE IF NOT EXISTS teachers (
    teacher_id    INT PRIMARY KEY AUTO_INCREMENT,
    name          VARCHAR(100)  NOT NULL,
    email         VARCHAR(150)  NOT NULL UNIQUE,
    phone         VARCHAR(20),
    department    VARCHAR(100),
    password_hash VARCHAR(255)  NOT NULL,
    is_active     TINYINT(1)   DEFAULT 1,
    created_at    TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);

-- Registration tokens (for teacher-registration QR)
CREATE TABLE IF NOT EXISTS reg_tokens (
    id         INT PRIMARY KEY AUTO_INCREMENT,
    token      VARCHAR(255) NOT NULL UNIQUE,
    is_active  TINYINT(1)  DEFAULT 1,
    created_at TIMESTAMP   DEFAULT CURRENT_TIMESTAMP
);

-- Daily QR sessions (for attendance QR)
CREATE TABLE IF NOT EXISTS qr_sessions (
    id           INT PRIMARY KEY AUTO_INCREMENT,
    token        VARCHAR(255)  NOT NULL UNIQUE,
    session_date DATE          NOT NULL,
    in_time      TIME,
    lunch_time   TIME,
    out_time     TIME,
    school_lat   DECIMAL(10,8),
    school_long  DECIMAL(11,8),
    is_active    TINYINT(1)   DEFAULT 1,
    created_at   TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);

-- Attendance records
CREATE TABLE IF NOT EXISTS attendance (
    id              INT PRIMARY KEY AUTO_INCREMENT,
    teacher_id      INT          NOT NULL,
    attendance_date DATE         NOT NULL,
    in_time         DATETIME,
    out_time        DATETIME,
    location_lat    DECIMAL(10,8),
    location_long   DECIMAL(11,8),
    status          ENUM('PRESENT','ABSENT','HALF_DAY') DEFAULT 'PRESENT',
    remarks         VARCHAR(255),
    FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id) ON DELETE CASCADE,
    UNIQUE KEY uk_teacher_date (teacher_id, attendance_date)
);

ALTER TABLE teachers    MODIFY is_active BOOLEAN DEFAULT TRUE;
ALTER TABLE reg_tokens  MODIFY is_active BOOLEAN DEFAULT TRUE;
ALTER TABLE qr_sessions MODIFY is_active BOOLEAN DEFAULT TRUE;


ALTER TABLE teachers
ADD COLUMN face_descriptor MEDIUMTEXT NULL AFTER password_hash;

SELECT COUNT(*) AS col_exists
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'teachers'
  AND COLUMN_NAME = 'face_descriptor';
  
  USE attendx;
SELECT teacher_id, name, email, is_active
FROM teachers
WHERE LOWER(email) = LOWER('your_email_here');

USE attendx;
SELECT teacher_id, name, email, is_active, created_at
FROM teachers
ORDER BY teacher_id DESC
LIMIT 5;