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

final appState = StateNotifierProvider<AppStateNotifier, AppState>((ref) => AppStateNotifier(AppState()));

class MyApp extends ConsumerWidget {
  const MyApp({ Key? key }) : super(key: key);

  void getPrefs(WidgetRef ref) {
    SharedPreferences.getInstance().then((sharedPreferences) {
      var diff = startTime.difference(DateTime.now()).inMilliseconds;
      Timer(Duration(milliseconds: max(1200 - diff, 0)), () {
        var appStateNotifier = ref.watch(appState.notifier);
        appStateNotifier.setPrefs(sharedPreferences);
        var jsonString = sharedPreferences.getString('tasks');
        if (jsonString == null) {
          return;
        }
        List<dynamic> tasksJson = jsonDecode(jsonString);
        for (var elJson in tasksJson) {
          appStateNotifier.addTask(Task.fromJson(elJson as Map<String, dynamic>), saveToDisk: false);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    var tasks = ref.watch(appState.select((state) => state.tasks));
    var showTaskCreationForm = ref.watch(appState.select((state) => state.showTaskCreationForm));
    var isLoading = ref.watch(appState.select((state) {
      return state.prefs == null;
    }));

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
            ref.read(appState.notifier).toggleCreationFormVisibility();
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
                      children: tasks.map((task) =>
                          Dismissible(
                            key: ValueKey<int>(task.id),
                            direction: DismissDirection.endToStart,
                            child: TaskWidget(task),
                            onDismissed: (dismissDirection) {
                              ref.read(appState.notifier).removeTask(task.id);
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