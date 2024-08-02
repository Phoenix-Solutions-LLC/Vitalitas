package com.patetlex.vitalitas.database.scrape.mayoclinic;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.patetlex.vitalitas.database.scrape.DataEntry;
import com.patetlex.vitalitas.database.scrape.ScrapeableSitemap;
import com.patetlex.vitalitas.database.scrape.openai.TrainingEntry;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

import java.io.IOException;
import java.util.*;

public class Drugs extends ScrapeableSitemap {

    public Drugs() {
        super("drugs", "https://www.mayoclinic.org/patient_consumer_drug.xml");
    }

    @Override
    public DataEntry scrapeEntry(Document document) {
        DrugEntry entry = new DrugEntry();
        entry.backLink = document.location();
        for (Element meta : document.getElementsByTag("meta")) {
            if (meta.attributes().get("name").equalsIgnoreCase("Subject")) {
                entry.name = meta.attributes().get("content");
            }
            if (meta.attributes().get("name").equalsIgnoreCase("PocID")) {
                entry.pocId = meta.attributes().get("content");
            }
        }
        Element main = document.getElementById("main-content");
        for (Element element : main.getElementsByTag("h3")) {
            if (element.text().contains("US Brand Name")) {
                Element ol = element.nextElementSibling();
                if (ol.tag().getName().equalsIgnoreCase("ol")) {
                    for (Element listE : ol.getElementsByTag("li")) {
                        if (entry.brandNames == null)
                            entry.brandNames = new ArrayList<>();
                        entry.brandNames.add(listE.text());
                    }
                }
            }
            if (element.text().contains("Descriptions")) {
                StringBuilder desc = new StringBuilder();
                Element sibling = element.nextElementSibling().nextElementSibling();
                while (!sibling.attributes().get("class").equalsIgnoreCase("page content") && (sibling.tag().getName().equalsIgnoreCase("p") || sibling.tag().getName().equalsIgnoreCase("br") || sibling.tag().getName().equalsIgnoreCase("ul") || sibling.tag().getName().equalsIgnoreCase("li") || sibling.id().equalsIgnoreCase("ad-mobile-top-container"))) {
                    desc.append(sibling.text());
                    if (!sibling.text().isEmpty())
                        desc.append("\n");
                    sibling = sibling.nextElementSibling();
                }
                entry.description = desc.toString();
            }
        }
        if (entry.brandNames == null)
            entry.brandNames = new ArrayList<>();
        if (entry.name == null) {
            log("No name found on " + document.location() + ".");
            entry.name = "UNDEFINED_DRUG_NAME";
        }
        if (entry.pocId == null) {
            log("No PocID found for " + entry.name + " on " + document.location() + ".");
            entry.pocId = "UNDEFINED_DRUG_POCID";
        }
        if (entry.description == null) {
            log("No Description found for " + entry.name + " on " + document.location() + ".");
            entry.description = "UNDEFINED_DRUG_DESCRIPTION";
        }
        Map<String, List<String>> sideEffectsMap = new HashMap<>();
        try {
            Document sideEffects = Jsoup.connect(document.location().replace("description", "side-effects")).timeout(0).get();
            Element main0 = sideEffects.getElementById("main-content");
            Elements elements = main0.getElementsByTag("h4");
            for (Element element : elements) {
                boolean flag = false;
                while (element.nextElementSibling() != null && element.nextElementSibling().tag().getName().equalsIgnoreCase("ol")) {
                    String rarity = element.text().toLowerCase(Locale.ROOT);
                    List<String> sideE = new ArrayList<>();
                    for (Element li : element.nextElementSibling().getElementsByTag("li")) {
                        sideE.add(li.text().toLowerCase(Locale.ROOT));
                    }
                    sideEffectsMap.put(rarity, sideE);
                    element = element.nextElementSibling().nextElementSibling();
                    if (element == null)
                        break;
                    flag = true;
                }
                if (flag)
                    break;
            }
        } catch (IOException e) {
            log(e.getMessage());
        }
        entry.symptoms = sideEffectsMap;
        return entry;
    }

    @Override
    public List<DataEntry> fromJson(String json) {
        return gson.fromJson(json, new TypeToken<List<DrugEntry>>() {}.getType());
    }

    public static class DrugEntry extends DataEntry {

        public String name;
        public List<String> brandNames;
        public String pocId;
        public String description;
        public Map<String, List<String>> symptoms;
        public String backLink;
        public List<String> routes;

        public Map<String, Integer> similarities;

        @Override
        public List<TrainingEntry> buildTrainingEntries() {
            List<TrainingEntry> trainingList = new ArrayList<>();
            trainingList.add(new TrainingEntry("", gson.toJson(this)));
            //trainingList.add(new TrainingEntry("", this.description));
            //trainingList.add(new TrainingEntry("What is " + this.name + "?", this.description));
            //trainingList.add(new TrainingEntry("What is the drug id of " + this.name + "?", this.pocId));
            //trainingList.add(new TrainingEntry("What is the poc id of " + this.name + "?", this.pocId));
            //trainingList.add(new TrainingEntry("What is the id of " + this.name + "?", this.pocId));
            //trainingList.add(new TrainingEntry("What is a link to " + this.name + "?", this.backLink));
            //trainingList.add(new TrainingEntry("Where can I find more information on " + this.name + "?", "You can find more information at " + this.backLink + "."));
            trainingList.add(new TrainingEntry("Add " + this.name + " to my current medications.", "${USER_ADD_MEDICATION-\"" + this.pocId + "\"}"));
            trainingList.add(new TrainingEntry("Remove " + this.name + " to my current medications.", "${USER_REMOVE_MEDICATION-\"" + this.pocId + "\"}"));
            if (this.brandNames != null) {
                for (String brandName : this.brandNames) {
                    //trainingList.add(new TrainingEntry("What is " + brandName + "?", this.description));
                    //trainingList.add(new TrainingEntry("What is the drug id of " + brandName + "?", this.pocId));
                    //trainingList.add(new TrainingEntry("What is the poc id of " + brandName + "?", this.pocId));
                    //trainingList.add(new TrainingEntry("What is the id of " + brandName + "?", this.pocId));
                    //trainingList.add(new TrainingEntry("What is a link to " + brandName + "?", this.backLink));
                    //trainingList.add(new TrainingEntry("Where can I find more information on " + brandName + "?", "You can find more information at " + this.backLink + "."));
                    trainingList.add(new TrainingEntry("Add " + brandName + " to my current medications.", "${USER_ADD_MEDICATION-\"" + this.pocId + "\"}"));
                    trainingList.add(new TrainingEntry("Remove " + brandName + " to my current medications.", "${USER_REMOVE_MEDICATION-\"" + this.pocId + "\"}"));
                }
            }
            for (String rarity : this.symptoms.keySet()) {
                StringBuilder symptoms = new StringBuilder();
                int i = 0;
                for (String symptom : this.symptoms.get(rarity)) {
                    if (i > 0)
                        symptoms.append(", ");
                    symptoms.append(symptom);
                    i++;
                    trainingList.add(new TrainingEntry("{\"my-medications\":[\"" + this.pocId + "\"]}\nWhat medication is my side effect " + symptom + " coming from?", "That is consistent with " + this.name + "."));
                    trainingList.add(new TrainingEntry("{\"my-medications\":[\"" + this.pocId + "\"]}\nShould I be expecting " + symptom + "?", "Yes. This side effect could be due to your medications. Always consult your doctor or pharmacist for any changes in your medication or health."));
                }
                symptoms.append(".");
                symptoms.setCharAt(0, symptoms.substring(0, 1).toUpperCase().toCharArray()[0]);
                //trainingList.add(new TrainingEntry("What are the " + rarity + " side effects of " + this.name + "?", symptoms.toString()));
                //trainingList.add(new TrainingEntry("What are the " + rarity + " symptoms of " + this.name + "?", symptoms.toString()));
                if (this.brandNames != null) {
                    for (String brandName : this.brandNames) {
                        //trainingList.add(new TrainingEntry("What are the " + rarity + " side effects of " + brandName + "?", symptoms.toString()));
                        //trainingList.add(new TrainingEntry("What are the " + rarity + " symptoms of " + brandName + "?", symptoms.toString()));
                    }
                }
            }
            return trainingList;
        }

        @Override
        public String toString() {
            return this.pocId;
        }
    }
}
