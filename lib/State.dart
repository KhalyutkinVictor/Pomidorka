
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

  clone({String? name, String? description, TaskStatus? status}) {
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

class TaskState extends StateNotifier<Task> {
  final Task task;

  TaskState(this.task) : super(task);

  void renameTask(String name) {
    state = task.clone(name: name);
  }

}

class TasksState extends StateNotifier<List<TaskState>> {
  final List<TaskState> tasks;
  final showTaskCreationForm = false;
  final Ref ref;

  TasksState(this.tasks, this.ref) : super(tasks);

  void addTask(Task task, {bool saveToDisk = true}) {
    if (state.indexWhere((element) => element.task.id == task.id) != -1) {
      return;
    }
    state = [...state, TaskState(task)];
    if (saveToDisk) {
      _saveStateToDisk();
    }
  }

  void removeTask(int id) {
    state = state.where((element) => element.task.id != id).toList();
    _saveStateToDisk();
  }

  void _saveStateToDisk() {
    var tasks = state.map((e) => e.task.toJson()).toList();
    var encodedString = jsonEncode(tasks);
    ref.read(prefsProvider)?.setString('tasks', encodedString);
  }
}

class PrefsState extends StateNotifier<SharedPreferences?> {
  final SharedPreferences? prefs;

  PrefsState(this.prefs) : super(prefs);

  void setPrefs(SharedPreferences prefs) {
    state = prefs;
  }
}