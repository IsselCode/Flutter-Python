abstract class Endpoint {
  static const String base = "http://192.168.100.11:5000";
}

class CameraAPI extends Endpoint {
  static const status = "${Endpoint.base}/status";
  static const meta = "${Endpoint.base}/meta";
  static const startCamera = "${Endpoint.base}/start";
  static const stopCamera = "${Endpoint.base}/stop";
  static const snapshot = "${Endpoint.base}/snapshot.jpg";
  static const stream = "${Endpoint.base}/stream.mjpg";
}

class BboxAPI extends Endpoint {
  static const base = "${Endpoint.base}/bbox";
  static const bboxes = "${Endpoint.base}/bboxes";
}


