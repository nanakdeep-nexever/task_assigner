class Notification {
  final String id;
  final String message;
  final DateTime timestamp;
  final DateTime? readAt;

  Notification(
      {required this.id,
      required this.message,
      required this.timestamp,
      this.readAt});
}
