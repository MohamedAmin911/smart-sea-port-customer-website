import 'package:flutter/material.dart';

TextStyle appStyle({
  // double? fw,
  required double size,
  required Color color,
  required FontWeight fontWeight,
}) {
  return TextStyle(
    fontFamily: "UberMove",
    fontSize: size,
    color: color,
    fontWeight: fontWeight,
    // fontVariations: fw == null ? [] : [FontVariation("wght", fw)],
  );
}
