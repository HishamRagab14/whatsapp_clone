import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whatsapp_clone/core/constants.dart';
import 'package:whatsapp_clone/core/data/countries.dart';
import 'package:whatsapp_clone/model/country_model.dart';
import 'package:whatsapp_clone/view_model/controllers/login_controller.dart';

class PhoneCountryInputDragDrop extends StatelessWidget {
  const PhoneCountryInputDragDrop({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginScreenController loginController =
        Get.find<LoginScreenController>();

    return SizedBox(
      width: double.infinity,
      child: Obx(
        () => DropdownButtonFormField<CountryModel>(
          value: loginController.selectedCountry,
          decoration: InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: kLightPrimaryColor, width: 1.5),
            ),
          ),
          icon: const Icon(Icons.arrow_drop_down, color: kLightPrimaryColor),
          onChanged: (CountryModel? newCountry) {
            if (newCountry != null) {
              loginController.updateSelectedCountry(newCountry);
            }
          },
          items:
              countries.map((country) {
                return DropdownMenuItem<CountryModel>(
                  value: country,
                  child: Row(
                    children: [
                      Text(country.flag),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.19),
                      Text(country.name),
                    ],
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}
