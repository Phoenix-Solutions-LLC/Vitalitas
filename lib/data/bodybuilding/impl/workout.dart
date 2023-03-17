import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vitalitas/data/bodybuilding/exercise.dart';
import 'package:vitalitas/data/data.dart';

class Workout {
  List<Set> sets = [];
  double intensity = 1;

  Workout();

  void addSet(int sets, List<Repetition> exercises) {
    this.sets.add(Set(sets: sets, exercises: exercises));
  }

  Workout.fromJson(Map<String, dynamic> json)
      : sets = (json['sets'] as List).map((set) => Set.fromJson(set)).toList(),
        intensity = json['intensity'] as double;

  Map<String, dynamic> toJson() {
    return {'sets': sets, 'intensity': intensity};
  }

  static Future<void> update() async {
    Map<String, String> data = {};
    for (DateTime date in Exercise.workouts.keys) {
      data[date.toString()] =
          base64Encode(utf8.encode(jsonEncode(Exercise.workouts[date])));
    }
    Data.setUserField('Workouts', data);
  }

  static Workout build(int sets, int exercisesPerSet, double intensity,
      List<String> muscleGroups) {
    Random rand = Random();

    List<String> groups = [];
    for (int i = 0; i < sets; i++) {
      String g = muscleGroups[rand.nextInt(muscleGroups.length)];
      muscleGroups.remove(g);
      groups.add(g);
    }

    List<Repetition> warmupSet = [];
    List<Set> exerciseSets = [];
    for (String group in groups) {
      List<Exercise> cardioExercises = [];
      List<Exercise> preferredCardioExercises = [];
      List<Exercise> stretchExercises = [];
      List<Exercise> preferredStretchExercises = [];
      List<Exercise> strengtheningExercises = [];
      List<Exercise> preferredStrengtheningExercises = [];

      for (Exercise exercise in Exercise.exercises) {
        if (exercise.muscleGroup == group) {
          if (exercise.exerciseType == 'cardio') {
            if (exercise.added) {
              preferredCardioExercises.add(exercise);
            }
            cardioExercises.add(exercise);
          } else if (exercise.exerciseType == 'stretching') {
            if (exercise.added) {
              preferredStretchExercises.add(exercise);
            }
            stretchExercises.add(exercise);
          } else {
            if (exercise.added) {
              preferredStrengtheningExercises.add(exercise);
            }
            strengtheningExercises.add(exercise);
          }
        }
      }

      Repetition? stretchCardioExercise;
      if (cardioExercises.isNotEmpty && rand.nextBool()) {
        double calculatedReps = (5 / intensity);
        double remainder = calculatedReps - calculatedReps.floor();
        int seconds = (remainder * 60).round();
        if (preferredCardioExercises.isNotEmpty) {
          stretchCardioExercise = Repetition(
              exercise: preferredCardioExercises[
                  rand.nextInt(preferredCardioExercises.length)],
              repetitions: calculatedReps.floor(),
              units: 'minutes' +
                  (seconds == 0 ? '' : ' ' + seconds.toString() + ' seconds'));
        } else {
          stretchCardioExercise = Repetition(
              exercise: cardioExercises[rand.nextInt(cardioExercises.length)],
              repetitions: calculatedReps.floor(),
              units: 'minutes' +
                  (seconds == 0 ? '' : ' ' + seconds.toString() + ' seconds'));
        }
      } else if (stretchExercises.isNotEmpty) {
        if (preferredStretchExercises.isNotEmpty) {
          stretchCardioExercise = Repetition(
              exercise: preferredStretchExercises[
                  rand.nextInt(preferredStretchExercises.length)],
              repetitions: 30,
              units: 'seconds');
        } else {
          stretchCardioExercise = Repetition(
              exercise: stretchExercises[rand.nextInt(stretchExercises.length)],
              repetitions: 30,
              units: 'seconds');
        }
      }

      List<Repetition> exercises = [];
      for (int i = 0; i < exercisesPerSet; i++) {
        if (strengtheningExercises.isEmpty) {
          break;
        }
        if (preferredStrengtheningExercises.isNotEmpty) {
          Exercise exercise = preferredStrengtheningExercises[
              rand.nextInt(preferredStrengtheningExercises.length)];
          preferredStrengtheningExercises.remove(exercise);
          exercises.add(Repetition(
              exercise: exercise,
              repetitions:
                  ((exercise.exerciseType == 'strength' ? 10 : 5) * intensity)
                      .round(),
              units: 'repetitions'));
          continue;
        }
        Exercise exercise =
            strengtheningExercises[rand.nextInt(strengtheningExercises.length)];
        strengtheningExercises.remove(exercise);
        exercises.add(Repetition(
            exercise: exercise,
            repetitions:
                ((exercise.exerciseType == 'strength' ? 10 : 5) * intensity)
                    .round(),
            units: 'repetitions'));
      }
      if (stretchCardioExercise != null) {
        warmupSet.add(stretchCardioExercise);
      }
      exerciseSets.add(Set(exercises: exercises, sets: 3));
    }
    Workout workout = Workout();
    workout.intensity = intensity;
    workout.sets.add(Set(exercises: warmupSet, sets: 1));
    workout.sets.addAll(exerciseSets);
    return workout;
  }
}

class Set {
  final List<Repetition> exercises;
  final int sets;
  bool complete = false;

  Set({required this.exercises, required this.sets});

  Set.fromJson(Map<String, dynamic> json)
      : exercises = (json['exercises'] as List)
            .map((exercise) => Repetition.fromJson(exercise))
            .toList(),
        sets = json['sets'] as int,
        complete = json['complete'] as bool;

  Map<String, dynamic> toJson() {
    return {'exercises': exercises, 'sets': sets, 'complete': complete};
  }
}

class Repetition {
  final String units;
  final int repetitions;
  final Exercise exercise;
  const Repetition(
      {required this.exercise, required this.units, required this.repetitions});

  Repetition.fromJson(Map<String, dynamic> json)
      : units = json['units'],
        repetitions = json['repetitions'],
        exercise = fromId(json['exercise'])!;

  static Exercise? fromId(String id) {
    for (Exercise exercise in Exercise.exercises) {
      if (exercise.id == id) {
        return exercise;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'units': units,
      'repetitions': repetitions,
      'exercise': exercise.id
    };
  }
}
