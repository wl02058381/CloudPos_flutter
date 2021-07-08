import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

timer(title) {
//設定 1 秒回撥一次
  Timer _timer;
  const period = const Duration(seconds: 5);
  _timer = Timer(period, () {
    //更新介面
    String clouddata;
    if (title == '(未結帳訂單)') {
      getSWData('0', '0').then((value) {
        clouddata = value;
        return clouddata;
      });
    } else if (title == "(已結帳訂單)") {
      getSWData('1', '0').then((value) {
        clouddata = value;
        return clouddata;
      });
    } else if (title == "(歷史紀錄)") {
      getSWData('-1', '0').then((value) {
        clouddata = value;
        return clouddata;
      });
    }
  });
}


Future<String> getSWData(paid, del) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storeID = prefs.getString('StoreID');
    var url = "https://iordering.tw:8011/GetTempOrder";
    var body = json.encode({"StoreID": storeID, "Paid": paid, "Del": del});
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    final response = await http.post(url, body: body, headers: headers);
    // setState(() {
    //   clouddata = response.body;
    // });
    return response.body;
  } catch (e) {
    return "error";
  }
}
