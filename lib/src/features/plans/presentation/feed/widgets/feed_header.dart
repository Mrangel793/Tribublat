import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/src/common/widgets/base64_image_widget.dart';

/// Header del feed con búsqueda, filtros y avatar
class FeedHeader extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) onSearch;
  final VoidCallback onProfileTap;
  final VoidCallback? onFilterTap;
  final String? userPhoto;
  final int activeFiltersCount;

  const FeedHeader({
    super.key,
    required this.searchController,
    required this.onSearch,
    required this.onProfileTap,
    this.onFilterTap,
    this.userPhoto,
    this.activeFiltersCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
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

          // Boton de filtros avanzados
          if (onFilterTap != null)
            GestureDetector(
              onTap: onFilterTap,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: activeFiltersCount > 0
                      ? const Color(0xFF9B59B6).withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: activeFiltersCount > 0
                        ? const Color(0xFF9B59B6)
                        : Colors.transparent,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha(26),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.tune,
                        color: activeFiltersCount > 0
                            ? const Color(0xFF9B59B6)
                            : const Color(0xFF636E72),
                        size: 22,
                      ),
                    ),
                    // Badge de filtros activos
                    if (activeFiltersCount > 0)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: Color(0xFF9B59B6),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$activeFiltersCount',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

          if (onFilterTap != null) const SizedBox(width: 12),

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
