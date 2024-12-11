import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class Utils {
  static final locationDialogKey = GlobalKey();

  static printLog(String message) {
    if (kDebugMode) {
      print(message);
    }
  }

  static Uint8List getImageFromBase64(String img) {
    Uint8List _bytes;
    _bytes = const Base64Decoder().convert(img);
    return _bytes;
  }

  static bool isValidFace(Face? face) {
    bool isValid = false;
    try {
      if (face == null) {
        return false;
      }
      if ((face.headEulerAngleY!) > 10 || (face.headEulerAngleY!) < -10) {
        isValid = false;
      } else {
        isValid = true;
      }
    } catch (e) {
      isValid = false;
    }
    return isValid;
  }

  // Method to mask the contact number
  static String maskContact(String contact) {
    // Assuming contact is a phone number, e.g., "9876543210"
    String maskedContact = contact.substring(0, 2) +
        '*' * (contact.length - 6) +
        contact.substring(contact.length - 4);
    return maskedContact;
  }
}
