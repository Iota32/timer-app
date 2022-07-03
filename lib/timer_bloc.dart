import 'dart:async';
import 'package:meta/meta.dart';

import 'cache_value_stream_controller.dart';

enum TimerBehaviour {
  initial,
  prepared,
  running,
  stopped,
  done,
}

@immutable
class TimerState {
  const TimerState(this.timerStr, this.behaviour);
  final String timerStr;
  final TimerBehaviour behaviour;
}

class TimerBloc {
  static final TimerBloc _instance = TimerBloc._internal();
  late final CacheValueStreamController<TimerState> _stateController;
  late final CacheValueStreamController<int> _inputController;
  Timer? _timer;

  factory TimerBloc() {
    return _instance;
  }

  TimerBloc._internal() {
    _stateController = CacheValueStreamController<TimerState>(
        initialValue: const TimerState('00:00:00', TimerBehaviour.done));
    _inputController = CacheValueStreamController(initialValue: 0);
  }

  get value => _covertStringToDateTime(_stateController.value.timerStr);

  void startTimer() {
    _stateController.add(
        TimerState(_stateController.value.timerStr, TimerBehaviour.running));
    _timer ??= Timer.periodic(const Duration(seconds: 1), (timer) async {
      final lastValue = _convertStringToInt(_stateController.value.timerStr);
      _stateController.add(TimerState(
          _convertIntToString(lastValue - 1), TimerBehaviour.running));
      if (lastValue == 1) {
        await _finishTimer();
      }
    });
  }

  void stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
    _stateController.add(
        TimerState(_stateController.value.timerStr, TimerBehaviour.stopped));
  }

  void restart() {
    stopTimer();
    _stateController.add(TimerState(
        _convertIntToString(_inputController.value), TimerBehaviour.running));
    startTimer();
  }

  Future<void> _finishTimer() async {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
    _stateController
        .add(TimerState(_stateController.value.timerStr, TimerBehaviour.done));
  }

  void setTimer(int hour, int minute, int second) {
    final value = hour.toString().padLeft(2, '0') +
        ':' +
        minute.toString().padLeft(2, '0') +
        ':' +
        second.toString().padLeft(2, '0');
    _inputController.add(_convertStringToInt(value));
    _stateController.add(TimerState(value, TimerBehaviour.prepared));
    stopTimer();
  }

  Stream<TimerState> getTimerStateStream() {
    return _stateController.stream;
  }

  String _convertIntToString(int value) {
    final int hours = (value / 3600).floor();
    final int minutes = ((value % 3600) / 60).floor();
    final int seconds = value % 60;
    return hours.toString().padLeft(2, '0') +
        ':' +
        minutes.toString().padLeft(2, '0') +
        ':' +
        seconds.toString().padLeft(2, '0');
  }

  int _convertStringToInt(String value) {
    String hoursStr = value.substring(0, 2);
    String minutesStr = value.substring(3, 5);
    String secondsStr = value.substring(6, 8);
    return int.parse(hoursStr) * 3600 +
        int.parse(minutesStr) * 60 +
        int.parse(secondsStr);
  }

  DateTime _covertStringToDateTime(String value) {
    String hoursStr = value.substring(0, 2);
    String minutesStr = value.substring(3, 5);
    String secondsStr = value.substring(6, 8);

    return DateTime(0, 0, 0, int.parse(hoursStr), int.parse(minutesStr),
        int.parse(secondsStr));
  }
}
