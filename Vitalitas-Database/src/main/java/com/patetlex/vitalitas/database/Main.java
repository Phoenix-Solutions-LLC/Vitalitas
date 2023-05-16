package com.patetlex.vitalitas.database;

import com.patetlex.vitalitas.database.scrape.bodybuilding.Exercises;
import com.patetlex.vitalitas.database.scrape.mayoclinic.Conditions;
import com.patetlex.vitalitas.database.scrape.mayoclinic.Drugs;
import com.patetlex.vitalitas.database.scrape.misc.Quotes;


public class Main {
    public static void main(String[] args) {
/*        DatabaseBuilder builder = new DatabaseBuilder().fromApi(new Exercises()).fromApi(new Conditions()).fromApi(new Drugs()).scrapeSitemap(new Quotes());

        int tokens = builder.build();
        System.out.println("Uses " + tokens + " tokens. Cost estimate of $" + ((tokens / 1000) * 0.012) + ".");*/

        DatabaseBuilder builder = new DatabaseBuilder().scrapeSitemap(new Conditions());
        builder.build();
    }
}
