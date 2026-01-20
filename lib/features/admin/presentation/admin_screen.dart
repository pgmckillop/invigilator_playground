import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invigilator/features/session/providers/session_provider.dart';
import 'package:invigilator/data/models/exam_session.dart';
import 'package:invigilator/main.dart';
import 'package:invigilator/features/admin/presentation/widgets/candidate_card.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  final _nameController = TextEditingController();
  bool _hasExtraTime = false;
  bool _breaksAllowed = true;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final notifier = ref.read(sessionProvider.notifier);
    const Color emeraldGreen = Color(0xFF10B981);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => ref.read(navigationProvider.notifier).state = 'menu',
        ),
        title: const Text("ADMIN DASHBOARD",
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (session.status != SessionStatus.idle) ...[
            TextButton.icon(
              icon: Icon(
                  session.status == SessionStatus.paused
                      ? Icons.play_arrow
                      : Icons.pause,
                  color: Colors.amber),
              label: Text(
                  session.status == SessionStatus.paused
                      ? "RESUME"
                      : "FIRE ALARM",
                  style: const TextStyle(color: Colors.amber)),
              onPressed: () => notifier.toggleGlobalPause(),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white54),
              onPressed: () => _confirmReset(context, notifier),
              tooltip: "Reset All",
            ),
            const SizedBox(width: 8),
          ]
        ],
      ),
      body: Row(
        children: [
          Container(
            width: 340,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              border: Border(right: BorderSide(color: Colors.white10)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("CANDIDATE SETUP",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        letterSpacing: 1.2)),
                const SizedBox(height: 24),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Candidate Name",
                    labelStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.black26,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    prefixIcon:
                        const Icon(Icons.person_outline, color: Colors.white24),
                  ),
                ),
                const SizedBox(height: 16),
                _buildToggle("25% Extra Time", _hasExtraTime,
                    (v) => setState(() => _hasExtraTime = v)),
                _buildToggle("Allow Breaks", _breaksAllowed,
                    (v) => setState(() => _breaksAllowed = v)),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (_nameController.text.isNotEmpty) {
                      notifier.addCandidate(
                          _nameController.text, _hasExtraTime, _breaksAllowed);
                      _nameController.clear();
                      FocusScope.of(context).unfocus();
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("ADD TO SESSION",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const Spacer(),
                if (session.status == SessionStatus.idle)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 64),
                      backgroundColor: emeraldGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: session.candidates.isEmpty
                        ? null
                        : () => notifier.startExam(),
                    child: const Text("START EXAM",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                if (session.status != SessionStatus.idle)
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      side: const BorderSide(color: Colors.redAccent),
                      foregroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _confirmReset(context, notifier),
                    child: const Text("STOP & RESET SESSION",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "CANDIDATES (${session.candidates.length})",
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5),
                      ),
                      if (session.status == SessionStatus.running)
                        const Chip(
                          label: Text("SESSION LIVE",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          backgroundColor: Colors.red,
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: session.candidates.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.group_add,
                                    size: 80,
                                    color:
                                        Colors.white.withValues(alpha: 0.05)),
                                const SizedBox(height: 16),
                                const Text("Waiting for candidates...",
                                    style: TextStyle(
                                        color: Colors.white24, fontSize: 18)),
                              ],
                            ),
                          )
                        : GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1.7,
                              crossAxisSpacing: 24,
                              mainAxisSpacing: 24,
                            ),
                            itemCount: session.candidates.length,
                            itemBuilder: (context, index) {
                              return CandidateCard(
                                candidate: session.candidates[index],
                                session: session,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, SessionNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Session?"),
        content: const Text(
            "This will clear all candidates and reset the clock. This action cannot be undone."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL")),
          TextButton(
              onPressed: () {
                notifier.resetSession();
                Navigator.pop(context);
              },
              child: const Text("RESET", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  Widget _buildToggle(String label, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label,
          style: const TextStyle(fontSize: 14, color: Colors.white70)),
      value: value,
      activeThumbColor: Colors.blue,
      onChanged: onChanged,
    );
  }
}
