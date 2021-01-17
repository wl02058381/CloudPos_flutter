// import 'package:flutter/material.dart';
// import 'package:flutter/semantics.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
// import 'dart:io';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:cloudpos_online/print.dart';
import 'package:cloudpos_online/chooseBT.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloudpos_online/login.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
//----print
import 'package:flutter/material.dart' hide Image;
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/services.dart';
import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'dart:typed_data';
// import 'package:image/image.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:charset_converter/charset_converter.dart';

//----
void main() {
  // runApp(MaterialApp(home: HomePage(), debugShowCheckedModeBanner: false));
  runApp(MaterialApp(
      home: LoginPage(),
      routes: <String, WidgetBuilder>{
        '/HomePage': (BuildContext context) => new HomePage(),
        '/ChooseBT': (BuildContext context) => new ChooseBT(),
        '/LoginPage': (BuildContext context) => new LoginPage(),
        '/BPage': (BuildContext context) => new BPage(),
        '/CloudPos': (BuildContext context) => new CloudPos(),
      },
      debugShowCheckedModeBanner: false));
}

class FoodInfo {
  final String orderTempID;
  final String price;
  final String diningStyle;
  final String mealDate;
  // final String picture;

  FoodInfo(this.orderTempID, this.price, this.diningStyle, this.mealDate);
}

class HomePage extends StatefulWidget {
  String data;
  HomePage({this.data}); //StoreName
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  loginclean() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('savedrawList', []);
  }

  Future<String> getstoreid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storeID = prefs.getString('StoreID');
    return storeID;
  }

  Future<String> getstorename() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storeName = prefs.getString('StoreName');
    setState(() {
      storeName = storeName;
    });
    return storeName;
  }

  String data;
  String storeName;
  HomePageState({this.data}); //StoreName

  @override
  Widget build(BuildContext context) {
    print("HomePageStatebuild");

    return SafeArea(
        child: Scaffold(
      body: Container(
          child: Center(
        child: SizedBox(
            width: 200,
            height: 500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(storeName ?? this.storeName,
                    style: TextStyle(fontSize: 32.0)),
                Text("店家系統", style: TextStyle(fontSize: 24.0)),
                ButtonTheme(
                    minWidth: 200.0,
                    height: 70.0,
                    buttonColor: Colors.white70,
                    child: RaisedButton(
                      child: Text("出單系統", style: TextStyle(fontSize: 22.0)),
                      onPressed: () {
                        Navigator.of(context).pushNamed('/CloudPos');
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => CloudPos()));
                      },
                    )),
                ButtonTheme(
                    minWidth: 200.0,
                    height: 70.0,
                    buttonColor: Colors.white70,
                    child: RaisedButton(
                      child: Text("後台設定", style: TextStyle(fontSize: 22.0)),
                      onPressed: () {
                        String storeid;
                        getstoreid().then((value) => storeid = value);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WebviewScaffold(
                                      url:
                                          'https://cloudpos.54ucl.com:3010/?s=' +
                                              storeid,
                                      // withLocalStorage: true,

                                      withJavascript: true,
                                      hidden: true,
                                      withZoom: true,
                                      initialChild: Container(
                                          child: const Center(
                                        child: CircularProgressIndicator(),
                                      )),
                                      appBar:
                                          new AppBar(title: new Text('後台設定')),
                                    )
                                // WebView(
                                //       initialUrl:
                                //           'https://cloudpos.54ucl.com:3010',
                                //       javascriptMode:
                                //           JavascriptMode.unrestricted,
                                //     )
                                ));

                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => CloudPos()));
                      },
                    )),
                ButtonTheme(
                    minWidth: 200.0,
                    height: 70.0,
                    buttonColor: Colors.white70,
                    child: RaisedButton(
                      child: Text("設備選擇", style: TextStyle(fontSize: 22.0)),
                      onPressed: () {
                        Navigator.of(context).pushNamed('/ChooseBT');

                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => ChooseBT()));
                      },
                    )),
                ButtonTheme(
                    minWidth: 200.0,
                    height: 70.0,
                    buttonColor: Colors.white70,
                    child: RaisedButton(
                      child: Text("登出", style: TextStyle(fontSize: 22.0)),
                      onPressed: () {
                        loginclean();
                        Navigator.of(context).pushNamed('/LoginPage');

                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => LoginPage()));
                      },
                    ))
              ],
            )),
      )),
    ));
  }

  @override
  void initState() {
    getstorename().then((value) => {storeName = value});
    setConnect() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String mac = prefs.getString('mac');
      if (mac == null) {
        print("藍芽未連線");
      }
      print("mac");
      print(mac);
      final String result = await BluetoothThermalPrinter.connect(mac);
      print("state conneected $result");
    }

    setConnect();
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    // if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }
}
// class HomePageState extends State<HomePage>{

// }
class CloudPos extends StatefulWidget {
  @override
  CloudPosState createState() => CloudPosState();
}

class CloudPosState extends State<CloudPos> {
  final String url = "https://cloudpos.54ucl.com:8011/GetTempOrder";
  String clouddata;
  dynamic order_data = {};
  Timer _timer;
  int seconds;
  List<String> _orderdrawlist = List<String>();
  Future<String> getSWData(paid, del) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String storeID = prefs.getString('StoreID');
      var url = "https://cloudpos.54ucl.com:8011/GetTempOrder";
      var body = json.encode({"StoreID": storeID, "Paid": paid, "Del": del});
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Accept': 'application/json',
      };
      final response = await http.post(url, body: body, headers: headers);
      setState(() {
        clouddata = response.body;
      });
      return "Success!";
    } catch (e) {
      return "error";
    }
  }

  Future<String> searchSWData(searchText) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storeID = prefs.getString('StoreID');
    var url = "https://cloudpos.54ucl.com:8011/GetSearchTempOrder";
    var body = json.encode({
      "Token": "GetRow.Token",
      "StoreID": storeID,
      "MealID": searchText,
      "Paid": "-1",
      "Del": "-1"
    });
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    final response = await http.post(url, body: body, headers: headers);
    print(response.body);
    // if  (json.decode(response.body)["Data"]
    title = "(編號搜尋)";
    setState(() {
      clouddata = response.body;
    });
    return "Success!";
  }

  Future<List> _getOrderdraw() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final order_drawlist = prefs.getStringList('order_drawlist') ?? [];
    // print('order_drawlist $order_drawlist ');
    // prefs.remove('order_drawlist');
    return order_drawlist;
  }

  String title = "(未結帳訂單)"; //預設title

  @override
  TextEditingController searchController = new TextEditingController();
  Widget build(BuildContext context) {
    print("CloudPosStatebuild");
    var diningStyle = new List();
    var dining = new List();
    var cardcolor = new List();
    var btncolor = Colors.orange;
    var orderAndstatus = new Map();
    return FutureBuilder<List>(
      future: _getOrderdraw().then((order_drawlist) {
        print(order_drawlist);
        //把字串分開用Map去存
        for (var i = 0; i < order_drawlist.length; i++) {
          // print(i);
          // print(order_drawlist[i].toString().split('#'));
          orderAndstatus[
                  order_drawlist[i].toString().split('#')[0].toString()] =
              order_drawlist[i].toString().split('#')[1].toString();
        }
        // print("orderAndstatus");
        // print(orderAndstatus);
      }),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        // 请求已结束
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            // 请求失败，显示错误
            // return Text("Error: ${snapshot.error}");
            Alert(
              context: context,
              type: AlertType.error,
              title: "發生異常狀況",
              desc: "請求資料失敗",
              buttons: [
                DialogButton(
                  child: Text(
                    "確認",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  onPressed: () => Navigator.pop(context),
                  width: 120,
                )
              ],
            ).show();
          } else {
            // 请求成功，显示数据
            // return Text("Contents: ${snapshot.data}");
            for (var i = 0; i < json.decode(clouddata)["Data"].length; i++) {
              for (var i = 0; i < json.decode(clouddata)["Data"].length; i++) {
                // print(orderAndstatus
                //     .containsKey(json.decode(clouddata)["Data"][i]["OrderID"]));
                dining.add(json.decode(clouddata)["Data"][i]["DiningStyle"]);
                if (json.decode(clouddata)["Data"][i]["DiningStyle"] ==
                    "TakeOut") {
                  //外帶
                  diningStyle.add(
                      "外帶-電話：" + json.decode(clouddata)["Data"][i]["Phone"]);
                  if (orderAndstatus.containsKey(
                              json.decode(clouddata)["Data"][i]["OrderID"]) ==
                          true &&
                      orderAndstatus[json.decode(clouddata)["Data"][i]
                              ["OrderID"]] ==
                          '1') {
                    // 畫完的
                    cardcolor.add(Colors.cyan);
                  } else if (orderAndstatus.containsKey(
                              json.decode(clouddata)["Data"][i]["OrderID"]) ==
                          true &&
                      orderAndstatus[json.decode(clouddata)["Data"][i]
                              ["OrderID"]] ==
                          '0') {
                    // 沒畫完
                    cardcolor.add(Colors.blueAccent);
                  } else {
                    cardcolor.add(Colors.black12);
                  }
                } else {
                  //內用
                  diningStyle.add(
                      "內用-桌號：" + json.decode(clouddata)["Data"][i]["Table"]);
                  if (orderAndstatus.containsKey(
                              json.decode(clouddata)["Data"][i]["OrderID"]) ==
                          true &&
                      orderAndstatus[json.decode(clouddata)["Data"][i]
                              ["OrderID"]] ==
                          '1') {
                    // 畫完的
                    cardcolor.add(Colors.cyan);
                  } else if (orderAndstatus.containsKey(
                              json.decode(clouddata)["Data"][i]["OrderID"]) ==
                          true &&
                      orderAndstatus[json.decode(clouddata)["Data"][i]
                              ["OrderID"]] ==
                          '0') {
                    // 沒畫完
                    cardcolor.add(Colors.blueAccent);
                  } else {
                    cardcolor.add(Colors.black26);
                  }
                }
              }
            }
            return Scaffold(
              appBar: AppBar(
                  leading: IconButton(
                    icon: Icon(
                      Icons.wrap_text_sharp,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/HomePage');
                      // Navigator.of(context).pushNamedAndRemoveUntil('/HomePage', (Route<dynamic> route) => false);
                      // Navigator.push(
                      //     context, MaterialPageRoute(builder: (_) => HomePage()));
                    },
                  ),
                  title: Text("CloudPos出單系統$title"),
                  backgroundColor: Colors.black45),
              bottomNavigationBar: BottomAppBar(
                child: Container(
                    height: 100.0,
                    child: Row(
                      children: <Widget>[
                        Row(
                          children: [
                            Text("   "),
                            FlatButton(
                              height: 80.0,
                              color: btncolor,
                              textColor: Colors.white,
                              child: Text('未結帳訂單',
                                  style: TextStyle(fontSize: 20.0)),
                              onPressed: () {
                                this.getSWData('0', '0').then((value) {
                                  if (value == "error") {
                                    Alert(
                                      context: context,
                                      type: AlertType.error,
                                      title: "網路未連接",
                                      desc: "請檢查網路連線狀態",
                                      buttons: [
                                        DialogButton(
                                          child: Text(
                                            "確認",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20),
                                          ),
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          width: 120,
                                        )
                                      ],
                                    ).show();
                                  }
                                  setState(() {
                                    title = '(未結帳訂單)';
                                    btncolor = Colors.red;
                                  });
                                });
                              },
                            ),
                            Text("   "),
                            // Spacer(),
                            FlatButton(
                              height: 80.0,
                              color: Colors.pink,
                              textColor: Colors.white,
                              child: Text('已結帳訂單',
                                  style: TextStyle(fontSize: 20.0)),
                              onPressed: () {
                                this.getSWData('1', '0').then((value) {
                                  if (value == "error") {
                                    Alert(
                                      context: context,
                                      type: AlertType.error,
                                      title: "網路未連接",
                                      desc: "請檢查網路連線狀態",
                                      buttons: [
                                        DialogButton(
                                          child: Text(
                                            "確認",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20),
                                          ),
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          width: 120,
                                        )
                                      ],
                                    ).show();
                                  }
                                  setState(() {
                                    title = '(已結帳訂單)';
                                  });
                                });
                              },
                            ),
                            Text("   "),
                            // Spacer(),
                            FlatButton(
                              height: 80.0,
                              color: Theme.of(context).primaryColor,
                              textColor: Colors.white,
                              child: Text('歷史紀錄',
                                  style: TextStyle(fontSize: 20.0)),
                              onPressed: () {
                                this.getSWData('-1', '0').then((value) {
                                  if (value == "error") if (value == "error") {
                                    Alert(
                                      context: context,
                                      type: AlertType.error,
                                      title: "網路未連接",
                                      desc: "請檢查網路連線狀態",
                                      buttons: [
                                        DialogButton(
                                          child: Text(
                                            "確認",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20),
                                          ),
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          width: 120,
                                        )
                                      ],
                                    ).show();
                                  }
                                  setState(() {
                                    title = '(歷史紀錄)';
                                  });
                                });
                              },
                            ),
                            Text("   "),
                            FlatButton(
                              height: 80.0,
                              color: Theme.of(context).textSelectionHandleColor,
                              textColor: Colors.white,
                              child: Text('編號搜尋',
                                  style: TextStyle(fontSize: 20.0)),
                              onPressed: () {
                                Alert(
                                    context: context,
                                    title: "編號搜尋",
                                    content: Column(
                                      children: <Widget>[
                                        TextField(
                                          controller: searchController,
                                          decoration: InputDecoration(
                                            icon: Icon(Icons.search_rounded),
                                            labelText: '輸入編號',
                                          ),
                                        )
                                      ],
                                    ),
                                    buttons: [
                                      DialogButton(
                                        onPressed: () {
                                          searchSWData(searchController.text);
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          "搜尋",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
                                        ),
                                      )
                                    ]).show();
                              },
                            )
                          ],
                        )
                      ],
                    )),
                color: Colors.white,
              ),
              body: ListView.builder(
                itemCount: clouddata == null
                    ? 0
                    : json.decode(clouddata)["Data"].length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Card(
                            color:
                                _orderdrawlist.contains(order_data["OrderID"])
                                    ? Colors.red.withOpacity(0.3)
                                    : Colors.white,
                            child: new InkWell(
                                onTap: () {
                                  print("Card按鈕");
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              BPage(order_data: {
                                                "orderTempID": json
                                                    .decode(clouddata)["Data"]
                                                        [index]["MealID"]
                                                    .toString(),
                                                "diningStyle":
                                                    diningStyle[index],
                                                "price": json.decode(
                                                        clouddata)["Data"]
                                                    [index]["TotalPrice"],
                                                "OrderTemp": json.decode(
                                                        clouddata)["Data"]
                                                    [index]["OrderTemp"],
                                                "DataTime": json.decode(
                                                        clouddata)["Data"]
                                                    [index]["DataTime"],
                                                "MealTime": json.decode(
                                                        clouddata)["Data"]
                                                    [index]["MealTime"],
                                                "DiningStyleID": json.decode(
                                                        clouddata)["Data"]
                                                    [index]["DiningStyleID"],
                                                "dining": dining[index],
                                                "OrderID": json.decode(
                                                        clouddata)["Data"]
                                                    [index]["OrderID"],
                                                "Phone": json.decode(
                                                        clouddata)["Data"]
                                                    [index]["Phone"],
                                                "Table": json.decode(
                                                        clouddata)["Data"]
                                                    [index]["Table"],
                                                "title": title
                                              })));
                                },
                                child: Container(
                                    color: cardcolor[index], //外送內用的卡片顏色
                                    padding: EdgeInsets.all(17.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                            "編號:" +
                                                json
                                                    .decode(clouddata)["Data"]
                                                        [index]["MealID"]
                                                    .toString(),
                                            style: new TextStyle(fontSize: 24)),
                                        Text(
                                            "價錢:" +
                                                json.decode(clouddata)["Data"]
                                                    [index]["TotalPrice"],
                                            style: TextStyle(
                                                fontSize: 22.0,
                                                color: Colors.red)),
                                        Column(
                                          children: [
                                            Text(diningStyle[index],
                                                style:
                                                    TextStyle(fontSize: 17.2)),
                                            Text(
                                                "時間：" +
                                                    json.decode(
                                                            clouddata)["Data"]
                                                        [index]["DataTime"],
                                                style: TextStyle(
                                                    fontSize: 14.0,
                                                    color: Colors.black87)),
                                          ],
                                        )
                                      ],
                                    ))),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
        } else {
          // 请求未结束，显示loading
          return Scaffold(
              backgroundColor: Colors.blue[900],
              body: Center(
                  child: SpinKitFadingCircle(
                size: 100.0,
                itemBuilder: (BuildContext context, int index) {
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      color: index.isEven ? Colors.red : Colors.green,
                    ),
                  );
                },
              )));
        }
      },
    );

    try {
      //訂單顏色狀態
      // _getOrderdraw().then((order_drawlist) {
      //   //把字串分開用Map去存
      //   for (var i = 0; i < order_drawlist.length; i++) {
      //     // print(i);
      //     print(order_drawlist[i].toString().split('#'));
      //     orderAndstatus[
      //             order_drawlist[i].toString().split('#')[0].toString()] =
      //         order_drawlist[i].toString().split('#')[1].toString();
      //   }
      //   print("orderAndstatus");
      //   print(orderAndstatus);
      // });
      print(orderAndstatus);
      for (var i = 0; i < json.decode(clouddata)["Data"].length; i++) {
        print(orderAndstatus
            .containsKey(json.decode(clouddata)["Data"][i]["OrderID"]));
        dining.add(json.decode(clouddata)["Data"][i]["DiningStyle"]);
        if (json.decode(clouddata)["Data"][i]["DiningStyle"] == "TakeOut") {
          //外帶
          diningStyle
              .add("外帶-電話：" + json.decode(clouddata)["Data"][i]["Phone"]);
          if (orderAndstatus.containsKey(
                      json.decode(clouddata)["Data"][i]["OrderID"]) ==
                  true &&
              orderAndstatus.containsValue('1') == true) {
            // 畫完的
            cardcolor.add(Colors.cyan);
          } else if (orderAndstatus.containsKey(
                      json.decode(clouddata)["Data"][i]["OrderID"]) ==
                  true &&
              orderAndstatus.containsValue('0') == true) {
            // 沒畫完
            cardcolor.add(Colors.blueAccent);
          } else {
            cardcolor.add(Colors.black12);
          }
        } else {
          //內用
          diningStyle
              .add("內用-桌號：" + json.decode(clouddata)["Data"][i]["Table"]);
          if (orderAndstatus.containsKey(
                      json.decode(clouddata)["Data"][i]["OrderID"]) ==
                  true &&
              orderAndstatus.containsValue('1') == true) {
            // 畫完的
            cardcolor.add(Colors.cyan);
          } else if (orderAndstatus.containsKey(
                      json.decode(clouddata)["Data"][i]["OrderID"]) ==
                  true &&
              orderAndstatus.containsValue('0') == true) {
            // 沒畫完
            cardcolor.add(Colors.blueAccent);
          } else {
            cardcolor.add(Colors.black26);
          }
        }
      }

      // return Scaffold(
      //   appBar: AppBar(
      //       leading: IconButton(
      //         icon: Icon(
      //           Icons.wrap_text_sharp,
      //           color: Colors.white,
      //         ),
      //         onPressed: () {
      //           Navigator.of(context).pushNamed('/HomePage');
      //           // Navigator.of(context).pushNamedAndRemoveUntil('/HomePage', (Route<dynamic> route) => false);
      //           // Navigator.push(
      //           //     context, MaterialPageRoute(builder: (_) => HomePage()));
      //         },
      //       ),
      //       title: Text("CloudPos出單系統$title"),
      //       backgroundColor: Colors.black45),
      //   bottomNavigationBar: BottomAppBar(
      //     child: Container(
      //         height: 100.0,
      //         child: Row(
      //           children: <Widget>[
      //             Row(
      //               children: [
      //                 Text("   "),
      //                 FlatButton(
      //                   height: 80.0,
      //                   color: btncolor,
      //                   textColor: Colors.white,
      //                   child: Text('未結帳訂單', style: TextStyle(fontSize: 20.0)),
      //                   onPressed: () {
      //                     this.getSWData('0', '0').then((value) {
      //                       if (value == "error") {
      //                         Alert(
      //                           context: context,
      //                           type: AlertType.error,
      //                           title: "網路未連接",
      //                           desc: "請檢查網路連線狀態",
      //                           buttons: [
      //                             DialogButton(
      //                               child: Text(
      //                                 "確認",
      //                                 style: TextStyle(
      //                                     color: Colors.white, fontSize: 20),
      //                               ),
      //                               onPressed: () => Navigator.pop(context),
      //                               width: 120,
      //                             )
      //                           ],
      //                         ).show();
      //                       }
      //                       setState(() {
      //                         title = '(未結帳訂單)';
      //                         btncolor = Colors.red;
      //                       });
      //                     });
      //                   },
      //                 ),
      //                 Text("   "),
      //                 // Spacer(),
      //                 FlatButton(
      //                   height: 80.0,
      //                   color: Colors.pink,
      //                   textColor: Colors.white,
      //                   child: Text('已結帳訂單', style: TextStyle(fontSize: 20.0)),
      //                   onPressed: () {
      //                     this.getSWData('1', '0').then((value) {
      //                       if (value == "error") {
      //                         Alert(
      //                           context: context,
      //                           type: AlertType.error,
      //                           title: "網路未連接",
      //                           desc: "請檢查網路連線狀態",
      //                           buttons: [
      //                             DialogButton(
      //                               child: Text(
      //                                 "確認",
      //                                 style: TextStyle(
      //                                     color: Colors.white, fontSize: 20),
      //                               ),
      //                               onPressed: () => Navigator.pop(context),
      //                               width: 120,
      //                             )
      //                           ],
      //                         ).show();
      //                       }
      //                       setState(() {
      //                         title = '(已結帳訂單)';
      //                       });
      //                     });
      //                   },
      //                 ),
      //                 Text("   "),
      //                 // Spacer(),
      //                 FlatButton(
      //                   height: 80.0,
      //                   color: Theme.of(context).primaryColor,
      //                   textColor: Colors.white,
      //                   child: Text('歷史紀錄', style: TextStyle(fontSize: 20.0)),
      //                   onPressed: () {
      //                     this.getSWData('-1', '0').then((value) {
      //                       if (value == "error") if (value == "error") {
      //                         Alert(
      //                           context: context,
      //                           type: AlertType.error,
      //                           title: "網路未連接",
      //                           desc: "請檢查網路連線狀態",
      //                           buttons: [
      //                             DialogButton(
      //                               child: Text(
      //                                 "確認",
      //                                 style: TextStyle(
      //                                     color: Colors.white, fontSize: 20),
      //                               ),
      //                               onPressed: () => Navigator.pop(context),
      //                               width: 120,
      //                             )
      //                           ],
      //                         ).show();
      //                       }
      //                       setState(() {
      //                         title = '(歷史紀錄)';
      //                       });
      //                     });
      //                   },
      //                 ),
      //                 Text("   "),
      //                 FlatButton(
      //                   height: 80.0,
      //                   color: Theme.of(context).textSelectionHandleColor,
      //                   textColor: Colors.white,
      //                   child: Text('編號搜尋', style: TextStyle(fontSize: 20.0)),
      //                   onPressed: () {
      //                     Alert(
      //                         context: context,
      //                         title: "編號搜尋",
      //                         content: Column(
      //                           children: <Widget>[
      //                             TextField(
      //                               controller: searchController,
      //                               decoration: InputDecoration(
      //                                 icon: Icon(Icons.search_rounded),
      //                                 labelText: '輸入編號',
      //                               ),
      //                             )
      //                           ],
      //                         ),
      //                         buttons: [
      //                           DialogButton(
      //                             onPressed: () {
      //                               searchSWData(searchController.text);
      //                               Navigator.pop(context);
      //                             },
      //                             child: Text(
      //                               "搜尋",
      //                               style: TextStyle(
      //                                   color: Colors.white, fontSize: 20),
      //                             ),
      //                           )
      //                         ]).show();
      //                   },
      //                 )
      //               ],
      //             )
      //           ],
      //         )),
      //     color: Colors.white,
      //   ),
      //   body: ListView.builder(
      //     itemCount:
      //         clouddata == null ? 0 : json.decode(clouddata)["Data"].length,
      //     itemBuilder: (BuildContext context, int index) {
      //       return Container(
      //         child: Center(
      //           child: Column(
      //             crossAxisAlignment: CrossAxisAlignment.stretch,
      //             children: <Widget>[
      //               Card(
      //                 color: _orderdrawlist.contains(order_data["OrderID"])
      //                     ? Colors.red.withOpacity(0.3)
      //                     : Colors.white,
      //                 child: new InkWell(
      //                     onTap: () {
      //                       print("Card按鈕");
      //                       Navigator.push(
      //                           context,
      //                           MaterialPageRoute(
      //                               builder: (context) => BPage(order_data: {
      //                                     "orderTempID": json
      //                                         .decode(clouddata)["Data"][index]
      //                                             ["MealID"]
      //                                         .toString(),
      //                                     "diningStyle": diningStyle[index],
      //                                     "price":
      //                                         json.decode(clouddata)["Data"]
      //                                             [index]["TotalPrice"],
      //                                     "OrderTemp":
      //                                         json.decode(clouddata)["Data"]
      //                                             [index]["OrderTemp"],
      //                                     "DataTime":
      //                                         json.decode(clouddata)["Data"]
      //                                             [index]["DataTime"],
      //                                     "MealTime":
      //                                         json.decode(clouddata)["Data"]
      //                                             [index]["MealTime"],
      //                                     "DiningStyleID":
      //                                         json.decode(clouddata)["Data"]
      //                                             [index]["DiningStyleID"],
      //                                     "dining": dining[index],
      //                                     "OrderID":
      //                                         json.decode(clouddata)["Data"]
      //                                             [index]["OrderID"],
      //                                     "Phone":
      //                                         json.decode(clouddata)["Data"]
      //                                             [index]["Phone"],
      //                                     "Table":
      //                                         json.decode(clouddata)["Data"]
      //                                             [index]["Table"],
      //                                     "title": title
      //                                   })));
      //                     },
      //                     child: Container(
      //                         color: cardcolor[index], //外送內用的卡片顏色
      //                         padding: EdgeInsets.all(17.0),
      //                         child: Row(
      //                           mainAxisAlignment:
      //                               MainAxisAlignment.spaceAround,
      //                           crossAxisAlignment: CrossAxisAlignment.center,
      //                           children: <Widget>[
      //                             Text(
      //                                 "編號:" +
      //                                     json
      //                                         .decode(clouddata)["Data"][index]
      //                                             ["MealID"]
      //                                         .toString(),
      //                                 style: new TextStyle(fontSize: 24)),
      //                             Text(
      //                                 "價錢:" +
      //                                     json.decode(clouddata)["Data"][index]
      //                                         ["TotalPrice"],
      //                                 style: TextStyle(
      //                                     fontSize: 22.0, color: Colors.red)),
      //                             Column(
      //                               children: [
      //                                 Text(diningStyle[index],
      //                                     style: TextStyle(fontSize: 17.2)),
      //                                 Text(
      //                                     "時間：" +
      //                                         json.decode(clouddata)["Data"]
      //                                             [index]["DataTime"],
      //                                     style: TextStyle(
      //                                         fontSize: 14.0,
      //                                         color: Colors.black87)),
      //                               ],
      //                             )
      //                           ],
      //                         ))),
      //               ),
      //             ],
      //           ),
      //         ),
      //       );
      //     },
      //   ),
      // );
    } catch (e) {
      return Scaffold(
          backgroundColor: Colors.blue[900],
          body: Center(
              child: SpinKitFadingCircle(
            size: 100.0,
            itemBuilder: (BuildContext context, int index) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: index.isEven ? Colors.red : Colors.green,
                ),
              );
            },
          )));
    }
  }

  @override
  void initState() {
    // print("安安");
    this.getSWData('0', '0').then((value) {
      if (value == "error") {
        Alert(
          context: context,
          type: AlertType.error,
          title: "網路未連接",
          desc: "請檢查網路連線狀態",
          buttons: [
            DialogButton(
              child: Text(
                "確認",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () {
                // Navigator.of(context).pushNamedAndRemoveUntil('/HomePage', (Route<dynamic> route) => false);
                Navigator.of(context).pushNamed('/HomePage');

                // Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => HomePage()));
              },
              width: 120,
            )
          ],
        ).show();
      }
    });
    startTimer();
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    // if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  void startTimer() {
    //設定 1 秒回撥一次
    const period = const Duration(seconds: 30);
    _timer = Timer(period, () {
      //更新介面
      if (title == '(未結帳訂單)') {
        this.getSWData('0', '0');
      } else if (title == "(已結帳訂單)") {
        this.getSWData('1', '0');
      } else if (title == "(歷史紀錄)") {
        this.getSWData('-1', '0');
      }
    });
  }
}

// class BPage extends StatefulWidget{
// @override
//   BPageState createState() => BPageState();
// }
class BPage extends StatefulWidget {
  final dynamic order_data;
  BPage({this.order_data});
  @override
  State<StatefulWidget> createState() {
    //createState方法會回傳一個state組件
    return BPageState();
    //上述的組件就是這個
  }
// BPageState createState() => BPageState();
}

class BPageState extends State<BPage> {
  @override
  // 從首頁傳orderTempID過來
  bool isSelected = false;
  dynamic order_data;
  BPageState({this.order_data});
  List<Map<String, dynamic>> data = [];
  var choiceCard = new List();
  // var cardColor = new List();
  // Color _cardColor1 = Colors.white;
  List<int> _selectedItems = List<int>();
  List<String> _drawlist = List<String>();
  List<String> _orderdrawlist = List<String>();
  // TextDecoration _lineThrough = TextDecoration.none;
  // Color _cardColor2 = Colors.white;
  // TextDecoration _lineThrough2 = TextDecoration.none;
  // String applydata;
  Future<String> orderApply(orderid, totalprice, mealid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storeID = prefs.getString('StoreID');
    var url = "https://cloudpos.54ucl.com:8011/OrderApply";
    var body = json.encode({
      "Token": "str",
      "StoreID": storeID,
      "OrderID": orderid,
      "TotalPrice": totalprice,
      "MealID": mealid
    });
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    final response = await http.post(url, body: body, headers: headers);
    print(json.decode(response.body)["Status"]);
    // setState(() {
    //   applydata = response.body;
    // });
    print("applydata Success!");
    return response.body;
  }

  Future<String> cancelApply(orderid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storeID = prefs.getString('StoreID');
    var url = "https://cloudpos.54ucl.com:8011/CancleOrder";
    var body =
        json.encode({"Token": "str", "StoreID": storeID, "OrderID": orderid});
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    final response = await http.post(url, body: body, headers: headers);
    // setState(() {
    //   applydata = response.body;
    // });
    print("cancelApply Success!");
    return "cancelApply Success!";
  }

  Future<List> _savedraw(orderid, index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // String savedraw = (prefs.getString('savedraw'));
    final myStringList = prefs.getStringList('savedrawList') ?? [];
    if (!myStringList.contains(orderid + index)) {
      myStringList.add(orderid + index);
    }
    print('Pressed $myStringList ');
    // await prefs.setString('savedraw', orderid + index);
    await prefs.setStringList('savedrawList', myStringList);
    return myStringList;
  }

  Future<List> _getOrderdraw() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // String savedraw = (prefs.getString('savedraw'));
    final order_drawlist = prefs.getStringList('order_drawlist') ?? [];
    print('order_drawlist $order_drawlist ');

    // await prefs.setString('savedraw', orderid + index);
    // await prefs.setStringList('order_drawlist', order_drawlist);
    return order_drawlist;
  }

  Future<List> _saveOrderdraw(orderID, order_drawlist) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // String savedraw = (prefs.getString('savedraw'));
    final myStringList = prefs.getStringList('order_drawlist') ?? [];
    if (myStringList.contains(orderID + '#0')) {
      myStringList.remove(orderID + '#0');
    } else if (myStringList.contains(orderID + '#1')) {
      myStringList.remove(orderID + '#1');
    }
    myStringList.add(order_drawlist);
    print('order_drawlist $myStringList ');
    // await prefs.setString('savedraw', orderid + index);
    await prefs.setStringList('order_drawlist', myStringList);
    // return myStringList;
  }

  Future<List> _removeOrderdraw(orderID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // String savedraw = (prefs.getString('savedraw'));
    final myStringList = prefs.getStringList('order_drawlist') ?? [];
    if (myStringList.contains(orderID.toString() + '#0')) {
      print("安安安安安安#0");
      myStringList.remove(orderID + '#0');
      await prefs.setStringList('order_drawlist', myStringList);
    } else if (myStringList.contains(orderID.toString() + '#1')) {
      myStringList.remove(orderID + '#1');
      await prefs.setStringList('order_drawlist', myStringList);
      print("安安安安安安#1");
    }
  }

  Future<String> getstorename() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storeName = prefs.getString('StoreName');
    return storeName;
  }

  Future<String> getmac() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String mac = prefs.getString('mac');
    // prefs.remove('mac');
    return mac;
  }

  Future<Ticket> getGraphicsTicket(ticketdata) async {
    // int total = 0;
    final ticket = Ticket(PaperSize.mm80);
    // Image assets
    // final ByteData data = await rootBundle.load('assets/store.png');
    // final Uint8List bytes = data.buffer.asUint8List();
    // final Image image = decodeImage(bytes);
    // print("here");
    // print(ticketdata);
    String storeName;
    // ticket.image(image); //圖片
    // getstorename().then((value) {
    // storeName = value;
    storeName = await getstorename();
    ticket.text(
      '${storeName}',
      containsChinese: true,
      styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2),
      linesAfter: 1,
    );
    // });
    String dintext;
    String phone;
    String table;
    String mealID;
    var now = new DateTime.now();
    // DateTime date = new DateTime(
    //     now.year, now.month, now.day, now.hour, now.month, now.second);
    var formatter = new DateFormat('yyyy-MM-dd h:m:s');
    String formattedDate = formatter.format(now);
    mealID = ticketdata[0]['MealID'];
    if (ticketdata[0]['DiningStyle'] == "TakeOut") {
      dintext = "外帶";
      phone = ticketdata[0]['Phone'];
      ticket.row([
        PosColumn(text: '編號：     ${mealID}', width: 4, containsChinese: true),
        PosColumn(text: '用餐方式：${dintext}', width: 8, containsChinese: true),
      ]);
      ticket.row([
        PosColumn(text: '電話：', width: 4, containsChinese: true),
        PosColumn(text: '${phone}', width: 8, containsChinese: true),
      ]);
      // ticket.row([
      //   PosColumn(text: '', width: 4, styles: PosStyles(bold: true)),
      //   PosColumn(text: '出單時間：     ${date}', width: 8, containsChinese: true),
      // ]);
      ticket.text('出單時間：             ${formattedDate}', containsChinese: true);
    } else if (ticketdata[0]['DiningStyle'] == "Intermal") {
      dintext = "內用";
      table = ticketdata[0]['Table'];
      ticket.row([
        PosColumn(text: '編號：     ${mealID}', width: 4, containsChinese: true),
        PosColumn(text: '用餐方式：${dintext}', width: 8, containsChinese: true),
      ]);
      ticket.row([
        PosColumn(text: '', width: 4, styles: PosStyles(bold: true)),
        PosColumn(text: '桌號：     ${table}', width: 8, containsChinese: true),
      ]);
      // ticket.row([
      //   PosColumn(text: '', width: 4, styles: PosStyles(bold: true)),
      //   PosColumn(text: '出單時間：     ${date}', width: 8, containsChinese: true),
      // ]);
      ticket.text('出單時間：             ${formattedDate}', containsChinese: true);
    }

    // ticket.text('用餐方式${dintext}', containsChinese: true);
    ticket.text('--------------------------------');
    List<String> charsets = await CharsetConverter.availableCharsets();
    print(charsets);
    for (var i = 1; i < ticketdata.length; i++) {
      // print("INININININNIN");
      // total += ticketdata[i]['total_price'];
      ticket.text(i.toString());

      /// Portuguese
      Uint8List encTxt1 =
          await CharsetConverter.encode("UTF-8", ticketdata[i]['title']);
      // String decoded = await CharsetConverter.decode(
      //     "UTF-8", encTxt1); // Hello (Cześć) in Polish
      // ticket.textEncoded(encTxt1,
      //     styles: PosStyles(codeTable: PosCodeTable.westEur));
      // ticket.textEncoded(encTxt1,
      //     styles: PosStyles(codeTable: PosCodeTable.greek));
      // ticket.textEncoded(encTxt1,
      //     styles: PosStyles(codeTable: PosCodeTable.hebrew1));
      // ticket.textEncoded(encTxt1,
      //     styles: PosStyles(codeTable: PosCodeTable.hebrew2));
      // ticket.textEncoded(encTxt1,
      //     styles: PosStyles(codeTable: PosCodeTable.iran1));
      // ticket.textEncoded(encTxt1,
      //     styles: PosStyles(codeTable: PosCodeTable.iran2));
      // ticket.textEncoded(encTxt1,
      //     styles: PosStyles(codeTable: PosCodeTable.israel));
      // ticket.textEncoded(encTxt1,
      //     styles: PosStyles(codeTable: PosCodeTable.katakana1));
      // ticket.textEncoded(encTxt1,
      //     styles: PosStyles(codeTable: PosCodeTable.katakana2));
      // ticket.textEncoded(encTxt1,
      //     styles: PosStyles(codeTable: PosCodeTable.latvian));
      // ticket.textEncoded(encTxt1,
      //     styles: PosStyles(codeTable: PosCodeTable.pc1001_1));
      // ticket.textEncoded(encTxt1,
      //     styles: PosStyles(codeTable: PosCodeTable.pc1001_2));
      // ticket.textEncoded(encTxt1,
      //     styles: PosStyles(codeTable: PosCodeTable.pc3011));
      // ticket.textEncoded(encTxt1,
      //     styles: PosStyles(codeTable: PosCodeTable.pc3012));
      // ticket.textEncoded(encTxt1,
      //     styles: PosStyles(codeTable: PosCodeTable.pc3840));
      // ticket.textEncoded(encTxt1,
      //     styles: PosStyles(codeTable: PosCodeTable.pc3843));
      // ticket.textEncoded(encTxt1,
      //     styles: PosStyles(codeTable: PosCodeTable.pc3846));
      // ticket.textEncoded(encTxt1,
      //     styles: PosStyles(codeTable: PosCodeTable.pc437_1));
      // ticket.textEncoded(encTxt1,
      //     styles: PosStyles(codeTable: PosCodeTable.pc720));
      // ticket.textEncoded(encTxt1,
      //     styles: PosStyles(codeTable: PosCodeTable.pc737));
      // ticket.text(decoded,containsChinese: true);
      // ticket.text(encTxt1.toString());
      // var _bytes = utf8.encode(ticketdata[i]['title']);
      //-----------------------------------------------------------
      print(ticketdata[i]['title']);
      String title = ticketdata[i]['title'];
      ticket.text('${title}',
          containsChinese: true,
          styles: PosStyles(
              align: PosAlign.center, codeTable: PosCodeTable.westEur));
      for (var j = 0; j < ticketdata[i]['ChoiceIDList'].length; j++) {
        ticket.text(ticketdata[i]['ChoiceIDList'][j]['ChoiceName'],
            containsChinese: true);
      }
      print(ticketdata[i]['Remark']);
      if (ticketdata[i]['Remark'] == '') {
        ticketdata[i]['Remark'] = '無';
      }
      ticket.row([
        PosColumn(text: '備註 ', containsChinese: true, width: 1),
        PosColumn(
            text: '：${ticketdata[i]['Remark']}',
            containsChinese: true,
            width: 11,
            styles: PosStyles(align: PosAlign.left)),
      ]);
      ticket.row([
        PosColumn(
            text: '小計：     ${ticketdata[i]['price']} x ${ticketdata[i]['qty']}',
            width: 6,
            containsChinese: true),
        PosColumn(text: 'TW ${ticketdata[i]['total_price']}', width: 6),
      ]);
      ticket.text('--------------------------------');
      ticket.feed(1);
    }

    ticket.feed(1);
    ticket.row([
      PosColumn(text: '總額', containsChinese: true, width: 6),
      PosColumn(text: 'TW ${ticketdata[0]['allprice']}', width: 6),
    ]);
    ticket.feed(2);
    ticket.text('謝謝光臨',
        containsChinese: true, styles: PosStyles(align: PosAlign.center));
    ticket.cut();

    return ticket;
  }

  Future<String> ifprintOpen() async {
    String isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      return "Connected";
    } else {
      //Hadnle Not Connected Senario
      return "notConnected";
    }
  }

  Future<void> printGraphics(data) async {
    String isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      Ticket ticket = await getGraphicsTicket(data);
      final result = await BluetoothThermalPrinter.writeBytes(ticket.bytes);
      print("Print $result");
      // return "Ok";
    } else {
      //Hadnle Not Connected Senario
      // return "notConnected";
    }
  }

  //品項變色（移除）
  _remove(orderid, index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final myStringList = prefs.getStringList('savedrawList') ?? [];
    if (myStringList.contains(orderid + index)) {
      myStringList.remove(orderid + index);
    }
    print('remove $orderid + index ');
    await prefs.setStringList('savedrawList', myStringList);
    if (myStringList != null) {
      setState(() {
        _drawlist = myStringList;
      });
    }
    print(_drawlist);
    return myStringList;
  }

  _getdraw() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final myStringList = prefs.getStringList('savedrawList');
    print(myStringList);
    if (myStringList != null) {
      setState(() {
        _drawlist = myStringList;
      });
    }
    return myStringList;
  }

  // Future<List> _getOrderdraw() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final myStringList = prefs.getStringList('saveorderdrawList');
  //   print(myStringList);
  //   if (myStringList != null) {
  //     setState(() {
  //       _orderdrawlist = myStringList;
  //     });
  //   }
  //   return myStringList;
  // }

  _setOrderdraw(list) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList("saveorderdrawList", list);
  }
  //-------------------------------------------出單機-------------------------------------------
  // Future<void> _startPrint(PrinterBluetooth printer) async {
  //   _printerManager.selectPrinter(printer);
  //   final result =
  //       await _printerManager.printTicket(await _ticket(PaperSize.mm80));
  //   showDialog(
  //     context: context,
  //     builder: (_) => AlertDialog(
  //       content: Text(result.msg),
  //     ),
  //   );
  // }

  //-------------------------------------------出單機-------------------------------------------

  Widget build(BuildContext context) {
    print("BPageStatebuild");
    // print(order_data["title"]);
    data = [];
    data.add({
      "DiningStyle": order_data["dining"],
      "Phone": order_data["Phone"],
      "Table": order_data["Table"],
      "MealID": order_data["orderTempID"],
      "allprice": order_data["price"]
    });
    // });

    Widget child;
    if (order_data['title'] == "(已結帳訂單)") {
      child = FlatButton(
        height: 60,
        minWidth: 180,
        color: Theme.of(context).primaryColor,
        textColor: Colors.white,
        child: Text('補單', style: new TextStyle(fontSize: 28)),
        onPressed: () {
          getmac().then((value) {
            if (value == null) {
              return Alert(
                context: context,
                type: AlertType.error,
                title: "您尚未連接上出單機",
                desc: "請回到主頁點選設備選擇",
                buttons: [
                  DialogButton(
                    height: 80,
                    width: 120,
                    child: Text(
                      "確認",
                      style: TextStyle(color: Colors.white, fontSize: 40),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              ).show();
            } else {
              ifprintOpen().then((value) {
                if (value == "Connected") {
                  printGraphics(data);
                } else if (value == "notConnected") {
                  return Alert(
                    context: context,
                    type: AlertType.error,
                    title: "您尚未連接上出單機",
                    desc: "請確認有將出單機開啟",
                    buttons: [
                      DialogButton(
                        height: 80,
                        width: 120,
                        child: Text(
                          "確認",
                          style: TextStyle(color: Colors.white, fontSize: 40),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ).show();
                }
              });
            }
          });
        },
      );
    } else {
      child = FlatButton(
        height: 60,
        minWidth: 180,
        color: Theme.of(context).primaryColor,
        textColor: Colors.white,
        child: Text('結帳', style: new TextStyle(fontSize: 28)),
        onPressed: () {
          getmac().then((value) {
            if (value == null) {
              return Alert(
                context: context,
                type: AlertType.error,
                title: "您尚未連接上出單機",
                desc: "請回到主頁點選設備選擇",
                buttons: [
                  DialogButton(
                    height: 80,
                    width: 120,
                    child: Text(
                      "確認",
                      style: TextStyle(color: Colors.white, fontSize: 40),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              ).show();
            } else {
              Alert(
                context: context,
                type: AlertType.info,
                title: "確定要結帳嗎",
                desc: "點選確認即結帳完成並開始出單",
                buttons: [
                  DialogButton(
                    height: 80,
                    width: 120,
                    child: Text(
                      "確認",
                      style: TextStyle(color: Colors.white, fontSize: 40),
                    ),
                    onPressed: () {
                      ifprintOpen().then((value) {
                        if (value == "Connected") {
                          orderApply(order_data["OrderID"], order_data['price'],
                                  order_data['orderTempID'])
                              .then((value) {
                            if (json.decode(value)["Status"] == "Success") {
                              // printGraphics(data);
                              Navigator.of(context).pushNamed('/CloudPos');

                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (_) => CloudPos()));
                            } else {
                              return Alert(
                                context: context,
                                type: AlertType.error,
                                title: "結帳失敗",
                                desc: json.decode(value)["msg"],
                                buttons: [
                                  DialogButton(
                                    height: 80,
                                    width: 120,
                                    child: Text(
                                      "確認",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 40),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  )
                                ],
                              ).show();
                            }
                          });
                        } else if (value == "notConnected") {
                          return Alert(
                            context: context,
                            type: AlertType.error,
                            title: "您尚未連接上出單機",
                            desc: "請確認有將出單機開啟",
                            buttons: [
                              DialogButton(
                                height: 80,
                                width: 120,
                                child: Text(
                                  "確認",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 40),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              )
                            ],
                          ).show();
                        }
                      });
                    },
                  )
                ],
              ).show();
            }
          });
        },
      );
    }
    if (order_data["dining"] == "Intermal") {
      for (var index = 0;
          index < json.decode(order_data["OrderTemp"]).length;
          index++) {
        var totalPrice = 0;
        try {
          totalPrice = int.parse(
                  json.decode(order_data["OrderTemp"])[index]["ItemPrice"]) *
              int.parse(json.decode(order_data["OrderTemp"])[index]["Count"]);
        } catch (e) {
          totalPrice = int.parse(
                  json.decode(order_data["OrderTemp"])[index]["ItemPrice"]) *
              json.decode(order_data["OrderTemp"])[index]["Count"];
        }
        data.add({
          'title': json.decode(order_data["OrderTemp"])[index]["FoodName"],
          'price': int.parse(
              json.decode(order_data["OrderTemp"])[index]["ItemPrice"]),
          'qty':
              int.parse(json.decode(order_data["OrderTemp"])[index]["Count"]),
          'total_price': totalPrice,
          'ChoiceIDList': json.decode(order_data["OrderTemp"])[index]
              ["ChoiceIDList"],
          'Remark': json.decode(order_data["OrderTemp"])[index]["Remark"]
        });
      }
      return Scaffold(
          appBar: AppBar(
            title: Text('畫單頁面'),
          ),
          body: Column(
            children: [
              Row(
                children: [
                  Column(
                    children: [
                      Text("編號：" + order_data['orderTempID'],
                          style: new TextStyle(fontSize: 20)),
                      Text(order_data["diningStyle"],
                          style: new TextStyle(fontSize: 22)),
                    ],
                  ),
                  Spacer(),
                  Column(
                    // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("訂單時間：" + order_data['DataTime'],
                          style: new TextStyle(fontSize: 16)),
                      // Text("桌單號碼：" + order_data["DiningStyleID"]),
                    ],
                  )
                ],
              ),
              Expanded(
                  child: Container(
                child: ListView.builder(
                    itemCount: order_data["OrderTemp"] == null
                        ? 0
                        : json.decode(order_data["OrderTemp"]).length,
                    itemBuilder: (BuildContext context, int index) {
                      print(index);
                      choiceCard = [];
                      if (json
                              .decode(order_data["OrderTemp"])[index]
                                  ["ChoiceIDList"]
                              .length !=
                          0) {
                        for (var k = 0;
                            k <
                                json
                                    .decode(order_data["OrderTemp"])[index]
                                        ["ChoiceIDList"]
                                    .length;
                            k++) {
                          choiceCard.add(
                            Text(
                                "細項名稱：" +
                                    (json.decode(order_data["OrderTemp"])[index]
                                        ["ChoiceIDList"][k])["ChoiceName"],
                                style: new TextStyle(fontSize: 16)),
                          );
                        }
                        var totalPrice = 0;
                        try {
                          totalPrice = int.parse(
                                  json.decode(order_data["OrderTemp"])[index]
                                      ["ItemPrice"]) *
                              int.parse(
                                  json.decode(order_data["OrderTemp"])[index]
                                      ["Count"]);
                        } catch (e) {
                          totalPrice = int.parse(
                                  json.decode(order_data["OrderTemp"])[index]
                                      ["ItemPrice"]) *
                              json.decode(order_data["OrderTemp"])[index]
                                  ["Count"];
                        }
                      }
                      // print('here');
                      // print(_drawlist);
                      return Center(
                          child: Column(children: [
                        GestureDetector(
                            onTap: () {},
                            child: Card(
                                color: _selectedItems.contains(index) ||
                                        _drawlist.contains(
                                            order_data["OrderID"] +
                                                index.toString())
                                    // ? Colors.black87.withOpacity(0.5)
                                    ? Colors.orangeAccent.withOpacity(0.3)
                                    // ? Colors.red.withOpacity(0.3)
                                    : Colors.white,
                                child: new InkWell(
                                    onTap: () {
                                      List drawlist;
                                      this
                                          ._savedraw(order_data["OrderID"],
                                              index.toString())
                                          .then((value) {
                                        drawlist = value;
                                        setState(() {
                                          _drawlist = drawlist;
                                        });
                                      });
                                      // setState(() {
                                      if (!_selectedItems.contains(index)) {
                                        setState(() {
                                          _selectedItems.add(index);
                                          // _drawlist = drawlist;
                                        });
                                      }
                                      //訂單變色===============
                                      if (_selectedItems.length ==
                                          json
                                              .decode(order_data["OrderTemp"])
                                              .length) {
                                        // order_drawlist[order_data["OrderID"]] = '1'; //全畫完
                                        // order_drawlist.add(order_data["OrderID"]+'_1'); //全畫完
                                        this._saveOrderdraw(
                                            order_data["OrderID"],
                                            order_data["OrderID"] + '#1');
                                      } else if (_selectedItems.length <
                                              json
                                                  .decode(
                                                      order_data["OrderTemp"])
                                                  .length &&
                                          _selectedItems.length != 0) {
                                        // order_drawlist[order_data["OrderID"]] = '0'; //有畫但沒畫完
                                        // order_drawlist.add(order_data["OrderID"] + '_0'); //有畫但沒畫完
                                        this._saveOrderdraw(
                                            order_data["OrderID"],
                                            order_data["OrderID"] + '#0');
                                      } else if (_selectedItems.length == 0) {
                                        print("等於零");
                                        this._removeOrderdraw(
                                            order_data["OrderID"]);
                                      }
                                      //訂單變色===============
                                      // print(_selectedItems);
                                      // print(_drawlist);
                                    },
                                    onLongPress: () {
                                      // print("_selectedItems.length");
                                      // print(_selectedItems.length);
                                      this._remove(order_data["OrderID"],
                                          index.toString());
                                      if (_selectedItems.contains(index)) {
                                        setState(() {
                                          _selectedItems.removeWhere(
                                              (val) => val == index);
                                        });
                                      }
                                      //訂單變色===============
                                      if (_selectedItems.length ==
                                          json
                                              .decode(order_data["OrderTemp"])
                                              .length) {
                                        // order_drawlist[order_data["OrderID"]] = '1'; //全畫完
                                        // order_drawlist.add(order_data["OrderID"]+'_1'); //全畫完
                                        this._saveOrderdraw(
                                            order_data["OrderID"],
                                            order_data["OrderID"] + '#1');
                                      } else if (_selectedItems.length <
                                              json
                                                  .decode(
                                                      order_data["OrderTemp"])
                                                  .length &&
                                          _selectedItems.length != 0) {
                                        // order_drawlist[order_data["OrderID"]] = '0'; //有畫但沒畫完
                                        // order_drawlist.add(order_data["OrderID"] + '_0'); //有畫但沒畫完
                                        this._saveOrderdraw(
                                            order_data["OrderID"],
                                            order_data["OrderID"] + '#0');
                                      } else if (_selectedItems.length == 0) {
                                        print("等於零");
                                        this._removeOrderdraw(
                                            order_data["OrderID"]);
                                      }
                                      //訂單變色===============
                                    },
                                    child: Container(
                                        constraints: BoxConstraints(
                                          minHeight: 80,
                                        ),
                                        padding: EdgeInsets.all(10.0),
                                        // height: 80,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                              (index + 1).toString(),
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            Column(
                                              children: [
                                                Text(
                                                    "品名：" +
                                                        json
                                                                .decode(order_data[
                                                                    "OrderTemp"])[
                                                            index]["FoodName"],
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.red,
                                                        decoration: (_selectedItems
                                                                    .contains(
                                                                        index)) ||
                                                                _drawlist.contains(
                                                                    order_data[
                                                                            "OrderID"] +
                                                                        index
                                                                            .toString())
                                                            ? TextDecoration
                                                                .lineThrough
                                                            : TextDecoration
                                                                .none)),
                                                Text(
                                                  "單價 " +
                                                      json.decode(order_data[
                                                              "OrderTemp"])[
                                                          index]["ItemPrice"] +
                                                      " " +
                                                      "X" +
                                                      " 數量：" +
                                                      json.decode(order_data[
                                                              "OrderTemp"])[
                                                          index]["Count"],
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      decoration: (_selectedItems
                                                                  .contains(
                                                                      index)) ||
                                                              _drawlist.contains(
                                                                  order_data[
                                                                          "OrderID"] +
                                                                      index
                                                                          .toString())
                                                          ? TextDecoration
                                                              .lineThrough
                                                          : TextDecoration
                                                              .none),
                                                ),
                                              ],
                                            ),
                                            Text("   "),
                                            Column(
                                              children: [
                                                Text(
                                                    "備註：" +
                                                        json.decode(order_data[
                                                                "OrderTemp"])[index]
                                                            ["Remark"],
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: Colors
                                                            .indigoAccent,
                                                        decoration: (_selectedItems
                                                                    .contains(
                                                                        index)) ||
                                                                _drawlist.contains(
                                                                    order_data["OrderID"] +
                                                                        index
                                                                            .toString())
                                                            ? TextDecoration
                                                                .lineThrough
                                                            : TextDecoration
                                                                .none)),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                // Text("單品項價錢" +
                                                //     json.decode(order_data["OrderTemp"])[index]
                                                //         ["FoodPrice"]),
                                                ...choiceCard,
                                                // Text("總額：" + order_data['price']),
                                              ],
                                            ),
                                          ],
                                        )))))
                      ]));
                    }),
              )),
              Container(
                height: 75,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FlatButton(
                        height: 60,
                        minWidth: 180,
                        color: Colors.redAccent,
                        textColor: Colors.white,
                        child: Text('取消訂單', style: new TextStyle(fontSize: 28)),
                        onPressed: () {
                          Alert(
                            context: context,
                            type: AlertType.error,
                            title: "確定要取消訂單嗎",
                            desc: "取消訂單後不會出現在歷史資料",
                            buttons: [
                              DialogButton(
                                height: 80,
                                width: 120,
                                child: Text(
                                  "確認",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 40),
                                ),
                                onPressed: () {
                                  cancelApply(order_data["OrderID"]).then(
                                      (value) => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => CloudPos())));
                                },
                              )
                            ],
                          ).show();
                        },
                      ),
                      child
                    ]),
              ),
              Text(
                "總額" + order_data["price"],
                style: TextStyle(fontSize: 48),
              )
            ],
          ));
    } else if (order_data["dining"] == "TakeOut") {
      for (var index = 0;
          index < json.decode(order_data["OrderTemp"]).length;
          index++) {
        // var totalPrice = 0;
        // try {
        final totalPrice = int.parse(
                json.decode(order_data["OrderTemp"])[index]["ItemPrice"]) *
            int.parse(json.decode(order_data["OrderTemp"])[index]["Count"]);
        // } catch (e) {
        //   totalPrice = int.parse(
        //           json.decode(order_data["OrderTemp"])[index]["ItemPrice"]) *
        //       json.decode(order_data["OrderTemp"])[index]["Count"];
        // }
        data.add({
          'title': json.decode(order_data["OrderTemp"])[index]["FoodName"],
          'price': int.parse(
              json.decode(order_data["OrderTemp"])[index]["ItemPrice"]),
          'qty':
              int.parse(json.decode(order_data["OrderTemp"])[index]["Count"]),
          'total_price': totalPrice,
          'ChoiceIDList': json.decode(order_data["OrderTemp"])[index]
              ["ChoiceIDList"],
          'Remark': json.decode(order_data["OrderTemp"])[index]["Remark"]
        });
      }
      return Scaffold(
          appBar: AppBar(
            title: Text('畫單頁面'),
          ),
          body: Column(
            children: [
              Row(
                children: [
                  Text("   "),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("編號：" + order_data['orderTempID'],
                          style: new TextStyle(fontSize: 20)),
                      Text(order_data["diningStyle"],
                          style: new TextStyle(fontSize: 22)),
                    ],
                  ),
                  Spacer(),
                  Column(
                    // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("訂單時間：" + order_data['DataTime'],
                          style: new TextStyle(fontSize: 17)),
                      // Text("桌單號碼：" + order_data["DiningStyleID"]),
                    ],
                  )
                ],
              ),
              Expanded(
                  child: Container(
                child: ListView.builder(
                    itemCount: order_data["OrderTemp"] == null
                        ? 0
                        : json.decode(order_data["OrderTemp"]).length,
                    itemBuilder: (BuildContext context, int index) {
                      print(index);
                      choiceCard = [];
                      if (json
                              .decode(order_data["OrderTemp"])[index]
                                  ["ChoiceIDList"]
                              .length !=
                          0) {
                        for (var k = 0;
                            k <
                                json
                                    .decode(order_data["OrderTemp"])[index]
                                        ["ChoiceIDList"]
                                    .length;
                            k++) {
                          choiceCard.add(
                            Text(
                                "細項名稱：" +
                                    (json.decode(order_data["OrderTemp"])[index]
                                        ["ChoiceIDList"][k])["ChoiceName"],
                                style: new TextStyle(fontSize: 16)),
                          );
                        }
                      }

                      return Center(
                          child: Column(children: [
                        Card(
                            color: (_selectedItems.contains(index)) ||
                                    _drawlist.contains(order_data["OrderID"] +
                                        index.toString())
                                // ? Colors.blue.withOpacity(0.5)
                                ? Colors.orangeAccent.withOpacity(0.3)
                                // ? Colors.red.withOpacity(0.3)
                                : Colors.white,
                            child: new InkWell(
                                onTap: () {
                                  List drawlist; //餐點的變色
                                  // List order_drawlist; //訂單的變色
                                  this
                                      ._savedraw(order_data["OrderID"],
                                          index.toString())
                                      .then((value) {
                                    drawlist = value;
                                    setState(() {
                                      _drawlist = drawlist;
                                    });
                                  });
                                  // setState(() {
                                  if (!_selectedItems.contains(index)) {
                                    setState(() {
                                      _selectedItems.add(index);
                                    });
                                  }
                                  // });
                                  if (_selectedItems.length ==
                                      json
                                          .decode(order_data["OrderTemp"])
                                          .length) {
                                    // order_drawlist[order_data["OrderID"]] = '1'; //全畫完
                                    // order_drawlist.add(order_data["OrderID"]+'_1'); //全畫完
                                    this._saveOrderdraw(order_data["OrderID"],
                                        order_data["OrderID"] + '#1');
                                  } else if (_selectedItems.length <
                                      json
                                          .decode(order_data["OrderTemp"])
                                          .length) {
                                    // order_drawlist[order_data["OrderID"]] = '0'; //有畫但沒畫完
                                    // order_drawlist.add(order_data["OrderID"] + '_0'); //有畫但沒畫完
                                    this._saveOrderdraw(order_data["OrderID"],
                                        order_data["OrderID"] + '#0');
                                  }
                                  //把狀態存到sharedpreferences
                                  // print('index');
                                  // print(index);
                                  // print('_selectedItems');
                                  // print(_selectedItems);
                                  // print('_drawlist');
                                  // print(_drawlist);
                                },
                                onLongPress: () {
                                  this._remove(
                                      order_data["OrderID"], index.toString());
                                  if (_selectedItems.contains(index)) {
                                    setState(() {
                                      _selectedItems
                                          .removeWhere((val) => val == index);
                                    });
                                  }
                                  //訂單變色===============
                                  if (_selectedItems.length ==
                                      json
                                          .decode(order_data["OrderTemp"])
                                          .length) {
                                    // order_drawlist[order_data["OrderID"]] = '1'; //全畫完
                                    // order_drawlist.add(order_data["OrderID"]+'_1'); //全畫完
                                    this._saveOrderdraw(order_data["OrderID"],
                                        order_data["OrderID"] + '#1');
                                  } else if (_selectedItems.length <
                                          json
                                              .decode(order_data["OrderTemp"])
                                              .length &&
                                      _selectedItems.length != 0) {
                                    // order_drawlist[order_data["OrderID"]] = '0'; //有畫但沒畫完
                                    // order_drawlist.add(order_data["OrderID"] + '_0'); //有畫但沒畫完
                                    this._saveOrderdraw(order_data["OrderID"],
                                        order_data["OrderID"] + '#0');
                                  } else if (_selectedItems.length == 0) {
                                    print("等於零");
                                    this._removeOrderdraw(
                                        order_data["OrderID"]);
                                  }
                                  //訂單變色===============
                                },
                                child: Container(
                                    constraints: BoxConstraints(
                                      minHeight: 80,
                                    ),
                                    padding: EdgeInsets.all(10.0),
                                    // height: 80,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          (index + 1).toString(),
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        Row(
                                          children: [
                                            Column(
                                              children: [
                                                Text(
                                                    "品名：" +
                                                        json
                                                                .decode(order_data[
                                                                    "OrderTemp"])[
                                                            index]["FoodName"],
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.red,
                                                        decoration: (_selectedItems
                                                                    .contains(
                                                                        index)) ||
                                                                _drawlist.contains(
                                                                    order_data[
                                                                            "OrderID"] +
                                                                        index
                                                                            .toString())
                                                            ? TextDecoration
                                                                .lineThrough
                                                            : TextDecoration
                                                                .none)),
                                                Text(
                                                  "單價 " +
                                                      json.decode(order_data[
                                                              "OrderTemp"])[
                                                          index]["ItemPrice"] +
                                                      " " +
                                                      "X" +
                                                      " 數量：" +
                                                      json.decode(order_data[
                                                              "OrderTemp"])[
                                                          index]["Count"],
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      decoration: (_selectedItems
                                                                  .contains(
                                                                      index)) ||
                                                              _drawlist.contains(
                                                                  order_data[
                                                                          "OrderID"] +
                                                                      index
                                                                          .toString())
                                                          ? TextDecoration
                                                              .lineThrough
                                                          : TextDecoration
                                                              .none),
                                                ),
                                              ],
                                            ),
                                            Text("   "),
                                            Column(
                                              children: [
                                                Text(
                                                    "備註：" +
                                                        json.decode(order_data[
                                                                "OrderTemp"])[index]
                                                            ["Remark"],
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: Colors
                                                            .indigoAccent,
                                                        decoration: (_selectedItems
                                                                    .contains(
                                                                        index)) ||
                                                                _drawlist.contains(
                                                                    order_data["OrderID"] +
                                                                        index
                                                                            .toString())
                                                            ? TextDecoration
                                                                .lineThrough
                                                            : TextDecoration
                                                                .none)),
                                                Column(
                                                  children: [
                                                    // Text("單品項價錢" +
                                                    //     json.decode(order_data["OrderTemp"])[index]
                                                    //         ["FoodPrice"]),
                                                    ...choiceCard,
                                                    // Text("總額：" + order_data['price']),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      ],
                                    ))))
                      ]));
                    }),
              )),
              Container(
                height: 75,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FlatButton(
                        height: 60,
                        minWidth: 180,
                        color: Colors.redAccent,
                        textColor: Colors.white,
                        child: Text('取消訂單', style: new TextStyle(fontSize: 28)),
                        onPressed: () {
                          Alert(
                            context: context,
                            type: AlertType.error,
                            title: "確定要取消訂單嗎",
                            desc: "取消訂單後不會出現在歷史資料",
                            buttons: [
                              DialogButton(
                                height: 80,
                                width: 120,
                                child: Text(
                                  "確認",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 40),
                                ),
                                onPressed: () {
                                  cancelApply(order_data["OrderID"]).then(
                                      (value) => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => CloudPos())));
                                },
                              )
                            ],
                          ).show();
                        },
                      ),
                      child
                    ]),
              ),
              Text(
                "總額" + order_data["price"],
                style: TextStyle(fontSize: 48),
              )
            ],
          ));
    }
  }

  @override
  void initState() {
    _getdraw(); //保存畫單資料
    // _getOrderdraw();
    if (widget.order_data != null) {
      order_data = widget.order_data;
      //把最外層的值放進來
    }
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }
}
