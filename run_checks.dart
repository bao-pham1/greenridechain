import 'src/app_state.dart';

/// Simple check to ensure AppState compiles and vehicles are accessible.
void runChecks() {
  final s = AppState();
  assert(s.vehicles.isNotEmpty);
}
