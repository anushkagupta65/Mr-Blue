import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FilterButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;
  final BuildContext context;

  const FilterButton({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color:
              isSelected
                  ? Colors.blue[200]!.withOpacity(0.7)
                  : Colors.blue[100]!.withOpacity(0.5),
        ),
        width: MediaQuery.of(context).size.width * 0.4,
        padding: EdgeInsets.all(8.r),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue, size: 20.sp),
            SizedBox(width: 10.w),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
