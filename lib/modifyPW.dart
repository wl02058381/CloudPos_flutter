import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:wifi_info_flutter/wifi_info_flutter.dart';
import 'package:cloudpos_online/main.dart';
import 'package:cloudpos_online/register.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';

class ModifyPWPage extends StatelessWidget {
  final String url = "https://iordering.tw:8011/LoginConfirm";
  String data;
  dynamic order_data = {};
  String _status;
  Future<String> getstoreid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storeID = prefs.getString('StoreID');
    return storeID;
  }

  // List<Map<String, dynamic>> logindata = [];
  Future<String> modifyBTN() async {
    try {
      // var wifiIP = await WifiInfo().getWifiIP();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String storeID = prefs.getString('StoreID');
      var url = "https://iordering.tw:8011/UpdatePwd";
      var body = json.encode({
        "StoreID": storeID,
        "Account": accountController.text,
        "PassWord": oldpasswordController.text,
        "NewPassWord": newpasswordController.text
      });
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Accept': 'application/json',
      };
      final response = await http.post(url, body: body, headers: headers);
      print(response.body);
      final String resbody = response.body;
      return resbody;
    } catch (e) {
      print(e);
      return 'neterror';
    }
  }

  @override
  TextEditingController accountController = new TextEditingController();
  TextEditingController oldpasswordController = new TextEditingController();
  TextEditingController newpasswordController = new TextEditingController();
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("修改密碼"), automaticallyImplyLeading: true),
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
                controller: oldpasswordController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.lock),
                  // suffixIcon: Icon(Icons.remove_red_eye),
                  labelText: "舊密碼 *",
                  hintText: "請輸入舊密碼",
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: TextFormField(
                controller: newpasswordController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.lock),
                  // suffixIcon: Icon(Icons.remove_red_eye),
                  labelText: "新密碼 *",
                  hintText: "請輸入新密碼",
                ),
              ),
            ),
            SizedBox(
              height: 52.0,
            ),
            SizedBox(
                width: MediaQuery.of(context).size.width - 48.0,
                height: 150.0,
                child: Column(
                  children: [
                    ProgressButton(
                      defaultWidget: const Text(
                        '修改密碼',
                        style: TextStyle(fontSize: 28),
                      ),
                      progressWidget: const CircularProgressIndicator(),
                      width: 196,
                      height: 60,
                      onPressed: () async {
                        if (accountController.text.length == 0 ||
                            oldpasswordController.text.length == 0 ||
                            newpasswordController.text.length == 0) {
                          Alert(
                            context: context,
                            type: AlertType.error,
                            title: "不可輸入空值",
                            desc: "帳號或密碼錯誤",
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
                          String status;
                          var value = await this.modifyBTN();
                          int score = await Future.delayed(
                              const Duration(milliseconds: 1000), () => 42);
                          return () {
                            if (value == 'neterror') {
                              Alert(
                                context: context,
                                type: AlertType.error,
                                title: "修改失敗",
                                desc: "請檢查網路連線狀態",
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
                            status = json.decode(value)["Status"];
                            print(status);
                            if (status == "Success") {
                              Alert(
                                context: context,
                                type: AlertType.success,
                                title: "修改成功",
                                desc: "修改密碼成功",
                                buttons: [
                                  DialogButton(
                                    child: Text(
                                      "確認",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                    onPressed: () => Navigator.of(context)
                                        .pushNamed('/HomePage'),
                                    width: 120,
                                  )
                                ],
                              ).show();
                            } else {
                              Alert(
                                context: context,
                                type: AlertType.error,
                                title: "修改失敗",
                                desc: "帳號或密碼錯誤",
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
                          };
                        }
                      },
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
