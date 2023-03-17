package com.patetlex.vitalitas.database.util;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.util.List;

public class SiteHelper {
    public static String htmlFromSites(String path) {
        File file = new File("sites\\" + path);
        try {
            List<String> lines = Files.readAllLines(file.toPath());
            StringBuilder builder = new StringBuilder();
            for (String line : lines) {
                builder.append(line);
            }
            return builder.toString();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
}
