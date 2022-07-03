import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';

import 'timer_bloc.dart';

class TimerPage extends StatelessWidget {
  const TimerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = TimerBloc();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer'),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                StreamBuilder(
                  stream: bloc.getTimerStateStream(),
                  builder: (context, AsyncSnapshot<TimerState> snapshot) {
                    return Column(
                      children: [
                        TextButton(
                          onPressed: () {
                            _buildTimerPicker(context, bloc);
                          },
                          child: Text(
                            snapshot.hasData
                                ? snapshot.data!.timerStr
                                : '00:00:00',
                            style: Theme.of(context).textTheme.headline2,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        snapshot.hasData
                            ? _buildStartStopButton(
                                context, bloc, snapshot.data!.behaviour)
                            : _buildStartStopButton(
                                context, bloc, TimerBehaviour.initial)
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStartStopButton(
      BuildContext context, TimerBloc bloc, TimerBehaviour behaviour) {
    ElevatedButton startStopButton;
    switch (behaviour) {
      case TimerBehaviour.prepared:
      case TimerBehaviour.stopped:
        startStopButton = ElevatedButton(
          onPressed: () {
            bloc.startTimer();
          },
          child: Text(
            'Start',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: Colors.white),
          ),
        );
        break;
      case TimerBehaviour.running:
        startStopButton = ElevatedButton(
          onPressed: () {
            bloc.stopTimer();
          },
          child: Text(
            'Stop',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: Colors.white),
          ),
        );
        break;
      case TimerBehaviour.initial:
      case TimerBehaviour.done:
        startStopButton = ElevatedButton(
          onPressed: null,
          child: Text(
            'Start',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: Colors.white),
          ),
        );
        break;
    }

    ElevatedButton restartButton;
    switch (behaviour) {
      case TimerBehaviour.running:
      case TimerBehaviour.done:
        restartButton = ElevatedButton(
          onPressed: () {
            bloc.restart();
          },
          child: Text(
            'Restart',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: Colors.white),
          ),
        );
        break;
      case TimerBehaviour.initial:
      case TimerBehaviour.prepared:
      case TimerBehaviour.stopped:
        restartButton = ElevatedButton(
          onPressed: null,
          child: Text(
            'Restart',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: Colors.white),
          ),
        );
        break;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36.0),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 48.0,
            child: startStopButton,
          ),
          const SizedBox(
            height: 8.0,
          ),
          SizedBox(
            width: double.infinity,
            height: 48.0,
            child: restartButton,
          ),
        ],
      ),
    );
  }

  Future<void> _buildTimerPicker(BuildContext context, TimerBloc bloc) {
    return Picker(
      height: 300.0,
      itemExtent: 72.0,
      textStyle: Theme.of(context).textTheme.bodyLarge,
      adapter: DateTimePickerAdapter(
        type: PickerDateTimeType.kHMS,
        value: bloc.value,
        customColumnType: [3, 4, 5],
      ),
      onConfirm: (_, List values) {
        bloc.setTimer(values[0], values[1], values[2]);
      },
    ).showModal(context);
  }
}
