import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/src/common/widgets/base64_image_widget.dart';

/// Header del feed con menú, búsqueda y avatar
class FeedHeader extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) onSearch;
  final VoidCallback onMenuTap;
  final VoidCallback onProfileTap;
  final String? userPhoto;

  const FeedHeader({
    super.key,
    required this.searchController,
    required this.onSearch,
    required this.onMenuTap,
    required this.onProfileTap,
    this.userPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Botón de menú
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(26),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: onMenuTap,
              icon: const Icon(
                Icons.menu,
                color: Color(0xFF2D3436),
              ),
              padding: EdgeInsets.zero,
            ),
          ),

          const SizedBox(width: 12),

          // Barra de búsqueda
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(26),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                onChanged: onSearch,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF2D3436),
                ),
                decoration: InputDecoration(
                  hintText: 'Buscar planes...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFFB2BEC3),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF636E72),
                    size: 20,
                  ),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: Color(0xFF636E72),
                            size: 18,
                          ),
                          onPressed: () {
                            searchController.clear();
                            onSearch('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Avatar del usuario
          GestureDetector(
            onTap: onProfileTap,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9B59B6).withAlpha(51),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: userPhoto != null && userPhoto!.isNotEmpty
                  ? Base64CircleAvatar(
                      base64String: userPhoto!,
                      radius: 22,
                    )
                  : const CircleAvatar(
                      radius: 22,
                      backgroundColor: Color(0xFF9B59B6),
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
