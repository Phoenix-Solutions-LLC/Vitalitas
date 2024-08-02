package com.patetlex.vitalitas.database;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.patetlex.vitalitas.database.scrape.DataEntry;
import com.patetlex.vitalitas.database.scrape.ScrapeableSitemap;
import com.patetlex.vitalitas.database.scrape.openai.TrainingEntry;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.net.URL;
import java.nio.file.Files;
import java.util.*;
import java.util.function.Consumer;

public class DatabaseBuilder {
    private static final Gson gson = new Gson();
    private static final Gson pretty = new GsonBuilder().setPrettyPrinting().create();
    private List<TrainingEntry> trainingData = new ArrayList<>();
    private Map<ScrapeableSitemap, List<DataEntry>> data = new HashMap<>();
    private String log = "";

    public DatabaseBuilder crop(int start, ScrapeableSitemap map) {
        List<DataEntry> subEntry = new ArrayList<>();
        for (int i = start; i < this.data.get(map).size(); i++) {
            DataEntry entry = this.data.get(map).get(i);
            subEntry.add(entry);
        }
        this.data.remove(map);
        this.data.put(map, subEntry);

        this.trainingData.clear();
        for (ScrapeableSitemap map0 : this.data.keySet()) {
            for (DataEntry entry : this.data.get(map0)) {
                this.trainingData.addAll(entry.buildTrainingEntries());
            }
        }
        return this;
    }
    public DatabaseBuilder crop(int start, int end, ScrapeableSitemap map) {
        List<DataEntry> subEntry = new ArrayList<>();
        for (int i = start; i < end; i++) {
            if (i < this.data.get(map).size()) {
                DataEntry entry = this.data.get(map).get(i);
                subEntry.add(entry);
            }
        }
        this.data.remove(map);
        this.data.put(map, subEntry);

        this.trainingData.clear();
        for (ScrapeableSitemap map0 : this.data.keySet()) {
            for (DataEntry entry : this.data.get(map0)) {
                this.trainingData.addAll(entry.buildTrainingEntries());
            }
        }
        return this;
    }

    public DatabaseBuilder addTrainingData(TrainingEntry entry) {
        this.trainingData.add(entry);
        return this;
    }

    public DatabaseBuilder scrapeSitemap(ScrapeableSitemap sitemap) {
        sitemap.scrapeSitemap(new Consumer<List<DataEntry>>() {
            @Override
            public void accept(List<DataEntry> dataEntries) {
                DatabaseBuilder.this.data.put(sitemap, dataEntries);
            }
        }, new Consumer<List<TrainingEntry>>() {
            @Override
            public void accept(List<TrainingEntry> entries) {
                DatabaseBuilder.this.trainingData.addAll(entries);
            }
        });
        this.log = this.log + "\n" + sitemap.getLog();
        return this;
    }

    public DatabaseBuilder scrapeJson(ScrapeableSitemap sitemap, String json) {
        List<DataEntry> data = sitemap.fromJson(json);
        int prevSize = data.size();
        Iterator<DataEntry> iterator = data.iterator();
        List<String> ids = new ArrayList<>();
        while (iterator.hasNext()) {
            DataEntry entry = iterator.next();
            if (!ids.contains(entry.toString())) {
                ids.add(entry.toString());
                this.trainingData.addAll(entry.buildTrainingEntries());
            } else {
                iterator.remove();
                System.out.println("Removed duplicate for " + entry.toString() + ".");
            }
        }
        System.out.println("Removed " + (prevSize - ids.size()) + " duplicates.");
        this.data.put(sitemap, data);
        return this;
    }

    public DatabaseBuilder fromApi(ScrapeableSitemap preBuild) {
        try {
            Scanner scanner = new Scanner(new URL("https://www.phoenixsolve.com/webapps/vitalitas/api/" + preBuild.getName() + "/data.json").openStream());
            StringBuffer buffer = new StringBuffer();
            while (scanner.hasNext()) {
                buffer.append(scanner.next() + " ");
            }
            String json = buffer.toString();
            scrapeJson(preBuild, json);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        return this;
    }

    public DatabaseBuilder fromBuild(ScrapeableSitemap preBuild) {
        File data = new File("build\\" + preBuild.getName() + "\\data.json");
        try {
            String json = "";
            for (String line : Files.readAllLines(data.toPath())) {
                json = json + line;
            }
            scrapeJson(preBuild, json);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        return this;
    }

    public Map<ScrapeableSitemap, List<DataEntry>> getData() {
        return data;
    }

    /**
     *
     * @return int Estimated number of tokens.
     */
    public int build() {
        File buildFolder = new File("build\\");
        buildFolder.mkdir();
        try {
            buildFolder.createNewFile();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }

        for (ScrapeableSitemap sitemap : this.data.keySet()) {
            File outFolder = new File("build\\" + sitemap.getName());
            outFolder.mkdir();
            try {
                outFolder.createNewFile();
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
            File data = new File(outFolder.getAbsolutePath() + "\\data.json");
            if (data.exists())
                data.delete();
            try {
                data.createNewFile();
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
            String json = pretty.toJson(this.data.get(sitemap));
            try {
                FileWriter writer = new FileWriter(data);
                writer.write(json);
                writer.flush();
                writer.close();
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        }

        System.out.println("Building training and log files.");
        File trainingData = new File(buildFolder.getAbsolutePath() + "\\training_data.json");
        if (trainingData.exists())
            trainingData.delete();
        try {
            trainingData.createNewFile();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        String trainingJson = gson.toJson(this.trainingData);
        try {
            FileWriter writer = new FileWriter(trainingData);
            writer.write(trainingJson);
            writer.flush();
            writer.close();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }

        File logFile = new File(buildFolder.getAbsolutePath() + "\\log.txt");
        if (logFile.exists())
            logFile.delete();
        try {
            logFile.createNewFile();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        try {
            FileWriter writer1 = new FileWriter(logFile);
            writer1.write(log);
            writer1.flush();
            writer1.close();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }

        // Token Estimation
        String complete = trainingJson.replace("prompt", "").replace("completion", "");
        float charCount = complete.length() / 4F;
        float wordCount = complete.split(" ").length / 0.75F;
        return Math.round((charCount + wordCount) / 2F);
    }
}
