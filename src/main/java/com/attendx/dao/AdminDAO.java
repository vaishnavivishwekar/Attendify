package com.attendx.dao;

import com.attendx.util.DBConnection;

import java.sql.*;

public class AdminDAO {

    public boolean exists() throws SQLException {
        String sql = "SELECT COUNT(*) FROM admin";
        try (Connection c = DBConnection.getConnection();
             Statement st = c.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            return rs.next() && rs.getInt(1) > 0;
        }
    }

    public void create(String username, String passwordHash) throws SQLException {
        String sql = "INSERT INTO admin (username, password_hash) VALUES (?, ?)";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, passwordHash);
            ps.executeUpdate();
        }
    }

    /** Returns the stored password hash for the given username, or null if not found. */
    public String getPasswordHash(String username) throws SQLException {
        String sql = "SELECT password_hash FROM admin WHERE username = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getString("password_hash") : null;
            }
        }
    }
}
