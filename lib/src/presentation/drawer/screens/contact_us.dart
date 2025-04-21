import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mr_blue/src/core/utils.dart';

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
              radius: 2,
              colors: [Colors.white, Colors.blue.shade500],
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Contact Us",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Colors.blue[900]!.withValues(alpha: 0.6),
                                fontSize: 22.sp,
                              ),
                            ),
                            Text(
                              'Email: care@mrblue.co.in',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black.withValues(alpha: 0.6),
                                fontSize: 14.sp,
                              ),
                            ),
                            Text(
                              'Phone: +91 9555900059',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black.withValues(alpha: 0.6),
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 16.h,
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
                                    fontSize: 14.sp,
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
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              child: Card(
                                elevation: 3,
                                shadowColor: Colors.blue[200],
                                color: Colors.white,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                  ),
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

                            Expanded(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Flexible(
                                      child: InkWell(
                                        onTap: () => call("9555900059"),
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
