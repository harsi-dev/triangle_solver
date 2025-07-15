import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/solver_controller.dart';
import '../domain/triangle_model.dart';

class InputPanel extends ConsumerStatefulWidget {
  const InputPanel({super.key});

  @override
  ConsumerState<InputPanel> createState() => _InputPanelState();
}

class _InputPanelState extends ConsumerState<InputPanel> {
  final List<String> parameters = ['a', 'b', 'c', 'A', 'B', 'C'];
  final Map<String, TextEditingController> controllers = {};

  final Set<String> selected = {};

  @override
  void initState() {
    super.initState();
    for (var param in parameters) {
      controllers[param] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var ctrl in controllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _onFieldChanged(String key, String value) {
    final doubleVal = double.tryParse(value);
    ref.read(triangleProvider.notifier).updateParameter(key, doubleVal);
  }

  void _updateControllersFromTriangle(TriangleModel? triangle) {
    if (triangle == null) return;
    final values = triangle.toMap();
    for (final key in parameters) {
      final value = values[key];
      final text = value == null
          ? ''
          : value.toStringAsFixed(6).replaceAll(RegExp(r'([.]*0+)\$'), '');
      final controller = controllers[key];
      if (controller != null && controller.text != text) {
        controller.text = text;
      }
    }
  }

  Widget _buildInput(String key, Map<String, bool> userEntered) {
    return Column(
      children: [
        Text(key, style: const TextStyle(color: Colors.black)),
        TextField(
          controller: controllers[key],
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.black),
          decoration: const InputDecoration(
            hintText: '0',
            hintStyle: TextStyle(color: Colors.black45),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blueAccent),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.cyanAccent),
            ),
          ),
          onChanged: (val) => _onFieldChanged(key, val),
        ),
        Builder(
          builder: (_) {
            final isUser = userEntered[key];
            if (controllers[key]?.text.isEmpty ?? true) {
              // Always show a lock icon, but faded if empty
              return Opacity(
                opacity: 0.3,
                child: isUser == true
                    ? const Icon(Icons.lock_open, color: Colors.green, size: 20)
                    : const Icon(Icons.lock, color: Colors.amber, size: 20),
              );
            } else if (isUser == true) {
              return const Icon(Icons.lock_open, color: Colors.green, size: 20);
            } else {
              return const Icon(Icons.lock, color: Colors.amber, size: 20);
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final triangleState = ref.watch(triangleProvider);
    final triangle = triangleState.value;
    final userEntered = triangle?.userEntered ?? {};
    // Update controllers when triangle is solved or reset
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (triangle == null) {
        // Reset: clear all fields
        for (final ctrl in controllers.values) {
          if (ctrl.text.isNotEmpty) ctrl.clear();
        }
      } else if (triangle.isFullySolved) {
        _updateControllersFromTriangle(triangle);
      }
    });
    return Column(
      children: [
        const Text(
          'Enter any 3 values (at least one side):',
          style: TextStyle(color: Colors.black87),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: parameters.map((key) {
            return SizedBox(width: 100, child: _buildInput(key, userEntered));
          }).toList(),
        ),
      ],
    );
  }
}
