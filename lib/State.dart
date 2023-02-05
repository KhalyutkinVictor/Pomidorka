
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'main.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TaskStatus {
  complete,
  inWork
}

@immutable
class Task {
  final int id;
  final String name;
  final String description;
  final TaskStatus status;

  const Task({required this.id, required this.name, required this.description, required this.status});

  Task.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      name = json['name'],
      description = json['description'],
      status = TaskStatus.values[json['status'] as int];

  Task clone({String? name, String? description, TaskStatus? status}) {
    return Task(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'status': status.index
  };
}

class AppState {
  SharedPreferences? prefs;

  List<Task> tasks = [];

  bool showTaskCreationForm = false;

  AppState({this.prefs = null, this.tasks = const [], this.showTaskCreationForm = false});

  AppState copy({SharedPreferences? prefs = null, List<Task>? tasks = null, bool? showTaskCreationForm = null}) {
    return AppState(
      prefs: prefs ?? this.prefs,
      tasks: tasks ?? this.tasks,
      showTaskCreationForm: showTaskCreationForm ?? this.showTaskCreationForm
    );
  }

}

class AppStateNotifier extends StateNotifier<AppState> {
  final AppState appState;

  AppStateNotifier(this.appState) : super(appState);

  void addTask(Task task, {bool saveToDisk = true}) {
    if (state.tasks.indexWhere((element) => element.id == task.id) != -1) {
      return;
    }
    state = state.copy(tasks: [...state.tasks, task]);
    if (saveToDisk) {
      _saveTasksStateToDisk();
    }
  }

  void removeTask(int id) {
    state = state.copy(tasks: state.tasks.where((task) => task.id != id).toList());
    _saveTasksStateToDisk();
  }

  void changeTaskStatus({required int id, required TaskStatus status}) {
    state = state.copy(tasks: state.tasks.map((task) => task.clone(status: status)).toList());
    _saveTasksStateToDisk();
  }

  void toggleCreationFormVisibility() {
    state = state.copy(showTaskCreationForm: !state.showTaskCreationForm);
  }

  void setPrefs(SharedPreferences prefs) {
    state = state.copy(prefs: prefs);
  }

  void _saveTasksStateToDisk() {
    try {
      state.prefs?.setString('tasksState', jsonEncode(state.tasks));
    } finally {
      // nothing :)
    }
  }
}