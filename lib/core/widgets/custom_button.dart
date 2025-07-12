import 'package:flutter/material.dart';
import 'package:whatsapp_clone/core/constants.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({super.key, this.onPressed, required this.text});
  final void Function()? onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,

      style: TextButton.styleFrom(
        backgroundColor: kLightPrimaryColor,
        foregroundColor: Colors.white,
      ),
      child: Text(text),
    );
  }
}
