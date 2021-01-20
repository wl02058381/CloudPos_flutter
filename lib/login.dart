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

class LoginPage extends StatelessWidget {
  final String url = "https://cloudpos.54ucl.com:8011/LoginConfirm";
  String data;
  dynamic order_data = {};
  String _status;

  // List<Map<String, dynamic>> logindata = [];
  Future<String> loginBTN() async {
    try {
      var wifiIP = await WifiInfo().getWifiIP();
      var url = "https://cloudpos.54ucl.com:8011/LoginConfirm";
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
      // final String status = json.decode(response.body)["Status"];
      // return status;
      final String resbody = response.body;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('StoreID', json.decode(resbody)["StoreID"]);
      // await prefs.setString('StoreName', json.decode(resbody)["StoreName"]);
      return resbody;
    } catch (e) {
      print(e);
      return 'neterror';
    }
  }

  @override
  TextEditingController accountController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("登入頁面"), automaticallyImplyLeading: false),
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
                height: 150.0,
                child: Column(
                  children: [
                    ProgressButton(
                      defaultWidget: const Text(
                        '登入',
                        style: TextStyle(fontSize: 28),
                      ),
                      progressWidget: const CircularProgressIndicator(),
                      width: 196,
                      height: 60,
                      onPressed: () async {
                        if (accountController.text.length == 0 ||
                            passwordController.text.length == 0) {
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
                          var value = await this.loginBTN();
                          int score = await Future.delayed(
                              const Duration(milliseconds: 1000), () => 42);
                          return () {
                            if (value == 'neterror') {
                              Alert(
                                context: context,
                                type: AlertType.error,
                                title: "登入失敗",
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
                              Navigator.of(context).pushNamed('/HomePage');
                              // logindata.add(json.decode(value)["StoreID"]);
                              // logindata.add(json.decode(value)["StoreName"]);
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => HomePage()));
                              print(json.decode(value)["StoreID"]);
                              print(json.decode(value)["StoreName"]);
                            } else {
                              Alert(
                                context: context,
                                type: AlertType.error,
                                title: "登入失敗",
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
                    // RaisedButton(
                    //   child: Text(
                    //     "登入",
                    //     style: new TextStyle(fontSize: 40),
                    //   ),
                    //   onPressed: () {
                    //     String status;
                    //     this.loginBTN().then((value) {
                    //       if (value == 'neterror') {
                    //         Alert(
                    //           context: context,
                    //           type: AlertType.error,
                    //           title: "登入失敗",
                    //           desc: "請檢查網路連線狀態",
                    //           buttons: [
                    //             DialogButton(
                    //               child: Text(
                    //                 "確認",
                    //                 style: TextStyle(
                    //                     color: Colors.white, fontSize: 20),
                    //               ),
                    //               onPressed: () => Navigator.pop(context),
                    //               width: 120,
                    //             )
                    //           ],
                    //         ).show();
                    //       }
                    //       status = json.decode(value)["Status"];
                    //       print(status);
                    //       if (status == "Success") {
                    //         // logindata.add(json.decode(value)["StoreID"]);
                    //         // logindata.add(json.decode(value)["StoreName"]);
                    //         Navigator.push(
                    //             context,
                    //             MaterialPageRoute(
                    //                 builder: (context) => HomePage()));
                    //         print(json.decode(value)["StoreID"]);
                    //         print(json.decode(value)["StoreName"]);
                    //       } else {
                    //         Alert(
                    //           context: context,
                    //           type: AlertType.error,
                    //           title: "登入失敗",
                    //           desc: "帳號或密碼錯誤",
                    //           buttons: [
                    //             DialogButton(
                    //               child: Text(
                    //                 "確認",
                    //                 style: TextStyle(
                    //                     color: Colors.white, fontSize: 20),
                    //               ),
                    //               onPressed: () => Navigator.pop(context),
                    //               width: 120,
                    //             )
                    //           ],
                    //         ).show();
                    //       }
                    //     });
                    //   },
                    // ),
                    FlatButton(
                      child: Text("註冊", style: new TextStyle(fontSize: 20)),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegisterPage()));
                      },
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
