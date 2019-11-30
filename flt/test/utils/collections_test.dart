import 'package:flutter_test/flutter_test.dart';
import 'package:notever/src/utils/collections.dart';

void main() {
  test('partition a list', () {
    var list = [1, 2, 3, 4, 5, 6];
    var result = partition(list, 3);
    expect(result, hasLength(2));
    expect(result.first, hasLength(3));
    expect(result.last, hasLength(3));
    expect(result.last, [4, 5, 6]);

    list = [3, 2];
    result = partition(list, 2);
    expect(result, hasLength(1));
    expect(result.last, [3, 2]);
  });

  test('partition a list has an odd length', () {
    var list = [1, 2, 3, 4, 5, 6, 7];
    var result = partition(list, 3);
    expect(result, hasLength(3));
    expect(result.first, hasLength(3));
    expect(result.last, hasLength(1));
    expect(result.last, [7]);

    list = [1, 2, 3];
    result = partition(list, 3);
    expect(result, hasLength(1));
    expect(result.last, [1, 2, 3]);
  });

  test('partition an empty list should get an empty list', () {
    expect(partition([], 3), isEmpty);
    expect(partition(null, 3), isEmpty);
  });

  test('partition a list with invalid batch size', () {
    expect(partition([1, 2], 0), isEmpty);
    expect(partition([1, 2], -1), isEmpty);
    expect(partition([1, 2], null), isEmpty);
  });
}
