import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:vitalitas/data/bodybuilding/exercise.dart';
import 'package:vitalitas/data/data.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:vitalitas/data/mayoclinic/conditon.dart';
import 'package:vitalitas/data/mayoclinic/drug.dart';
import 'package:vitalitas/main.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:vitalitas/data/bodybuilding/impl/workout.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class Survey {
  List<Question> questions = [];
  int currentIndex = 0;
  Function onQuestionCompletion = () {};

  double totalWeight = 0;
  double values = 0;
  List<String> feedbackList = [];

  void submit(double value, double weight) {
    totalWeight += weight;
    values += value * weight;
    onQuestionCompletion();
  }

  void addToFeedback(String feedback) {
    feedbackList.add(feedback);
  }

  double calculate() {
    if (totalWeight == 0) {
      return 0;
    }
    return values / totalWeight;
  }

  String formulateResults() {
    String feedback = '';
    for (String fb in feedbackList) {
      feedback = feedback.trim() + ' ' + fb.trim();
    }
    return feedback;
  }

  static Future<Survey> build(State state) async {
    Survey survey = Survey();

    num sleep = -1;
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      HealthFactory health = HealthFactory();
      DateTime now = DateTime.now();

      var types = [
        HealthDataType.SLEEP_ASLEEP,
        HealthDataType.HEIGHT,
        HealthDataType.WEIGHT,
        HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
        HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
        HealthDataType.HEART_RATE
      ];

      bool? perms = await HealthFactory.hasPermissions(types);
      if (perms ?? false) {
        List<HealthDataPoint> data = await health.getHealthDataFromTypes(
            DateTime(now.year, now.month, now.day - 1),
            DateTime(now.year, now.month, now.day),
            types);

        num sysPressure = -1;
        num diaPressure = -1;
        num heartRate = -1;
        for (HealthDataPoint dataPoint in data) {
          if (dataPoint.type == HealthDataType.SLEEP_ASLEEP) {
            sleep = ((dataPoint.value as NumericHealthValue).numericValue) / 60;
          } else if (dataPoint.type == HealthDataType.HEIGHT) {
            await Data.setUserField(
                'Height',
                (((dataPoint.value as NumericHealthValue)
                            .numericValue
                            .toDouble()) *
                        39.3700787)
                    .round());
          } else if (dataPoint.type == HealthDataType.WEIGHT) {
            await Data.setUserField(
                'Weight',
                (((dataPoint.value as NumericHealthValue)
                            .numericValue
                            .toDouble()) *
                        2.20462262)
                    .round());
          } else if (dataPoint.type == HealthDataType.BLOOD_PRESSURE_SYSTOLIC) {
            sysPressure = (dataPoint.value as NumericHealthValue).numericValue;
          } else if (dataPoint.type ==
              HealthDataType.BLOOD_PRESSURE_DIASTOLIC) {
            diaPressure = (dataPoint.value as NumericHealthValue).numericValue;
          } else if (dataPoint.type == HealthDataType.HEART_RATE) {
            heartRate = (dataPoint.value as NumericHealthValue).numericValue;
          }
        }
        if (sysPressure > 0 && diaPressure > 0) {
          num regSys = sysPressure - 120;
          num regDia = diaPressure - 80;
          num totalD = 0;

          if (regSys > 0 || regDia > 0) {
            bool flag = false;
            for (Condition condition in Condition.conditions) {
              if (condition.pocId == 'CON-20373392') {
                if (!condition.added) {
                  condition.added = true;
                  flag = true;
                }
                break;
              }
            }
            String pre = flag
                ? 'High blood presssure has been added to your conditions.'
                : 'Your high blood pressure has been prolonged. Watch for symptoms and contact a medical professional';
            survey.addToFeedback(pre +
                ' Try breathing exercises in the morning or a proper diet.');
          }
          if (regSys > 0) {
            totalD += (regSys / 20);
          }
          if (regDia > 0) {
            totalD += (regDia / 20);
          }
          totalD = totalD.clamp(0, 1);
          num invV = 1 - totalD;

          survey.submit(invV.toDouble(), 5);
        }

        if (heartRate > 0) {
          num reqHr = heartRate - 60;
          num totalD = 0;
          if (reqHr > 0) {
            totalD += (reqHr / 40);

            if (reqHr < 20) {
              survey.addToFeedback('Your resting heart rate is slightly high.');
            } else if (reqHr < 40) {
              survey.addToFeedback('Your resting heart rate is high.');
            } else {
              survey.addToFeedback(
                  'Your resting heart rate is very high. Seek a doctor if you experience symptoms such as palpitations.');
            }
          }
          totalD = totalD.clamp(0, 1);
          num invV = 1 - totalD;

          survey.submit(invV.toDouble(), 3);
        }
      }
    }

    List<Question> possibleQuestions = [];

    // Understanding
    possibleQuestions.add(Question(
        priority: 0,
        question:
            'This survey will formulate 0-10 questions for you to answer. This survey may ask for personal information regarding diagnosis, medications, and other medical information which will never be shared publicly. Your response to each question will add weight to a final score we denote as your daily health score.',
        answerWidget: (question) {
          return AnimatedButton(
            text: 'Proceed',
            textStyle: TextStyle(
              fontFamily: 'Comfort',
              color: Vitalitas.theme.txt,
              fontSize: 25,
            ),
            onPress: () {
              survey.submit(0, 0);
            },
            animatedOn: AnimatedOn.onHover,
            height: 50,
            width: 150,
            borderWidth: 4,
            borderRadius: 25,
            backgroundColor: Vitalitas.theme.acc!,
            selectedBackgroundColor: Vitalitas.theme.fg!,
            selectedTextColor: Vitalitas.theme.bg!,
            borderColor: Vitalitas.theme.fg!,
          );
        }));

    dynamic age = await Data.getUserField('Age');
    if (!(age is int)) {
      possibleQuestions.add(Question(
          priority: 1,
          question: 'What is your age?',
          answerWidget: (question) {
            return Column(
              children: [
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 75),
                    child: SfSlider(
                      min: 0,
                      max: 100,
                      activeColor: Vitalitas.theme.fg,
                      inactiveColor: Vitalitas.theme.acc,
                      value: question.value ?? 18,
                      interval: 10,
                      showLabels: true,
                      enableTooltip: true,
                      stepSize: 1,
                      minorTicksPerInterval: 8,
                      showTicks: true,
                      onChanged: (value) {
                        state.setState(() {
                          question.value = value;
                        });
                      },
                    )),
                SizedBox(
                  height: 40,
                ),
                AnimatedButton(
                  text: 'Submit',
                  textStyle: TextStyle(
                    fontFamily: 'Comfort',
                    color: Vitalitas.theme.txt,
                    fontSize: 25,
                  ),
                  onPress: () {
                    if (!(question.value is num)) {
                      question.value = 18;
                    }
                    Data.setUserField(
                        'Age', ((question.value as num).toInt()).clamp(1, 100));
                    survey.submit(0, 0);
                  },
                  animatedOn: AnimatedOn.onHover,
                  height: 50,
                  width: 150,
                  borderWidth: 4,
                  borderRadius: 25,
                  backgroundColor: Vitalitas.theme.acc!,
                  selectedBackgroundColor: Vitalitas.theme.fg!,
                  selectedTextColor: Vitalitas.theme.bg!,
                  borderColor: Vitalitas.theme.fg!,
                )
              ],
            );
          }));
    }

    dynamic weight = await Data.getUserField('Weight');
    if (!(weight is int)) {
      possibleQuestions.add(Question(
          priority: 1,
          question: 'What is your weight (pounds)?',
          answerWidget: (question) {
            return Column(
              children: [
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 75),
                    child: SfSlider(
                      min: 50,
                      max: 350,
                      activeColor: Vitalitas.theme.fg,
                      inactiveColor: Vitalitas.theme.acc,
                      value: question.value ?? 150,
                      interval: 50,
                      showLabels: true,
                      enableTooltip: true,
                      stepSize: 1,
                      minorTicksPerInterval: 5,
                      showTicks: true,
                      onChanged: (value) {
                        state.setState(() {
                          question.value = value;
                        });
                      },
                    )),
                SizedBox(
                  height: 40,
                ),
                AnimatedButton(
                  text: 'Submit',
                  textStyle: TextStyle(
                    fontFamily: 'Comfort',
                    color: Vitalitas.theme.txt,
                    fontSize: 25,
                  ),
                  onPress: () {
                    if (!(question.value is num)) {
                      question.value = 150;
                    }
                    Data.setUserField('Weight',
                        ((question.value as num).toInt()).clamp(50, 350));
                    survey.submit(0, 0);
                  },
                  animatedOn: AnimatedOn.onHover,
                  height: 50,
                  width: 150,
                  borderWidth: 4,
                  borderRadius: 25,
                  backgroundColor: Vitalitas.theme.acc!,
                  selectedBackgroundColor: Vitalitas.theme.fg!,
                  selectedTextColor: Vitalitas.theme.bg!,
                  borderColor: Vitalitas.theme.fg!,
                )
              ],
            );
          }));
    }

    dynamic height = await Data.getUserField('Height');
    if (!(height is int)) {
      possibleQuestions.add(Question(
          priority: 1,
          question: 'What is your height (inches)?',
          answerWidget: (question) {
            return Column(
              children: [
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 75),
                    child: SfSlider(
                      min: 36,
                      max: 96,
                      activeColor: Vitalitas.theme.fg,
                      inactiveColor: Vitalitas.theme.acc,
                      value: question.value ?? 72,
                      interval: 10,
                      showLabels: true,
                      enableTooltip: true,
                      stepSize: 1,
                      minorTicksPerInterval: 5,
                      showTicks: true,
                      onChanged: (value) {
                        state.setState(() {
                          question.value = value;
                        });
                      },
                    )),
                SizedBox(
                  height: 40,
                ),
                AnimatedButton(
                  text: 'Submit',
                  textStyle: TextStyle(
                    fontFamily: 'Comfort',
                    color: Vitalitas.theme.txt,
                    fontSize: 25,
                  ),
                  onPress: () {
                    if (!(question.value is num)) {
                      question.value = 72;
                    }
                    Data.setUserField('Height',
                        ((question.value as num).toInt()).clamp(1, 100));
                    survey.submit(0, 0);
                  },
                  animatedOn: AnimatedOn.onHover,
                  height: 50,
                  width: 150,
                  borderWidth: 4,
                  borderRadius: 25,
                  backgroundColor: Vitalitas.theme.acc!,
                  selectedBackgroundColor: Vitalitas.theme.fg!,
                  selectedTextColor: Vitalitas.theme.bg!,
                  borderColor: Vitalitas.theme.fg!,
                )
              ],
            );
          }));
    }

    possibleQuestions.add(Question(
        priority: 2,
        question:
            'Indicate your happiness from the past 24 hours on a scale from 0 (depressed) to 5 (content) to 10 (ecstatic)?',
        answerWidget: (question) {
          return Column(
            children: [
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 75),
                  child: SfSlider(
                    min: 0,
                    max: 10,
                    activeColor: Vitalitas.theme.fg,
                    inactiveColor: Vitalitas.theme.acc,
                    value: question.value ?? 5,
                    interval: 1,
                    showLabels: true,
                    enableTooltip: true,
                    stepSize: 1,
                    minorTicksPerInterval: 0,
                    onChanged: (value) {
                      state.setState(() {
                        question.value = value;
                      });
                    },
                  )),
              SizedBox(
                height: 40,
              ),
              AnimatedButton(
                text: 'Submit',
                textStyle: TextStyle(
                  fontFamily: 'Comfort',
                  color: Vitalitas.theme.txt,
                  fontSize: 25,
                ),
                onPress: () {
                  if (!(question.value is num)) {
                    question.value = 5;
                  }
                  int hap = ((question.value as num).toInt()).clamp(0, 10);
                  double v = (1 / 26.66) * pow(hap - 5, 3) + 0.7;
                  if (v > 1) {
                    v = 1;
                  } else if (v < 0) {
                    v = 0;
                  }
                  if (v < 0.3) {
                    survey.addToFeedback(
                        'Listen to your emotions. If depression persists, seek a medical professional.');
                  } else if (v < 0.5) {
                    survey.addToFeedback(
                        'Try breathing exercises, listening to music, or focusing on what makes you happy.');
                  }
                  survey.submit(v, 7);
                },
                animatedOn: AnimatedOn.onHover,
                height: 50,
                width: 150,
                borderWidth: 4,
                borderRadius: 25,
                backgroundColor: Vitalitas.theme.acc!,
                selectedBackgroundColor: Vitalitas.theme.fg!,
                selectedTextColor: Vitalitas.theme.bg!,
                borderColor: Vitalitas.theme.fg!,
              )
            ],
          );
        }));

    if (sleep < 0) {
      possibleQuestions.add(Question(
          priority: 2,
          question: 'How much sleep did u get last night (hour)?',
          answerWidget: (question) {
            return Column(
              children: [
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 75),
                    child: SfSlider(
                      min: 0,
                      max: 12,
                      activeColor: Vitalitas.theme.fg,
                      inactiveColor: Vitalitas.theme.acc,
                      value: question.value ?? 7,
                      interval: 1,
                      showLabels: true,
                      enableTooltip: true,
                      stepSize: 1,
                      minorTicksPerInterval: 0,
                      onChanged: (value) {
                        state.setState(() {
                          question.value = value;
                        });
                      },
                    )),
                SizedBox(
                  height: 40,
                ),
                AnimatedButton(
                  text: 'Submit',
                  textStyle: TextStyle(
                    fontFamily: 'Comfort',
                    color: Vitalitas.theme.txt,
                    fontSize: 25,
                  ),
                  onPress: () {
                    if (!(question.value is num)) {
                      question.value = 7;
                    }
                    if (question.value < 7) {
                      survey.addToFeedback(
                          'You are sleep deprived. Make sure to get rest today. Watch out for symptoms of fatigue or headaches.');
                    } else if (question.value > 10) {
                      survey.addToFeedback(
                          'You overslept. Watch out for symptoms of brain fog or anxiety.');
                    }
                    int sHr = ((question.value as num).toInt()).clamp(0, 12);
                    double v = sHr / 9.5;
                    if (v > 1) {
                      double top = v - v.floor();
                      v = v - (top * 2);
                    }
                    survey.submit(v, 7);
                  },
                  animatedOn: AnimatedOn.onHover,
                  height: 50,
                  width: 150,
                  borderWidth: 4,
                  borderRadius: 25,
                  backgroundColor: Vitalitas.theme.acc!,
                  selectedBackgroundColor: Vitalitas.theme.fg!,
                  selectedTextColor: Vitalitas.theme.bg!,
                  borderColor: Vitalitas.theme.fg!,
                )
              ],
            );
          }));
    } else {
      int sHr = sleep.toDouble().round().clamp(0, 12);
      if (sHr < 7) {
        survey.addToFeedback(
            'You are sleep deprived. Make sure to get rest today. Watch out for symptoms of fatigue or headaches.');
      } else if (sHr > 10) {
        survey.addToFeedback(
            'You overslept. Watch out for symptoms of brain fog or anxiety.');
      }
      double v = sHr / 9.5;
      if (v > 1) {
        double top = v - v.floor();
        v = v - top;
      }
      survey.submit(v, 7);
    }

    if (age != null && age is int && age >= 18) {
      for (Drug drug in Drug.drugs) {
        if (drug.added) {
          List<Widget> sideEffects = [];
          for (String rarity in drug.symptoms.keys) {
            sideEffects.add(SizedBox(
              height: 10,
            ));
            sideEffects.add(Text(
              rarity.substring(0, 1).toUpperCase() + rarity.substring(1),
              style: TextStyle(
                  fontFamily: 'Comfort',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Vitalitas.theme.txt),
            ));
            sideEffects.add(SizedBox(
              height: 10,
            ));
            for (String sideEffect in drug.symptoms[rarity]) {
              sideEffects.add(Text(
                sideEffect,
                style: TextStyle(
                    fontFamily: 'Comfort',
                    fontSize: 16,
                    color: Vitalitas.theme.txt),
              ));
              sideEffects.add(SizedBox(
                height: 5,
              ));
            }
          }
          possibleQuestions.add(Question(
              priority: 3,
              question:
                  'Have you experienced any of the following side effects due to your listed prescription ' +
                      drug.name.trim() +
                      ' in the past 24 hours, submit severity from (none) 0-10 (unbearable)?',
              answerWidget: (question) {
                return Column(
                  children: [
                    SizedBox(
                      height: 50,
                    ),
                    Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(40)),
                            color: const Color.fromARGB(255, 221, 221, 221),
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 20,
                                  color: Colors.black.withOpacity(0.1))
                            ]),
                        child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Column(children: sideEffects))),
                    SizedBox(
                      height: 50,
                    ),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 75),
                        child: SfSlider(
                          min: 0,
                          max: 10,
                          activeColor: Vitalitas.theme.fg,
                          inactiveColor: Vitalitas.theme.acc,
                          value: question.value ?? 5,
                          interval: 1,
                          showLabels: true,
                          enableTooltip: true,
                          stepSize: 1,
                          minorTicksPerInterval: 0,
                          onChanged: (value) {
                            state.setState(() {
                              question.value = value;
                            });
                          },
                        )),
                    SizedBox(
                      height: 40,
                    ),
                    AnimatedButton(
                      text: 'Submit',
                      textStyle: TextStyle(
                        fontFamily: 'Comfort',
                        color: Vitalitas.theme.txt,
                        fontSize: 25,
                      ),
                      onPress: () {
                        if (!(question.value is num)) {
                          question.value = 5;
                        }
                        if (question.value > 7) {
                          survey.addToFeedback('If side effects of ' +
                              drug.name +
                              ' persist, seek a medical professional for a change in medication.');
                        } else if (question.value > 3) {
                          survey.addToFeedback('If side effects of ' +
                              drug.name +
                              ' become uncomfortable, seek a medical professional for a change in medication.');
                        }
                        int pain =
                            ((question.value as num).toInt()).clamp(0, 10);
                        int reg = 10 - pain;
                        double v = reg / 10;
                        survey.submit(v, 10);
                      },
                      animatedOn: AnimatedOn.onHover,
                      height: 50,
                      width: 150,
                      borderWidth: 4,
                      borderRadius: 25,
                      backgroundColor: Vitalitas.theme.acc!,
                      selectedBackgroundColor: Vitalitas.theme.fg!,
                      selectedTextColor: Vitalitas.theme.bg!,
                      borderColor: Vitalitas.theme.fg!,
                    )
                  ],
                );
              }));
        }
      }
      for (Condition condition in Condition.conditions) {
        if (condition.added) {
          List<Widget> symptoms = [];
          symptoms.add(SizedBox(
            height: 10,
          ));
          symptoms.add(Text(
            'Symptoms',
            style: TextStyle(
                fontFamily: 'Comfort',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Vitalitas.theme.txt),
          ));
          for (String symptom in condition.symptoms) {
            symptoms.add(Text(
              symptom,
              style: TextStyle(
                  fontFamily: 'Comfort',
                  fontSize: 16,
                  color: Vitalitas.theme.txt),
            ));
            symptoms.add(SizedBox(
              height: 5,
            ));
          }
          possibleQuestions.add(Question(
              priority: 3,
              question:
                  'Have you experienced any of the following symptoms due to your listed condition ' +
                      condition.name.trim() +
                      ' in the past 24 hours, submit severity from (none) 0-10 (unbearable)?',
              answerWidget: (question) {
                return Column(
                  children: [
                    SizedBox(
                      height: 50,
                    ),
                    Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(40)),
                            color: const Color.fromARGB(255, 221, 221, 221),
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 20,
                                  color: Colors.black.withOpacity(0.1))
                            ]),
                        child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Column(children: symptoms))),
                    SizedBox(
                      height: 50,
                    ),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 75),
                        child: SfSlider(
                          min: 0,
                          max: 10,
                          activeColor: Vitalitas.theme.fg,
                          inactiveColor: Vitalitas.theme.acc,
                          value: question.value ?? 5,
                          interval: 1,
                          showLabels: true,
                          enableTooltip: true,
                          stepSize: 1,
                          minorTicksPerInterval: 0,
                          onChanged: (value) {
                            state.setState(() {
                              question.value = value;
                            });
                          },
                        )),
                    SizedBox(
                      height: 40,
                    ),
                    AnimatedButton(
                      text: 'Submit',
                      textStyle: TextStyle(
                        fontFamily: 'Comfort',
                        color: Vitalitas.theme.txt,
                        fontSize: 25,
                      ),
                      onPress: () {
                        if (!(question.value is num)) {
                          question.value = 5;
                        }
                        if (question.value > 7) {
                          survey.addToFeedback(
                              'Seek a medical professional for a change in your treatment plan for ' +
                                  condition.name +
                                  '.');
                        } else if (question.value > 3) {
                          survey.addToFeedback('If symptoms of ' +
                              condition.name +
                              ' increase, seek a medical professional for advice.');
                        }
                        int pain =
                            ((question.value as num).toInt()).clamp(0, 10);
                        int reg = 10 - pain;
                        double v = reg / 10;
                        survey.submit(v, 10);
                      },
                      animatedOn: AnimatedOn.onHover,
                      height: 50,
                      width: 150,
                      borderWidth: 4,
                      borderRadius: 25,
                      backgroundColor: Vitalitas.theme.acc!,
                      selectedBackgroundColor: Vitalitas.theme.fg!,
                      selectedTextColor: Vitalitas.theme.bg!,
                      borderColor: Vitalitas.theme.fg!,
                    )
                  ],
                );
              }));
        }
      }
    }

    if (Exercise.yesterdaysWorkout != null) {
      double v = 0;
      double t = 0;
      for (Set set in Exercise.yesterdaysWorkout!.sets) {
        v += set.complete ? 1 : 0;
        t++;
      }
      if (v < 0.33) {
        survey.addToFeedback(
            'Make sure you are completing your workouts. Doctors recommend at least 40 minutes of quality exercise per day.');
      }
      survey.submit(t == 0 ? 0 : v / t, t == 0 ? 0 : 5);
    }

    // Sorting
    List<Question> questions = [];
    Random rand = Random();
    Map<int, List<Question>> priorityMap = {};
    int highestPriority = 0;
    for (Question question in possibleQuestions) {
      if (!priorityMap.containsKey(question.priority)) {
        priorityMap[question.priority] = [];
        if (question.priority > highestPriority) {
          highestPriority = question.priority;
        }
      }
      priorityMap[question.priority]!.add(question);
    }
    for (int priority = 0; priority <= highestPriority; priority++) {
      if (priorityMap.containsKey(priority)) {
        if (questions.length + priorityMap[priority]!.length <= 10) {
          questions.addAll(priorityMap[priority]!);
        } else {
          int left = 10 - questions.length;
          while (left > 0) {
            Question question = priorityMap[priority]![
                rand.nextInt(priorityMap[priority]!.length)];
            questions.add(question);
            priorityMap[priority]!.remove(question);
            left--;
          }
        }
      }
    }
    survey.questions = questions;
    return survey;
  }
}

class Question {
  final int priority;
  final String question;
  final Function(Question) answerWidget;

  dynamic value;

  Question(
      {required this.priority,
      required this.question,
      required this.answerWidget});
}
