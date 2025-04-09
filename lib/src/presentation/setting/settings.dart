import 'package:flutter/material.dart';
import 'package:mr_blue/src/core/utils.dart';

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
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: Center(
          child: Text(
            'Mr BLUE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
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
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => const MyProfile()),
                // );
              },
              child: ListTile(
                title: Text("My Profile", style: textStyle),
                leading: Icon(Icons.person_outline, color: blueColor),
              ),
            ),
            Divider(),
            InkWell(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => const AddAddress()),
                // );
              },
              child: ListTile(
                title: Text("Add Address", style: textStyle),
                leading: Icon(Icons.location_on_outlined, color: blueColor),
              ),
            ),
            Divider(),
            InkWell(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => const AboutUs()),
                // );
              },
              child: ListTile(
                title: Text("About us", style: textStyle),
                leading: Icon(Icons.article_outlined, color: blueColor),
              ),
            ),
            Divider(),
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
            Divider(),
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
