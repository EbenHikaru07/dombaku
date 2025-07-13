
import 'package:flutter/material.dart';
import 'package:dombaku/style.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final bool hasCenterFAB;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    this.hasCenterFAB = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: BottomAppBar(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        height: 55,
        color: Color(0xff042E22).withOpacity(0.95),
        shape: hasCenterFAB ? const CircularNotchedRectangle() : null,
        notchMargin: hasCenterFAB ? 4 : 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(
              context,
              icon: Icons.home_rounded,
              index: 0,
              label: 'Beranda',
            ),
            _buildNavItem(
              context,
              icon: Icons.assignment_rounded,
              index: 1,
              label: 'Pendataan',
            ),
            if (hasCenterFAB) const SizedBox(width: 30),
            _buildNavItem(
              context,
              icon: Icons.bar_chart_rounded,
              index: 2,
              label: 'Laporan',
            ),
            _buildNavItem(
              context,
              icon: Icons.health_and_safety_rounded,
              index: 3,
              label: 'Kesehatan',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required int index,
    required String label,
  }) {
    final isSelected = selectedIndex == index;
    final color = isSelected ? Colors.white : Colors.grey.withOpacity(0.8);
    final style =
        isSelected
            ? BottomBarTextStyle.selectedLabelStyle
            : BottomBarTextStyle.unselectedLabelStyle;

    return Expanded(
      child: Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: () => onItemTapped(index),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [Icon(icon, color: color), Text(label, style: style)],
              ),
            ),
          ),

          if (index != 3 && !(hasCenterFAB && index == 1))
            Positioned(
              right: 0,
              top: 15,
              bottom: 15,
              child: Container(width: 1.5, color: Colors.white24),
            ),
        ],
      ),
    );
  }
}
