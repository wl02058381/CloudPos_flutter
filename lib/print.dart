import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';
import 'package:http/http.dart';
import 'dart:io' show Platform;
import 'package:image/image.dart';
import 'dart:convert';
import 'package:cloudpos_online/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/date_symbol_data_file.dart';
import 'package:intl/intl.dart';
import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';

class Print extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  Print(this.data);
  @override
  _PrintState createState() => _PrintState();
}

class _PrintState extends State<Print> {
  PrinterBluetoothManager _printerManager = PrinterBluetoothManager();
  List<PrinterBluetooth> _devices = [];
  String _devicesMsg;
  BluetoothManager bluetoothManager = BluetoothManager.instance;

  Future<String> getBT() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String bt = await prefs.getString('BT');
    return bt;
  }

  Future<String> isConnected() async {
    String isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      return isConnected;
    } else {
      return 'false';
    }
  }

  @override
  void initState() {
    if (Platform.isAndroid) {
      bluetoothManager.state.listen((val) {
        print('state = $val');
        if (!mounted) return;
        if (val == 12) {
          print('on');
          initPrinter();
        } else if (val == 10) {
          print('off');
          setState(() => _devicesMsg = '結帳已完成\n藍牙連線未開啟\n如要打印出單機請開啟藍芽!');
        }
      });
    } else {
      initPrinter();
    }
    // String bt;
    // getBT().then((value) {
    //   bt = value;
    //   // _startPrint(bt);
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // isConnected().then((value) {
    //   if (value == "false") {
        return Scaffold(
            appBar: AppBar(
              title: Text('print'),
            ),
            body: _devices.isEmpty
                ? Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                        Text(_devicesMsg ?? ''),
                        RaisedButton(
                            child: Text('回到首頁'),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CloudPos()));
                            })
                      ]))
                : SizedBox(
                    height: 300.0,
                    child: Column(
                      children: [
                        Expanded(
                          flex: 1,
                          child: ListView.builder(
                            itemCount: _devices.length,
                            itemBuilder: (c, i) {
                              return ListTile(
                                leading: Icon(Icons.print),
                                title: Text(_devices[i].name),
                                subtitle: Text(_devices[i].address),
                                onTap: () {
                                  _startPrint(_devices[i]);
                                },
                              );
                            },
                          ),
                        ),
                        RaisedButton(
                            child: Text('回到首頁'),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CloudPos()));
                            })
                      ],
                    )));
      // } else {
      //   printTicket();
      // }
    // });
  }

  Future<void> printTicket() async {
    String isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      Ticket ticket = await getTicket();
      final result = await BluetoothThermalPrinter.writeBytes(ticket.bytes);
      print("Print $result");
    } else {
      //Hadnle Not Connected Senario
    }
  }

  Future<Ticket> getTicket() async {
    _ticket(PaperSize.mm80);
  }

//  RaisedButton(child: Text('回到首頁'),onPressed: (){
//                     Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => CloudPos()));
//                   });
  void initPrinter() {
    _printerManager.startScan(Duration(seconds: 2));
    _printerManager.scanResults.listen((val) {
      if (!mounted) return;
      setState(() => _devices = val);
      if (_devices.isEmpty) setState(() => _devicesMsg = '結帳已完成\n附近沒有藍牙裝置');
    });
  }

  Future<void> _startPrint(PrinterBluetooth printer) async {
    _printerManager.selectPrinter(printer);
    final result =
        await _printerManager.printTicket(await _ticket(PaperSize.mm80));
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(result.msg),
      ),
    );
  }

  Future<String> getstorename() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storeName = prefs.getString('StoreName');
    // setState(() {
    //   storeName = storeName;
    // });
    return storeName;
  }

  Future<Ticket> _ticket(PaperSize paper) async {
    final ticket = Ticket(paper);
    int total = 0;
    // Image assets
    final ByteData data = await rootBundle.load('assets/store.png');
    final Uint8List bytes = data.buffer.asUint8List();
    final Image image = decodeImage(bytes);
    print("here");
    print(widget.data);
    String storeName;
    ticket.image(image);
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
    mealID = widget.data[0]['MealID'];
    if (widget.data[0]['DiningStyle'] == "TakeOut") {
      dintext = "外帶";
      phone = widget.data[0]['Phone'];
      ticket.row([
        PosColumn(text: '編號：     ${mealID}', width: 4, containsChinese: true),
        PosColumn(text: '用餐方式：${dintext}', width: 8, containsChinese: true),
      ]);
      ticket.row([
        PosColumn(text: '', width: 4, styles: PosStyles(bold: true)),
        PosColumn(text: '電話：     ${phone}', width: 8, containsChinese: true),
      ]);
      // ticket.row([
      //   PosColumn(text: '', width: 4, styles: PosStyles(bold: true)),
      //   PosColumn(text: '出單時間：     ${date}', width: 8, containsChinese: true),
      // ]);
      ticket.text('出單時間：             ${formattedDate}', containsChinese: true);
    } else if (widget.data[0]['DiningStyle'] == "Intermal") {
      dintext = "內用";
      table = widget.data[0]['Table'];
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
    for (var i = 1; i < widget.data.length; i++) {
      // print("INININININNIN");
      total += widget.data[i]['total_price'];
      ticket.text(
        widget.data[i]['title'],
        containsChinese: true,
      );
      // styles: PosStyles(
      //     codeTable: PosCodeTable.westEur,
      //     height: PosTextSize.size1,
      //     width: PosTextSize.size1));
      ticket.text('-------');
      for (var j = 0; j < widget.data[i]['ChoiceIDList'].length; j++) {
        ticket.text(widget.data[i]['ChoiceIDList'][j]['ChoiceName'],
            containsChinese: true);
      }
      print(widget.data[i]['Remark']);
      if (widget.data[i]['Remark'] == '') {
        widget.data[i]['Remark'] = '無';
      }
      ticket.row([
        PosColumn(text: '備註 ', containsChinese: true, width: 1),
        PosColumn(
            text: '：${widget.data[i]['Remark']}',
            containsChinese: true,
            width: 11,
            styles: PosStyles(align: PosAlign.left)),
      ]);
      ticket.row([
        PosColumn(
            text:
                '小計：     ${widget.data[i]['price']} x ${widget.data[i]['qty']}',
            width: 6,
            containsChinese: true),
        PosColumn(text: 'TW ${widget.data[i]['total_price']}', width: 6),
      ]);
      ticket.feed(1);
    }

    ticket.feed(1);
    ticket.row([
      PosColumn(text: '總額', containsChinese: true, width: 6),
      PosColumn(text: 'TW $total', width: 6),
    ]);
    ticket.feed(2);
    ticket.text('謝謝光臨',
        containsChinese: true, styles: PosStyles(align: PosAlign.center));
    ticket.cut();

    return ticket;
  }

  @override
  void dispose() {
    _printerManager.stopScan();
    super.dispose();
  }
}
