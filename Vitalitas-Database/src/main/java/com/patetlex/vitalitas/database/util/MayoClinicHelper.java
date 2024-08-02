package com.patetlex.vitalitas.database.util;

import com.patetlex.vitalitas.database.DatabaseBuilder;
import com.patetlex.vitalitas.database.scrape.DataEntry;
import com.patetlex.vitalitas.database.scrape.ScrapeableSitemap;
import com.patetlex.vitalitas.database.scrape.mayoclinic.Conditions;
import com.patetlex.vitalitas.database.scrape.mayoclinic.Drugs;

import java.util.*;
import java.util.concurrent.TimeUnit;

public class MayoClinicHelper {

    public static void fixDrugRoutes(DatabaseBuilder builder) {
        List<Drugs.DrugEntry> fix = new ArrayList<>();
        for (ScrapeableSitemap map : builder.getData().keySet()) {
            for (DataEntry entry : builder.getData().get(map)) {
                if (entry instanceof Drugs.DrugEntry) {
                    String entryName = ((Drugs.DrugEntry) entry).name;
                    String route = null;
                    List<String> routesList = new ArrayList<>();
                    if (entryName.lastIndexOf("(") > 0) {
                        route = entryName.substring(entryName.lastIndexOf("(") + 1);
                        List<String> routes = Arrays.asList("Oral", "Topical", "Subgingival", "Intravenous", "Rectal", "Transdermal", "Injection", "Inhalation", "Intramuscular", "Subcutaneous", "Nasal", "Buccal", "Intradermal", "Ophthalmic", "Parenteral", "Intraocular", "Vaginal", "Otic", "Urinary Bladder", "Oromucosal", "Intracerebroventricular", "Intravenous", "Intraspinal", "Intra-Arterial", "Intracoronary", "Implantation", "Dental", "Oromucosal", "Injection", "Intraocular", "Intravesical", "Intratracheal", "Gingival", "Sublingual");
                        for (String r : routes) {
                            if (route.contains(r)) {
                                routesList.add(r);
                            }
                        }
                        entryName = entryName.substring(0, entryName.lastIndexOf("(")).trim();
                    }
                    ((Drugs.DrugEntry) entry).name = entryName;
                    ((Drugs.DrugEntry) entry).routes = routesList;
                }
            }
        }
    }
    public static void propagateSimilarities(DatabaseBuilder builder) {
        propagateSimilarities(builder, 10);
    }
    public static void propagateSimilarities(DatabaseBuilder builder, int maxEntries) {
        int totalElements = 0;
        for (ScrapeableSitemap map : builder.getData().keySet()) {
            totalElements += builder.getData().get(map).size();
        }
        System.out.println("~~~Similarity Propagation~~~");
        System.out.println("Total Elements: " + totalElements);
        System.out.println("Total Iterations: " + (totalElements * (totalElements - 1)));
        System.out.println("~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        long totalTime = 0;
        int totalIterations = totalElements * (totalElements - 1);
        int iteration = 0;
        for (ScrapeableSitemap map0 : builder.getData().keySet()) {
            for (DataEntry entry0 : builder.getData().get(map0)) {
                for (ScrapeableSitemap map1 : builder.getData().keySet()) {
                    for (DataEntry entry1 : builder.getData().get(map1)) {
                        if (entry1 != entry0) {
                            long start = System.nanoTime();
                            if (entry0 instanceof Drugs.DrugEntry && ((Drugs.DrugEntry) entry0).similarities == null) {
                                ((Drugs.DrugEntry) entry0).similarities = new HashMap<>();
                            } else if (entry0 instanceof Conditions.ConditionEntry && ((Conditions.ConditionEntry) entry0).similarities == null) {
                                ((Conditions.ConditionEntry) entry0).similarities = new HashMap<>();
                            }
                            if (entry1 instanceof Drugs.DrugEntry && ((Drugs.DrugEntry) entry1).similarities == null) {
                                ((Drugs.DrugEntry) entry1).similarities = new HashMap<>();
                            } else if (entry1 instanceof Conditions.ConditionEntry && ((Conditions.ConditionEntry) entry1).similarities == null) {
                                ((Conditions.ConditionEntry) entry1).similarities = new HashMap<>();
                            }

                            if ((entry0 instanceof Drugs.DrugEntry) && (entry1 instanceof Conditions.ConditionEntry)) {
                                drugConditionSimilarity((Drugs.DrugEntry) entry0, (Conditions.ConditionEntry) entry1);
                            } else if ((entry0 instanceof Conditions.ConditionEntry) && (entry1 instanceof Drugs.DrugEntry)) {
                                drugConditionSimilarity((Drugs.DrugEntry) entry1, (Conditions.ConditionEntry) entry0);
                            } else if ((entry0 instanceof Drugs.DrugEntry) && (entry1 instanceof Drugs.DrugEntry)) {
                                drugDrugSimilarity((Drugs.DrugEntry) entry0, (Drugs.DrugEntry) entry1);
                            } else if ((entry0 instanceof Conditions.ConditionEntry) && (entry1 instanceof Conditions.ConditionEntry)) {
                                conditionConditionSimilarity((Conditions.ConditionEntry) entry0, (Conditions.ConditionEntry) entry1);
                            }
                            long delta = System.nanoTime() - start;
                            totalTime += delta;
                            iteration++;
                            if (iteration % Math.round(((float) totalIterations) * 0.02F) == 0) {
                                System.out.println("Percent done: " + String.valueOf(((float) iteration / ((float) totalElements * totalElements)) * 100));
                                long timeToGo = ((totalTime / iteration) * (((long) totalElements * totalElements) - iteration));
                                System.out.println("Time to go: " + TimeUnit.MINUTES.convert(timeToGo, TimeUnit.NANOSECONDS) + " minutes");
                                System.out.println("~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
                            }
                        }
                    }
                }
            }
        }
        System.out.println("Cleaning data to " + (maxEntries) + " entries.");
        System.out.println("Total Elements: " + totalElements);
        System.out.println("Total Iterations: " + totalElements);
        System.out.println("~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        totalTime = 0;
        iteration = 0;
        totalIterations = totalElements;
        for (ScrapeableSitemap map : builder.getData().keySet()) {
            for (DataEntry entry : builder.getData().get(map)) {
                long start = System.nanoTime();
                if (entry instanceof Drugs.DrugEntry) {
                    Drugs.DrugEntry drug = (Drugs.DrugEntry) entry;
                    int hV = 0;
                    for (String pocId : drug.similarities.keySet()) {
                        int v = drug.similarities.get(pocId);
                        if (v > hV) {
                            hV = v;
                        }
                    }

                    Map<String, Integer> nSim = new HashMap<>();
                    for (int i = hV; i >= 0; i--) {
                        if (nSim.size() >= maxEntries) {
                            break;
                        }
                        String removeId = null;
                        for (String pocId : drug.similarities.keySet()) {
                            int v = drug.similarities.get(pocId);
                            if (v == i) {
                                removeId = pocId;
                                nSim.put(pocId, v);
                                break;
                            }
                        }
                        drug.similarities.remove(removeId);
                    }
                    drug.similarities = nSim;
                } else if (entry instanceof Conditions.ConditionEntry) {
                    Conditions.ConditionEntry condition = (Conditions.ConditionEntry) entry;
                    int hV = 0;
                    for (String pocId : condition.similarities.keySet()) {
                        int v = condition.similarities.get(pocId);
                        if (v > hV) {
                            hV = v;
                        }
                    }

                    Map<String, Integer> nSim = new HashMap<>();
                    for (int i = hV; i >= 0; i--) {
                        if (nSim.size() >= maxEntries) {
                            break;
                        }
                        String removeId = null;
                        for (String pocId : condition.similarities.keySet()) {
                            int v = condition.similarities.get(pocId);
                            if (v == i) {
                                removeId = pocId;
                                nSim.put(pocId, v);
                                break;
                            }
                        }
                        condition.similarities.remove(removeId);
                    }
                    condition.similarities = nSim;
                }
                long delta = System.nanoTime() - start;
                totalTime += delta;
                iteration++;
                if (iteration % Math.round(((float) totalIterations) * 0.02F) == 0) {
                    System.out.println("Percent done: " + String.valueOf(((float) iteration / ((float) totalElements)) * 100));
                    long timeToGo = ((totalTime / iteration) * (((long) totalElements) - iteration));
                    System.out.println("Time to go: " + TimeUnit.MINUTES.convert(timeToGo, TimeUnit.NANOSECONDS) + " minutes");
                    System.out.println("~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
                }
            }
        }
    }
    private static void drugConditionSimilarity(Drugs.DrugEntry drug, Conditions.ConditionEntry condition) {
        for (String treatment : condition.treatment) {
            if (treatment.toLowerCase().contains(drug.name.toLowerCase())) {
                if (!condition.similarities.containsKey(drug.pocId))
                    condition.similarities.put(drug.pocId, 0);
                if (!drug.similarities.containsKey(condition.pocId))
                    drug.similarities.put(condition.pocId, 0);
                condition.similarities.replace(drug.pocId, condition.similarities.get(drug.pocId) + 10);
                drug.similarities.replace(condition.pocId, drug.similarities.get(condition.pocId) + 10);
            }
            for (String brandName : drug.brandNames) {
                if (treatment.toLowerCase().contains(brandName.toLowerCase())) {
                    if (!condition.similarities.containsKey(drug.pocId))
                        condition.similarities.put(drug.pocId, 0);
                    if (!drug.similarities.containsKey(condition.pocId))
                        drug.similarities.put(condition.pocId, 0);
                    condition.similarities.replace(drug.pocId, condition.similarities.get(drug.pocId) + 10);
                    drug.similarities.replace(condition.pocId, drug.similarities.get(condition.pocId) + 10);
                }
            }
        }
        for (String cause : condition.causes) {
            if (cause.toLowerCase().contains(drug.name.toLowerCase())) {
                if (!condition.similarities.containsKey(drug.pocId))
                    condition.similarities.put(drug.pocId, 0);
                if (!drug.similarities.containsKey(condition.pocId))
                    drug.similarities.put(condition.pocId, 0);
                condition.similarities.replace(drug.pocId, condition.similarities.get(drug.pocId) + 5);
                drug.similarities.replace(condition.pocId, drug.similarities.get(condition.pocId) + 5);
            }
            for (String brandName : drug.brandNames) {
                if (cause.toLowerCase().contains(brandName.toLowerCase())) {
                    if (!condition.similarities.containsKey(drug.pocId))
                        condition.similarities.put(drug.pocId, 0);
                    if (!drug.similarities.containsKey(condition.pocId))
                        drug.similarities.put(condition.pocId, 0);
                    condition.similarities.replace(drug.pocId, condition.similarities.get(drug.pocId) + 5);
                    drug.similarities.replace(condition.pocId, drug.similarities.get(condition.pocId) + 5);
                }
            }
        }
        for (String prevention : condition.preventions) {
            if (prevention.toLowerCase().contains(drug.name.toLowerCase())) {
                if (!condition.similarities.containsKey(drug.pocId))
                    condition.similarities.put(drug.pocId, 0);
                if (!drug.similarities.containsKey(condition.pocId))
                    drug.similarities.put(condition.pocId, 0);
                condition.similarities.replace(drug.pocId, condition.similarities.get(drug.pocId) + 5);
                drug.similarities.replace(condition.pocId, drug.similarities.get(condition.pocId) + 5);
            }
            for (String brandName : drug.brandNames) {
                if (prevention.toLowerCase().contains(brandName.toLowerCase())) {
                    if (!condition.similarities.containsKey(drug.pocId))
                        condition.similarities.put(drug.pocId, 0);
                    if (!drug.similarities.containsKey(condition.pocId))
                        drug.similarities.put(condition.pocId, 0);
                    condition.similarities.replace(drug.pocId, condition.similarities.get(drug.pocId) + 5);
                    drug.similarities.replace(condition.pocId, drug.similarities.get(condition.pocId) + 5);
                }
            }
        }
    }
    private static void drugDrugSimilarity(Drugs.DrugEntry drug0, Drugs.DrugEntry drug1) {
        int score = 0;
        for (String rarity : drug0.symptoms.keySet()) {
            for (String symptom : drug0.symptoms.get(rarity)) {
                for (String rarity0 : drug1.symptoms.keySet()) {
                    for (String symptom0 : drug1.symptoms.get(rarity0)) {
//                        String[] split0 = symptom.split(" ");
//                        String[] split1 = symptom0.split(" ");
//
//                        for (String word0 : split0) {
//                            word0 = word0.trim();
//                            word0 = word0.replaceAll("\\p{Punct}", "");
//                            word0 = word0.replaceAll(",", "");
//                            if ((!(word0.equalsIgnoreCase("and"))) && (!(word0.equalsIgnoreCase("or"))) && (!(word0.equalsIgnoreCase("the")))) {
//                                for (String word1 : split1) {
//                                    word1 = word1.trim();
//                                    word1 = word1.replaceAll("\\p{Punct}", "");
//                                    word1 = word1.replaceAll(",", "");
//                                    if ((!(word1.equalsIgnoreCase("and"))) && (!(word1.equalsIgnoreCase("or"))) && (!(word1.equalsIgnoreCase("the")))) {
//                                        if (word0.equalsIgnoreCase(word1)) {
//                                            score++;
//                                        }
//                                    }
//                                }
//                            }
//                        }
                        if (symptom0.equalsIgnoreCase(symptom)) {
                            score += 5;
                        }
                    }
                }
            }
        }
        if (score > 0) {
            if (!drug0.similarities.containsKey(drug1.pocId))
                drug0.similarities.put(drug1.pocId, 0);
            if (!drug1.similarities.containsKey(drug0.pocId))
                drug1.similarities.put(drug0.pocId, 0);
            drug0.similarities.replace(drug1.pocId, drug0.similarities.get(drug1.pocId) + score);
            drug1.similarities.replace(drug0.pocId, drug1.similarities.get(drug0.pocId) + score);
        }
    }
    private static void conditionConditionSimilarity(Conditions.ConditionEntry condition0, Conditions.ConditionEntry condition1) {
        int score = 0;
        for (String symptom0 : condition0.symptoms) {
            for (String symptom1 : condition1.symptoms) {
//                String[] split0 = symptom0.split(" ");
//                String[] split1 = symptom1.split(" ");
//
//                for (String word0 : split0) {
//                    word0 = word0.trim();
//                    word0 = word0.replaceAll("\\p{Punct}", "");
//                    word0 = word0.replaceAll(",", "");
//                    if ((!(word0.equalsIgnoreCase("and"))) && (!(word0.equalsIgnoreCase("or"))) && (!(word0.equalsIgnoreCase("the")))) {
//                        for (String word1 : split1) {
//                            word1 = word1.trim();
//                            word1 = word1.replaceAll("\\p{Punct}", "");
//                            word1 = word1.replaceAll(",", "");
//                            if ((!(word1.equalsIgnoreCase("and"))) && (!(word1.equalsIgnoreCase("or"))) && (!(word1.equalsIgnoreCase("the")))) {
//                                if (word0.equalsIgnoreCase(word1)) {
//                                    score++;
//                                }
//                            }
//                        }
//                    }
//                }
                if (symptom0.equalsIgnoreCase(symptom1)) {
                    score += 5;
                }
            }
        }
        if (score > 0) {
            if (!condition0.similarities.containsKey(condition1.pocId))
                condition0.similarities.put(condition1.pocId, 0);
            if (!condition1.similarities.containsKey(condition0.pocId))
                condition1.similarities.put(condition0.pocId, 0);
            condition0.similarities.replace(condition1.pocId, condition0.similarities.get(condition1.pocId) + score);
            condition1.similarities.replace(condition0.pocId, condition1.similarities.get(condition0.pocId) + score);
        }
        for (String cause : condition0.causes) {
            if (cause.toLowerCase().contains(condition1.name.toLowerCase())) {
                if (!condition0.similarities.containsKey(condition1.pocId))
                    condition0.similarities.put(condition1.pocId, 0);
                if (!condition1.similarities.containsKey(condition0.pocId))
                    condition1.similarities.put(condition0.pocId, 0);
                condition0.similarities.replace(condition1.pocId, condition0.similarities.get(condition1.pocId) + 5);
                condition1.similarities.replace(condition0.pocId, condition1.similarities.get(condition0.pocId) + 5);
            }
            for (String commonName : condition1.commonNames) {
                if (cause.toLowerCase().contains(commonName.toLowerCase())) {
                    if (!condition0.similarities.containsKey(condition1.pocId))
                        condition0.similarities.put(condition1.pocId, 0);
                    if (!condition1.similarities.containsKey(condition0.pocId))
                        condition1.similarities.put(condition0.pocId, 0);
                    condition0.similarities.replace(condition1.pocId, condition0.similarities.get(condition1.pocId) + 5);
                    condition1.similarities.replace(condition0.pocId, condition1.similarities.get(condition0.pocId) + 5);
                }
            }
        }
        for (String risk : condition0.risks) {
            if (risk.toLowerCase().contains(condition1.name.toLowerCase())) {
                if (!condition0.similarities.containsKey(condition1.pocId))
                    condition0.similarities.put(condition1.pocId, 0);
                if (!condition1.similarities.containsKey(condition0.pocId))
                    condition1.similarities.put(condition0.pocId, 0);
                condition0.similarities.replace(condition1.pocId, condition0.similarities.get(condition1.pocId) + 5);
                condition1.similarities.replace(condition0.pocId, condition1.similarities.get(condition0.pocId) + 5);
            }
            for (String commonName : condition1.commonNames) {
                if (risk.toLowerCase().contains(commonName.toLowerCase())) {
                    if (!condition0.similarities.containsKey(condition1.pocId))
                        condition0.similarities.put(condition1.pocId, 0);
                    if (!condition1.similarities.containsKey(condition0.pocId))
                        condition1.similarities.put(condition0.pocId, 0);
                    condition0.similarities.replace(condition1.pocId, condition0.similarities.get(condition1.pocId) + 5);
                    condition1.similarities.replace(condition0.pocId, condition1.similarities.get(condition0.pocId) + 5);
                }
            }
        }
        for (String risk0 : condition0.risks) {
            for (String risk1 : condition1.risks) {
                if (risk0.equalsIgnoreCase(risk1)) {
                    if (!condition0.similarities.containsKey(condition1.pocId))
                        condition0.similarities.put(condition1.pocId, 0);
                    if (!condition1.similarities.containsKey(condition0.pocId))
                        condition1.similarities.put(condition0.pocId, 0);
                    condition0.similarities.replace(condition1.pocId, condition0.similarities.get(condition1.pocId) + 5);
                    condition1.similarities.replace(condition0.pocId, condition1.similarities.get(condition0.pocId) + 5);
                }
            }
        }
        for (String complication : condition0.complications) {
            if (complication.toLowerCase().contains(condition1.name.toLowerCase())) {
                if (!condition0.similarities.containsKey(condition1.pocId))
                    condition0.similarities.put(condition1.pocId, 0);
                if (!condition1.similarities.containsKey(condition0.pocId))
                    condition1.similarities.put(condition0.pocId, 0);
                condition0.similarities.replace(condition1.pocId, condition0.similarities.get(condition1.pocId) + 5);
                condition1.similarities.replace(condition0.pocId, condition1.similarities.get(condition0.pocId) + 5);
            }
            for (String commonName : condition1.commonNames) {
                if (complication.toLowerCase().contains(commonName.toLowerCase())) {
                    if (!condition0.similarities.containsKey(condition1.pocId))
                        condition0.similarities.put(condition1.pocId, 0);
                    if (!condition1.similarities.containsKey(condition0.pocId))
                        condition1.similarities.put(condition0.pocId, 0);
                    condition0.similarities.replace(condition1.pocId, condition0.similarities.get(condition1.pocId) + 5);
                    condition1.similarities.replace(condition0.pocId, condition1.similarities.get(condition0.pocId) + 5);
                }
            }
        }
    }
}
