// lib/features/how_to_play/widgets/hole_grid_demo.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/theme_colors.dart';

class HoleGridDemo extends StatelessWidget {
  const HoleGridDemo({super.key});

  // Map des trous avec leurs valeurs
  static const List<Map<String, dynamic>> holes = [
    {'label': '+10', 'color': Colors.green,   'desc': 'top_left'},
    {'label': '-10', 'color': Colors.red,     'desc': 'top_center'},
    {'label': '+5',  'color': Colors.green,   'desc': 'top_right'},
    {'label': '-5',  'color': Colors.red,     'desc': 'mid_left'},
    {'label': '+30', 'color': Colors.cyan,    'desc': 'mid_center'},
    {'label': '-5',  'color': Colors.red,     'desc': 'mid_right'},
    {'label': '+5',  'color': Colors.green,   'desc': 'low_left'},
    {'label': '×0',  'color': Colors.redAccent, 'desc': 'low_center'},
    {'label': '×2',  'color': Colors.amber,   'desc': 'low_right'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            'guide_board_layout'.tr,
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 11.sp,
              color: ThemeColors.textSecondary,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 10.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.5,
            ),
            itemCount: 9,
            itemBuilder: (context, index) {
              final h = holes[index];
              final color = h['color'] as Color;
              return Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color, width: 1.5),
                  boxShadow: ThemeColors.useGlow
                      ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8)]
                      : null,
                ),
                child: Center(
                  child: Text(
                    h['label'] as String,
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 10.h),
          Text(
            'guide_board_explanation'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 10.sp,
              color: ThemeColors.textSecondary,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}