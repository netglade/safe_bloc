import 'package:uuid/uuid.dart';

class TrackingIdService {
  static const _uuid = Uuid();

  static String? _trackingId;

  const TrackingIdService._();

  /// Creates a unique `trackingId`.
  static String createTrackingId() {
    return _trackingId ?? _uuid.v4();
  }
}
