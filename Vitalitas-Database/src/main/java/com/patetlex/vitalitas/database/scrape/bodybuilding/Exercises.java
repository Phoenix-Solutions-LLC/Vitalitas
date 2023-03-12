package com.patetlex.vitalitas.database.scrape.bodybuilding;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.patetlex.vitalitas.database.scrape.DataEntry;
import com.patetlex.vitalitas.database.scrape.ScrapeableSitemap;
import com.patetlex.vitalitas.database.scrape.mayoclinic.Conditions;
import com.patetlex.vitalitas.database.scrape.openai.TrainingEntry;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

import java.io.IOException;
import java.util.*;
import java.util.function.Consumer;

public class Exercises extends ScrapeableSitemap {

    public Exercises() {
        super("exercises", "");
    }

    @Override
    public void scrapeSitemap(Consumer<List<DataEntry>> dataEntryConsumer, Consumer<List<TrainingEntry>> trainingEntryConsumer) {
        String[] muscleGroups = {"chest", "forearms", "lats", "middle-back", "lower-back", "neck", "quadriceps", "hamstrings", "calves", "triceps", "traps", "shoulders", "abdominals", "glutes", "biceps", "adductors", "abductors"};
        String[] exerciseTypes = {"cardio", "plyometrics", "strength", "stretching"};

        List<String> exclusions = new ArrayList<>();
        exclusions.add("swimming");

        List<DataEntry> data = new ArrayList<>();
        List<TrainingEntry> trainingData = new ArrayList<>();
        for (int i = 0; i < muscleGroups.length; i++) {
            trainingData.add(new TrainingEntry("Increase " + muscleGroups[i] + " exercises in my routine.", "${USER_PREFER_EXERCISE_GROUP-\"" + muscleGroups[i] + "\"}"));
            trainingData.add(new TrainingEntry("Remove " + muscleGroups[i] + " exercises from my routine.", "${USER_BLACKLIST_EXERCISE_GROUP-\"" + muscleGroups[i] + "\"}"));
            for (int j = 0; j < exerciseTypes.length; j++) {
                int k = 0;
                while (k >= 0 && k < 20) {
                    k++;
                    try {
                        Document doc = Jsoup.connect("https://www.bodybuilding.com/exercises/finder/" + k + "?exercise-type=" + exerciseTypes[j] + "&muscle=" + muscleGroups[i]).timeout(0).get();
                        Elements cards = doc.getElementsByClass("ExResult-cell ExResult-cell--nameEtc");
                        for (int x = 0; x < cards.size(); x++) {
                            ExerciseEntry entry = new ExerciseEntry();
                            Element card = cards.get(x);
                            Element header = card.getElementsByClass("ExHeading ExResult-resultsHeading").get(0);

                            String[] ind = header.children().get(0).text().trim().split(" ");

                            entry.name = "";
                            for (int y = 0; y < ind.length; y++) {
                                entry.name = entry.name + (ind[y].substring(0, 1).toUpperCase() + ind[y].substring(1)) + " ";
                            }
                            entry.id = header.children().get(0).attributes().get("href").replace("/exercises/", "");
                            entry.muscleGroup = muscleGroups[i];
                            entry.exerciseType = exerciseTypes[j];
                            entry.equipmentType = card.getElementsByClass("ExResult-details ExResult-equipmentType").get(0).children().get(0).text();

                            String rating = card.nextElementSibling().getElementsByClass("ExRating").get(0).getElementsByClass("ExRating-badge").get(0).text();
                            if (rating.equalsIgnoreCase( "n/a") && !exclusions.contains(entry.id)) {
                                k = -1;
                                continue;
                            }
                            data.add(entry);
                            System.out.println("Successfully scraped " + Objects.toString(entry) + ". K = " + k + ". MG = " + muscleGroups[i] + ". ET = " + exerciseTypes[j] + ".");
                        }
                    } catch (IOException e) {
                        throw new RuntimeException(e);
                    }
                }
            }
        }
        System.out.println("Finished scraping sitemap.");
        dataEntryConsumer.accept(data);
        this.addTrainingData(trainingData);
        List<String> ids = new ArrayList<>();
        Iterator<DataEntry> iterator = data.iterator();
        while (iterator.hasNext()) {
            DataEntry entry = iterator.next();
            if (!ids.contains(entry.toString())) {
                ids.add(entry.toString());
                trainingData.addAll(entry.buildTrainingEntries());
                System.out.println("Successfully built training data for " + Objects.toString(entry) + ".");
            } else {
                iterator.remove();
                System.out.println("Removed duplicate for " + entry.toString() + ".");
            }
        }
        trainingEntryConsumer.accept(trainingData);
    }

    @Override
    @Deprecated
    /**
     * Builds on single page. Use Exercises::scrapeSitemap(Consumer<List<DataEntry>>, Consumer<List<TrainingEntry>>) instead.
     */
    public DataEntry scrapeEntry(Document document) {
        return null;
    }

    @Override
    public List<DataEntry> fromJson(String json) {
        return gson.fromJson(json, new TypeToken<List<ExerciseEntry>>() {}.getType());
    }

    public static class ExerciseEntry extends DataEntry {

        public String name;
        public String id;
        public String muscleGroup;
        public String equipmentType;
        public String exerciseType;

        @Override
        public List<TrainingEntry> buildTrainingEntries() {
            List<TrainingEntry> trainingList = new ArrayList<>();
            trainingList.add(new TrainingEntry("Add " + this.name + " in my exercise routine.", "${USER_PREFER_EXERCISE-\"" + this.id + "\"}"));
            trainingList.add(new TrainingEntry("Remove " + this.name + " from my exercise routine.", "${USER_BLACKLIST_EXERCISE-\"" + this.id + "\"}"));
            return trainingList;
        }

        @Override
        public String toString() {
            return this.id;
        }
    }
}
