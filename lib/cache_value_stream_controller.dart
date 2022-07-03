import 'dart:async';

class CacheValueStreamController<T> {
  CacheValueStreamController({
    required T initialValue,
  }) {
    _value = initialValue;
    _controller = StreamController<T>.broadcast();
  }
  late T _value;
  late StreamController<T> _controller;

  get value => _value;

  void add(T value) {
    _value = value;
    _controller.add(value);
  }

  get stream => _controller.stream;

  void close() {
    _controller.close();
  }
}
