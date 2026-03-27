  import 'package:flutter/material.dart';
  import 'package:frontend/theme/app_colors.dart';
  import 'package:google_fonts/google_fonts.dart';

  class SwipeButton extends StatefulWidget {
    final VoidCallback onSwipeCompleted;
    final String text;

    const SwipeButton({
      super.key,
      required this.onSwipeCompleted,
      this.text = 'Swipe To Get Started',
    });

    @override
    State<SwipeButton> createState() => _SwipeButtonState();
  }

  class _SwipeButtonState extends State<SwipeButton> {
    double _dragPosition = 0;
    final double _buttonWidth = 342;
    final double _iconSize = 48;

    @override
    Widget build(BuildContext context) {
      return Container(
        width: _buttonWidth,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Text(
                  widget.text,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF94A3B8),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.43,
                  ),
                ),
              ),
            ),
            Positioned(
              left: _dragPosition + 8,
              top: 8,
              bottom: 8,
              child: GestureDetector(
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    _dragPosition += details.delta.dx;
                    if (_dragPosition < 0) _dragPosition = 0;
                    if (_dragPosition > _buttonWidth - _iconSize - 16) {
                      _dragPosition = _buttonWidth - _iconSize - 16;
                    }
                  });
                },
                onHorizontalDragEnd: (details) {
                  if (_dragPosition >= _buttonWidth - _iconSize - 25) {
                    widget.onSwipeCompleted();
                  }
                  setState(() {
                    _dragPosition = 0;
                  });
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryBrownGold,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.keyboard_double_arrow_right,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
