import 'package:flutter/material.dart';

class AlbertCharacter extends StatelessWidget {
  final double size;
  final bool showGlasses;
  final bool showMustache;

  const AlbertCharacter({
    super.key,
    this.size = 120,
    this.showGlasses = true,
    this.showMustache = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Main body
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF90EE90), // Light green
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),

          // Hair/hat (white fluffy shapes)
          if (showGlasses) ...[
            Positioned(
              top: size * 0.05,
              left: size * 0.15,
              child: Container(
                width: size * 0.25,
                height: size * 0.2,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(size * 0.1),
                ),
              ),
            ),
            Positioned(
              top: size * 0.08,
              right: size * 0.15,
              child: Container(
                width: size * 0.2,
                height: size * 0.15,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(size * 0.1),
                ),
              ),
            ),
          ],

          // Glasses
          if (showGlasses) ...[
            Positioned(
              top: size * 0.35,
              left: size * 0.25,
              child: Container(
                width: size * 0.2,
                height: size * 0.15,
                decoration: BoxDecoration(
                  color: Colors.pink[300],
                  borderRadius: BorderRadius.circular(size * 0.075),
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
            Positioned(
              top: size * 0.35,
              right: size * 0.25,
              child: Container(
                width: size * 0.2,
                height: size * 0.15,
                decoration: BoxDecoration(
                  color: Colors.pink[300],
                  borderRadius: BorderRadius.circular(size * 0.075),
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],

          // Eyes
          Positioned(
            top: size * 0.4,
            left: size * 0.35,
            child: Container(
              width: size * 0.08,
              height: size * 0.08,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: size * 0.4,
            right: size * 0.35,
            child: Container(
              width: size * 0.08,
              height: size * 0.08,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Mustache
          if (showMustache)
            Positioned(
              bottom: size * 0.25,
              left: size * 0.2,
              child: Container(
                width: size * 0.6,
                height: size * 0.08,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(size * 0.04),
                ),
              ),
            ),

          // Shirt
          Positioned(
            bottom: 0,
            left: size * 0.1,
            right: size * 0.1,
            height: size * 0.4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.lightBlue[300],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(size * 0.1),
                  bottomRight: Radius.circular(size * 0.1),
                ),
              ),
            ),
          ),

          // Bow tie
          Positioned(
            bottom: size * 0.35,
            left: size * 0.4,
            child: Container(
              width: size * 0.2,
              height: size * 0.12,
              decoration: BoxDecoration(
                color: Colors.blue[600],
                borderRadius: BorderRadius.circular(size * 0.06),
              ),
              child: Center(
                child: Container(
                  width: size * 0.06,
                  height: size * 0.06,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),

          // Arms
          Positioned(
            top: size * 0.5,
            left: size * 0.05,
            child: Container(
              width: size * 0.15,
              height: size * 0.15,
              decoration: BoxDecoration(
                color: const Color(0xFF90EE90),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: size * 0.5,
            right: size * 0.05,
            child: Container(
              width: size * 0.15,
              height: size * 0.15,
              decoration: BoxDecoration(
                color: const Color(0xFF90EE90),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
