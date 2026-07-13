import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// Contains the dimensions and padding used
/// all over the application.
abstract class Dimens {
  // ==========================================
  // MÉTHODES SÉCURISÉES POUR OBTENIR LES DIMENSIONS
  // ==========================================

  static double get screenHeight {
    try {
      if (Get.context != null) {
        return MediaQuery.of(Get.context!).size.height;
      }
    } catch (e) {}
    return 829.0; // Fallback
  }

  static double get screenWidth {
    try {
      if (Get.context != null) {
        return MediaQuery.of(Get.context!).size.width;
      }
    } catch (e) {}
    return 384.0; // Fallback
  }

  static double screenWidthXD = 384;
  static double screenHeightXD = 829;

  static double screenPaddingW = 27.w;

  // common widget dim
  static double commonWidgetHeight = 59.h;
  static double commonWidgetWidth = 364.w;

  /// heights
  static double oneH = 1.h;
  static double maxsizeH = 0.9.h;
  static double minsizeH = 0.8.h;
  static double twoH = 2.h;
  static double threeH = 3.h;
  static double fourH = 4.h;
  static double fiveH = 5.h;
  static double sixH = 6.h;
  static double sevenH = 7.h;
  static double eightH = 8.h;
  static double nineH = 9.h;
  static double tenH = 10.h;
  static double elevenH = 11.h;
  static double twelveH = 12.h;
  static double thirteenH = 13.h;
  static double fourTeenH = 14.h;
  static double fifTeenH = 15.h;
  static double sixTeenH = 16.h;
  static double sixteenH = 16.h;
  static double sevenTeenH = 17.h;
  static double eigtheenH = 18.h;
  static double nineTeenH = 19.h;
  static double twentyH = 20.h;
  static double twentyFirstH = 21.h;
  static double twentyTwoH = 22.h;
  static double twentyThirdH = 23.h;
  static double twentyFourH = 24.h;
  static double twentyFiveH = 25.h;
  static double twentySixH = 26.h;
  static double twentySevenH = 27.h;
  static double twentyEightH = 28.h;
  static double twentyNineH = 29.h;
  static double thirtyH = 30.h;
  static double thirtyFiveH = 35.h;
  static double bootomSheetLGH = 710.h;

  /// widths
  static double oneW = 1.w;
  static double twoW = 2.w;
  static double threeW = 3.w;
  static double fourW = 4.w;
  static double fiveW = 5.w;
  static double sixW = 6.w;
  static double sevenW = 7.w;
  static double eightW = 8.w;
  static double nineW = 9.w;
  static double tenW = 10.w;
  static double elevenW = 11.w;
  static double twelveW = 12.w;
  static double thirteenW = 13.w;
  static double fourTeenW = 14.w;
  static double fifTeenW = 15.w;
  static double sixTeenW = 16.w;
  static double sevenTeenW = 17.w;
  static double eigtheenW = 18.w;
  static double nineTeenW = 19.w;
  static double twentyW = 20.w;
  static double twentyFirstW = 21.w;
  static double twentyTwoW = 22.w;
  static double twentyThirdW = 23.w;
  static double twentyFourW = 24.w;
  static double twentyFiveW = 25.w;
  static double twentySixW = 26.w;
  static double twentySevenW = 27.w;
  static double twentyEightW = 28.w;
  static double twentyNineW = 29.w;
  static double thirtyW = 30.w;

  static double SpaceicoBottomnavBar = 54.5.w;

  // -----measure for sp and radius only
  static double zero = 0.r;
  static double one = 1.r;
  static double two = 2.r;
  static double three = 3.r;
  static double four = 4.r;
  static double five = 5.r;
  static double six = 6.r;
  static double seven = 7.r;
  static double eight = 8.r;
  static double nine = 9.r;
  static double ten = 10.r;
  static double eleven = 11.r;
  static double twelve = 12.r;
  static double thirteen = 13.r;
  static double fourteen = 14.r;
  static double fifTeen = 15.r;
  static double sixTeen = 16.r;
  static double sevenTeen = 17.r;
  static double eighteen = 18.r;
  static double nineteen = 19.r;
  static double twenty = 20.r;
  static double twentyFirst = 21.r;
  static double twentyTwo = 22.r;
  static double twentyThree = 23.r;
  static double twentyFour = 24.r;
  static double twentyFive = 25.r;
  static double twentySix = 26.r;
  static double twentySeven = 27.r;
  static double twentyEight = 28.r;
  static double thirtySix = 36.r;
  static double thirtySeven = 37.r;
  static double sixty = 60.r;
  static double fifty = 50.r;
  static double thirtyNine = 39.r;
  static double thirty = 30.r;
  static double eighty = 80.r;
  static double pointFive = 0.5.r;
  static double sixtyFour = 64.r;
  static double thirtyTwo = 32.r;
  static double thirtyFive = 35.r;
  static double seventy = 70.r;
  static double fourty = 40.r;
  static double fourtyEight = 48.r;
  static double thirtyFour = 34.r;
  static double ninetyEight = 98.r;
  static double ninetyFive = 95.r;
  static double fiftyFive = 55.r;
  static double fiftyFour = 54.r;
  static double fiftySix = 56.r;
  static double hundred = 100.r;
  static double oneHundredFifty = 150.r;
  static double oneHundredTwenty = 120.r;
  static double seventyEight = 78.r;

  static EdgeInsets edgeInsets16 = EdgeInsets.all(sixTeen);

  // SizedBoxes
  static SizedBox boxHeight2 = SizedBox(height: twoH);
  static SizedBox boxHeight4 = SizedBox(height: fourH);
  static SizedBox boxHeight8 = SizedBox(height: eightH);
  static SizedBox boxHeight10 = SizedBox(height: tenH);
  static SizedBox boxHeight12 = SizedBox(height: twelveH);
  static SizedBox boxHeight16 = SizedBox(height: sixTeenH);
  static SizedBox boxHeight20 = SizedBox(height: twentyH);

  static SizedBox boxWidth2 = SizedBox(width: twoW);
  static SizedBox boxWidth4 = SizedBox(width: fourW);
  static SizedBox boxWidth8 = SizedBox(width: eightW);
  static SizedBox boxWidth10 = SizedBox(width: tenW);
  static SizedBox boxWidth12 = SizedBox(width: twelveW);
  static SizedBox boxWidth16 = SizedBox(width: sixTeenW);
  static SizedBox boxWidth20 = SizedBox(width: twentyW);
  static SizedBox boxWidth24 = SizedBox(width: twentyFourW);
  static SizedBox boxWidth32 = SizedBox(width: thirtyTwo);
  static SizedBox boxWidth40 = SizedBox(width: fourty);
  static SizedBox boxWidth60 = SizedBox(width: sixty);
  static SizedBox boxHeight60 = SizedBox(height: sixty);
  static SizedBox boxWidth80 = SizedBox(width: eighty);
  static SizedBox boxHeight80 = SizedBox(height: eighty);
  static SizedBox shrinkBox = const SizedBox.shrink();

  static Divider divider = const Divider(height: 0.0, thickness: 0.4);
  static Divider dividerWithHeight = const Divider(thickness: 0.5);

  // EdgeInsets
  static EdgeInsets edgeInsets4_0 = EdgeInsets.symmetric(vertical: four, horizontal: zero);
  static EdgeInsets edgeInsets4_8 = EdgeInsets.symmetric(vertical: four, horizontal: eight);
  static EdgeInsets edgeInsets0_4 = EdgeInsets.symmetric(vertical: zero, horizontal: four);
  static EdgeInsets edgeInsets0_8 = EdgeInsets.symmetric(vertical: zero, horizontal: eight);
  static EdgeInsets edgeInsets8_0 = EdgeInsets.symmetric(vertical: eight, horizontal: zero);
  static EdgeInsets edgeInsets4 = EdgeInsets.all(fourH);
  static EdgeInsets edgeInsets8 = EdgeInsets.all(eightH);
  static EdgeInsets edgeInsets10 = EdgeInsets.all(tenH);
  static EdgeInsets edgeInsets12 = EdgeInsets.all(twelveH);
  static EdgeInsets edgeInsets20 = EdgeInsets.all(twentyH);
  static EdgeInsets edgeInsetsOnlyTop2 = EdgeInsets.only(top: twoH);
  static EdgeInsets edgeInsetsOnlyTop4 = EdgeInsets.only(top: fourH);
  static EdgeInsets edgeInsetsOnlyTop8 = EdgeInsets.only(top: eightH);
  static EdgeInsets edgeInsetsOnlyTop16 = EdgeInsets.only(top: sixTeenH);
  static EdgeInsets edgeInsets0 = EdgeInsets.zero;
  static EdgeInsets edgeInsets12_0 = EdgeInsets.symmetric(vertical: twelveH, horizontal: zero);
  static EdgeInsets edgeInsets0_12 = EdgeInsets.symmetric(vertical: zero, horizontal: twelveW);
  static EdgeInsets edgeInsets16_0 = EdgeInsets.symmetric(vertical: sixTeenH, horizontal: zero);
  static EdgeInsets edgeInsets0_16 = EdgeInsets.symmetric(vertical: zero, horizontal: sixTeenW);
  static EdgeInsets edgeInsets8_16 = EdgeInsets.symmetric(vertical: eightH, horizontal: sixTeenW);
  static EdgeInsets edgeInsets6_12 = EdgeInsets.symmetric(vertical: sixH, horizontal: twelveW);
  static EdgeInsets edgeInsets2_0 = EdgeInsets.symmetric(vertical: two, horizontal: zero);
  static EdgeInsets edgeInsets0_2 = EdgeInsets.symmetric(vertical: zero, horizontal: two);
}