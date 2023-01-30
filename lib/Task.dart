
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'State.dart';

class TaskWidget extends ConsumerWidget {
  final TaskState state;
  late final StateNotifierProvider<TaskState, Task> provider;

  TaskWidget(this.state, {super.key}) {
    provider = StateNotifierProvider<TaskState, Task>((ref) => state);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var taskState = ref.watch(provider);

    return Card(
        child: Column(
          children: [
            ListTile(
              title: Text(taskState.name),
              subtitle: Text(taskState.description),
            )
          ],
        ),
    );
  }


}