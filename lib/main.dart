import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cloudpos_online/print.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloudpos_online/login.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
void main() {
  // runApp(MaterialApp(home: HomePage(), debugShowCheckedModeBanner: false));
  runApp(MaterialApp(home: LoginPage(), debugShowCheckedModeBanner: false));
}

class FoodInfo {
  final String orderTempID;
  final String price;
  final String diningStyle;
  final String mealDate;
  // final String picture;

  FoodInfo(this.orderTempID, this.price, this.diningStyle, this.mealDate);
}

class HomePage extends StatelessWidget {
  loginclean() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('savedrawList', []);
  }

  Future<String> getstoreid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storeID = prefs.getString('StoreID');
    return storeID;
  }

  String data;
  HomePage({this.data});  //StoreID
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Container(
          child: Center(
        child: SizedBox(
            width: 200,
            height: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("哈囉簡餐店", style: TextStyle(fontSize: 32.0)),
                Text("店家系統", style: TextStyle(fontSize: 24.0)),
                ButtonTheme(
                    minWidth: 200.0,
                    height: 70.0,
                    buttonColor: Colors.white70,
                    child: RaisedButton(
                      child: Text("出單管理", style: TextStyle(fontSize: 22.0)),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CloudPos()));
                      },
                    )),
                ButtonTheme(
                    minWidth: 200.0,
                    height: 70.0,
                    buttonColor: Colors.white70,
                    child: RaisedButton(
                      child: Text("後台管理", style: TextStyle(fontSize: 22.0)),
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
                                      // url:'data:image/octet-stream;base64,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hjlNx6zq2YrrjOnYhOAN+jfacLKZU37MfGU3gb25EkAGXYpb7L8AIg3SongN/qcFEAFk8KW4xREIIAJIi+I1+J8WQBoACBIDxrlixIiZMBSxyjpyTFrL999/X6677rpy5513li233HLaMJ944ony5ptvlttuu61ssskmLgteeeWV8vzzz5dbbrmlPPnkk+Wtt96q3vn333/LGWecUe69996y2WablWuuuabccccdZeutt2bYOUnbRABmVg1PeYk5vYjaYoI9TF/TTroAgtltJ+Tuu+++8sknn3QR2AJiAv/OO+9UAj71MWB/9dVX1a8eeuihYt95//33q/8+99xzFWD++eefsvvuu5fXX3+9ev+oo44q7777bnVS0P5/p512YmSgCCA+uwQQQpSiGuTvv/8uRx55ZNl0003LxRdfPNmCaZKTTz653HzzzS5Afvnll7LrrrtW7/z+++8VGEwz/PHHH8W+29ESP/74Y9lmm22qjN2ffvqpbLvtttW/jz766PLMM8/ATF5vqAKIAFJxoF8m1qefflr23Xffst9++02aV99++235888/ywcffFDuuusuFyBTp+q4444rw8PD5cEHHyw33XRTefrppyutY6Ax08y00xZbbFH22muv8uWXX5YddtiBgPv/SQUQAaRvAPntt9/K3nvvXU444YTKROrsRF977bXVym6mkO3yeyaWddTMrEsuuaQ88sgj5Ysvvqi0hgHEgHLVVVdVPogVlTCAbLXVVmW33XardsINkFZYYp999qGAIoD0AMjo6GhXqgkqw8hk2DJOuk3sqlWrQhOKSkZalQ6zz+sPSjVB5Sm991GHIqVHzWG+5557yocfflj5CZ3n+OOPL4cffni59dZbq/PT5lQ/8MAD5cwzz5zW1Lp16yqAmZAbwEzo7TEn9sUXX5xGe/nll5ftt9++2EU1Tz31VAWcQw89tAKg97DlW1HKESqpii4LWr58eVcJWa/06OLFi7uqrXjlQNHYmNKj6H1PDoeiB6baAkhbZk80hyjqV8yEYFv1TfDvvvvu8vjjj5cDDzxwEiDffPNNZQa9+uqrlcAY3f3331990swoA4Jpgs7z7LPPFvNFNtpoo5ma7fr7AQccUJl33sNEApnIUvb0Iuovs9DSjKq9kD4wJYD0ngLzCwxsF154YTnppJMqgJjWsDDvpZdeWswvee2116qP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',
                                      withLocalStorage: true,
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
                      child: Text("登出", style: TextStyle(fontSize: 22.0)),
                      onPressed: () {
                        loginclean();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()));
                      },
                    ))
              ],
            )),
      )),
    ));
  }
}

class CloudPos extends StatefulWidget {
  @override
  CloudPosState createState() => CloudPosState();
}

class CloudPosState extends State<CloudPos> {
  final String url = "https://cloudpos.54ucl.com:8011/GetTempOrder";
  String data;
  dynamic order_data = {};
  Future<String> getSWData(paid, del) async {
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
      data = response.body;
    });
    return "Success!";
  }

  String title = "(未結帳訂單)";

  @override
  Widget build(BuildContext context) {
    // this.getSWData('0', '0');
    var diningStyle = new List();
    var dining = new List();
    var cardcolor = new List();
    var btncolor = Colors.orange;
    try {
      for (var i = 0; i < json.decode(data)["Data"].length; i++) {
        dining.add(json.decode(data)["Data"][i]["DiningStyle"]);
        if (json.decode(data)["Data"][i]["DiningStyle"] == "TakeOut") {
          diningStyle.add("外帶-電話：" + json.decode(data)["Data"][i]["Phone"]);
          cardcolor.add(Colors.black12);
        } else {
          diningStyle.add("內用-桌號：" + json.decode(data)["Data"][i]["Table"]);
          cardcolor.add(Colors.black26);
        }
      }
      print(diningStyle);

      return Scaffold(
        appBar: AppBar(
            leading: IconButton(
              icon: Icon(
                Icons.wrap_text_sharp,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomePage()));
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
                        color: btncolor,
                        textColor: Colors.white,
                        child: Text('未結帳訂單'),
                        onPressed: () {
                          setState(() {
                            title = '(未結帳訂單)';
                            btncolor = Colors.red;
                          });
                          this.getSWData('0', '0');
                        },
                      ),
                      Text("   "),
                      // Spacer(),
                      FlatButton(
                        color: Colors.pink,
                        textColor: Colors.white,
                        child: Text('已結帳訂單'),
                        onPressed: () {
                          setState(() {
                            title = '(已結帳訂單)';
                          });
                          this.getSWData('1', '0');
                        },
                      ),
                      Text("   "),
                      // Spacer(),
                      FlatButton(
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        child: Text('歷史紀錄'),
                        onPressed: () {
                          setState(() {
                            title = '(歷史紀錄)';
                          });
                          this.getSWData('-1', '-1');
                        },
                      )
                    ],
                  )
                ],
              )),
          color: Colors.white,
        ),
        body: ListView.builder(
          itemCount: data == null ? 0 : json.decode(data)["Data"].length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Card(
                      child: new InkWell(
                          onTap: () {
                            print("Card按鈕");
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BPage(order_data: {
                                          "orderTempID": json
                                              .decode(data)["Data"][index]
                                                  ["MealID"]
                                              .toString(),
                                          "diningStyle": diningStyle[index],
                                          "price": json.decode(data)["Data"]
                                              [index]["TotalPrice"],
                                          "OrderTemp": json.decode(data)["Data"]
                                              [index]["OrderTemp"],
                                          "DataTime": json.decode(data)["Data"]
                                              [index]["DataTime"],
                                          "MealTime": json.decode(data)["Data"]
                                              [index]["MealTime"],
                                          "DiningStyleID":
                                              json.decode(data)["Data"][index]
                                                  ["DiningStyleID"],
                                          "dining": dining[index],
                                          "OrderID": json.decode(data)["Data"]
                                              [index]["OrderID"]
                                        })));
                          },
                          child: Container(
                              color: cardcolor[index],
                              padding: EdgeInsets.all(15.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text("編號:" +
                                      json
                                          .decode(data)["Data"][index]["MealID"]
                                          .toString()),
                                  Text(
                                      "價錢:" +
                                          json.decode(data)["Data"][index]
                                              ["TotalPrice"],
                                      style: TextStyle(
                                          fontSize: 18.0, color: Colors.red)),
                                  Column(
                                    children: [
                                      Text(diningStyle[index],
                                          style: TextStyle(fontSize: 17.2)),
                                      Text(
                                          "時間：" +
                                              json.decode(data)["Data"][index]
                                                  ["DataTime"],
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
    } catch (e) {
      return Scaffold(
        backgroundColor: Colors.blue[900],
        body: Center(
        child:SpinKitFadingCircle(
        size: 100.0,
        itemBuilder: (BuildContext context, int index) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: index.isEven ? Colors.red : Colors.green,
            ),
          );
        },
      )
      )
      );
    }
  }

  @override
  void initState() {
    this.getSWData('0', '0');
    super.initState();
    // if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
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
  final List<Map<String, dynamic>> data = [];
  var choiceCard = new List();
  // var cardColor = new List();
  // Color _cardColor1 = Colors.white;
  List<int> _selectedItems = List<int>();
  List<String> _drawlist = List<String>();
  // TextDecoration _lineThrough = TextDecoration.none;
  Color _cardColor2 = Colors.white;
  // TextDecoration _lineThrough2 = TextDecoration.none;
  String applydata;
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
    setState(() {
      applydata = response.body;
    });
    print("applydata Success!");
    return "applydata Success!";
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

  Widget build(BuildContext context) {
    print(order_data["dining"]);
    if (order_data["dining"] == "Intermal") {
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
                      Text("編號：" + order_data['orderTempID']),
                      Text(order_data["diningStyle"]),
                    ],
                  ),
                  Spacer(),
                  Column(
                    // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("訂單時間：" + order_data['DataTime']),
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
                            Text("細項名稱：" +
                                (json.decode(order_data["OrderTemp"])[index]
                                    ["ChoiceIDList"][k])["ChoiceName"]),
                          );
                        }
                        final totalPrice = int.parse(
                                json.decode(order_data["OrderTemp"])[index]
                                    ["ItemPrice"]) *
                            int.parse(
                                json.decode(order_data["OrderTemp"])[index]
                                    ["Count"]);
                        print(totalPrice);
                        data.add({
                          'title': json.decode(order_data["OrderTemp"])[index]
                              ["FoodName"],
                          'price': int.parse(
                              json.decode(order_data["OrderTemp"])[index]
                                  ["ItemPrice"]),
                          'qty': int.parse(json
                              .decode(order_data["OrderTemp"])[index]["Count"]),
                          'total_price': totalPrice,
                          'ChoiceIDList':
                              json.decode(order_data["OrderTemp"])[index]
                                  ["ChoiceIDList"]
                        });
                      }
                      // List<String> drawlist;
                      // _getdraw()
                      // .then((value) {
                      //   drawlist = value;
                      //   print(_drawlist);
                      //   print('---');
                      // });
                      print('here');
                      print(_drawlist);
                      return Center(
                          child: Column(children: [
                        GestureDetector(
                            onTap: () {},
                            child: Card(
                                color: _selectedItems.contains(index) ||
                                        _drawlist.contains(
                                            order_data["OrderID"] +
                                                index.toString())
                                    //         ||
                                    // drawlist.contains(
                                    //     order_data["OrderID"] +
                                    //         index.toString())
                                    // ? Colors.blue.withOpacity(0.5)
                                    ? Colors.red.withOpacity(0.3)
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
                                      setState(() {
                                        if (!_selectedItems.contains(index)) {
                                          setState(() {
                                            _selectedItems.add(index);
                                            // _drawlist = drawlist;
                                          });
                                        }
                                        // _cardColor1 = Colors.teal;
                                        // _lineThrough =
                                        //     TextDecoration.lineThrough;
                                      });
                                    },
                                    onLongPress: () {
                                      this._remove(order_data["OrderID"],
                                          index.toString());
                                      if (_selectedItems.contains(index)) {
                                        setState(() {
                                          _selectedItems.removeWhere(
                                              (val) => val == index);
                                        });
                                      }
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Column(
                                          children: [
                                            Text(
                                                "品名：" +
                                                    json.decode(order_data[
                                                            "OrderTemp"])[index]
                                                        ["FoodName"],
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
                                                        : TextDecoration.none)),
                                            Text(
                                              "單價 " +
                                                  json.decode(order_data[
                                                          "OrderTemp"])[index]
                                                      ["ItemPrice"] +
                                                  " " +
                                                  "X" +
                                                  " 數量：" +
                                                  json.decode(order_data[
                                                          "OrderTemp"])[index]
                                                      ["Count"],
                                              style: TextStyle(
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
                                                      : TextDecoration.none),
                                            ),
                                            Text(
                                                "備註：" +
                                                    json.decode(order_data[
                                                            "OrderTemp"])[index]
                                                        ["Remark"],
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.indigoAccent,
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
                                                        : TextDecoration.none)),
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
                                    ))))
                      ]));
                    }),
              )),
              Column(children: [
                FlatButton(
                  color: Colors.redAccent,
                  textColor: Colors.white,
                  child: Text('取消訂單'),
                  onPressed: () {
                    cancelApply(order_data["OrderID"]);
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => CloudPos()));
                  },
                ),
                FlatButton(
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  child: Text('結帳'),
                  onPressed: () {
                    orderApply(order_data["OrderID"], order_data['price'],
                        order_data['orderTempID']);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => Print(data)));
                  },
                ),
              ]),
              Text(
                "總額" + order_data["price"],
                style: TextStyle(fontSize: 48),
              )
            ],
          ));
    } else if (order_data["dining"] == "TakeOut") {
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
                      Text("編號：" + order_data['orderTempID']),
                      Text(order_data["diningStyle"]),
                    ],
                  ),
                  Spacer(),
                  Column(
                    // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("訂單時間：" + order_data['DataTime']),
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
                            Text("細項名稱：" +
                                (json.decode(order_data["OrderTemp"])[index]
                                    ["ChoiceIDList"][k])["ChoiceName"]),
                          );
                        }
                      }
                      final totalPrice = int.parse(
                              json.decode(order_data["OrderTemp"])[index]
                                  ["ItemPrice"]) *
                          int.parse(json.decode(order_data["OrderTemp"])[index]
                              ["Count"]);
                      print("QQ");
                      data.add({
                        'title': json.decode(order_data["OrderTemp"])[index]
                            ["FoodName"],
                        'price': int.parse(
                            json.decode(order_data["OrderTemp"])[index]
                                ["ItemPrice"]),
                        'qty': int.parse(json
                            .decode(order_data["OrderTemp"])[index]["Count"]),
                        'total_price': totalPrice,
                        'ChoiceIDList':
                            json.decode(order_data["OrderTemp"])[index]
                                ["ChoiceIDList"]
                      });
                      return Center(
                          child: Column(children: [
                        Card(
                            color: (_selectedItems.contains(index)) ||
                                    _drawlist.contains(order_data["OrderID"] +
                                        index.toString())
                                // ? Colors.blue.withOpacity(0.5)
                                ? Colors.red.withOpacity(0.3)
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
                                  setState(() {
                                    if (!_selectedItems.contains(index)) {
                                      setState(() {
                                        _selectedItems.add(index);
                                      });
                                    }
                                  });
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
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Column(
                                      children: [
                                        Text(
                                            "品名：" +
                                                json.decode(order_data[
                                                        "OrderTemp"])[index]
                                                    ["FoodName"],
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.redAccent,
                                                decoration: (_selectedItems
                                                            .contains(index)) ||
                                                        _drawlist.contains(
                                                            order_data[
                                                                    "OrderID"] +
                                                                index
                                                                    .toString())
                                                    ? TextDecoration.lineThrough
                                                    : TextDecoration.none)),
                                        Text(
                                          "單價 " +
                                              json.decode(
                                                      order_data["OrderTemp"])[
                                                  index]["ItemPrice"] +
                                              " " +
                                              "X" +
                                              " 數量：" +
                                              json.decode(
                                                      order_data["OrderTemp"])[
                                                  index]["Count"],
                                          style: TextStyle(
                                              decoration: (_selectedItems
                                                          .contains(index)) ||
                                                      _drawlist.contains(
                                                          order_data[
                                                                  "OrderID"] +
                                                              index.toString())
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none),
                                        ),
                                        Text(
                                            "備註：" +
                                                json.decode(order_data[
                                                        "OrderTemp"])[index]
                                                    ["Remark"],
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.indigoAccent,
                                                decoration: (_selectedItems
                                                            .contains(index)) ||
                                                        _drawlist.contains(
                                                            order_data[
                                                                    "OrderID"] +
                                                                index
                                                                    .toString())
                                                    ? TextDecoration.lineThrough
                                                    : TextDecoration.none)),
                                        ...choiceCard
                                      ],
                                    ),
                                  ],
                                )))
                      ]));
                    }),
              )),
              Column(children: [
                FlatButton(
                  color: Colors.redAccent,
                  textColor: Colors.white,
                  child: Text('取消訂單'),
                  onPressed: () {
                    cancelApply(order_data["OrderID"]);
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => CloudPos()));
                  },
                ),
                FlatButton(
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  child: Text('結帳'),
                  onPressed: () {
                    orderApply(order_data["OrderID"], order_data['price'],
                        order_data['orderTempID']);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => Print(data)));
                  },
                ),
              ]),
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
    _getdraw();
    if (widget.order_data != null) {
      order_data = widget.order_data;
      //把最外層的值放進來
    }
    super.initState();
  }
}
