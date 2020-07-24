import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seeds/providers/notifiers/settings_notifier.dart';
import 'package:seeds/providers/services/eos_service.dart';
import 'package:seeds/providers/services/navigation_service.dart';
import 'package:seeds/screens/app/wallet/custom_transaction.dart';
import 'package:seeds/screens/app/wallet/fill_request_placeholders.dart';
// import 'package:seeds/screens/app/scan/signing_request/fill_request_placeholders.dart';

enum Steps { init, scan, processing, success, error }

class Scan extends StatefulWidget {
  @override
  _ScanState createState() => new _ScanState();
}

class _ScanState extends State<Scan> {
  String action, account, data, error, qrcode;
  Steps step = Steps.init;

  @override
  void initState() {
    super.initState();
    scan();
  }

  Future scan() async {
    setState(() {
      this.step = Steps.scan;
    });

    try {
      ScanResult scanResult = await BarcodeScanner.scan();
      setState(() {
        this.step = Steps.processing;
        this.qrcode = scanResult.rawContent;
      });
      processSigningRequest();
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          this.error = 'The user did not grant the camera permission!';
          this.step = Steps.error;
        });
      } else {
        setState(() {
          this.error = 'Unknown error: $e';
          this.step = Steps.error;
        });
      }
    } on FormatException {
      setState(() {
        this.error =
            'null (User returned using the "back"-button before scanning anything. Result)';
        this.step = Steps.error;
      });
    } catch (e) {
      setState(() {
        this.error = 'Scan unknown error: $e';
        this.step = Steps.error;
      });
    }
  }

  void processSigningRequest() async {
    var uri = this.qrcode;

    print('X uri: $uri');

    try {
      String uriPath = uri.split(':')[1];

      Map<String, dynamic> signingRequest =
          await EosService.of(context, listen: false)
              .getReadableRequest(uriPath);

    print('X signingRequest: $signingRequest');

      var action = signingRequest['action'];
      var account = signingRequest['account'];
      var data = signingRequest['data'];

      Map<String, dynamic> actionData = fillRequestPlaceholders(
          data, SettingsNotifier.of(context).accountName);

      setState(() {
        this.step = Steps.success;
      });

      NavigationService.of(context).navigateTo(
        Routes.customTransaction,
        CustomTransactionArguments(
          account: account,
          name: action,
          data: actionData,
        ),
        true,
      );
    } catch (e) {
      setState(() {
        this.step = Steps.scan;
        this.error = 'Processing unknown error: $e';
      });
      print(e.toString());
      scan();
    }
  }

  @override
  Widget build(BuildContext context) {
    var message;

    switch (step) {
      case Steps.init:
        message = 'Initialize Camera...';
        break;
      case Steps.scan:
        message = 'Scan QR Code...';
        break;
      case Steps.processing:
        message = 'Process signing request...';
        break;
      case Steps.success:
        message = 'Success!';
        break;
      case Steps.error:
        message = this.error;
        break;
    }

    return Scaffold(
          body: Center(
        child: Text(
          message,
          style: TextStyle(
            fontFamily: "heebo",
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
