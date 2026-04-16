class ACState {
  bool isPowerOn;
  int targetTemperature;

  int roomTemperature;
  int humidity;

  String selectedAC;
  int fanSpeed;
  int mode;
  bool swingOn;

  // mapping merk → protocol_id
  Map<String, int> protocolMap = {
    'Daikin': 14,
    'Panasonic': 3,
    'Sharp': 27,
    'LG': 6,
    'Samsung': 11,
    'Gree': 32,
  };

  ACState({
    this.isPowerOn = false,
    this.targetTemperature = 24,
    this.roomTemperature = 28,
    this.humidity = 60,
    this.selectedAC = 'Daikin',
    this.fanSpeed = 1,
    this.mode = 1,
    this.swingOn = false,
  });

  List<String> get acList => ['Daikin', 'Panasonic', 'Samsung', 'LG', 'Gree'];

  int get protocolId => protocolMap[selectedAC]!;
}
