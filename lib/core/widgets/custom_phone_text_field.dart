import 'package:flutter/material.dart';
import 'package:whatsapp_clone/core/constants.dart';

class CustomPhoneTextField extends StatelessWidget {
  const CustomPhoneTextField({
    super.key,
    required this.phoneController,
    required this.codeController,
  });
  final TextEditingController phoneController;
  final TextEditingController codeController;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: TextFormField(
              controller: codeController,
              keyboardType: TextInputType.phone,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                isDense: true,
                hintText: '+20',
                hintStyle: TextStyle(fontSize: 14),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: kLightPrimaryColor),
                ),
                disabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: kLightPrimaryColor),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: kLightPrimaryColor),
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                isDense: true,
                hintStyle: TextStyle(fontSize: 14),
                hintText: 'Phone Number',
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: kLightPrimaryColor),
                ),
                disabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: kLightPrimaryColor),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: kLightPrimaryColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
