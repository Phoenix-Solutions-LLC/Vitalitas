import 'dart:convert';

import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:vitalitas/data/data.dart';
import 'package:vitalitas/main.dart';
import 'package:vitalitas/ui/appstate/health.dart';
import 'package:vitalitas/ui/appstate/healthdex.dart';

class Drug {
  static Uri api =
      Uri.https('www.patetlex.com', '/webapps/vitalitas/api/drugs/data.json');
  static Future<void> load() async {
    Drug.drugs.clear();

    var doc = await http.get(api);
    var json = jsonDecode(doc.body);
    dynamic ddata = await Data.getUserField('Drugs');
    if (ddata == null) {
      Data.setUserField('Drugs', []);
      ddata = [];
    }
    int i = 0;
    while (i < json.length) {
      Map<String, dynamic> obj = json[i];
      if (obj['name'] == null ||
          obj['pocId'] == null ||
          obj['description'] == null ||
          obj['backLink'] == null) {
        print('Cannot parse required elements for ' +
            (obj['name'] ?? 'unnamed') +
            ' of PocID ' +
            (obj['pocId'] ?? 'no id') +
            '.');
        continue;
      }
      Drug d = Drug(
          name: obj['name'].toString(),
          pocId: obj['pocId'].toString(),
          description: obj['description'].toString(),
          backLink: obj['backLink'].toString(),
          brandNames: obj['brandNames'] ?? [],
          symptoms: obj['symptoms'] ?? {});
      d.added = ddata.contains(obj['pocId'].toString());
      drugs.add(d);
      i++;
    }
    print('Loaded ' + i.toString() + ' drugs.');
  }

  static String search = '';
  static Widget getGrid(State state) {
    List<Widget> elements = [];
    drugs.forEach((drug) {
      bool flag = true;
      if (search.isNotEmpty) {
        if (!drug.name
            .trim()
            .toLowerCase()
            .contains(search.trim().toLowerCase())) {
          flag = false;
        }
        drug.brandNames.forEach((commonName) {
          if (!flag) {
            flag = true;
            if (!commonName
                .toString()
                .trim()
                .toLowerCase()
                .contains(search.trim().toLowerCase())) {
              flag = false;
            }
          }
        });
      }
      if (flag) {
        elements.add(
          Padding(
            padding: EdgeInsets.all(15),
            child: InkWell(
              onTap: () {
                state.setState(() {
                  HealthdexAppState.currentScreen = drug;
                });
              },
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Icon(
                      Icons.science_outlined,
                      size: 25,
                    ),
                    Text(drug.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Comfort',
                            fontSize: 8))
                  ],
                ),
              ),
            ),
          ),
        );
      }
    });
    return Center(
        child: Container(
      padding: EdgeInsets.only(left: 20, right: 20, top: 35),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                state.setState(() {
                  HealthdexAppState.currentScreen = 'main';
                });
              },
              child: Padding(
                  padding: EdgeInsets.only(bottom: 10, top: 20),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(children: [
                        Icon(Icons.arrow_back_ios_new_outlined),
                        DefaultTextStyle(
                            style: TextStyle(
                                fontFamily: 'Comfort',
                                fontSize: 10,
                                color: Vitalitas.theme.txt),
                            child: Text(
                              'Back',
                              textAlign: TextAlign.center,
                            ))
                      ]))),
            ),
            Padding(
              padding: EdgeInsets.only(top: 50, bottom: 50),
              child: DefaultTextStyle(
                  style: TextStyle(
                      fontFamily: 'Comfort',
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                      color: Vitalitas.theme.txt),
                  child: Text(
                    'Drugs',
                    textAlign: TextAlign.center,
                  )),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Search',
                    style: TextStyle(fontFamily: 'Comfort', fontSize: 15),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                      onChanged: (v) {
                        state.setState(() {
                          search = v.trim();
                        });
                      },
                      cursorColor: Vitalitas.theme.fg,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          fillColor: Color(0xfff3f3f4),
                          filled: true))
                ],
              ),
            ),
            Expanded(
                child: GridView.count(
              crossAxisCount: 3,
              children: elements,
            ))
          ]),
    ));
  }

  static List<Drug> drugs = [];

  final String name;
  final List<dynamic> brandNames;
  final String pocId;
  final String description;
  final Map symptoms;
  final String backLink;

  Drug(
      {required this.name,
      required this.pocId,
      required this.description,
      required this.backLink,
      this.brandNames = const [],
      this.symptoms = const {}});

  bool added = false;
  Widget getDetails(State state) {
    List<Widget> extraInfo = [];
    if (this.brandNames.isNotEmpty) {
      extraInfo.addAll(createInformationWidget(
          'Common Names', this.brandNames, Icons.abc_outlined));
    }
    for (String rarity in this.symptoms.keys) {
      extraInfo.addAll(createInformationWidget(
          rarity.substring(0, 1).toUpperCase() +
              rarity.substring(1) +
              ' Side Effects',
          this.symptoms[rarity],
          Icons.sick_outlined));
    }
    extraInfo.add(Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Add to Prescriptions:',
          style: TextStyle(
              fontFamily: 'Comfort',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Vitalitas.theme.txt),
        ),
        SizedBox(width: 25),
        AnimatedToggleSwitch.dual(
          current: added,
          first: true,
          second: false,
          dif: 50.0,
          borderColor: Colors.transparent,
          borderWidth: 5.0,
          height: 55,
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              spreadRadius: 1,
              blurRadius: 2,
              offset: Offset(0, 1.5),
            ),
          ],
          onChanged: (b) {
            added = b;
            state.setState(() {
              Data.getUserField('Age').then((age) {
                if (!(age is int) || age >= 18) {
                  Data.getUserField('Drugs').then((value) {
                    if (b) {
                      value.add(pocId);
                    } else {
                      value.remove(pocId);
                    }
                    Data.setUserField('Drugs', value);
                  });
                } else {
                  Data.setUserField('Drugs', []);
                }
              });
            });
          },
          colorBuilder: (b) => b ? Colors.greenAccent : Vitalitas.theme.fg,
          iconBuilder: (value) => value
              ? Icon(Icons.check, color: Colors.green)
              : Icon(
                  Icons.clear,
                  color: Colors.red,
                ),
          textBuilder: (value) => value
              ? Center(child: Text('Prescribed'))
              : Center(child: Text('None')),
        )
      ],
    ));
    extraInfo.add(SizedBox(
      height: 20,
    ));
    extraInfo.add(Center(
        child: DefaultTextStyle(
            style: TextStyle(
                fontFamily: 'Comfort',
                fontWeight: FontWeight.bold,
                fontSize: 25,
                color: Vitalitas.theme.txt),
            child: InkWell(
                onTap: () {
                  launchUrl(Uri.parse(backLink));
                },
                child: Text(
                  'Source: Mayo Clinic',
                  textAlign: TextAlign.center,
                )))));
    return Container(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20)),
                  color: Vitalitas.theme.acc,
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 20, color: Colors.black.withOpacity(0.1))
                  ]),
              child: Column(children: [
                SizedBox(
                  height: 35,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                      onTap: () {
                        state.setState(() {
                          HealthdexAppState.currentScreen = 'Drug';
                        });
                      },
                      child: Icon(
                        Icons.arrow_back_ios_new_outlined,
                        size: 30,
                      )),
                ),
                Center(
                    child: DefaultTextStyle(
                        style: TextStyle(
                            fontFamily: 'Comfort',
                            fontWeight: FontWeight.bold,
                            fontSize: 60,
                            color: Vitalitas.theme.txt),
                        child: Text(
                          name,
                          textAlign: TextAlign.center,
                        ))),
                SizedBox(
                  height: 10,
                ),
                Center(
                    child: DefaultTextStyle(
                        style: TextStyle(
                            fontFamily: 'Comfort',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Vitalitas.theme.txt),
                        child: Text(
                          pocId,
                          textAlign: TextAlign.center,
                        ))),
                SizedBox(
                  height: 50,
                ),
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Center(
                      child: DefaultTextStyle(
                          style: TextStyle(
                              fontFamily: 'Comfort',
                              fontSize: 20,
                              color: Vitalitas.theme.txt),
                          child: Text(
                            description,
                            textAlign: TextAlign.center,
                          )),
                    )),
                SizedBox(
                  height: 15,
                ),
              ]),
            ),
            SizedBox(
              height: 30,
            ),
            Column(
              children: extraInfo,
            )
          ],
        ),
      ),
    );
  }

  static List<Widget> createInformationWidget(
      String title, List<dynamic> info, IconData bullet) {
    List<Widget> extraInfo = [];
    List<Widget> li = [];
    info.forEach((i) {
      li.add(Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            Icon(bullet),
            SizedBox(
              width: 5,
            ),
            Expanded(
              child: DefaultTextStyle(
                  style: TextStyle(
                      fontFamily: 'Comfort',
                      fontSize: 14,
                      color: Vitalitas.theme.txt),
                  child: Text(
                    i,
                    textAlign: TextAlign.left,
                  )),
            ),
            SizedBox(
              height: 5,
            )
          ])));
    });
    extraInfo.add(Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: DefaultTextStyle(
              style: TextStyle(
                  fontFamily: 'Comfort',
                  fontWeight: FontWeight.bold,
                  fontSize: 35,
                  color: Vitalitas.theme.txt),
              child: Text(
                title,
                textAlign: TextAlign.left,
              )),
        ),
        SizedBox(
          height: 20,
        ),
        Column(
          children: li,
        ),
        SizedBox(
          height: 30,
        )
      ],
    ));
    return extraInfo;
  }
}
