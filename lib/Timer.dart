
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';

class TimerWidget extends StatefulWidget {

  TimerWidget({super.key});

  @override
  State<StatefulWidget> createState() => _TimerState();
}

class _TimerState extends State<TimerWidget> {

  static const WORK_TIME = 25 * 60;
  static const BREAK_TIME = 5 * 60;

  int remainingTimeSeconds = WORK_TIME;
  int loop = 0;
  bool isPaused = true;
  Timer? timer;

  String getTimeToDisplay() {
    return '${remainingTimeSeconds ~/ 60}'.padLeft(2, '0') + ':' + '${remainingTimeSeconds % 60}'.padLeft(2, '0');
  }

  bool isWorkLoop() {
    return loop % 2 == 0;
  }

  void startClick() {
    setState(() {
      timer = createTimer();
      isPaused = false;
    });
  }

  void pauseClick() {
    setState(() {
      timer?.cancel();
      isPaused = true;
    });
  }

  void skipClick() {
    nextLoop();
  }

  void timerTick() {
    var remainingTime = remainingTimeSeconds - 1;
    if (remainingTime <= 0) {
      nextLoop();
      return;
    }

    setState(() {
      remainingTimeSeconds = remainingTime;
    });
  }

  void nextLoop() {
    setState(() {
      SystemSound.play(SystemSoundType.alert);
      loop++;
      remainingTimeSeconds = loop % 2 == 0
        ? WORK_TIME
        : BREAK_TIME;
    });
  }

  Timer createTimer() {
    return Timer.periodic(const Duration(seconds: 1), (timer) {
      timerTick();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Center(
                  child: Text(
                    isWorkLoop() ? 'Помидор' : 'Чил',
                    style: TextStyle(
                      fontSize: 24,
                      color: isWorkLoop()
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      getTimeToDisplay(),
                      style: TextStyle(
                        fontSize: 64,
                        color: isWorkLoop()
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size.fromHeight(50),
                          ),
                          onPressed: skipClick,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.skip_next_rounded),
                              Text('Пропустить', style: TextStyle(fontSize: 16),)
                            ],
                          )
                      ),
                    ),
                    const SizedBox(width: 10,),
                    Expanded(
                      child: isPaused
                        ? OutlinedButton(
                            style: OutlinedButton.styleFrom(
                                minimumSize: Size.fromHeight(50)
                            ),
                            onPressed: startClick,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.play_arrow_rounded),
                                Text('Старт', style: TextStyle(fontSize: 16),)
                              ],
                            )
                        )
                        : OutlinedButton(
                            style: OutlinedButton.styleFrom(
                                minimumSize: Size.fromHeight(50)
                            ),
                            onPressed: pauseClick,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.pause_rounded),
                                Text('Пауза', style: TextStyle(fontSize: 16),)
                              ],
                            )
                        )
                    )
                  ],
                )
              ],
            ),
          )
      ),
    );
  }

}