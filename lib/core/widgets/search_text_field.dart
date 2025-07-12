import 'package:flutter/material.dart';

class SearchTextField extends StatelessWidget {
  const SearchTextField({
    super.key,
    required this.onChanged,
    this.hintText = 'Search',
    this.prefixIcon = const Icon(Icons.search, size: 26),
  });

  final Function(String) onChanged;
  final String hintText;
  final Widget prefixIcon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 45,
        child: TextField(
          decoration: InputDecoration(
            fillColor: Colors.grey[300],
            filled: true,
            hintText: hintText,
            contentPadding: const EdgeInsets.all(0),
            prefixIcon: prefixIcon,
            hintStyle: TextStyle(fontSize: 18, color: Colors.grey[700]),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
} 