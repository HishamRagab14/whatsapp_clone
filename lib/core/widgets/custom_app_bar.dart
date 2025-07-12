import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key, required this.appTitle, this.action});
  final String appTitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 30, top: 60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              appTitle,
              style: const TextStyle(
                fontSize: 34,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}
