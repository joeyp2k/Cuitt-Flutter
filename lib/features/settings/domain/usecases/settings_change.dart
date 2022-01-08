import 'package:flutter_blue/flutter_blue.dart';

class SettingsChange {
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  var _settingsServiceId = "";
  var _settingsCharId = "";
  var _settingsChar;

  void changeSettings(newSettings) async {
    await flutterBlue.connectedDevices.then((value) async {
      for (var i = 0; i < value.length; i++) {
        var services = await value[i].discoverServices();
        for (BluetoothService s in services) {
          if (s.uuid.toString() == _settingsServiceId) {
            print("SERVICE FOUND: " + s.uuid.toString());
            var characteristics = s.characteristics;
            print("GETTING CHARACTERISTICS");
            for (BluetoothCharacteristic c in characteristics) {
              if (c.uuid.toString() == _settingsCharId) {
                print("CHARACTERISTIC FOUND: " + c.uuid.toString());
                _settingsChar = c;
                _settingsChar.write(newSettings);
              }
            }
          }
        }
      }
    });
  }
}
