import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mr_blue/src/core/utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  final List<String> items = ['Query', 'Feedback', 'Complaints'];
  String? selectedValue;
  bool isSelected = false;
  final message = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final status = await Permission.photos.request();

    if (status.isGranted) {
      try {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
        );
        if (image != null) {
          setState(() {
            _image = File(image.path);
          });
        }
      } catch (e) {
        print('Error picking image: $e');
      }
    } else {
      print('Photo permission denied');
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Permission Denied'),
              content: Text('Please grant photo access to select an image.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("mr. blue"),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              focalRadius: 0,
              radius: 1.2,
              colors: [Colors.white, Colors.blue.shade200],
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            left: 16.w,
                            right: 16.w,
                            top: 28.h,
                          ),
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            hint: Text(
                              'Select a service',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                fontSize: 15.sp,
                              ),
                            ),
                            value: selectedValue,
                            items:
                                items
                                    .map(
                                      (item) => DropdownMenuItem<String>(
                                        value: item,
                                        child: Text(
                                          item,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                            fontSize: 15.sp,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedValue = value;
                                isSelected = true;
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: 16.h,
                            left: 16.w,
                            right: 16.w,
                          ),
                          child: Card(
                            elevation: 3,
                            shadowColor: Colors.blue[200],
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.all(20.r),
                              child: TextField(
                                controller: message,
                                decoration: InputDecoration(
                                  hintText:
                                      isSelected
                                          ? ""
                                          : "We value your feedback! Share your queries, complaints, or suggestions.",
                                  hintStyle: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey,
                                    fontSize: 12.sp,
                                  ),
                                  border: InputBorder.none,
                                ),
                                maxLines: null,
                                maxLength: 255,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(color: Colors.blue),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(14.r),
                              child: Icon(
                                Icons.image_outlined,
                                color: Colors.blue[900],
                                size: 50.sp,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        _image != null
                            ? Image.file(
                              _image!,
                              height: 200.h,
                              width: 200.w,
                              fit: BoxFit.cover,
                            )
                            : Text(
                              'Select Image',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                fontSize: 15.sp,
                              ),
                            ),
                        SizedBox(height: 40.h),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Contact Us",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Colors.blue[800],
                                fontSize: 24.sp,
                              ),
                            ),
                            Text(
                              'Email: care@mrblue.co.in',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                fontSize: 15.sp,
                              ),
                            ),
                            Text(
                              'Phone: +91 9555900059',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                fontSize: 15.sp,
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Flexible(
                                  child: InkWell(
                                    onTap: () => call(""),
                                    child: Container(
                                      height: 60.h,
                                      color: Colors.blue[700],
                                      child: Center(
                                        child: Text(
                                          'Call',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                            fontSize: 15.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: InkWell(
                                    onTap: () {},
                                    child: Container(
                                      height: 60.h,
                                      color: Colors.blue[700],
                                      child: Center(
                                        child: Text(
                                          'Send',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                            fontSize: 15.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
