import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_state/phone_state.dart';
import 'package:system_alert_window/system_alert_window.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemAlertWindow.registerOnClickListener(callBack);
  runApp(const MyApp());
}

void callBack(String tag) {
  print(tag);
  switch (tag) {
    case "btn_1":
      SystemAlertWindow.closeSystemWindow(
          prefMode: SystemWindowPrefMode.OVERLAY);
      break;
    case "focus_button":
      print("Focus button has been called");
      break;
    default:
      print("OnClick event of $tag");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SystemWindowPrefMode prefMode = SystemWindowPrefMode.OVERLAY;
  PhoneStateStatus status = PhoneStateStatus.NOTHING;
  bool granted = false;

  Future<void> _requestPermissions() async {
    await SystemAlertWindow.requestPermissions(prefMode: prefMode);
  }

  Future<bool> requestPermission() async {
    var status = await Permission.phone.request();

    switch (status) {
      case PermissionStatus.denied:
      case PermissionStatus.restricted:
      case PermissionStatus.limited:
      case PermissionStatus.permanentlyDenied:
        return false;
      case PermissionStatus.granted:
        return true;
    }
  }

  void setStream() {
    PhoneState.phoneStateStream.listen((status) {
      showWindowsDialog(status!);
    });
  }

  @override
  void initState() {
    _requestPermissions();
    requestPermission();
    setStream();
    super.initState();
  }

  showWindowsDialog(PhoneStateStatus status) {
    switch (status) {
      case PhoneStateStatus.NOTHING:
        return print('No call');
      case PhoneStateStatus.CALL_INCOMING:
        return print('Call incoming');
      case PhoneStateStatus.CALL_STARTED:
        return print('Call started');
      case PhoneStateStatus.CALL_ENDED:
        return SystemAlertWindow.showSystemWindow(
            height: 80,
            margin:
                SystemWindowMargin(left: 20, right: 20, top: 200, bottom: 0),
            gravity: SystemWindowGravity.TOP,
            notificationTitle: "Incoming Call",
            notificationBody: "+1 646 980 4741",
            prefMode: prefMode,
            header: SystemWindowHeader(
                title: SystemWindowText(text: 'Hello am coming'),
                button: SystemWindowButton(
                    tag: 'btn_1', text: SystemWindowText(text: 'CLOSE'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Phone State"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Status of call",
              style: TextStyle(fontSize: 24),
            ),
            Icon(
              getIcons(),
              color: getColor(),
              size: 80,
            )
          ],
        ),
      ),
    );
  }

  IconData getIcons() {
    switch (status) {
      case PhoneStateStatus.NOTHING:
        return Icons.clear;
      case PhoneStateStatus.CALL_INCOMING:
        return Icons.add_call;
      case PhoneStateStatus.CALL_STARTED:
        return Icons.call;
      case PhoneStateStatus.CALL_ENDED:
        return Icons.call_end;
    }
  }

  Color getColor() {
    switch (status) {
      case PhoneStateStatus.NOTHING:
      case PhoneStateStatus.CALL_ENDED:
        return Colors.red;
      case PhoneStateStatus.CALL_INCOMING:
        return Colors.green;
      case PhoneStateStatus.CALL_STARTED:
        return Colors.orange;
    }
  }
}
