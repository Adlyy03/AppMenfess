import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/neo_brutalism_theme.dart';

class InputBox extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;

  const InputBox({
    super.key,
    required this.controller,
    this.hintText = 'Tulis sesuatu...',
    this.maxLines = 5,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: NeoBrutalismTheme.black,
        height: 1.5,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.spaceGrotesk(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: NeoBrutalismTheme.black.withOpacity(0.4),
        ),
        filled: true,
        fillColor: NeoBrutalismTheme.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoBrutalismTheme.borderRadius),
          borderSide: const BorderSide(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoBrutalismTheme.borderRadius),
          borderSide: const BorderSide(
            color: NeoBrutalismTheme.black,
            width: NeoBrutalismTheme.borderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoBrutalismTheme.borderRadius),
          borderSide: const BorderSide(
            color: NeoBrutalismTheme.blue,
            width: NeoBrutalismTheme.borderWidth,
          ),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}
