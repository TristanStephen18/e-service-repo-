import 'package:flutter/widgets.dart';

class Responsive {
  static double screenWidth = 0;
  static double screenHeight = 0;
  static double blockSizeHorizontal = 0;
  static double blockSizeVertical = 0;
  static double textScaleFactor = 0;

  static double _baseWidth = 375; // iPhone 8 width
  static double _baseHeight = 667; // iPhone 8 height

  static double textMultiplier = 0.5;
  static double heightMultiplier = 0.5;
  static double widthMultiplier = 0.5;

  static void init(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    blockSizeHorizontal = screenWidth / _baseWidth;
    blockSizeVertical = screenHeight / _baseHeight;
    textScaleFactor = MediaQuery.of(context).textScaleFactor;

    textMultiplier =
        blockSizeVertical; // Scaling text based on vertical block size
    heightMultiplier = blockSizeVertical;
    widthMultiplier = blockSizeHorizontal;
  }

  // Use this to scale fonts based on the screen size and text scale factor
  static double getTextScale(double fontSize) {
    // Scale the font size based on the screen size first
    double scaledFontSize = fontSize * textMultiplier;

    // Factor in the text scale factor from MediaQuery (to accommodate user text settings)
    // Limiting to a reasonable range for a better UI experience
    return scaledFontSize * textScaleFactor.clamp(0.5, 1.0);
  }

  // Use this to scale width based on the screen size
  static double getWidthScale(double width) {
    return width * widthMultiplier;
  }

  // Use this to scale height based on the screen size
  static double getHeightScale(double height) {
    return height * heightMultiplier;
  }
}
