package com.patetlex.vitalitas.database;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.patetlex.vitalitas.database.mayoclinic.DataEntry;
import com.patetlex.vitalitas.database.mayoclinic.ScrapeableSitemap;
import com.patetlex.vitalitas.database.mayoclinic.openai.TrainingEntry;
import com.patetlex.vitalitas.database.mayoclinic.sitemap.Conditions;
import com.patetlex.vitalitas.database.mayoclinic.sitemap.Drugs;

import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.List;
import java.util.function.Consumer;

public class Main {
    private static final Gson gson = new Gson();
    private static final Gson pretty = new GsonBuilder().setPrettyPrinting().create();

    public static void main(String[] args) throws IOException {
        File buildFolder = new File("build\\");
        buildFolder.mkdir();
        buildFolder.createNewFile();

        List<TrainingEntry> allEntries = new ArrayList<>();
        Consumer<List<TrainingEntry>> addingConsumer = new Consumer<List<TrainingEntry>>() {
            @Override
            public void accept(List<TrainingEntry> entries) {
                allEntries.addAll(entries);
            }
        };

/*        String json = Files.readString(new File(buildFolder.getAbsolutePath() + "\\drugs\\data.json").toPath());
        for (DataEntry entry : new Drugs().fromJson(json)) {
            allEntries.addAll(entry.buildTrainingEntries());
        }*/

        String log = "";
        log = log + buildFiles("drugs", new Drugs(), addingConsumer);
        log = log + buildFiles("conditions", new Conditions(), addingConsumer);


        System.out.println("Building training and log files.");
        File trainingData = new File(buildFolder.getAbsolutePath() + "\\training_data.json");
        if (trainingData.exists())
            trainingData.delete();
        trainingData.createNewFile();
        FileWriter writer = new FileWriter(trainingData);
        writer.write(gson.toJson(allEntries));
        writer.flush();
        writer.close();

        File logFile = new File(buildFolder.getAbsolutePath() + "\\log.txt");
        if (logFile.exists())
            logFile.delete();
        logFile.createNewFile();
        FileWriter writer1 = new FileWriter(logFile);
        writer1.write(log);
        writer1.flush();
        writer1.close();
    }

    public static String buildFiles(String fileName, ScrapeableSitemap sitemap, Consumer<List<TrainingEntry>> trainingEntryConsumer) throws IOException {
        File outFolder = new File("build\\" + fileName);
        outFolder.mkdir();
        outFolder.createNewFile();
        File data = new File(outFolder.getAbsolutePath() + "\\data.json");
        if (data.exists())
            data.delete();
        data.createNewFile();
        sitemap.scrapeSitemap(new Consumer<List<DataEntry>>() {
            @Override
            public void accept(List<DataEntry> dataEntries) {
                String json = pretty.toJson(dataEntries);
                try {
                    FileWriter writer = new FileWriter(data);
                    writer.write(json);
                    writer.flush();
                    writer.close();
                } catch (IOException e) {
                    throw new RuntimeException(e);
                }
            }
        }, trainingEntryConsumer);
        return sitemap.getLog();
    }
}
