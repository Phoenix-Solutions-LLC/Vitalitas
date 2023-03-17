import 'dart:convert';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vitalitas/data/data.dart';
import 'package:vitalitas/main.dart';
import 'package:vitalitas/ui/appstate/healthdex.dart';
import 'package:url_launcher/url_launcher.dart';

class Condition {
  static Uri api = Uri.https(
      'www.patetlex.com', '/webapps/vitalitas/api/conditions/data.json');
  static Future<void> load() async {
    var doc = await http.get(api);
    var json = jsonDecode(doc.body);
    dynamic cdata = await Data.getUserField('Conditions');
    if (cdata == null) {
      Data.setUserField('Conditions', []);
      cdata = [];
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
      Condition c = Condition(
          name: obj['name'].toString(),
          pocId: obj['pocId'].toString(),
          description: obj['description'].toString(),
          backLink: obj['backLink'].toString(),
          commonNames: obj['commonNames'] ?? [],
          symptoms: obj['symptoms'] ?? [],
          causes: obj['causes'] ?? [],
          risks: obj['risks'] ?? [],
          complications: obj['complications'] ?? [],
          preventions: obj['preventions'] ?? [],
          diagnosis: obj['diagnosis'] ?? [],
          treatment: obj['treatment'] ?? []);
      c.added = cdata.contains(obj['pocId'].toString());
      conditions.add(c);
      i++;
    }
    print('Loaded ' + i.toString() + ' conditions.');
  }

  static String search = '';
  static Widget getGrid(State state) {
    List<Widget> elements = [];
    conditions.forEach((condition) {
      bool flag = true;
      if (search.isNotEmpty) {
        if (!condition.name
            .trim()
            .toLowerCase()
            .contains(search.trim().toLowerCase())) {
          flag = false;
        }
        condition.commonNames.forEach((commonName) {
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
                  HealthdexAppState.currentScreen = condition;
                });
              },
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Icon(
                      Icons.accessibility_outlined,
                      size: 25,
                    ),
                    Text(condition.name,
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
      padding: EdgeInsets.symmetric(horizontal: 20),
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
                  padding: EdgeInsets.only(bottom: 10, top: 20, left: 20),
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
              padding: EdgeInsets.only(bottom: 50),
              child: DefaultTextStyle(
                  style: TextStyle(
                      fontFamily: 'Comfort',
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                      color: Vitalitas.theme.txt),
                  child: Text(
                    'Conditions',
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

  static List<Condition> conditions = [];

  final String name;
  final List<dynamic> commonNames;
  final String pocId;
  final String description;
  final List<dynamic> symptoms;
  final List<dynamic> causes;
  final List<dynamic> risks;
  final List<dynamic> complications;
  final List<dynamic> preventions;
  final List<dynamic> diagnosis;
  final List<dynamic> treatment;
  final String backLink;

  Condition(
      {required this.name,
      required this.pocId,
      required this.description,
      required this.backLink,
      this.commonNames = const [],
      this.symptoms = const [],
      this.risks = const [],
      this.complications = const [],
      this.causes = const [],
      this.preventions = const [],
      this.diagnosis = const [],
      this.treatment = const []});

  bool added = false;
  Widget getDetails(State state) {
    List<Widget> extraInfo = [];
    if (this.commonNames.isNotEmpty) {
      extraInfo.addAll(createInformationWidget(
          'Common Names', this.commonNames, Icons.abc_outlined));
    }
    if (this.symptoms.isNotEmpty) {
      extraInfo.addAll(createInformationWidget(
          'Symptoms', this.symptoms, Icons.sick_outlined));
    }
    if (this.risks.isNotEmpty) {
      extraInfo.addAll(
          createInformationWidget('Risks', this.risks, Icons.percent_outlined));
    }
    if (this.complications.isNotEmpty) {
      extraInfo.addAll(createInformationWidget(
          'Complications', this.complications, Icons.accessible_outlined));
    }
    if (this.causes.isNotEmpty) {
      extraInfo
          .addAll(createInformationWidget('Causes', this.causes, Icons.input));
    }
    if (this.preventions.isNotEmpty) {
      extraInfo.addAll(createInformationWidget(
          'Preventions', this.preventions, Icons.blind_outlined));
    }
    if (this.diagnosis.isNotEmpty) {
      extraInfo.addAll(createInformationWidget(
          'Diagnosis', this.diagnosis, Icons.info_outline));
    }
    if (this.treatment.isNotEmpty) {
      extraInfo.addAll(createInformationWidget(
          'Treatment', this.treatment, Icons.science_outlined));
    }
    extraInfo.add(Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Add to Diagnosis:',
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
              Data.getUserField('Conditions').then((value) {
                if (b) {
                  value.add(pocId);
                } else {
                  value.remove(pocId);
                }
                Data.setUserField('Conditions', value);
              });
            });
          },
          colorBuilder: (b) => b ? Colors.greenAccent : Vitalitas.theme.fg,
          iconBuilder: (value) => value
              ? Icon(Icons.check_rounded, color: Colors.green)
              : Icon(
                  Icons.clear,
                  color: Colors.red,
                ),
          textBuilder: (value) => value
              ? Center(child: Text('Diagnosed'))
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
                  'Learn More',
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
                  height: 15,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                      onTap: () {
                        state.setState(() {
                          HealthdexAppState.currentScreen = 'Condition';
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
