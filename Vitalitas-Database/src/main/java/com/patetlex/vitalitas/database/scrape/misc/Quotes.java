package com.patetlex.vitalitas.database.scrape.misc;

import com.google.gson.reflect.TypeToken;
import com.patetlex.vitalitas.database.scrape.DataEntry;
import com.patetlex.vitalitas.database.scrape.ScrapeableSitemap;
import com.patetlex.vitalitas.database.scrape.bodybuilding.Exercises;
import com.patetlex.vitalitas.database.scrape.openai.TrainingEntry;
import com.patetlex.vitalitas.database.util.SiteHelper;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

import java.io.IOException;
import java.util.*;
import java.util.function.Consumer;

public class Quotes extends ScrapeableSitemap {

    public Quotes() {
        super("quotes", "");
    }

    @Override
    public void scrapeSitemap(Consumer<List<DataEntry>> dataEntryConsumer, Consumer<List<TrainingEntry>> trainingEntryConsumer) {
        Document doc = Jsoup.parse(SiteHelper.htmlFromSites("quotes.html"));
        Elements elements = doc.getElementsByTag("em");

        List<DataEntry> data = new ArrayList<>();
        List<TrainingEntry> trainingData = new ArrayList<>();
        for (Element element : elements) {
            Element quoteAndAuthor = element.parent().parent();
            String text = quoteAndAuthor.getElementsByTag("p").text();
            int index = text.lastIndexOf("\"");
            String quote = text.substring(1, index);
            String authorAndBiography = text.substring(index + 4);

            Element date = quoteAndAuthor.previousElementSibling();
            while (date.getElementsByTag("h2").size() == 0) {
                date = date.previousElementSibling();
            }
            if (date.getElementsByTag("h2").size() > 1) {
                System.out.println("Issue with " + date + ".");
                break;
            }
            String dirtyDate = date.getElementsByTag("h2").get(0).text();
            String monthNum = dirtyDate.split(", ")[1];
            String month = monthNum.split(" ")[0];
            String day = monthNum.split(" ")[1];

            Map<String, Integer> monthToInt = new HashMap<>();
            monthToInt.put("January", 0);
            monthToInt.put("February", 1);
            monthToInt.put("March", 2);
            monthToInt.put("April", 3);
            monthToInt.put("May", 4);
            monthToInt.put("June", 5);
            monthToInt.put("July", 6);
            monthToInt.put("August", 7);
            monthToInt.put("September", 8);
            monthToInt.put("October", 9);
            monthToInt.put("November", 10);
            monthToInt.put("December", 11);

            String mmDd = (monthToInt.get(month) + 1) + "/" + day;

            QuoteEntry entry = new QuoteEntry();
            entry.quote = quote;
            entry.name = authorAndBiography;
            entry.date = mmDd;
            data.add(entry);
        }
        System.out.println("Finished scraping sitemap.");
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
        dataEntryConsumer.accept(data);
        trainingEntryConsumer.accept(trainingData);
    }

    @Override
    public DataEntry scrapeEntry(Document document) {
        return null;
    }

    @Override
    public List<DataEntry> fromJson(String json) {
        return gson.fromJson(json, new TypeToken<List<QuoteEntry>>() {
        }.getType());
    }

    public static class QuoteEntry extends DataEntry {

        public String name;
        public String date;
        public String quote;

        @Override
        public List<TrainingEntry> buildTrainingEntries() {
            return new ArrayList<>();
        }

        @Override
        public String toString() {
            return date;
        }
    }
}
