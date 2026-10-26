class ProfileCompletionModel {
  final bool? isProfileCompleted;
  final int completionPercentage;
  final List<String> missingFields;
  final Map<String, bool> steps;

  const ProfileCompletionModel({
    this.isProfileCompleted,
    this.completionPercentage = 0,
    this.missingFields = const [],
    this.steps = const {},
  });

  factory ProfileCompletionModel.fromJson(Map<String, dynamic> json) =>
      ProfileCompletionModel(
        isProfileCompleted: json['isProfileCompleted'] as bool?,
        completionPercentage:
            (num.tryParse('${json['completionPercentage']}') ?? 0)
                .round()
                .clamp(0, 100),
        missingFields: json['missingFields'] is List
            ? (json['missingFields'] as List).map((e) => e.toString()).toList()
            : const [],
        steps: json['steps'] is Map
            ? {
                for (final e in (json['steps'] as Map).entries)
                  if (e.value is bool) e.key.toString(): e.value as bool,
              }
            : const {},
      );

  Map<String, dynamic> toJson() => {
    if (isProfileCompleted != null) 'isProfileCompleted': isProfileCompleted,
    'completionPercentage': completionPercentage,
    'missingFields': missingFields,
    'steps': steps,
  };
}
