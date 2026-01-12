import 'dart:async';

class StateStreamController<T> {

  final _streamController = StreamController<T>.broadcast();
  T? _value;

  void emit(T value) {
    _value = value;
    _streamController.add(value);
  }

  StreamSubscription<T> listen(void Function(T) onData) {
    if (_value != null) {
      onData(_value!);
    }
    return _streamController.stream.listen(onData);
  }

  Stream<T> get stream async* {
    if (_value != null) {
      yield _value!;
    }

    await for (final value in _streamController.stream) {
      yield value;
    }

  }

  void close(){
    _streamController.close();
  }
}
