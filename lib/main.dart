import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'Task.dart';
import 'TaskCreationForm.dart';
import 'Timer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'LoadScreen.dart';
import 'State.dart';

void main() {
  runApp(
      const ProviderScope(child: MyApp())
  );
}

final startTime = DateTime.now();

final tasksProvider = StateNotifierProvider<TasksState, List<TaskState>>((ref) => TasksState(
  <TaskState>[], ref
));

final showTaskCreationFormProvider = StateProvider<bool>((ref) => false);

final prefsProvider = StateNotifierProvider<PrefsState, SharedPreferences?>((ref) => PrefsState(null));

final isLoadingProvider = Provider<bool>((ref) {
  final prefs = ref.watch(prefsProvider);
  return prefs == null;
});

class MyApp extends ConsumerWidget {
  const MyApp({ Key? key }) : super(key: key);

  void getPrefs(WidgetRef ref) {
    SharedPreferences.getInstance().then((sharedPreferences) {
      var diff = startTime.difference(DateTime.now()).inMilliseconds;
      Timer(Duration(milliseconds: max(1200 - diff, 0)), () {
        ref.read(prefsProvider.notifier).setPrefs(sharedPreferences);
        var tasksState = ref.read(tasksProvider.notifier);
        var jsonString = sharedPreferences.getString('tasks');
        if (jsonString == null) {
          return;
        }
        List<dynamic> tasksJson = jsonDecode(jsonString);
        for (var elJson in tasksJson) {
          tasksState.addTask(Task.fromJson(elJson as Map<String, dynamic>), saveToDisk: false);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    var tasks = ref.watch(tasksProvider);
    var showTaskCreationForm = ref.watch(showTaskCreationFormProvider);
    var isLoading = ref.watch(isLoadingProvider);

    if (isLoading) {
      getPrefs(ref);
    }

    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.red,
          secondary: Colors.redAccent,
          background: Colors.grey.shade200
        ),
        canvasColor: Colors.grey.shade200
      ),
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            ref.read(showTaskCreationFormProvider.notifier).state = !showTaskCreationForm;
          },
          child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: RotationTransition(
                  turns: animation,
                  child: child,
                ),
              ),
              child: showTaskCreationForm
                  ? const Icon(Icons.close, key: Key('FabIconClose'),)
                  : const Icon(Icons.add, key: Key('FabIconAdd'),)
          ),
        ),
        appBar: AppBar(
          title: const Text("Помидорка"),
          elevation: 0,
        ),
        body: AnimatedSwitcher(
          transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child,),
          duration: const Duration(milliseconds: 400),
          child: isLoading ? const LoadScreen(key: Key('loadScreen')) : Column(
            key: const Key('appScreen'),
            children: [
              TimerWidget(),
              Expanded(
                child: ListView(
                  children: [
                    TaskCreationFormWidget(visibility: showTaskCreationForm,),
                    Column(
                      children: tasks.map((taskState) =>
                          Dismissible(
                            key: ValueKey<int>(taskState.task.id),
                            direction: DismissDirection.endToStart,
                            child: TaskWidget(taskState),
                            onDismissed: (dismissDirection) {
                              ref.read(tasksProvider.notifier).removeTask(taskState.task.id);
                            },
                          )
                      ).toList(),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      )
    );
  }
}