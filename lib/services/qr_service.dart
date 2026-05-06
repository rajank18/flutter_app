class QrService {
  static String parseParticipantId(String raw) {
    final value = raw.trim();
    if (value.contains(':')) {
      return value.split(':').last.trim().toUpperCase();
    }
    return value.toUpperCase();
  }
}
