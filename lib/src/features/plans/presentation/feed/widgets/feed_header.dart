import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/src/common/theme/dark_feed_colors.dart';
import 'package:myapp/src/common/widgets/base64_image_widget.dart';

/// Header del feed con saludo, búsqueda y filtros (dark mode)
class FeedHeader extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) onSearch;
  final VoidCallback? onFilterTap;
  final int activeFiltersCount;
  final String? userName;
  final String? userPhotoBase64;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAvatarTap;
  final int notificationCount;

  const FeedHeader({
    super.key,
    required this.searchController,
    required this.onSearch,
    this.onFilterTap,
    this.activeFiltersCount = 0,
    this.userName,
    this.userPhotoBase64,
    this.onNotificationTap,
    this.onAvatarTap,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DarkFeedColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: logo, search icon, notification bell, avatar ──
          _buildTopRow(),

          const SizedBox(height: 16),

          // ── Greeting ──
          _buildGreeting(),

          const SizedBox(height: 16),

          // ── Search bar ──
          _buildSearchBar(),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Top row
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildTopRow() {
    return Row(
      children: [
        // Logo "Tribulat" with gradient shader mask
        ShaderMask(
          shaderCallback: (Rect bounds) {
            return const LinearGradient(
              colors: [
                DarkFeedColors.gradientOrange,
                DarkFeedColors.gradientViolet,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: Text(
            'Tribulat',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white, // gets masked by shader
            ),
          ),
        ),

        const Spacer(),

        // Search icon
        IconButton(
          onPressed: () {
            // Scroll / focus search bar — no-op placeholder
          },
          icon: const Icon(
            Icons.search,
            color: DarkFeedColors.textSecondary,
            size: 24,
          ),
        ),

        // Notification bell with badge
        _buildNotificationBell(),

        const SizedBox(width: 8),

        // User avatar with gradient border
        _buildAvatar(),
      ],
    );
  }

  Widget _buildNotificationBell() {
    return GestureDetector(
      onTap: onNotificationTap,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          children: [
            const Center(
              child: Icon(
                Icons.notifications_outlined,
                color: DarkFeedColors.textSecondary,
                size: 26,
              ),
            ),
            if (notificationCount > 0)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: DarkFeedColors.greenEmerald,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Center(
                    child: Text(
                      notificationCount > 99
                          ? '99+'
                          : '$notificationCount',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    ImageProvider? avatarImage;
    if (userPhotoBase64 != null && userPhotoBase64!.isNotEmpty) {
      avatarImage = smartImageProvider(userPhotoBase64!);
    }

    return GestureDetector(
      onTap: onAvatarTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: DarkFeedColors.primaryGradient,
        ),
        padding: const EdgeInsets.all(2), // gradient border width
        child: CircleAvatar(
          radius: 18,
          backgroundColor: DarkFeedColors.cardBackground,
          backgroundImage: avatarImage,
          child: avatarImage == null
              ? const Icon(
                  Icons.person,
                  color: DarkFeedColors.textSecondary,
                  size: 20,
                )
              : null,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Greeting
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildGreeting() {
    final displayName = userName ?? 'Explorador';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hola, $displayName \u{1F44B}',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: DarkFeedColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '\u00BFQu\u00E9 plan tienes hoy?',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: DarkFeedColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Search bar
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: DarkFeedColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DarkFeedColors.borderSubtle),
      ),
      child: Row(
        children: [
          // Text field (expanded)
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: onSearch,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: DarkFeedColors.textPrimary,
              ),
              cursorColor: DarkFeedColors.gradientOrange,
              decoration: InputDecoration(
                hintText: 'Buscar planes...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: DarkFeedColors.textSecondary,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: DarkFeedColors.textSecondary,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
              ),
            ),
          ),

          // Clear button (visible when text is not empty)
          if (searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                searchController.clear();
                onSearch('');
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  Icons.close,
                  color: DarkFeedColors.textSecondary,
                  size: 18,
                ),
              ),
            ),

          // Filter button with badge
          if (onFilterTap != null) _buildFilterButton(),

          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
    return GestureDetector(
      onTap: onFilterTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: activeFiltersCount > 0
              ? DarkFeedColors.gradientViolet.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: activeFiltersCount > 0
                ? DarkFeedColors.gradientViolet
                : DarkFeedColors.borderSubtle,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                Icons.tune,
                color: activeFiltersCount > 0
                    ? DarkFeedColors.gradientViolet
                    : DarkFeedColors.textSecondary,
                size: 20,
              ),
            ),
            // Active filters badge
            if (activeFiltersCount > 0)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: DarkFeedColors.gradientViolet,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$activeFiltersCount',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
