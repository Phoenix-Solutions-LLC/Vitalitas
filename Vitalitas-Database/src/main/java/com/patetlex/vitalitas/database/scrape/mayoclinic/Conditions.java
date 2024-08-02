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
import java.util.concurrent.atomic.AtomicInteger;
import java.util.function.Consumer;

public class Conditions extends ScrapeableSitemap {

    public Conditions() {
        super("conditions", "");
    }

    @Override
    public void scrapeSitemap(Consumer<List<DataEntry>> dataEntryConsumer, Consumer<List<TrainingEntry>> trainingEntryConsumer) {
        String[] indexs = new String[] {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0"};
        List<Element> foundLi = new ArrayList<>();
        for (int i = 0; i < indexs.length; i++) {
            try {
                Document doc = Jsoup.connect("https://www.mayoclinic.org/diseases-conditions/index?letter=" + indexs[i]).timeout(0).get();
                Element index = doc.getElementById("index");
                Elements liNodes = index.getElementsByTag("li");
                foundLi.addAll(liNodes);
            } catch (IOException e) {
                log(e.getMessage());
            }
        }
        System.out.println("Found " + foundLi.size() + " elements.");

        List<DataEntry> data = new ArrayList<>();
        List<TrainingEntry> trainingData = new ArrayList<>();

        AtomicInteger numLeft = new AtomicInteger(foundLi.size());
        List<Thread> openThreads = new ArrayList<>();
        for (int s = 0; s < foundLi.size() + DISPATCH_GROUP_SIZE; s += DISPATCH_GROUP_SIZE) {
            final int dS = s;
            Thread thread = new Thread(() -> {
                System.out.println("Thread from " + dS + " to " + (dS + DISPATCH_GROUP_SIZE));
                for (int i = 0; i < DISPATCH_GROUP_SIZE; i++) {
                    if (dS + i < foundLi.size()) {
                        Element li = foundLi.get(dS + i);
                        Elements hrefs = li.getElementsByAttribute("href");
                        if (hrefs.size() != 1)
                            System.out.println("Multiple pointing references for node " + li.wholeText() + ".");
                        if (hrefs.size() < 1)
                            continue;
                        try {
                            Document eDoc = Jsoup.connect("https://www.mayoclinic.org" + hrefs.get(0).attributes().get("href")).timeout(0).get();
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
    public DataEntry scrapeEntry(Document document) {
        ConditionEntry entry = new ConditionEntry();
        entry.backLink = document.location();
        Elements metaData = document.getElementsByTag("meta");
        for (Element meta : metaData) {
            if (meta.attributes().get("name").equalsIgnoreCase("PocID")) {
                entry.pocId = meta.attributes().get("content");
            }
            if (meta.attributes().get("name").equalsIgnoreCase("Subject")) {
                if (entry.name == null) {
                    entry.name = meta.attributes().get("content");
                } else {
                    if (entry.commonNames == null)
                        entry.commonNames = new ArrayList<>();
                    entry.commonNames.add(meta.attributes().get("content"));
                }
            }
            if (meta.attributes().get("name").equalsIgnoreCase("Description")) {
                entry.description = meta.attributes().get("content");
            }
        }
        List<Element> headers = new ArrayList<>();
        Elements h2 = document.getElementsByTag("h2");
        Elements h3 = document.getElementsByTag("h3");
        headers.addAll(h2);
        headers.addAll(h3);
        for (Element header : headers) {
            if (header.text().contains("Symptoms")) {
                Element prev = header.nextElementSibling();
                entry.symptoms = new ArrayList<>();
                if (prev != null) {
                    while (prev != null && prev.tag().getName().equalsIgnoreCase("p") || prev.tag().getName().equalsIgnoreCase("ul") || prev.tag().getName().equalsIgnoreCase("strong") || prev.tag().getName().equalsIgnoreCase("abbr") || prev.attributes().get("id").equalsIgnoreCase("ad-mobile-top-container")) {
                        if (prev.tag().getName().equalsIgnoreCase("ul")) {
                            for (Element li : prev.getElementsByTag("li")) {
                                if (li.getElementsByTag("p").size() > 0) {
                                    for (Element p : li.getElementsByTag("p")) {
                                        if (p.getElementsByTag("strong").size() > 0) {
                                            entry.symptoms.add(p.getElementsByTag("strong").get(0).text().replaceAll("\\p{Punct}", ""));
                                            break;
                                        }
                                    }
                                } else if (li.getElementsByTag("strong").size() > 0) {
                                    entry.symptoms.add(li.getElementsByTag("strong").get(0).text().replaceAll("\\p{Punct}", ""));
                                } else {
                                    entry.symptoms.add(li.text());
                                }
                            }
                            break;
                        }
                        prev = prev.nextElementSibling();
                        if (prev == null)
                            break;
                    }
                }
            }
            if (header.text().contains("Causes")) {
                Element prev = header.nextElementSibling();
                entry.causes = new ArrayList<>();
                if (prev != null) {
                    while (prev != null && prev.tag().getName().equalsIgnoreCase("p") || prev.tag().getName().equalsIgnoreCase("ul") || prev.tag().getName().equalsIgnoreCase("strong") || prev.tag().getName().equalsIgnoreCase("abbr") || prev.attributes().get("id").equalsIgnoreCase("ad-mobile-top-container")) {
                        if (prev.tag().getName().equalsIgnoreCase("ul")) {
                            for (Element li : prev.getElementsByTag("li")) {
                                if (li.getElementsByTag("p").size() > 0) {
                                    for (Element p : li.getElementsByTag("p")) {
                                        if (p.getElementsByTag("strong").size() > 0) {
                                            entry.causes.add(p.getElementsByTag("strong").get(0).text().replaceAll("\\p{Punct}", ""));
                                            break;
                                        }
                                    }
                                } else if (li.getElementsByTag("strong").size() > 0) {
                                    entry.causes.add(li.getElementsByTag("strong").get(0).text().replaceAll("\\p{Punct}", ""));
                                } else {
                                    entry.causes.add(li.text());
                                }
                            }
                            break;
                        }
                        prev = prev.nextElementSibling();
                        if (prev == null)
                            break;
                    }
                }
            }
            if (header.text().contains("Risk factors")) {
                Element prev = header.nextElementSibling();
                entry.risks = new ArrayList<>();
                if (prev != null) {
                    while (prev != null && prev.tag() != null && prev.tag().getName().equalsIgnoreCase("p") || prev.tag().getName().equalsIgnoreCase("ul") || prev.tag().getName().equalsIgnoreCase("strong") || prev.tag().getName().equalsIgnoreCase("abbr") || prev.attributes().get("id").equalsIgnoreCase("ad-mobile-top-container")) {
                        if (prev.tag().getName().equalsIgnoreCase("ul")) {
                            for (Element li : prev.getElementsByTag("li")) {
                                if (li.getElementsByTag("p").size() > 0) {
                                    for (Element p : li.getElementsByTag("p")) {
                                        if (p.getElementsByTag("strong").size() > 0) {
                                            entry.risks.add(p.getElementsByTag("strong").get(0).text().replaceAll("\\p{Punct}", ""));
                                            break;
                                        }
                                    }
                                } else if (li.getElementsByTag("strong").size() > 0) {
                                    entry.risks.add(li.getElementsByTag("strong").get(0).text().replaceAll("\\p{Punct}", ""));
                                } else {
                                    entry.risks.add(li.text());
                                }
                            }
                            break;
                        }
                        prev = prev.nextElementSibling();
                        if (prev == null)
                            break;
                    }
                }
            }
            if (header.text().contains("Complications")) {
                Element prev = header.nextElementSibling();
                entry.complications = new ArrayList<>();
                if (prev != null) {
                    while (prev != null && prev.tag().getName().equalsIgnoreCase("p") || prev.tag().getName().equalsIgnoreCase("ul") || prev.tag().getName().equalsIgnoreCase("strong") || prev.tag().getName().equalsIgnoreCase("abbr") || prev.attributes().get("id").equalsIgnoreCase("ad-mobile-top-container")) {
                        if (prev.tag().getName().equalsIgnoreCase("ul")) {
                            for (Element li : prev.getElementsByTag("li")) {
                                if (li.getElementsByTag("p").size() > 0) {
                                    for (Element p : li.getElementsByTag("p")) {
                                        if (p.getElementsByTag("strong").size() > 0) {
                                            entry.complications.add(p.getElementsByTag("strong").get(0).text().replaceAll("\\p{Punct}", ""));
                                            break;
                                        }
                                    }
                                } else if (li.getElementsByTag("strong").size() > 0) {
                                    entry.complications.add(li.getElementsByTag("strong").get(0).text().replaceAll("\\p{Punct}", ""));
                                } else {
                                    entry.complications.add(li.text());
                                }
                            }
                            break;
                        }
                        prev = prev.nextElementSibling();
                        if (prev == null)
                            break;
                    }
                }
            }
            if (header.text().contains("Prevention")) {
                Element prev = header.nextElementSibling();
                entry.preventions = new ArrayList<>();
                if (prev != null) {
                    while (prev != null && prev.tag().getName().equalsIgnoreCase("p") || prev.tag().getName().equalsIgnoreCase("ul") || prev.tag().getName().equalsIgnoreCase("strong") || prev.tag().getName().equalsIgnoreCase("abbr") || prev.attributes().get("id").equalsIgnoreCase("ad-mobile-top-container")) {
                        if (prev.tag().getName().equalsIgnoreCase("ul")) {
                            for (Element li : prev.getElementsByTag("li")) {
                                if (li.getElementsByTag("p").size() > 0) {
                                    for (Element p : li.getElementsByTag("p")) {
                                        if (p.getElementsByTag("strong").size() > 0) {
                                            entry.preventions.add(p.getElementsByTag("strong").get(0).text().replaceAll("\\p{Punct}", ""));
                                            break;
                                        }
                                    }
                                } else if (li.getElementsByTag("strong").size() > 0) {
                                    entry.preventions.add(li.getElementsByTag("strong").get(0).text().replaceAll("\\p{Punct}", ""));
                                } else {
                                    entry.preventions.add(li.text());
                                }
                            }
                            break;
                        }
                        prev = prev.nextElementSibling();
                        if (prev == null)
                            break;
                    }
                }
            }
        }
        if (entry.preventions == null)
            entry.preventions = new ArrayList<>();
        if (entry.symptoms == null)
            entry.symptoms = new ArrayList<>();
        if (entry.complications == null)
            entry.complications = new ArrayList<>();
        if (entry.causes == null)
            entry.causes = new ArrayList<>();
        if (entry.risks == null)
            entry.risks = new ArrayList<>();
        if (entry.commonNames == null)
            entry.commonNames = new ArrayList<>();
        if (entry.name == null) {
            log("No name found on " + document.location() + ".");
            entry.name = "UNDEFINED_CONDITION_NAME";
        }
        if (entry.pocId == null) {
            log("No PocID found for " + entry.name + " on " + document.location() + ".");
            entry.pocId = "UNDEFINED_CONDITION_POCID";
        }
        if (entry.description == null) {
            log("No Description found for " + entry.name + " on " + document.location() + ".");
            entry.description = "UNDEFINED_CONDITION_DESCRIPTION";
        }
        try {
            if (document.getElementById("et_genericNavigation_diagnosis-treatment") != null) {
                Document diagnosisTreatment = Jsoup.connect("https://www.mayoclinic.org" + document.getElementById("et_genericNavigation_diagnosis-treatment").attributes().get("href")).timeout(0).get();
                List<Element> headers0 = new ArrayList<>();
                Elements h20 = diagnosisTreatment.getElementsByTag("h2");
                Elements h30 = diagnosisTreatment.getElementsByTag("h3");
                headers0.addAll(h20);
                headers0.addAll(h30);
                for (Element header : headers0) {
                    if (header.text().contains("Diagnosis")) {
                        Element prev = header.nextElementSibling();
                        entry.diagnosis = new ArrayList<>();
                        if (prev != null) {
                            while (prev != null && prev.tag().getName().equalsIgnoreCase("p") || prev.tag().getName().equalsIgnoreCase("ul") || prev.tag().getName().equalsIgnoreCase("strong") || prev.tag().getName().equalsIgnoreCase("abbr") || prev.attributes().get("id").equalsIgnoreCase("ad-mobile-top-container")) {
                                if (prev.tag().getName().equalsIgnoreCase("ul")) {
                                    for (Element li : prev.getElementsByTag("li")) {
                                        if (li.getElementsByTag("p").size() > 0) {
                                            for (Element p : li.getElementsByTag("p")) {
                                                if (p.getElementsByTag("strong").size() > 0) {
                                                    entry.diagnosis.add(p.getElementsByTag("strong").get(0).text().replaceAll("\\p{Punct}", ""));
                                                    break;
                                                }
                                            }
                                        } else if (li.getElementsByTag("strong").size() > 0) {
                                            entry.diagnosis.add(li.getElementsByTag("strong").get(0).text().replaceAll("\\p{Punct}", ""));
                                        } else {
                                            entry.diagnosis.add(li.text());
                                        }
                                    }
                                    break;
                                }
                                prev = prev.nextElementSibling();
                                if (prev == null)
                                    break;
                            }
                        }
                    }
                    if (header.text().contains("Medications") || header.text().contains("Treatment")) {
                        Element prev = header.nextElementSibling();
                        entry.treatment = new ArrayList<>();
                        if (prev != null) {
                            while (prev != null && prev.tag().getName().equalsIgnoreCase("p") || prev.tag().getName().equalsIgnoreCase("ul") || prev.tag().getName().equalsIgnoreCase("strong") || prev.tag().getName().equalsIgnoreCase("abbr") || prev.attributes().get("id").equalsIgnoreCase("ad-mobile-top-container")) {
                                if (prev.tag().getName().equalsIgnoreCase("ul")) {
                                    for (Element li : prev.getElementsByTag("li")) {
                                        if (li.getElementsByTag("p").size() > 0) {
                                            for (Element p : li.getElementsByTag("p")) {
                                                if (p.getElementsByTag("strong").size() > 0) {
                                                    entry.treatment.add(p.getElementsByTag("strong").get(0).text().replaceAll("\\p{Punct}", ""));
                                                    break;
                                                }
                                            }
                                        } else if (li.getElementsByTag("strong").size() > 0) {
                                            entry.treatment.add(li.getElementsByTag("strong").get(0).text().replaceAll("\\p{Punct}", ""));
                                        } else {
                                            entry.treatment.add(li.text());
                                        }
                                    }
                                    break;
                                }
                                prev = prev.nextElementSibling();
                                if (prev == null)
                                    break;
                            }
                        }
                    }
                }
            } else {
                log("Skipping diagnosis & treatment for " + entry.toString() + ".");
            }
        } catch (IOException e) {
            log(e.getMessage());
        }
        if (entry.diagnosis == null)
            entry.diagnosis = new ArrayList<>();
        if (entry.treatment == null)
            entry.treatment = new ArrayList<>();
        return entry;
    }

    @Override
    public List<DataEntry> fromJson(String json) {
        return gson.fromJson(json, new TypeToken<List<ConditionEntry>>() {}.getType());
    }

    public static class ConditionEntry extends DataEntry {

        public String name;
        public List<String> commonNames;
        public String pocId;
        public String description;
        public List<String> symptoms;
        public List<String> causes;
        public List<String> risks;
        public List<String> complications;
        public List<String> preventions;
        public List<String> diagnosis;
        public List<String> treatment;
        public String backLink;

        public Map<String, Integer> similarities;

        @Override
        public List<TrainingEntry> buildTrainingEntries() {
            List<TrainingEntry> trainingList = new ArrayList<>();
            trainingList.add(new TrainingEntry("", gson.toJson(this)));
/*            trainingList.add(new TrainingEntry("", this.description));
            trainingList.add(new TrainingEntry("What is " + this.name + "?", this.description));
            trainingList.add(new TrainingEntry("What is the condition id of " + this.name + "?", this.pocId));
            trainingList.add(new TrainingEntry("What is the poc id of " + this.name + "?", this.pocId));
            trainingList.add(new TrainingEntry("What is a link to " + this.name + "?", this.backLink));
            trainingList.add(new TrainingEntry("Where can I find more information on " + this.name + "?", this.backLink));*/
            trainingList.add(new TrainingEntry("Add " + this.name + " to my current conditions.", "${USER_ADD_CONDITION-\"" + this.pocId + "\"}"));
            trainingList.add(new TrainingEntry("Remove " + this.name + " to my current conditions.", "${USER_REMOVE_CONDITION-\"" + this.pocId + "\"}"));
            if (this.commonNames != null) {
                for (String brandName : this.commonNames) {
/*                    trainingList.add(new TrainingEntry("What is " + brandName + "?", this.description));
                    trainingList.add(new TrainingEntry("What is the condition id of " + brandName + "?", this.pocId));
                    trainingList.add(new TrainingEntry("What is the poc id of " + brandName + "?", this.pocId));
                    trainingList.add(new TrainingEntry("What is a link to " + brandName + "?", this.backLink));
                    trainingList.add(new TrainingEntry("Where can I find more information on " + brandName + "?", this.backLink));*/
                    trainingList.add(new TrainingEntry("Add " + brandName + " to my current conditions.", "${USER_ADD_CONDITION-\"" + this.pocId + "\"}"));
                    trainingList.add(new TrainingEntry("Remove " + brandName + " to my current conditions.", "${USER_REMOVE_CONDITION-\"" + this.pocId + "\"}"));
                }
            }
            if (this.symptoms.size() > 0) {
                StringBuilder symptoms = new StringBuilder();
                int i = 0;
                for (String symptom : this.symptoms) {
                    if (i > 0)
                        symptoms.append(", ");
                    symptoms.append(symptom);
                    i++;
                    trainingList.add(new TrainingEntry("{\"my-conditions\":[\"" + this.pocId + "\"]}\nWhat condition is my symptom " + symptom + " coming from?", "That is consistent with " + this.name + "."));
                    trainingList.add(new TrainingEntry("{\"my-conditions\":[\"" + this.pocId + "\"]}\nShould I be expecting " + symptom + "?", "Yes. This side effect could be due to your medications. Always consult your doctor or pharmacist for any changes in your medication or health."));
                }
                symptoms.append(".");
                symptoms.setCharAt(0, symptoms.substring(0, 1).toUpperCase().toCharArray()[0]);
/*                trainingList.add(new TrainingEntry("What are the side effects of " + this.name + "?", symptoms.toString()));
                trainingList.add(new TrainingEntry("What are the symptoms of " + this.name + "?", symptoms.toString()));*/
                if (this.commonNames != null) {
                    for (String brandName : this.commonNames) {
/*                        trainingList.add(new TrainingEntry("What are the side effects of " + brandName + "?", symptoms.toString()));
                        trainingList.add(new TrainingEntry("What are the symptoms of " + brandName + "?", symptoms.toString()));*/
                    }
                }
            }
            if (this.causes.size() > 0) {
                StringBuilder causes = new StringBuilder();
                int i = 0;
                for (String cause : this.causes) {
                    if (i > 0)
                        causes.append(", ");
                    causes.append(cause);
                    i++;
                }
                causes.append(".");
                causes.setCharAt(0, causes.substring(0, 1).toUpperCase().toCharArray()[0]);
                //trainingList.add(new TrainingEntry("What are the causes of " + this.name + "?", causes.toString()));
                if (this.commonNames != null) {
                    for (String brandName : this.commonNames) {
                        //trainingList.add(new TrainingEntry("What are the causes of " + brandName + "?", causes.toString()));
                    }
                }
            }
            if (this.risks.size() > 0) {
                StringBuilder risks = new StringBuilder();
                int i = 0;
                for (String risk : this.risks) {
                    if (i > 0)
                        risks.append(", ");
                    risks.append(risk);
                    i++;
                }
                risks.append(".");
                risks.setCharAt(0, risks.substring(0, 1).toUpperCase().toCharArray()[0]);
                //trainingList.add(new TrainingEntry("What are the risks of " + this.name + "?", risks.toString()));
                if (this.commonNames != null) {
                    for (String brandName : this.commonNames) {
                        //trainingList.add(new TrainingEntry("What are the risks of " + brandName + "?", risks.toString()));
                    }
                }
            }
            if (this.treatment.size() > 0) {
                StringBuilder treatments = new StringBuilder();
                int i = 0;
                for (String treatment : this.treatment) {
                    if (i > 0)
                        treatments.append(", ");
                    treatments.append(treatment);
                    i++;
                }
                treatments.append(".");
                treatments.setCharAt(0, treatments.substring(0, 1).toUpperCase().toCharArray()[0]);
                //trainingList.add(new TrainingEntry("What are the treatments of " + this.name + "?", treatments.toString()));
                if (this.commonNames != null) {
                    for (String brandName : this.commonNames) {
                        //trainingList.add(new TrainingEntry("What are the treatments of " + brandName + "?", treatments.toString()));
                    }
                }
            }
            if (this.complications.size() > 0) {
                StringBuilder complications = new StringBuilder();
                int i = 0;
                for (String complication : this.complications) {
                    if (i > 0)
                        complications.append(", ");
                    complications.append(complication);
                    i++;
                }
                complications.append(".");
                complications.setCharAt(0, complications.substring(0, 1).toUpperCase().toCharArray()[0]);
                //trainingList.add(new TrainingEntry("What are the complications of " + this.name + "?", complications.toString()));
                if (this.commonNames != null) {
                    for (String brandName : this.commonNames) {
                        //trainingList.add(new TrainingEntry("What are the complications of " + brandName + "?", complications.toString()));
                    }
                }
            }
            if (this.preventions.size() > 0) {
                StringBuilder preventions = new StringBuilder();
                int i = 0;
                for (String prevention : this.preventions) {
                    if (i > 0)
                        preventions.append(", ");
                    preventions.append(prevention);
                    i++;
                }
                preventions.append(".");
                preventions.setCharAt(0, preventions.substring(0, 1).toUpperCase().toCharArray()[0]);
                //trainingList.add(new TrainingEntry("What are the preventions of " + this.name + "?", preventions.toString()));
                if (this.commonNames != null) {
                    for (String brandName : this.commonNames) {
                        //trainingList.add(new TrainingEntry("What are the preventions of " + brandName + "?", preventions.toString()));
                    }
                }
            }
            if (this.diagnosis.size() > 0) {
                StringBuilder diagnosis = new StringBuilder();
                int i = 0;
                for (String d : this.diagnosis) {
                    if (i > 0)
                        diagnosis.append(", ");
                    diagnosis.append(d);
                    i++;
                }
                diagnosis.append(".");
                diagnosis.setCharAt(0, diagnosis.substring(0, 1).toUpperCase().toCharArray()[0]);
                //trainingList.add(new TrainingEntry("How is " + this.name + " diagnosed?", diagnosis.toString()));
                if (this.commonNames != null) {
                    for (String brandName : this.commonNames) {
                        //trainingList.add(new TrainingEntry("How is " + brandName + " diagnosed?", diagnosis.toString()));
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
