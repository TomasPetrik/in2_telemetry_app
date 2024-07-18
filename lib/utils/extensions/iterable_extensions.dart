extension IterableExtensions<T> on Iterable<T> {
  Iterable<T> whereWithIndex(bool Function(T element, int index) test) sync* {
    var index = 0;
    for (final item in this) {
      if (test(item, index)) {
        yield item;
      }
      index++;
    }
  }

  Iterable<T> distinctBy<TProperty>(TProperty Function(T element) selector) sync* {
    final Set<TProperty> seen = {};

    for (final item in this) {
      final property = selector(item);
      if (seen.add(property)) {
        yield item;
      }
    }
  }
}
