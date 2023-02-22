package com.patetlex.vitalitas.database.mayoclinic.openai;

public class TrainingEntry {
    public String prompt;
    public String completion;

    public TrainingEntry(String prompt, String completion) {
        this.prompt = prompt;
        this.completion = completion;
    }

    public TrainingEntry() {

    }
}
