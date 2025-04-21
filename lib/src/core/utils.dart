import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

Widget customDivider() {
  return Divider(color: Colors.blue.shade100, height: 0.4);
}

AppBar customAppBar(String title, {Widget? leading}) {
  return AppBar(
    leading: leading,
    backgroundColor: Colors.blue.shade700,
    title: Text(
      title,
      style: TextStyle(
        color: Colors.white,
        fontSize: 22.h,
        fontWeight: FontWeight.w900,
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
    fontSize: 16.sp,
  );
}

Future<void> call(String phoneNumber) async {
  final Uri telUri = Uri(scheme: 'tel', path: phoneNumber);

  final status = await Permission.phone.request();

  if (status.isGranted) {
    try {
      if (await canLaunchUrl(telUri)) {
        await launchUrl(telUri);
      } else {
        throw 'Could not launch dialer';
      }
    } catch (e) {
      showToastMessage("Something went wrong while calling");
    }
  } else {}
}

void shareApplication() {
  String text =
      'Hey there! Check out this app: mr. blue.\nPicks up, Cleans and Delivers your laundry right to your doorstep!\n\nDownload it now and enjoy the convenience!';
  String url = 'https://play.google.com/store/apps/details?id=com.mrblue';
  Share.share('$text\n\n$url');
}

Future<void> openWhatsAppChat(String phoneNumber, {String? message}) async {
  try {
    phoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

    String url = 'https://wa.me/$phoneNumber';
    if (message != null && message.isNotEmpty) {
      url += '?text=${Uri.encodeComponent(message)}';
    }

    final Uri whatsappUrl = Uri.parse(url);

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(whatsappUrl, mode: LaunchMode.platformDefault);
    }
  } catch (e) {
    throw 'Could not launch WhatsApp. Please ensure WhatsApp is installed or try again.';
  }
}
