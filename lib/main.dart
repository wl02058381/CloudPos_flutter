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
  String data;
  HomePage({this.data});
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
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WebView(
                                      initialUrl:
                                          'https://cloudpos.54ucl.com:3010',
                                      javascriptMode:
                                          JavascriptMode.unrestricted,
                                    )));

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

  @override
  Widget build(BuildContext context) {
    var diningStyle = new List();
    var dining = new List();
    var cardcolor = new List();
    var btncolor = Colors.orange;
    String title = "";

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
    {
      return Scaffold(
        appBar: AppBar(
            title: Text("CloudPos出單系統$title"), backgroundColor: Colors.black45),
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
                          this.getSWData('0', '-1');
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
                          this.getSWData('1', '-1');
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
    }
  }

  @override
  void initState() {
    this.getSWData('0', '-1');
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
  // TextDecoration _lineThrough = TextDecoration.none;
  Color _cardColor2 = Colors.white;
  // TextDecoration _lineThrough2 = TextDecoration.none;
  String applydata;
  Future<String> orderApply(orderid, totalprice, mealid) async {
    var url = "https://cloudpos.54ucl.com:8011/OrderApply";
    var body = json.encode({
      "Token": "str",
      "StoreID": "S_725d0fd9-4875-4762-8bc8-43404d2d5775",
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
                      return Center(
                          child: Column(children: [
                        GestureDetector(
                            onTap: () {},
                            child: Card(
                                color: (_selectedItems.contains(index))
                                    // ? Colors.blue.withOpacity(0.5)
                                    ? Colors.red.withOpacity(0.3)
                                    : Colors.white,
                                child: new InkWell(
                                    onTap: () {
                                      setState(() {
                                        if (!_selectedItems.contains(index)) {
                                          setState(() {
                                            _selectedItems.add(index);
                                          });
                                        }
                                        // _cardColor1 = Colors.teal;
                                        // _lineThrough =
                                        //     TextDecoration.lineThrough;
                                      });
                                    },
                                    onLongPress: () {
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
                                                            .contains(index))
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
                                                          .contains(index))
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
                                                            .contains(index))
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
              FlatButton(
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                child: Text('結帳'),
                onPressed: () {
                  orderApply(order_data["OrderID"], order_data['price'],
                      order_data['orderTempID']);
                  Navigator.push(
                      context, MaterialPageRoute(builder: (_) => Print(data)));
                },
              ),
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
                            color: (_selectedItems.contains(index))
                                // ? Colors.blue.withOpacity(0.5)
                                ? Colors.red.withOpacity(0.3)
                                : Colors.white,
                            child: new InkWell(
                                onTap: () {
                                  setState(() {
                                    if (!_selectedItems.contains(index)) {
                                      setState(() {
                                        _selectedItems.add(index);
                                      });
                                    }
                                  });
                                },
                                onLongPress: () {
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
                                                        .contains(index))
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
                                                      .contains(index))
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
                                                        .contains(index))
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
              FlatButton(
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                child: Text('結帳'),
                onPressed: () {
                  print(data);
                  orderApply(order_data["OrderID"], order_data['price'],
                      order_data['orderTempID']);
                  Navigator.push(
                      context, MaterialPageRoute(builder: (_) => Print(data)));
                },
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
    if (widget.order_data != null) {
      order_data = widget.order_data;
      //把最外層的值放進來
    }
  }
}
