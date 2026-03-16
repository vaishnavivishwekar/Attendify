package com.attendx.dao;

import com.attendx.model.Settings;
import com.attendx.util.DBConnection;

import java.sql.*;

public class SettingsDAO {

    private Settings mapRow(ResultSet rs) throws SQLException {
        Settings s = new Settings();
        s.setId(rs.getInt("id"));
        s.setSchoolName(rs.getString("school_name"));
        s.setSchoolLat(rs.getDouble("school_lat"));
        s.setSchoolLong(rs.getDouble("school_long"));
        s.setAllowedRadius(rs.getInt("allowed_radius"));
        s.setMorningInTime(rs.getTime("morning_in_time"));
        s.setLunchTime(rs.getTime("lunch_time"));
        s.setOutTime(rs.getTime("out_time"));
        return s;
    }

    public Settings get() throws SQLException {
        String sql = "SELECT * FROM settings LIMIT 1";
        try (Connection c = DBConnection.getConnection();
             Statement st = c.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            return rs.next() ? mapRow(rs) : null;
        }
    }

    public void save(Settings s) throws SQLException {
        if (s.getId() == 0) {
            String sql = "INSERT INTO settings (school_name, school_lat, school_long, allowed_radius, "
                    + "morning_in_time, lunch_time, out_time) VALUES (?,?,?,?,?,?,?)";
            try (Connection c = DBConnection.getConnection();
                 PreparedStatement ps = c.prepareStatement(sql)) {
                setParams(ps, s);
                ps.executeUpdate();
            }
        } else {
            String sql = "UPDATE settings SET school_name=?, school_lat=?, school_long=?, allowed_radius=?, "
                    + "morning_in_time=?, lunch_time=?, out_time=? WHERE id=?";
            try (Connection c = DBConnection.getConnection();
                 PreparedStatement ps = c.prepareStatement(sql)) {
                setParams(ps, s);
                ps.setInt(8, s.getId());
                ps.executeUpdate();
            }
        }
    }

    private void setParams(PreparedStatement ps, Settings s) throws SQLException {
        ps.setString(1, s.getSchoolName());
        ps.setDouble(2, s.getSchoolLat());
        ps.setDouble(3, s.getSchoolLong());
        ps.setInt(4, s.getAllowedRadius());
        ps.setTime(5, s.getMorningInTime());
        ps.setTime(6, s.getLunchTime());
        ps.setTime(7, s.getOutTime());
    }
}
