package com.attendx.dao;

import com.attendx.model.QRSession;
import com.attendx.util.DBConnection;

import java.sql.*;

public class QRSessionDAO {

    private QRSession mapRow(ResultSet rs) throws SQLException {
        QRSession s = new QRSession();
        s.setId(rs.getInt("id"));
        s.setToken(rs.getString("token"));
        s.setSessionDate(rs.getDate("session_date"));
        s.setInTime(rs.getTime("in_time"));
        s.setLunchTime(rs.getTime("lunch_time"));
        s.setOutTime(rs.getTime("out_time"));

        double lat = rs.getDouble("school_lat");
        if (!rs.wasNull()) s.setSchoolLat(lat);
        double lon = rs.getDouble("school_long");
        if (!rs.wasNull()) s.setSchoolLong(lon);

        s.setActive(rs.getBoolean("is_active"));
        s.setCreatedAt(rs.getTimestamp("created_at"));
        return s;
    }

    public void create(QRSession session) throws SQLException {
        String sql = "INSERT INTO qr_sessions (token, session_date, in_time, lunch_time, out_time, school_lat, school_long) "
                + "VALUES (?,?,?,?,?,?,?)";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, session.getToken());
            ps.setDate(2, session.getSessionDate());
            ps.setTime(3, session.getInTime());
            ps.setTime(4, session.getLunchTime());
            ps.setTime(5, session.getOutTime());
            if (session.getSchoolLat() != null) ps.setDouble(6, session.getSchoolLat());
            else ps.setNull(6, Types.DECIMAL);
            if (session.getSchoolLong() != null) ps.setDouble(7, session.getSchoolLong());
            else ps.setNull(7, Types.DECIMAL);
            ps.executeUpdate();
        }
    }

    public QRSession findByToken(String token) throws SQLException {
        String sql = "SELECT * FROM qr_sessions WHERE token = ? AND is_active = 1";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, token);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        }
    }

    public QRSession findLatestActive() throws SQLException {
        String sql = "SELECT * FROM qr_sessions WHERE is_active = 1 ORDER BY created_at DESC LIMIT 1";
        try (Connection c = DBConnection.getConnection();
             Statement st = c.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            return rs.next() ? mapRow(rs) : null;
        }
    }

    /** Deactivates all previous QR sessions before creating a new one. */
    public void deactivateAll() throws SQLException {
        String sql = "UPDATE qr_sessions SET is_active = 0";
        try (Connection c = DBConnection.getConnection();
             Statement st = c.createStatement()) {
            st.executeUpdate(sql);
        }
    }
}
