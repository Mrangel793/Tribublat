import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// TabBar para las secciones del feed
class FeedTabBar extends StatelessWidget {
  final TabController controller;

  const FeedTabBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
      ),
      child: TabBar(
        controller: controller,
        labelColor: const Color(0xFF9B59B6),
        unselectedLabelColor: const Color(0xFF636E72),
        indicatorColor: const Color(0xFF9B59B6),
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(
            icon: Icon(Icons.star, size: 20),
            text: 'Para ti',
            iconMargin: EdgeInsets.only(bottom: 4),
          ),
          Tab(
            icon: Icon(Icons.location_on, size: 20),
            text: 'Cerca',
            iconMargin: EdgeInsets.only(bottom: 4),
          ),
          Tab(
            icon: Icon(Icons.bolt, size: 20),
            text: 'Instantaneos',
            iconMargin: EdgeInsets.only(bottom: 4),
          ),
          Tab(
            icon: Icon(Icons.event_note, size: 20),
            text: 'Mis planes',
            iconMargin: EdgeInsets.only(bottom: 4),
          ),
        ],
      ),
    );
  }
}
