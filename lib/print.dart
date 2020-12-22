import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';
import 'dart:io' show Platform;
import 'package:image/image.dart';
import 'dart:convert';
import 'package:cloudpos_online/main.dart';

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
          setState(() => _devicesMsg = 'Bluetooth Disconnect!');
        }
      });
    } else {
      initPrinter();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Print'),
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
          : ListView.builder(
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
    );
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
      if (_devices.isEmpty) setState(() => _devicesMsg = '結帳已完成\nNo Devices');
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

  Future<Ticket> _ticket(PaperSize paper) async {
    final ticket = Ticket(paper);
    int total = 0;
    // Image assets
    final ByteData data = await rootBundle.load('assets/store.png');
    final Uint8List bytes = data.buffer.asUint8List();
    final Image image = decodeImage(bytes);
    ticket.image(image);
    ticket.text(
      'CloudPos',
      styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2),
      linesAfter: 1,
    );
    print("here");
    print(widget.data);
    for (var i = 0; i < widget.data.length/3 ; i++) {
      // print("INININININNIN");
      total += widget.data[i]['total_price'];
      ticket.text(widget.data[i]['title'],
          containsChinese: true,
          styles: PosStyles(
              codeTable: PosCodeTable.westEur,
              height: PosTextSize.size1,
              width: PosTextSize.size1));
      ticket.text('-------');
      for (var j = 0; j < widget.data[i]['ChoiceIDList'].length; j++) {
        ticket.text(widget.data[i]['ChoiceIDList'][j]['ChoiceName'],
            containsChinese: true);
      }
      ticket.row([
        PosColumn(
            text: '${widget.data[i]['price']} x ${widget.data[i]['qty']}',
            width: 6,
            containsChinese: true),
        PosColumn(text: 'TW ${widget.data[i]['total_price']}', width: 6),
      ]);
    }

    ticket.feed(1);
    ticket.row([
      PosColumn(text: 'Total', width: 6, styles: PosStyles(bold: true)),
      PosColumn(text: 'TW $total', width: 6, styles: PosStyles(bold: true)),
    ]);
    ticket.feed(2);
    ticket.text('Thank You',
        styles: PosStyles(align: PosAlign.center, bold: true));
    ticket.cut();

    return ticket;
  }

  @override
  void dispose() {
    _printerManager.stopScan();
    super.dispose();
  }
}
