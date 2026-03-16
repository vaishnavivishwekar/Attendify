package com.attendx.dao;

import com.attendx.model.Attendance;
import com.attendx.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AttendanceDAO {

    private Attendance mapRow(ResultSet rs) throws SQLException {
        Attendance a = new Attendance();
        a.setId(rs.getInt("id"));
        a.setTeacherId(rs.getInt("teacher_id"));
        a.setAttendanceDate(rs.getDate("attendance_date"));
        a.setInTime(rs.getTimestamp("in_time"));
        a.setOutTime(rs.getTimestamp("out_time"));

        double lat = rs.getDouble("location_lat");
        if (!rs.wasNull()) a.setLocationLat(lat);
        double lon = rs.getDouble("location_long");
        if (!rs.wasNull()) a.setLocationLong(lon);

        a.setStatus(rs.getString("status"));
        a.setRemarks(rs.getString("remarks"));
        return a;
    }

    /** Creates an IN attendance record for today. */
    public void markIn(int teacherId, Date date, Timestamp inTime) throws SQLException {
        String sql = "INSERT INTO attendance (teacher_id, attendance_date, in_time, status) VALUES (?,?,?,'PRESENT')";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, teacherId);
            ps.setDate(2, date);
            ps.setTimestamp(3, inTime);
            ps.executeUpdate();
        }
    }

    /** Updates the OUT time and GPS location on an existing record. */
    public void markOut(int attendanceId, Timestamp outTime, double lat, double lon) throws SQLException {
        String sql = "UPDATE attendance SET out_time=?, location_lat=?, location_long=? WHERE id=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setTimestamp(1, outTime);
            ps.setDouble(2, lat);
            ps.setDouble(3, lon);
            ps.setInt(4, attendanceId);
            ps.executeUpdate();
        }
    }

    public Attendance findByTeacherAndDate(int teacherId, Date date) throws SQLException {
        String sql = "SELECT * FROM attendance WHERE teacher_id=? AND attendance_date=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, teacherId);
            ps.setDate(2, date);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        }
    }

    /** All records for a teacher, newest first. */
    public List<Attendance> findByTeacher(int teacherId) throws SQLException {
        String sql = "SELECT * FROM attendance WHERE teacher_id=? ORDER BY attendance_date DESC";
        List<Attendance> list = new ArrayList<>();
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, teacherId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    /**
     * Returns all attendance rows joined with teacher info for a given date
     * (used in admin reports). Includes teachers with no record (LEFT JOIN).
     */
    public List<Attendance> findByDateForAdmin(Date date) throws SQLException {
        String sql = "SELECT a.id, t.teacher_id, t.name AS tname, t.department AS tdept, "
                + "? AS attendance_date, a.in_time, a.out_time, a.location_lat, a.location_long, "
                + "COALESCE(a.status,'ABSENT') AS status, a.remarks "
                + "FROM teachers t "
                + "LEFT JOIN attendance a ON t.teacher_id = a.teacher_id AND a.attendance_date = ? "
                + "WHERE t.is_active = 1 ORDER BY t.name";
        List<Attendance> list = new ArrayList<>();
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setDate(1, date);
            ps.setDate(2, date);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Attendance a = mapRow(rs);
                    a.setTeacherName(rs.getString("tname"));
                    a.setTeacherDepartment(rs.getString("tdept"));
                    list.add(a);
                }
            }
        }
        return list;
    }

    /** Paginated report query with optional date range and teacher filter. */
    public List<Attendance> findForReport(Date from, Date to) throws SQLException {
        String sql = "SELECT a.*, t.name AS tname, t.department AS tdept "
                + "FROM attendance a JOIN teachers t ON a.teacher_id = t.teacher_id "
                + "WHERE a.attendance_date BETWEEN ? AND ? "
                + "ORDER BY a.attendance_date DESC, t.name";
        List<Attendance> list = new ArrayList<>();
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setDate(1, from);
            ps.setDate(2, to);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Attendance a = mapRow(rs);
                    a.setTeacherName(rs.getString("tname"));
                    a.setTeacherDepartment(rs.getString("tdept"));
                    list.add(a);
                }
            }
        }
        return list;
    }

    public int countByDateWithIn(Date date) throws SQLException {
        String sql = "SELECT COUNT(*) FROM attendance WHERE attendance_date=? AND in_time IS NOT NULL";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setDate(1, date);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    public int countByDateWithOut(Date date) throws SQLException {
        String sql = "SELECT COUNT(*) FROM attendance WHERE attendance_date=? AND out_time IS NOT NULL";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setDate(1, date);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }
}
