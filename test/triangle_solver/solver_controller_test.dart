import 'package:flutter_test/flutter_test.dart';

import 'package:triangle_solver/features/triangle_solver/application/solver_controller.dart';

void main() {
  group('TriangleSolverController', () {
    late TriangleSolverController controller;

    setUp(() {
      controller = TriangleSolverController();
    });

    test('updateParameter marks field as user-entered', () {
      controller.updateParameter('a', 3.0);
      final model = controller.state.value;
      expect(model?.a, 3.0);
      expect(model?.userEntered['a'], isTrue);
    });

    test('reset clears user-entered info', () {
      controller.updateParameter('a', 3.0);
      controller.reset();
      final model = controller.state.value;
      expect(model, isNull);
    });

    test('solve marks calculated fields as auto-generated', () {
      controller.updateParameter('a', 3.0);
      controller.updateParameter('b', 4.0);
      controller.updateParameter('C', 90.0);
      controller.solve();
      final model = controller.state.value;
      expect(model, isNotNull);
      expect(model?.userEntered['a'], isTrue);
      expect(model?.userEntered['b'], isTrue);
      expect(model?.userEntered['C'], isTrue);
      // The rest should be auto-generated (false)
      expect(model?.userEntered['A'], isFalse);
      expect(model?.userEntered['B'], isFalse);
      expect(model?.userEntered['c'], isFalse);
    });
  });
}
