
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'State.dart';

class TaskWidget extends ConsumerWidget {
  final Task state;

  TaskWidget(this.state, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Card(
        child: Column(
          children: [
            ListTile(
              title: Text(state.name),
              subtitle: Text(state.description),
            )
          ],
        ),
    );
  }


}