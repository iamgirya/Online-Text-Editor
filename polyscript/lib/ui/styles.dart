import 'package:flutter/material.dart';

import 'colors.dart';

const textStyle = TextStyle(
  fontFamily: "Roboto",
  fontStyle: FontStyle.normal,
  color: text,
  fontSize: 16,
  height: 1.25,
  letterSpacing: 0,
  decorationStyle: null,
);

var indexStyle = TextStyle(
  fontFamily: "Roboto",
  fontStyle: FontStyle.normal,
  color: Colors.black.withOpacity(0.25),
  fontSize: 16,
  height: 1.25,
  letterSpacing: 0,
  decorationStyle: null,
);

var buttonStyle = ButtonStyle(
  backgroundColor: MaterialStateProperty.all(highlight),
  elevation: MaterialStateProperty.all(0),
  shape: MaterialStateProperty.all(
    const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
  ),
  fixedSize: MaterialStateProperty.all(const Size(256, 42)),
);

var plainButton = ButtonStyle(
  backgroundColor: MaterialStateProperty.all(Colors.transparent),
  foregroundColor: MaterialStateProperty.all(text),
  elevation: MaterialStateProperty.all(0),
  shape: MaterialStateProperty.all(
    const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
  ),
);

var sizedPlainButton = ButtonStyle(
  backgroundColor: MaterialStateProperty.all(Colors.red),
  foregroundColor: MaterialStateProperty.all(text),
  elevation: MaterialStateProperty.all(0),
  shape: MaterialStateProperty.all(
    const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
  ),
  maximumSize: MaterialStateProperty.all(const Size(28, 28)),
  minimumSize: MaterialStateProperty.all(const Size(28, 28)),
  fixedSize: MaterialStateProperty.all(const Size(28, 28)),
);
