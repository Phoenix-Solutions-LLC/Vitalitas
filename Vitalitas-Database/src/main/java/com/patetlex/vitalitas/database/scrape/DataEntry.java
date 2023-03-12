package com.patetlex.vitalitas.database.scrape;

import com.patetlex.vitalitas.database.scrape.openai.TrainingEntry;

import java.util.List;

public abstract class DataEntry {
    public abstract List<TrainingEntry> buildTrainingEntries();
}
