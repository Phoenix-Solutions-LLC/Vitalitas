package com.patetlex.vitalitas.database;

import com.patetlex.vitalitas.database.scrape.DataEntry;
import com.patetlex.vitalitas.database.scrape.ScrapeableSitemap;
import com.patetlex.vitalitas.database.scrape.bodybuilding.Exercises;

import javax.xml.crypto.Data;
import java.util.List;
import java.util.function.BiConsumer;

public class Main {
    public static void main(String[] args) {
        DatabaseBuilder builder = new DatabaseBuilder().fromBuild(new Exercises());

        builder.getData().forEach(new BiConsumer<ScrapeableSitemap, List<DataEntry>>() {
            @Override
            public void accept(ScrapeableSitemap scrapeableSitemap, List<DataEntry> dataEntries) {
                if (scrapeableSitemap instanceof Exercises) {
                    for (DataEntry entry : dataEntries) {
                        Exercises.ExerciseEntry exerciseEntry = (Exercises.ExerciseEntry) entry;
                        exerciseEntry.name = exerciseEntry.name.trim();
                    }
                }
            }
        });

        int tokens = builder.build();
        System.out.println("Uses " + tokens + " tokens. Cost estimate of $" + ((tokens / 1000) * 0.012) + ".");
    }
}
