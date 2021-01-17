import 'package:cloudpos_online/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:wifi_info_flutter/wifi_info_flutter.dart';
import 'package:cloudpos_online/main.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatelessWidget {
  final String url = "https://cloudpos.54ucl.com:8011/AddAccount";
  String data;
  String _status;
  Future<String> registerBTN() async {
    try {
      var wifiIP = await WifiInfo().getWifiIP();
      var url = "https://cloudpos.54ucl.com:8011/AddAccount";
      var body = json.encode({
        "IP": wifiIP,
        "Account": accountController.text,
        "PassWord": passwordController.text,
      });
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Accept': 'application/json',
      };
      final response = await http.post(url, body: body, headers: headers);
      // setState(() {
      //   _status = json.decode(response.body)["Status"];
      // });
      print(response.body);
      final String resbody = response.body;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('StoreID', json.decode(resbody)["StoreID"]);
      return resbody;
    } catch (e) {
      return 'neterror';
    }
  }

  @override
  TextEditingController accountController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("註冊頁面")),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: TextFormField(
                controller: accountController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  labelText: "帳號 *",
                  hintText: "請輸入帳號",
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: Icon(Icons.remove_red_eye),
                  labelText: "密碼 *",
                  hintText: "請輸入密碼",
                ),
              ),
            ),
            SizedBox(
              height: 52.0,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 48.0,
              height: 48.0,
              child: RaisedButton(
                child: Text("註冊", style: TextStyle(fontSize: 20)),
                onPressed: () {
                  String status;
                  // String accountstatus;
                  this.registerBTN().then((value) {
                    if (value != 'neterror') {
                      status = json.decode(value)["Status"];
                      // accountstatus = json.decode(value)["msg"];
                      print(status);
                    }
                    if (value == 'neterror') {
                      Alert(
                        context: context,
                        type: AlertType.error,
                        title: "註冊失敗",
                        desc: "請檢查網路連線狀態",
                        buttons: [
                          DialogButton(
                            child: Text(
                              "確認",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            onPressed: () => Navigator.pop(context),
                            width: 120,
                          )
                        ],
                      ).show();
                    }
                    if (status == "Success") {
                      Alert(
                        context: context,
                        type: AlertType.success,
                        title: "註冊成功",
                        desc: "註冊成功",
                        buttons: [
                          DialogButton(
                            child: Text(
                              "確認",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage())),
                            width: 120,
                          )
                        ],
                      ).show();

                      // print(json.decode(value)["StoreID"]);
                    } else if (status == "AccountRepeat") {
                      Alert(
                        context: context,
                        type: AlertType.error,
                        title: "註冊失敗",
                        desc: "已經有重覆的帳號，請更換帳號重試",
                        buttons: [
                          DialogButton(
                            child: Text(
                              "確認",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
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
                        title: "註冊失敗",
                        desc: "帳號或密碼錯誤",
                        buttons: [
                          DialogButton(
                            child: Text(
                              "確認",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            onPressed: () => Navigator.pop(context),
                            width: 120,
                          )
                        ],
                      ).show();
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
