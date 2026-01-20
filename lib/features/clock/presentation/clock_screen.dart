import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:collection/collection.dart';
import 'package:invigilator/data/models/exam_session.dart';
import 'package:invigilator/data/models/candidate.dart';
import 'package:invigilator/core/utils/time_utils.dart';
import 'dart:async';

class ClockScreen extends StatefulWidget {
  const ClockScreen({super.key});

  @override
  State<ClockScreen> createState() => _ClockScreenState();
}

class _ClockScreenState extends State<ClockScreen> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer =
        Timer.periodic(const Duration(seconds: 1), (timer) => setState(() {}));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ValueListenableBuilder(
        valueListenable: Hive.box<ExamSession>('session_box').listenable(),
        builder: (context, Box<ExamSession> box, _) {
          final session = box.get('current');
          if (session == null) {
            return const Center(
              child: Text("NO ACTIVE SESSION",
                  style: TextStyle(
                      color: Colors.white24,
                      fontSize: 32,
                      fontWeight: FontWeight.bold)),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("CURRENT TIME",
                            style: TextStyle(
                                color: Colors.white54,
                                fontSize: 24,
                                fontWeight: FontWeight.bold)),
                        Text(
                          TimeUtils.formatTime(DateTime.now()),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 80,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                    if (session.status == SessionStatus.paused)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.amber.withValues(alpha: 0.3),
                                blurRadius: 30)
                          ],
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.warning, size: 40, color: Colors.black),
                            SizedBox(width: 20),
                            Text("FIRE ALARM PAUSE",
                                style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                          ],
                        ),
                      ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text("SESSION DURATION",
                            style:
                                TextStyle(color: Colors.white54, fontSize: 18)),
                        Text("${session.baseDurationMinutes}m",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 40),
                // Big Timers
                Expanded(
                  child: Row(
                    children: [
                      _buildLargeTimer(
                          "Standard Time", Colors.cyan, session, false),
                      const SizedBox(width: 40),
                      _buildLargeTimer(
                          "25% Extra Time", Colors.purpleAccent, session, true),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLargeTimer(
      String title, Color color, ExamSession session, bool extraTime) {
    // Find the primary candidate to track for this specific display box
    final candidate = session.candidates.firstWhereOrNull(
          (c) =>
              c.hasExtraTime == extraTime &&
              c.status != CandidateStatus.finished,
        ) ??
        session.candidates.firstWhereOrNull((c) => c.hasExtraTime == extraTime);

    final isRunning = session.status != SessionStatus.idle &&
        session.status != SessionStatus.stopped;
    final remaining = candidate
            ?.calculateEndTime(session.currentGlobalOffset)
            ?.difference(DateTime.now()) ??
        Duration.zero;
    final isOnBreak = candidate?.status == CandidateStatus.onBreak;

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 4),
          borderRadius: BorderRadius.circular(40),
        ),
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title.toUpperCase(),
                style: TextStyle(
                    color: color,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5)),
            const Spacer(),
            Center(
              child: Text(
                candidate == null
                    ? "00:00:00"
                    : TimeUtils.formatDuration(remaining),
                style: TextStyle(
                    color: (remaining.inMinutes < 5 &&
                            isRunning &&
                            candidate != null)
                        ? Colors.red
                        : color,
                    fontSize: 160,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace'),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("ESTIMATED END",
                        style: TextStyle(color: Colors.white24, fontSize: 18)),
                    Text(
                      candidate == null || !isRunning
                          ? "--:--:--"
                          : TimeUtils.formatTime(candidate
                              .calculateEndTime(session.currentGlobalOffset)),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (isOnBreak)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Text("ON BREAK",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
