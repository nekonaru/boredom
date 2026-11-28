/// A short reflection written after a mission. Journal entries never affect
/// XP or statistics; they exist so a player can remember what a mission
/// actually felt like. Stored locally inside the backup like everything else.
enum JournalMood { great, okay, meh }

class JournalEntry {
  final String missionId;
  final String note;
  final JournalMood mood;
  final DateTime writtenAt;

  const JournalEntry({
    required this.missionId,
    required this.note,
    required this.mood,
    required this.writtenAt,
  });

  Map<String, dynamic> toJson() => {
        'missionId': missionId,
        'note': note,
        'mood': mood.name,
        'writtenAt': writtenAt.toIso8601String(),
      };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
        missionId: json['missionId'] as String? ?? '',
        note: json['note'] as String? ?? '',
        mood: JournalMood.values.firstWhere(
          (m) => m.name == json['mood'],
          orElse: () => JournalMood.okay,
        ),
        writtenAt: DateTime.tryParse(json['writtenAt'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
      );
}
