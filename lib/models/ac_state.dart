class ACState {
  bool isPowerOn;
  int targetTemperature;

  int? roomTemperature;
  int? humidity;

  String selectedAC;
  int fanSpeed;
  int mode;
  bool swingOn;

  // mapping merk → protocol_id
  Map<String, int> protocolMap = {
    'Daikin': 16,
    'Panasonic': 5,
    'Sharp': 14,
    'LG': 10,
    'Samsung': 7,
    'Gree': 24,
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

  List<String> get acList => [
    'Daikin',
    'Panasonic',
    'Samsung',
    'LG',
    'Gree',
    'Sharp',
  ];

  int get protocolId => protocolMap[selectedAC]!;

  set isSwingOn(bool isSwingOn) {}
}
