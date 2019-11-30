import 'dart:math';

/// Partition the given [list] into groups with size of [batchSize].
Iterable<Iterable<T>> partition<T>(List<T> list, int batchSize) {
  final batches = List<List<T>>();
  if (list?.isNotEmpty != true || batchSize == null || batchSize <= 0) return batches;

  final total = list.length;
  int offset = 0;
  int remains = total;

  while (offset < list.length && remains > 0) {
    final size = min(remains, batchSize);
    batches.add(list.sublist(offset, offset + size));
    offset += size;
    remains -= size;
  }

  return batches;
}
