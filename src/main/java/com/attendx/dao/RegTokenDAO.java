package com.attendx.dao;

import com.attendx.util.DBConnection;

import java.sql.*;

public class RegTokenDAO {

    public void create(String token) throws SQLException {
        String sql = "INSERT INTO reg_tokens (token) VALUES (?)";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, token);
            ps.executeUpdate();
        }
    }

    public boolean isValid(String token) throws SQLException {
        String sql = "SELECT COUNT(*) FROM reg_tokens WHERE token = ? AND is_active = 1";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, token);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    /** Deactivates all previous registration tokens. */
    public void deactivateAll() throws SQLException {
        String sql = "UPDATE reg_tokens SET is_active = 0";
        try (Connection c = DBConnection.getConnection();
             Statement st = c.createStatement()) {
            st.executeUpdate(sql);
        }
    }
}
