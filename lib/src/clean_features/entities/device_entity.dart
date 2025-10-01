class DeviceEntity {
  final String name;
  final String host;
  final int port;
  final Map<String, String> txt;
  DeviceEntity(this.name, this.host, this.port, this.txt);
}