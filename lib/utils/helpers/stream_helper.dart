import 'dart:async';

class StreamHelper {
  static bool isNullable<T>() => null is T;

  static Stream<TResult> combineLastValues<T1, T2, TResult>(
    Stream<T1> stream1,
    Stream<T2> stream2,
    TResult Function(T1, T2) combiner,
  ) {
    final controller = StreamController<TResult>();

    T1? lastValue1;
    T2? lastValue2;

    void emitCombinedValue() {
      if ((lastValue1 != null || isNullable<T1>()) &&
          (lastValue2 != null || isNullable<T2>())) {
        controller.add(combiner(lastValue1 as T1, lastValue2 as T2));
      }
    }

    stream1.listen((value) {
      lastValue1 = value;
      emitCombinedValue();
    });

    stream2.listen((value) {
      lastValue2 = value;
      emitCombinedValue();
    });

    return controller.stream;
  }
}
