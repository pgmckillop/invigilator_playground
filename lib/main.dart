import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/models/exam_break.dart';
import 'data/models/candidate.dart';
import 'data/models/exam_session.dart';
import 'features/admin/presentation/admin_screen.dart';
import 'features/clock/presentation/clock_screen.dart';

// Phase 2 Theme Color
const Color emeraldGreen = Color(0xFF10B981);

// Prototype navigation state provider
final navigationProvider = StateProvider<String>((ref) => 'menu');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // Registering Adapters for Phase 2 Models
  Hive.registerAdapter(ExamBreakAdapter()); // TypeId: 0
  Hive.registerAdapter(CandidateAdapter()); // TypeId: 1
  Hive.registerAdapter(CandidateStatusAdapter()); // TypeId: 3
  Hive.registerAdapter(ExamSessionAdapter()); // TypeId: 2
  Hive.registerAdapter(SessionStatusAdapter()); // TypeId: 4

  await Hive.openBox<ExamSession>('session_box');

  runApp(
    const ProviderScope(
      child: InvigilatorApp(),
    ),
  );
}

class InvigilatorApp extends StatelessWidget {
  const InvigilatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Invigilator Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF2563EB),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.dark,
          surface: const Color(0xFF1E293B),
        ),
      ),
      home: const MainRouter(),
    );
  }
}

class MainRouter extends ConsumerWidget {
  const MainRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(navigationProvider);

    switch (view) {
      case 'admin':
        return const AdminScreen();
      case 'clock':
        return const ClockScreen();
      default:
        return const PrototypeReadyScreen();
    }
  }
}

class PrototypeReadyScreen extends ConsumerWidget {
  const PrototypeReadyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F172A)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.05),
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.15), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.05),
                    blurRadius: 40,
                    spreadRadius: 10,
                  )
                ],
              ),
              child: const Icon(Icons.timer_outlined,
                  size: 110, color: Colors.blue),
            ),
            const SizedBox(height: 40),
            const Text(
              "INVIGILATOR PRO",
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                letterSpacing: 6,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                "PHASE 2: PROTOTYPE READY",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Multi-Tab Exam Management System",
              style: TextStyle(
                color: Colors.white38,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 64),
            _MenuButton(
              label: "ADMIN DASHBOARD",
              icon: Icons.dashboard_customize_rounded,
              onPressed: () =>
                  ref.read(navigationProvider.notifier).state = 'admin',
              isPrimary: true,
            ),
            const SizedBox(height: 20),
            _MenuButton(
              label: "CLOCK MONITOR",
              icon: Icons.monitor_rounded,
              onPressed: () =>
                  ref.read(navigationProvider.notifier).state = 'clock',
              isPrimary: false,
            ),
            const SizedBox(height: 100),
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: emeraldGreen,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: emeraldGreen, blurRadius: 4)
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "LOCAL STATE INITIALIZED",
                      style: TextStyle(
                        color: Colors.white24,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "v1.0.0-p2-stable",
                  style: TextStyle(
                      color: Colors.white10,
                      fontSize: 10,
                      fontFamily: 'monospace'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _MenuButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340,
      height: 68,
      child: isPrimary
          ? ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                elevation: 12,
                shadowColor: Colors.blue.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: onPressed,
              icon: Icon(icon, size: 24),
              label: Text(
                label,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1),
              ),
            )
          : OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: const BorderSide(color: Colors.white12, width: 2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: onPressed,
              icon: Icon(icon, size: 24),
              label: Text(
                label,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1),
              ),
            ),
    );
  }
}
