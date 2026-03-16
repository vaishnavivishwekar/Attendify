package com.attendx.dao;

import com.attendx.model.Teacher;
import com.attendx.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TeacherDAO {

    private Teacher mapRow(ResultSet rs) throws SQLException {
        Teacher t = new Teacher();
        t.setTeacherId(rs.getInt("teacher_id"));
        t.setName(rs.getString("name"));
        t.setEmail(rs.getString("email"));
        t.setPhone(rs.getString("phone"));
        t.setDepartment(rs.getString("department"));
        t.setPasswordHash(rs.getString("password_hash"));
        t.setFaceDescriptor(rs.getString("face_descriptor"));
        t.setActive(rs.getBoolean("is_active"));
        t.setCreatedAt(rs.getTimestamp("created_at"));
        return t;
    }

    public int create(Teacher t) throws SQLException {
        String sql = "INSERT INTO teachers (name, email, phone, department, password_hash, face_descriptor) VALUES (?,?,?,?,?,?)";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, t.getName());
            ps.setString(2, t.getEmail());
            ps.setString(3, t.getPhone());
            ps.setString(4, t.getDepartment());
            ps.setString(5, t.getPasswordHash());
            ps.setString(6, t.getFaceDescriptor());
            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    int id = rs.getInt(1);
                    t.setTeacherId(id);
                    return id;
                }
            }
            return 0;
        }
    }

    public Teacher findByEmail(String email) throws SQLException {
        String sql = "SELECT * FROM teachers WHERE LOWER(email) = LOWER(?) AND is_active = 1";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        }
    }

    public Teacher findById(int id) throws SQLException {
        String sql = "SELECT * FROM teachers WHERE teacher_id = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        }
    }

    public boolean emailExists(String email) throws SQLException {
        String sql = "SELECT COUNT(*) FROM teachers WHERE LOWER(email) = LOWER(?)";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    public List<Teacher> findAll() throws SQLException {
        String sql = "SELECT * FROM teachers WHERE is_active = 1 ORDER BY name";
        List<Teacher> list = new ArrayList<>();
        try (Connection c = DBConnection.getConnection();
             Statement st = c.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) list.add(mapRow(rs));
        }
        return list;
    }

    public int countActive() throws SQLException {
        String sql = "SELECT COUNT(*) FROM teachers WHERE is_active = 1";
        try (Connection c = DBConnection.getConnection();
             Statement st = c.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    public void updateFaceDescriptor(int teacherId, String descriptor) throws SQLException {
        String sql = "UPDATE teachers SET face_descriptor = ? WHERE teacher_id = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, descriptor);
            ps.setInt(2, teacherId);
            ps.executeUpdate();
        }
    }
}
