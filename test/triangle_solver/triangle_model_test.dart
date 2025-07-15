import 'package:flutter_test/flutter_test.dart';
import 'package:triangle_solver/features/triangle_solver/domain/triangle_model.dart';

void main() {
  group('TriangleModel userEntered tracking', () {
    test('Initial model has empty userEntered map', () {
      const model = TriangleModel();
      expect(model.userEntered, isEmpty);
    });

    test('copyWith updates userEntered map', () {
      const model = TriangleModel(a: 3, userEntered: {'a': true});
      final updated = model.copyWith(
        b: 4,
        userEntered: {'a': true, 'b': false},
      );
      expect(updated.a, 3);
      expect(updated.b, 4);
      expect(updated.userEntered['a'], isTrue);
      expect(updated.userEntered['b'], isFalse);
    });

    test('reset clears userEntered', () {
      final reset = const TriangleModel();
      expect(reset.userEntered, isEmpty);
    });
  });
}
