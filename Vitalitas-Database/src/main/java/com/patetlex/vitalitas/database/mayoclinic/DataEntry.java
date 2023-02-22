package com.patetlex.vitalitas.database.mayoclinic;

import com.patetlex.vitalitas.database.mayoclinic.openai.TrainingEntry;

import java.util.List;

public abstract class DataEntry {
    public abstract List<TrainingEntry> buildTrainingEntries();
}
