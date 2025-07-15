import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/triangle_model.dart';
import '../domain/triangle_math.dart';

final triangleProvider =
    StateNotifierProvider<TriangleSolverController, AsyncValue<TriangleModel?>>(
      (ref) => TriangleSolverController(),
    );

class TriangleSolverController
    extends StateNotifier<AsyncValue<TriangleModel?>> {
  TriangleSolverController() : super(const AsyncValue.data(null));

  TriangleModel _input = const TriangleModel();

  Map<String, bool> _userEntered = {};

  void updateParameter(String key, double? value) {
    _input = _updateModelField(_input, key, value);
    if (value != null) {
      _userEntered[key] = true;
    } else {
      _userEntered.remove(key);
    }
    state = AsyncValue.data(
      _input.copyWith(userEntered: Map<String, bool>.from(_userEntered)),
    );
  }

  void solve() {
    try {
      if (!_input.hasEnoughInfo) {
        throw Exception(
          'Please provide exactly 3 known values (at least one side).',
        );
      }

      final result = solveTriangle(_input);
      // Mark user-entered fields as true, others as false
      final Map<String, bool> userMap = {};
      for (final key in ['a', 'b', 'c', 'A', 'B', 'C']) {
        if (_userEntered[key] == true) {
          userMap[key] = true;
        } else if (result.toMap().containsKey(key)) {
          userMap[key] = false;
        }
      }
      state = AsyncValue.data(result.copyWith(userEntered: userMap));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void reset() {
    _input = const TriangleModel();
    _userEntered = {};
    state = const AsyncValue.data(null);
  }

  TriangleModel _updateModelField(
    TriangleModel model,
    String key,
    double? value,
  ) {
    switch (key) {
      case 'a':
        return model.copyWith(a: value);
      case 'b':
        return model.copyWith(b: value);
      case 'c':
        return model.copyWith(c: value);
      case 'A':
        return model.copyWith(A: value);
      case 'B':
        return model.copyWith(B: value);
      case 'C':
        return model.copyWith(C: value);
      default:
        return model;
    }
  }
}
