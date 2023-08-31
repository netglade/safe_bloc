import 'package:uuid/uuid.dart';

class TrackingIdService {
  TrackingIdService._();

  static const _uuid = Uuid();

  static String? _trackingId;

  static void mockTrackingId(String? arg) {
    _trackingId = arg;
    return;
  }

  static String createTrackingId() {
    return _trackingId ?? _uuid.v4();
  }
}
