import 'package:flutter/material.dart';

class JeanCharacter extends StatelessWidget {
  final double size;
  final bool showTablet;
  final bool showPencil;

  const JeanCharacter({
    super.key,
    this.size = 100,
    this.showTablet = true,
    this.showPencil = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Main body (pink blob-like figure)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.pink[300],
                borderRadius: BorderRadius.circular(size * 0.3),
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

          // Glasses
          Positioned(
            top: size * 0.3,
            left: size * 0.25,
            child: Container(
              width: size * 0.2,
              height: size * 0.15,
              decoration: BoxDecoration(
                color: Colors.pink[200],
                borderRadius: BorderRadius.circular(size * 0.075),
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
          Positioned(
            top: size * 0.3,
            right: size * 0.25,
            child: Container(
              width: size * 0.2,
              height: size * 0.15,
              decoration: BoxDecoration(
                color: Colors.pink[200],
                borderRadius: BorderRadius.circular(size * 0.075),
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),

          // Eyes
          Positioned(
            top: size * 0.35,
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
            top: size * 0.35,
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

          // Cheeks
          Positioned(
            top: size * 0.45,
            left: size * 0.2,
            child: Container(
              width: size * 0.12,
              height: size * 0.08,
              decoration: BoxDecoration(
                color: Colors.pink[200],
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: size * 0.45,
            right: size * 0.2,
            child: Container(
              width: size * 0.12,
              height: size * 0.08,
              decoration: BoxDecoration(
                color: Colors.pink[200],
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Smile
          Positioned(
            bottom: size * 0.3,
            left: size * 0.35,
            child: Container(
              width: size * 0.3,
              height: size * 0.15,
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border(
                  bottom: BorderSide(color: Colors.pink[600]!, width: 3),
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(size * 0.15),
                  bottomRight: Radius.circular(size * 0.15),
                ),
              ),
            ),
          ),

          // Lower body (blue)
          Positioned(
            bottom: 0,
            left: size * 0.1,
            right: size * 0.1,
            height: size * 0.4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue[300],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(size * 0.2),
                  bottomRight: Radius.circular(size * 0.2),
                ),
              ),
            ),
          ),

          // Arms
          Positioned(
            top: size * 0.5,
            left: size * 0.05,
            child: Container(
              width: size * 0.12,
              height: size * 0.12,
              decoration: BoxDecoration(
                color: Colors.pink[300],
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: size * 0.5,
            right: size * 0.05,
            child: Container(
              width: size * 0.12,
              height: size * 0.12,
              decoration: BoxDecoration(
                color: Colors.pink[300],
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Tablet
          if (showTablet)
            Positioned(
              bottom: size * 0.6,
              right: size * 0.1,
              child: Container(
                width: size * 0.4,
                height: size * 0.25,
                decoration: BoxDecoration(
                  color: Colors.orange[400],
                  borderRadius: BorderRadius.circular(size * 0.05),
                  border: Border.all(color: Colors.orange[600]!, width: 2),
                ),
                child: Center(
                  child: Container(
                    width: size * 0.3,
                    height: size * 0.15,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(size * 0.02),
                    ),
                  ),
                ),
              ),
            ),

          // Pencil
          if (showPencil)
            Positioned(
              bottom: size * 0.55,
              left: size * 0.15,
              child: Container(
                width: size * 0.08,
                height: size * 0.3,
                decoration: BoxDecoration(
                  color: Colors.yellow[600],
                  borderRadius: BorderRadius.circular(size * 0.04),
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: size * 0.08,
                    height: size * 0.08,
                    decoration: BoxDecoration(
                      color: Colors.orange[600],
                      borderRadius: BorderRadius.circular(size * 0.04),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
