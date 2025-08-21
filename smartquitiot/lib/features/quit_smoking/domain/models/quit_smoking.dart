class QuitSmoking {
  final String id;
  final DateTime startDate;
  final bool isActive;
  final int daysSmokeFree;

  const QuitSmoking({
    required this.id,
    required this.startDate,
    this.isActive = false,
    this.daysSmokeFree = 0,
  });
}
