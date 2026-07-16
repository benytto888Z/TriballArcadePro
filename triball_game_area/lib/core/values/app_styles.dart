import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/game_constants.dart';
import '../utils/ dimens.dart';
import '../values/color_values.dart';

class AppStyles {
  // ==========================================
  // CONSTANTES DE BASE
  // ==========================================

  static String get defaultFontFamily => 'Power Grotesk';
  static String get defaultFontFamily2 =>  GameConstants.gameFontFamily;
  static String get regularFontFamily => 'Power Grotesk Reg';
  static String get boldFontFamily => 'Power Grotesk Bold';
  static double get defaultHeight => 1.25;
  static double get gameLineHeight => 1.3;

  // ==========================================
  // STYLES EXISTANTS (gardés tels quels)
  // ==========================================
  static TextStyle style16RegularHint = TextStyle(
    fontFamily: regularFontFamily,
    fontSize: Dimens.sixTeen,
    color: ColorValues.txtFieldHintColor,
    height: defaultHeight,
  );

  static TextStyle style16RegularTxt = TextStyle(
    fontFamily: regularFontFamily,
    fontSize: Dimens.sixTeen,
    color: ColorValues.txtFieldTxtColor,
    height: defaultHeight,
  );

  static TextStyle style10NormalGrey = TextStyle(
    fontSize: Dimens.tenH,
    fontWeight: FontWeight.w400,
    fontFamily: regularFontFamily,
    height: defaultHeight,
  );

  static TextStyle style12NormalGrey = TextStyle(
    fontSize: Dimens.twelveH,
    fontWeight: FontWeight.w400,
    fontFamily: regularFontFamily,
    height: defaultHeight,
  );

  static TextStyle style14NormalGrey = TextStyle(
    fontSize: Dimens.fourTeenH,
    fontWeight: FontWeight.w400,
    fontFamily: regularFontFamily,
    height: defaultHeight,
  );

  static TextStyle style12Normal = TextStyle(
    fontSize: Dimens.twelve,
    fontWeight: FontWeight.w400,
    fontFamily: defaultFontFamily,
    height: defaultHeight,
  );

  static TextStyle style12NormalWhite = TextStyle(
    fontSize: Dimens.twelve,
    fontWeight: FontWeight.w600,
    fontFamily: defaultFontFamily,
    color: ColorValues.txtFieldTxtColor,
    height: defaultHeight,
  );

  static TextStyle style12Normalgrey = TextStyle(
    fontSize: Dimens.twelve,
    fontWeight: FontWeight.w600,
    fontFamily: defaultFontFamily,
    color: ColorValues.greyTxtInfoColor,
    height: defaultHeight,
  );

  static TextStyle style14Normalgrey = TextStyle(
    fontSize: Dimens.fourteen,
    fontWeight: FontWeight.w600,
    fontFamily: defaultFontFamily,
    color: ColorValues.greyTxtInfoColor,
    height: defaultHeight,
  );

  static TextStyle style12Bold = TextStyle(
    fontSize: Dimens.twelve,
    fontWeight: FontWeight.w700,
    fontFamily: defaultFontFamily,
    height: defaultHeight,
  );

  static TextStyle style13Normal = TextStyle(
    fontSize: 13.r,
    fontWeight: FontWeight.w400,
    fontFamily: defaultFontFamily,
    height: defaultHeight,
  );

  static TextStyle style13Bold = TextStyle(
    fontSize: 13.r,
    fontWeight: FontWeight.w700,
    fontFamily: defaultFontFamily,
    height: defaultHeight,
  );

  static TextStyle style14Normal = TextStyle(
    fontSize: 14.r,
    fontWeight: FontWeight.w400,
    fontFamily: defaultFontFamily,
    height: defaultHeight,
  );

  static TextStyle style14NormalFFFF = TextStyle(
    fontSize: 14.r,
    fontWeight: FontWeight.w400,
    fontFamily: defaultFontFamily,
    color: ColorValues.whiteColor,
    height: defaultHeight,
  );

  static TextStyle style14NormalWhite = TextStyle(
    fontSize: Dimens.fourTeenH,
    fontWeight: FontWeight.w400,
    fontFamily: defaultFontFamily,
    color: ColorValues.darkSubtitleTextColor,
    height: defaultHeight,
  );

  static TextStyle style14NormalgreyLight = TextStyle(
    fontSize: Dimens.fourTeenH,
    fontWeight: FontWeight.w500,
    fontFamily: defaultFontFamily,
    color: ColorValues.darkBodyTextColor,
    height: defaultHeight,
  );

  static TextStyle style14NormalWhiteColor = TextStyle(
    fontSize: Dimens.fourTeenH,
    fontWeight: FontWeight.w400,
    fontFamily: defaultFontFamily,
    color: ColorValues.whiteColor,
    height: defaultHeight,
  );

  static TextStyle style14RegularGrey = TextStyle(
    fontSize: Dimens.fourTeenH,
    fontWeight: FontWeight.w400,
    fontFamily: defaultFontFamily,
    color: ColorValues.darkSubtitleTextColor,
    height: defaultHeight,
  );

  static TextStyle style14RegularBlack = TextStyle(
    fontSize: Dimens.fourTeenH,
    fontWeight: FontWeight.w400,
    fontFamily: defaultFontFamily,
    color: ColorValues.blackColor,
    height: defaultHeight,
  );

  static TextStyle style12RegularGrey = TextStyle(
    fontSize: Dimens.twelveH,
    fontWeight: FontWeight.w400,
    fontFamily: defaultFontFamily,
    color: ColorValues.darkSubtitleTextColor,
    height: defaultHeight,
  );

  static TextStyle style12RegularGrey2 = TextStyle(
    fontSize: Dimens.twelveH,
    fontWeight: FontWeight.w400,
    fontFamily: defaultFontFamily,
    color: ColorValues.darkSubtitleTextColor2,
    height: defaultHeight,
  );

  static TextStyle style12RegularGrey3 = TextStyle(
    fontSize: Dimens.twelveH,
    fontWeight: FontWeight.w400,
    fontFamily: defaultFontFamily,
    color: ColorValues.greyTxtInfoColor,
    height: defaultHeight,
  );

  static TextStyle style12RegularYellow = TextStyle(
    fontSize: Dimens.twelveH,
    fontWeight: FontWeight.w400,
    fontFamily: defaultFontFamily,
    color: ColorValues.btnBgColorYellow,
    height: defaultHeight,
  );

  static TextStyle style24RegularYellow = TextStyle(
    fontSize: Dimens.twelveH*2,
    fontWeight: FontWeight.w400,
    fontFamily: defaultFontFamily,
    color: ColorValues.btnBgColorYellow,
    height: defaultHeight,
  );

  static TextStyle style14BoldPower = TextStyle(
    fontSize: Dimens.fourTeenH,
    fontWeight: FontWeight.w700,
    fontFamily: defaultFontFamily,
    color: ColorValues.txtFieldTxtColor,
    height: defaultHeight,
  );

  static TextStyle style14MediumPower = TextStyle(
    fontSize: Dimens.fourTeenH,
    fontWeight: FontWeight.w600,
    fontFamily: defaultFontFamily,
    color: ColorValues.txtFieldTxtColor,
    height: defaultHeight,
  );

  static TextStyle style14NormalWhitily = TextStyle(
    fontSize: Dimens.fourTeenH,
    fontWeight: FontWeight.w400,
    fontFamily: defaultFontFamily,
    color: ColorValues.txtFieldTxtColor,
    shadows: [
      Shadow(color: Color(0xff000029), offset: Offset(0, 3), blurRadius: 6)
    ],
    height: defaultHeight,
  );

  static TextStyle style16NormalWhitily = TextStyle(
    fontSize: 16.r,
    fontWeight: FontWeight.w400,
    fontFamily: defaultFontFamily,
    color: ColorValues.txtFieldTxtColor,
    shadows: [
      Shadow(color: Color(0xff000029), offset: Offset(0, 3), blurRadius: 6)
    ],
    height: defaultHeight,
  );

  static TextStyle style24NormalWhitily = TextStyle(
    fontSize: 24.r,
    fontWeight: FontWeight.w400,
    fontFamily: defaultFontFamily,
    // color: ColorValues.txtFieldTxtColor,
    color: ColorValues.grayColor,
    shadows: [
      Shadow(color: Color(0xff000029), offset: Offset(0, 3), blurRadius: 6)
    ],
    height: defaultHeight,
  );

  static TextStyle style12NormalWhitily = TextStyle(
    fontSize: Dimens.twelve,
    fontWeight: FontWeight.w400,
    fontFamily: defaultFontFamily,
    color: Color(0xffB1B1B1),
    shadows: [
      Shadow(color: Color(0xff000029), offset: Offset(0, 3), blurRadius: 6)
    ],
    height: defaultHeight,
  );

  static TextStyle style12NormalGreyLy = TextStyle(
    fontSize: Dimens.twelveH*1.3,
    fontWeight: FontWeight.w900,
    fontFamily: defaultFontFamily,
    color: Color(0xff000000),
    shadows: [
      Shadow(color: Color(0xff000029), offset: Offset(0, 3), blurRadius: 6)
    ],
    height: defaultHeight,
  );

  static TextStyle style14NormalGreyLy = TextStyle(
    fontSize: Dimens.fourTeenH,
    fontWeight: FontWeight.w900,
    fontFamily: defaultFontFamily,
    color: Color(0xff000000),
    shadows: [
      Shadow(color: Color(0xff000029), offset: Offset(0, 3), blurRadius: 6)
    ],
    height: defaultHeight,
  );

  static TextStyle style14PNormalGreyLy = TextStyle(
    fontSize: Dimens.fourTeenH,
    fontWeight: FontWeight.w900,
    fontFamily: defaultFontFamily,
    color: Color(0xff000000),
    shadows: [
      Shadow(color: Color(0xff000029), offset: Offset(0, 3), blurRadius: 6)
    ],
    height: defaultHeight,
  );

  static TextStyle style12BoldWhitily = TextStyle(
    fontSize: Dimens.twelveH,
    fontWeight: FontWeight.w700,
    fontFamily: defaultFontFamily,
    color: ColorValues.txtFieldTxtColor,
    shadows: [
      Shadow(color: Color(0xff000029), offset: Offset(0, 3), blurRadius: 6)
    ],
    height: defaultHeight,
  );

  static TextStyle styleGeneral(ftz, ftw, c) => TextStyle(
    fontSize: ftz,
    fontWeight: ftw,
    fontFamily: defaultFontFamily,
    color: c,
    height: defaultHeight,
  );

  static TextStyle styleGeneralWhitily(ftz, ftw, c) => TextStyle(
    fontSize: ftz,
    fontWeight: ftw,
    fontFamily: defaultFontFamily,
    color: c,
    shadows: [
      Shadow(color: Color(0xff000029), offset: Offset(0, 3), blurRadius: 6)
    ],
    height: defaultHeight,
  );

  static TextStyle styleGeneralShadow(ftz, ftw, c) => TextStyle(
    fontSize: ftz,
    fontWeight: ftw,
    fontFamily: defaultFontFamily2,
    color: c,
    shadows: [
      Shadow(color: Color(0xff000029), offset: Offset(0, 3), blurRadius: 6)
    ],
    height: defaultHeight,
  );

  static TextStyle styleGeneralShadowCl(ftz, ftw, c) => TextStyle(
    fontSize: ftz,
    fontWeight: ftw,
    fontFamily: defaultFontFamily2,
    color: c,
    shadows: [
      Shadow(color: Color(0xff0b0302), offset: Offset(0, 4), blurRadius: 7)
    ],
    height: defaultHeight,
  );

  static TextStyle style10NormalWhite = TextStyle(
    fontSize: Dimens.ten,
    fontWeight: FontWeight.w400,
    fontFamily: defaultFontFamily,
    color: ColorValues.darkSubtitleTextColor,
    height: defaultHeight,
  );

  static TextStyle style14Bold = TextStyle(
    fontSize: Dimens.fourteen,
    fontWeight: FontWeight.w700,
    fontFamily: defaultFontFamily,
    height: defaultHeight,
  );

  static TextStyle style15Normal = TextStyle(
    fontSize: 15.r,
    fontWeight: FontWeight.w400,
    fontFamily: defaultFontFamily,
    height: defaultHeight,
  );

  static TextStyle style15Bold = TextStyle(
    fontSize: 15.r,
    fontWeight: FontWeight.w700,
    fontFamily: defaultFontFamily,
    height: defaultHeight,
  );

  static TextStyle style16Normal = TextStyle(
    fontSize: Dimens.sixTeen,
    fontWeight: FontWeight.w400,
    fontFamily: defaultFontFamily,
    height: defaultHeight,
  );

  static TextStyle style16NormalWhite = TextStyle(
    fontSize: Dimens.sixTeen,
    fontWeight: FontWeight.w400,
    fontFamily: regularFontFamily,
    color: Color(0xffFEFEFE),
    height: defaultHeight,
  );

  static TextStyle style24NormalWhite = TextStyle(
    fontSize: Dimens.twenty,
    fontWeight: FontWeight.w500,
    fontFamily: regularFontFamily,
    color: Color(0xffFEFEFE),
    height: defaultHeight,
  );

  static TextStyle style16MediumWhite = TextStyle(
    fontSize: Dimens.sixTeen,
    fontWeight: FontWeight.w600,
    fontFamily: defaultFontFamily,
    color: Color(0xffFFFFFF),
    height: defaultHeight,
  );

  static TextStyle style16NormalWhiteEllipsis = TextStyle(
    fontSize: Dimens.sixTeen,
    fontWeight: FontWeight.w400,
    fontFamily: regularFontFamily,
    color: Color(0xffFEFEFE),
    overflow: TextOverflow.ellipsis,
    height: defaultHeight,
  );

  static TextStyle style16NormalGrey = TextStyle(
    fontSize: Dimens.sixTeen,
    fontWeight: FontWeight.w400,
    fontFamily: regularFontFamily,
    color: ColorValues.greyTxtInfoColor,
    height: defaultHeight,
  );

  static TextStyle style22NormalGrey = TextStyle(
    fontSize: Dimens.twentyTwo,
    fontWeight: FontWeight.w400,
    fontFamily: regularFontFamily,
    color: ColorValues.greyTxtInfoColor,
    height: defaultHeight,
  );

  static TextStyle style16NormalBlack = TextStyle(
    fontSize: Dimens.sixTeen,
    fontWeight: FontWeight.w400,
    fontFamily: regularFontFamily,
    color: ColorValues.bottomNavBgColor,
    height: defaultHeight,
  );

  static TextStyle style16Bold = TextStyle(
    fontSize: Dimens.sixTeen,
    fontWeight: FontWeight.w700,
    fontFamily: defaultFontFamily,
    height: defaultHeight,
  );

  static TextStyle style18Normal = TextStyle(
    fontSize: Dimens.eighteen,
    fontWeight: FontWeight.w400,
    fontFamily: defaultFontFamily,
    height: defaultHeight,
  );

  static TextStyle style18Bold = TextStyle(
    fontSize: Dimens.eighteen,
    fontWeight: FontWeight.w700,
    fontFamily: defaultFontFamily,
    height: defaultHeight,
  );

  static TextStyle style18BoldWhite = TextStyle(
    fontSize: Dimens.eighteen,
    fontWeight: FontWeight.w700,
    fontFamily: defaultFontFamily,
    color: Colors.white,
    height: defaultHeight,
  );

  static TextStyle style20Normal = TextStyle(
    fontSize: 20.r,
    fontWeight: FontWeight.w400,
    fontFamily: defaultFontFamily,
    height: defaultHeight,
  );

  static TextStyle style20Bold = TextStyle(
    fontSize: 20.r,
    fontWeight: FontWeight.w700,
    fontFamily: defaultFontFamily,
    height: defaultHeight,
  );

  static TextStyle style24Normal = TextStyle(
    fontSize: 24.r,
    fontWeight: FontWeight.w400,
    fontFamily: defaultFontFamily,
    height: defaultHeight,
  );

  static TextStyle style24Bold = TextStyle(
    fontSize: 24.r,
    fontWeight: FontWeight.w700,
    fontFamily: defaultFontFamily,
    height: defaultHeight,
  );

  static TextStyle style28Normal = TextStyle(
    fontSize: 28.r,
    fontWeight: FontWeight.w400,
    fontFamily: defaultFontFamily,
    height: defaultHeight,
  );

  static TextStyle style28Bold = TextStyle(
    fontSize: 28.r,
    fontWeight: FontWeight.w700,
    fontFamily: defaultFontFamily,
    height: defaultHeight,
  );

  static TextStyle style32Normal = TextStyle(
    fontSize: 32.r,
    fontWeight: FontWeight.w400,
    fontFamily: defaultFontFamily,
    height: defaultHeight,
  );

  static TextStyle style32Bold = TextStyle(
    fontSize: 32.r,
    fontWeight: FontWeight.w700,
    fontFamily: defaultFontFamily,
    height: defaultHeight,
  );

  static TextStyle style40Normal = TextStyle(
    fontSize: 40.r,
    fontWeight: FontWeight.w400,
    fontFamily: defaultFontFamily,
    height: defaultHeight,
  );

  static TextStyle style40Bold = TextStyle(
    fontSize: 40.r,
    fontWeight: FontWeight.w700,
    fontFamily: defaultFontFamily,
    height: defaultHeight,
  );

  // ==========================================
  // STYLES SPÉCIFIQUES POUR NEURONA ARENA (JEU)
  // ==========================================

  static TextStyle gameTimer = TextStyle(
    fontSize: Dimens.fifty,
    fontWeight: FontWeight.w800,
    fontFamily: boldFontFamily,
    color: ColorValues.gameTimer,
    letterSpacing: 2,
    height: gameLineHeight,
    shadows: const [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
  );

  static TextStyle gameQuestion = TextStyle(
    fontSize: Dimens.twentyFive,
    fontWeight: FontWeight.w800,
    fontFamily: boldFontFamily,
    color: ColorValues.whiteColor,
    height: gameLineHeight,
    shadows: const [Shadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 2))],
  );

  static TextStyle gameAnswer = TextStyle(
    fontSize: Dimens.eighteen,
    fontWeight: FontWeight.w600,
    fontFamily: defaultFontFamily,
    color: ColorValues.whiteColor,
    height: gameLineHeight,
  );

  static TextStyle gameScore = TextStyle(
    fontSize: Dimens.thirtySix,
    fontWeight: FontWeight.w800,
    fontFamily: boldFontFamily,
    color: ColorValues.gameSecondary,
    letterSpacing: 1,
    height: gameLineHeight,
    shadows: const [Shadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 2))],
  );

  static TextStyle gamePlayerName = TextStyle(
    fontSize: Dimens.sixTeen,
    fontWeight: FontWeight.w700,
    fontFamily: defaultFontFamily,
    color: ColorValues.whiteColor,
    height: gameLineHeight,
  );

  static TextStyle gameRoundTitle = TextStyle(
    fontSize: Dimens.twentyTwo,
    fontWeight: FontWeight.w800,
    fontFamily: boldFontFamily,
    color: ColorValues.gamePrimary,
    letterSpacing: 2,
    height: gameLineHeight,
  );


}