package com.attendx.util;

import org.mindrot.jbcrypt.BCrypt;

public class PasswordUtil {

    private PasswordUtil() {}

    public static String hashPassword(String plainText) {
        return BCrypt.hashpw(plainText, BCrypt.gensalt(12));
    }

    public static boolean verifyPassword(String plainText, String hash) {
        if (plainText == null || hash == null) return false;
        return BCrypt.checkpw(plainText, hash);
    }
}
