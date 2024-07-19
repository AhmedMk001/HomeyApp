import 'package:flutter/material.dart';
import 'package:homey_app/shared/colors.dart';

var decorationTextfield = InputDecoration(
  
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(15),
    borderSide: BorderSide(
      color: Colors.black,
    ),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.black,
    ),
  ),
  fillColor:backgroundColor,
  filled: true,
  contentPadding: EdgeInsets.all(8),
);