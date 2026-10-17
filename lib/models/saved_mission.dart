/// One mission parked in the inbox, saved for later instead of rolled now.
class SavedMission {
  final String missionId;
  final DateTime savedAt;

  const SavedMission({required this.missionId, required this.savedAt});

  Map<String, dynamic> toJson() => {
        'missionId': missionId,
        'savedAt': savedAt.toIso8601String(),
      };

  factory SavedMission.fromJson(Map<String, dynamic> json) => SavedMission(
        missionId: json['missionId'] as String,
        savedAt: DateTime.parse(json['savedAt'] as String),
      );
}