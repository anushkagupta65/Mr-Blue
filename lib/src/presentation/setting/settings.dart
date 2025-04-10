import 'package:flutter/material.dart';
import 'package:mr_blue/src/core/utils.dart';
import 'package:mr_blue/src/presentation/drawer/drawer.dart';
import 'package:mr_blue/src/presentation/setting/about_us.dart';
import 'package:mr_blue/src/presentation/setting/addresses.dart';
import 'package:mr_blue/src/presentation/setting/profile.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  Color blueColor = Colors.blue.shade900;

  TextStyle textStyle = TextStyle(color: Colors.blue.shade900, fontSize: 16);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("mr. blue"),
      drawer: CustomDrawer(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyProfile()),
                );
              },
              child: ListTile(
                title: Text("My Profile", style: textStyle),
                leading: Icon(Icons.person_outline, color: blueColor),
              ),
            ),
            const SizedBox(height: 10),
            customDivider(),
            const SizedBox(height: 10),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddAddressStatic(),
                  ),
                );
              },
              child: ListTile(
                title: Text("Add Address", style: textStyle),
                leading: Icon(Icons.location_on_outlined, color: blueColor),
              ),
            ),
            const SizedBox(height: 10),
            customDivider(),
            const SizedBox(height: 10),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutUs()),
                );
              },
              child: ListTile(
                title: Text("About us", style: textStyle),
                leading: Icon(Icons.article_outlined, color: blueColor),
              ),
            ),
            const SizedBox(height: 10),
            customDivider(),
            const SizedBox(height: 10),
            InkWell(
              onTap: () {
                // directCall();
                call("9555900059");
              },
              child: ListTile(
                title: Text("Call us", style: textStyle),
                leading: Icon(Icons.call, color: blueColor),
              ),
            ),
            const SizedBox(height: 10),
            customDivider(),
            const SizedBox(height: 10),
            InkWell(
              onTap: () {
                shareApplication();
              },
              child: ListTile(
                title: Text("Share", style: textStyle),
                leading: Icon(Icons.share, color: blueColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
