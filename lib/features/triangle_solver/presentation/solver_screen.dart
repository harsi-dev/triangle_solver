import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/solver_controller.dart';
import 'triangle_canvas.dart';
import 'input_panel.dart';

class SolverScreen extends ConsumerWidget {
  const SolverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final triangleState = ref.watch(triangleProvider);

    // Error banner widget
    Widget? errorBanner;
    triangleState.whenOrNull(
      error: (err, _) {
        errorBanner = Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          margin: const EdgeInsets.only(
            bottom: 12,
            left: 12,
            right: 12,
            top: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.red.shade900,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  err.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    Widget inputAndButtons({bool compact = false}) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (errorBanner != null) errorBanner!,
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          margin: EdgeInsets.only(bottom: compact ? 8 : 16),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: compact ? 4 : 10,
              horizontal: compact ? 8 : 16,
            ),
            child: const InputPanel(),
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: compact ? 4 : 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    ref.read(triangleProvider.notifier).solve();
                  },
                  label: const Text('Solve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: compact ? 8 : 14),
                    textStyle: TextStyle(
                      fontSize: compact ? 14 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    ref.read(triangleProvider.notifier).reset();
                  },
                  label: const Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[700],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: compact ? 8 : 14),
                    textStyle: TextStyle(
                      fontSize: compact ? 14 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Triangle Solver'),
        backgroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[100],
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: isLandscape
                ? Row(
                    children: [
                      // Canvas on the left
                      Expanded(
                        flex: 3,
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          margin: const EdgeInsets.only(right: 16),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            child: const TriangleCanvas(),
                          ),
                        ),
                      ),
                      // Input panel and buttons on the right (scrollable)
                      Expanded(
                        flex: 2,
                        child: SingleChildScrollView(
                          child: inputAndButtons(compact: true),
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      // Canvas takes all available space
                      Expanded(
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            child: const TriangleCanvas(),
                          ),
                        ),
                      ),
                      // Input panel and buttons at the bottom
                      inputAndButtons(),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
