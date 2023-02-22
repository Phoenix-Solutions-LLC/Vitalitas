package com.patetlex.vitalitas.database.mayoclinic;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.patetlex.vitalitas.database.mayoclinic.openai.TrainingEntry;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.function.Consumer;

public abstract class ScrapeableSitemap {

    public static final int DISPATCH_GROUP_SIZE = 500;
    private String sitemap;
    private StringBuilder log = new StringBuilder();

    public ScrapeableSitemap(String sitemapURL) {
        this.sitemap = sitemapURL;
    }

    public abstract DataEntry scrapeEntry(Document document);
    public abstract List<DataEntry> fromJson(String json);

    public void scrapeSitemap(Consumer<List<DataEntry>> dataEntryConsumer, Consumer<List<TrainingEntry>> trainingEntryConsumer) {
        List<DataEntry> data = new ArrayList<>();
        List<TrainingEntry> trainingData = new ArrayList<>();
        try {
            Document doc = Jsoup.connect(this.sitemap).timeout(0).get();
            Elements elements = doc.getElementsByTag("loc");
            System.out.println("Found " + elements.size() + " elements.");

            AtomicInteger numLeft = new AtomicInteger(elements.size());
            List<Thread> openThreads = new ArrayList<>();
            for (int s = 0; s < elements.size() + DISPATCH_GROUP_SIZE; s += DISPATCH_GROUP_SIZE) {
                final int dS = s;
                Thread thread = new Thread(() -> {
                    System.out.println("Thread from " + dS + " to " + (dS + DISPATCH_GROUP_SIZE));
                    for (int i = 0; i < DISPATCH_GROUP_SIZE; i++) {
                        if (dS + i < elements.size()) {
                            Element element = elements.get(dS + i);
                            try {
                                Document eDoc = Jsoup.connect(element.text()).timeout(0).get();
                                DataEntry entry = scrapeEntry(eDoc);
                                data.add(entry);
                                System.out.println("Successfully scraped " + Objects.toString(entry) + ". " + numLeft.decrementAndGet() + " elements left.");
                            } catch (IOException e) {
                                log(e.getMessage());
                                e.printStackTrace();
                            }
                        }
                    }
                });
                thread.start();
                openThreads.add(thread);
            }
            while (true) {
                boolean flag = true;
                for (Thread thread : openThreads) {
                    if (thread.isAlive()) {
                        flag = false;
                        break;
                    }
                }
                if (flag)
                    break;
            }
            ScrapeableSitemap.this.addTrainingData(trainingData);
            for (DataEntry entry : data) {
                trainingData.addAll(entry.buildTrainingEntries());
                System.out.println("Successfully built training data for " + Objects.toString(entry) + ".");
            }
            dataEntryConsumer.accept(data);
            trainingEntryConsumer.accept(trainingData);
            System.out.println("Finished scraping sitemap.");
        } catch (IOException e) {
            log(e.getMessage());
            e.printStackTrace();
        }
    }

    public void addTrainingData(List<TrainingEntry> entries) {

    }

    public void log(String info) {
        this.log.append(info).append("\n");
    }

    public String getLog() {
        return this.log.toString();
    }
}
