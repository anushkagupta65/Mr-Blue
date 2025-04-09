import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

Widget customDivider() {
  return Divider(color: Colors.blue.shade100, height: 0.4);
}

dynamic customAppBar() {
  return AppBar(
    backgroundColor: Colors.blue.shade700,
    title: Center(
      child: Text(
        'mr. blue',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    centerTitle: true,
    iconTheme: IconThemeData(color: Colors.white),
  );
}

void showToastMessage(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
    backgroundColor: Colors.lightBlue.shade900,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

Future<void> call(String phoneNumber) async {
  String formattedNumber =
      phoneNumber.startsWith('+') ? phoneNumber : '+91$phoneNumber';
  final Uri telUri = Uri(scheme: 'tel', path: formattedNumber);

  final status = await Permission.phone.request();

  if (status.isGranted) {
    try {
      if (await canLaunchUrl(telUri)) {
        await launchUrl(telUri);
      } else {
        throw 'Could not launch dialer';
      }
    } catch (e) {
      print('Error: $e');
    }
  } else {
    print('Phone permission denied');
  }
}

Future<void> directCall() async {
  await FlutterPhoneDirectCaller.callNumber('+919555900059');
}

void shareApplication() {
  String text =
      'Hey there! Check out this app: Mr BLUE.\nPicks up, Cleans and Delivers your laundry right to your doorstep!\n\nDownload it now and enjoy the convenience!';
  String url = 'https://play.google.com/store/apps/details?id=com.mrblue';
  Share.share('$text\n\n$url');
}

Future<void> openWhatsApp() async {
  final Uri whatsappUri = Uri.parse('https://wa.me/7011744407');
  try {
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    } else {
      throw 'Could not launch WhatsApp';
    }
  } catch (e) {
    print('Error: $e');
  }
}
