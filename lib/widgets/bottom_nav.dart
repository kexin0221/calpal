import 'dart:ui';
import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int index;
  final Function(int) onTap;

  const BottomNav({
    super.key,
    required this.index,
    required this.onTap,
  });

  Widget navItem({
    required IconData icon,
    required String text,
    required bool selected,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? Colors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: selected ? Colors.white : Colors.black54,
              ),
              const SizedBox(height: 3),
              Text(
                text,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : Colors.black54,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 74,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.72),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.55),
            ),
          ),
          child: Row(
            children: [
              navItem(
                icon: Icons.menu_book_rounded,
                text: "热量库",
                selected: index == 0,
                onPressed: () => onTap(0),
              ),
              navItem(
                icon: Icons.add_circle_outline_rounded,
                text: "品牌",
                selected: index == 1,
                onPressed: () => onTap(1),
              ),
              navItem(
                icon: Icons.casino_outlined,
                text: "转盘",
                selected: index == 2,
                onPressed: () => onTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}