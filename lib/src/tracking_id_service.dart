import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

class TrackingIdService {
  static const _uuid = Uuid();

  static String? _trackingId;

  const TrackingIdService._();

  @visibleForTesting
  // Ignored since the method is for testing purpose and should not be used as setter
  // ignore: use_setters_to_change_properties
  static void mockTrackingId(String? arg) => _trackingId = arg;

  /// Creates a unique `trackingId`.
  static String createTrackingId() {
    return _trackingId ?? _uuid.v4();
  }
}
