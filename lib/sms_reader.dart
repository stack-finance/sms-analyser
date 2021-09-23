import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sms_analyser/http_service.dart';
import 'package:sms_analyser/utils.dart';
import 'package:telephony/telephony.dart';
import 'package:flutter/services.dart';
import 'package:connectivity/connectivity.dart';

backgroundMessageHandler(SmsMessage message) async {
  print('backgroundMessageHandler $message');
  if (!Utils.bankFilter(message.address as String)) {
    return;
  }

  /// Read SMS data from the argument
  var payload = {
    "messageData": [
      {
        "smsDate": message.date,
        "senderId": message.address,
        "message": message.body
      }
    ]
  };

  /// Check the network connection availability
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile ||
      connectivityResult == ConnectivityResult.wifi) {
    HttpService.makePostReq('/users/smsReader', json.encode(payload));
  } else {
    ///   b. If no, store in a local DB array
  }
}

class SMSReader extends StatefulWidget {
  @override
  _SMSReaderState createState() => _SMSReaderState();
}

class _SMSReaderState extends State<SMSReader> {
  List<SmsMessage> _messages = [];
  late Telephony _instance;
  DateTime _today = DateTime.now();
  var _earlier;

  @override
  void initState() {
    super.initState();
    _earlier = _today.subtract(const Duration(days: 30));
    _instance = Telephony.instance;
    _attachListener();
    _init();
  }

  void _init() async {
    var isGranted = await _instance.requestSmsPermissions;
    if (isGranted == null || !isGranted) {
      print('Permission is required!');
      return;
    }

    var res = await _instance.getInboxSms();
    _messages = res
        .where((m) =>
            DateTime.fromMillisecondsSinceEpoch(m.date!).isAfter(_earlier))
        .toList();
    _messages = _messages.where((el) => Utils.bankFilter(el.address!)).toList();
    setState(() {});
  }

  void _attachListener() {
    _instance.listenIncomingSms(
      onNewMessage: (SmsMessage message) {
        // When App is in foreground
        print('What the heck is message $message');
      },
      onBackgroundMessage: backgroundMessageHandler,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              var msg = '';
              _messages.forEach((m) {
                msg += (m.body as String) + '\n \n';
              });
              Clipboard.setData(ClipboardData(text: msg));
            },
            icon: Icon(Icons.copy_all),
          ),
        ],
      ),
      body: ListView.separated(
        separatorBuilder: (_, __) => Divider(),
        itemCount: _messages.length,
        itemBuilder: (context, i) => ListTile(
          title: Text(_messages[i].body.toString()),
          trailing: Text(
            DateTime.fromMillisecondsSinceEpoch((_messages[i].date) as int)
                .toString()
                .substring(0, 10),
          ),
          onTap: () {
            Clipboard.setData(ClipboardData(text: _messages[i].body));
            final snackBar = SnackBar(content: Text('Copied to Clipboard'));
            Scaffold.of(context).showSnackBar(snackBar);
          },
        ),
      ),
    );
  }
}
