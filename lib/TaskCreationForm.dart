

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'main.dart';

import 'State.dart';

class TaskCreationFormWidget extends ConsumerWidget {
  bool visibility = true;
  final _formKey = GlobalKey<FormState>();

  TaskCreationFormWidget({ this.visibility = true, super.key });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    const addFormMargins = EdgeInsets.only(left: 10, right: 10, bottom: 10);

    final taskNameController = TextEditingController();
    final taskDescriptionController = TextEditingController();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 120),
      transitionBuilder: (child, animation) =>
          SizeTransition(sizeFactor: animation, child: child,),
      child: !visibility ? null : Card(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const ListTile(
                title: Center(child: Text('Добавить задачу'))
              ),
              Container(
                margin: addFormMargins,
                child: TextFormField(
                  controller: taskNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Укажите название задачи';
                    }
                  },
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Название задачи'
                  ),
                ),
              ),
              Container(
                margin: addFormMargins,
                child: TextFormField(
                  controller: taskDescriptionController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Описание задачи'
                  ),
                ),
              ),
              Container(
                margin: addFormMargins,
                child: TextButton(
                  style: TextButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  onPressed: () {
                    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
                      return;
                    }

                    ref.read(tasksProvider.notifier).addTask(Task(
                      id: Random().nextInt(4294967296),
                      name: taskNameController.text,
                      description: taskDescriptionController.text,
                      status: TaskStatus.inWork
                    ));
                    taskNameController.clear();
                    taskDescriptionController.clear();
                  },
                  child: const Text('Создать задачу')
                ),
              )
            ],
          ),
        )
      ),
    );
  }



}