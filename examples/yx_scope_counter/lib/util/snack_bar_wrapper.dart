import 'package:flutter/material.dart';

class SnackBarWrapper {
  const SnackBarWrapper();

  void show(
    BuildContext context, {
    required SnackBar snackBar,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
