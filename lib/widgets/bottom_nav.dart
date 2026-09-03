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

  Widget item(IconData icon, String text, bool selected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: selected ? Colors.black : Colors.grey,
          size: 25,
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            color: selected ? Colors.black : Colors.grey,
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          height: 78,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.72),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () => onTap(0),
                child: item(Icons.menu_book, "热量库", index == 0),
              ),
              GestureDetector(
                onTap: () => onTap(1),
                child: item(Icons.add_circle_outline, "添加食物", index == 1),
              ),
              GestureDetector(
                onTap: () => onTap(2),
                child: item(Icons.casino_outlined, "转盘", index == 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}