package com.patetlex.vitalitas.database;

import com.patetlex.vitalitas.database.scrape.DataEntry;
import com.patetlex.vitalitas.database.scrape.ScrapeableSitemap;
import com.patetlex.vitalitas.database.scrape.bodybuilding.Exercises;
import com.patetlex.vitalitas.database.scrape.mayoclinic.Conditions;
import com.patetlex.vitalitas.database.scrape.mayoclinic.Drugs;
import com.patetlex.vitalitas.database.scrape.misc.Quotes;
import com.patetlex.vitalitas.database.util.MayoClinicHelper;

import java.util.*;


public class Main {
    public static void main(String[] args) {
/*        DatabaseBuilder builder = new DatabaseBuilder().fromApi(new Exercises()).fromApi(new Conditions()).fromApi(new Drugs()).scrapeSitemap(new Quotes());

        int tokens = builder.build();
        System.out.println("Uses " + tokens + " tokens. Cost estimate of $" + ((tokens / 1000) * 0.012) + ".");*/

        Drugs drugs = new Drugs();
        Conditions conditions = new Conditions();
        DatabaseBuilder builder = new DatabaseBuilder().fromApi(drugs).fromApi(conditions);
        System.out.println(builder.getData().get(drugs).size()); // 2634
        System.out.println(builder.getData().get(conditions).size()); // 1148
//        builder.crop(0, 100, drugs);
//        builder.crop(0, 100, conditions);
        System.out.println(builder.getData().get(drugs).size()); // 1317
        System.out.println(builder.getData().get(conditions).size()); // 574
        MayoClinicHelper.propagateSimilarities(builder);
        builder.build();
    }
}
