import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static TextStyle heading1 = GoogleFonts.roboto(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static TextStyle heading2 = GoogleFonts.roboto(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  static TextStyle subtitle = GoogleFonts.roboto(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Colors.grey[800],
  );

  static TextStyle body = GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Colors.black,
  );

  static TextStyle bodySmall = GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.black87,
  );

  static TextStyle caption = GoogleFonts.roboto(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colors.grey,
  );

  static TextStyle button = GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}
