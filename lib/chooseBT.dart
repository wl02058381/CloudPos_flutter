import 'dart:async';

import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(ChooseBT());
}

class ChooseBT extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<ChooseBT> {
  @override
  void initState() {
    super.initState();
  }

  bool connected = false;
  List availableBluetoothDevices = new List();

  Future<void> getBluetooth() async {
    final List bluetooths = await BluetoothThermalPrinter.getBluetooths;
    print("Print $bluetooths");
    setState(() {
      availableBluetoothDevices = bluetooths;
    });
  }

  Future<String> setConnect(String mac) async {
    final String result = await BluetoothThermalPrinter.connect(mac);
    print("state conneected $result");
    if (result == "true") {
      setState(() {
        connected = true;
      });
    }
    return result;
  }




  

  savemac(mac) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('mac', mac);
  }

  @override
  Widget build(BuildContext context) {
    return
        // MaterialApp(
        // home:
        Scaffold(
      appBar: AppBar(
        title: const Text('設備選擇'),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("搜尋藍牙裝置", style: new TextStyle(fontSize: 28.0)),
            SizedBox(
                height: 50,
                child: OutlineButton(
                  onPressed: () {
                    this.getBluetooth();
                  },
                  child: Text(
                    "搜尋",
                    style: new TextStyle(fontSize: 24.0),
                  ),
                )),
            Container(
              height: 200,
              child: ListView.builder(
                itemCount: availableBluetoothDevices.length > 0
                    ? availableBluetoothDevices.length
                    : 0,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      String select = availableBluetoothDevices[index];
                      List list = select.split("#");
                      String name = list[0];
                      String mac = list[1];
                      // this.setConnect(mac);
                      this.setConnect(mac).then((value) {
                        print("gggg");
                        if (value == 'true') {
                          savemac(mac);
                          Alert(
                            context: context,
                            type: AlertType.success,
                            title: "連接成功",
                            desc: "藍芽裝置連接成功",
                            buttons: [
                              DialogButton(
                                child: Text(
                                  "確認",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                                onPressed: () => Navigator.pop(context),
                                width: 120,
                              )
                            ],
                          ).show();
                        } else {
                          Alert(
                            context: context,
                            type: AlertType.error,
                            title: "連接失敗",
                            desc: "藍芽裝置連接失敗",
                            buttons: [
                              DialogButton(
                                child: Text(
                                  "確認",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                                onPressed: () => Navigator.pop(context),
                                width: 120,
                              )
                            ],
                          ).show();
                        }
                      });
                    },
                    title: Text('${availableBluetoothDevices[index]}',
                        style: new TextStyle(fontSize: 24.0)),
                    subtitle: Text("點擊連線"),
                  );
                },
              ),
            ),
            SizedBox(
              height: 30,
            ),
            // OutlineButton(
            //   onPressed: connected ? this.printGraphics : null,
            //   child: Text("Print"),
            // ),
            // OutlineButton(
            //   onPressed: connected ? this.printTicket : null,
            //   child: Text("Print Ticket"),
            // ),
          ],
        ),
      ),
    );
    // );
  }
}
