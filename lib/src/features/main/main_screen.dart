import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myapp/src/common/theme/dark_feed_colors.dart';
import 'package:myapp/src/features/plans/presentation/feed/screens/feed_screen.dart';
import 'package:myapp/src/features/explore/explore_screen.dart';
import 'package:myapp/src/features/alerts/alerts_screen.dart';
import 'package:myapp/src/features/profile/profile_screen.dart';
import 'package:myapp/src/features/notifications/data/notification_repository.dart';

/// Pantalla principal con bottom navigation (Dark Mode)
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    FeedScreen(),
    ExploreScreen(),
    SizedBox(), // Placeholder para Crear (abre pantalla aparte)
    AlertsScreen(),
    ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    if (index == 2) {
      // Crear plan - navegar a pantalla separada
      context.push('/create-plan');
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DarkFeedColors.background,
      body: IndexedStack(
        index: _currentIndex == 2 ? 0 : _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: DarkFeedColors.background,
          border: Border(
            top: BorderSide(
              color: DarkFeedColors.borderSubtle,
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Inicio',
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.explore_outlined,
                  activeIcon: Icons.explore,
                  label: 'Explorar',
                ),
                _buildCreateButton(),
                _buildAlertsNavItem(),
                _buildNavItem(
                  index: 4,
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Perfil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    bool showBadge = false,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Icono con gradiente si esta activo
                if (isSelected)
                  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return DarkFeedColors.primaryGradient
                          .createShader(bounds);
                    },
                    blendMode: BlendMode.srcIn,
                    child: Icon(
                      activeIcon,
                      color: Colors.white,
                      size: 26,
                    ),
                  )
                else
                  Icon(
                    icon,
                    color: DarkFeedColors.textSecondary,
                    size: 26,
                  ),
                // Badge de notificaciones
                if (showBadge)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: DarkFeedColors.greenEmerald,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            // Label con gradiente si esta activo
            if (isSelected)
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return DarkFeedColors.primaryGradient.createShader(bounds);
                },
                blendMode: BlendMode.srcIn,
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              )
            else
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: DarkFeedColors.textSecondary,
                ),
              ),
            // Dot indicador verde bajo el tab activo
            const SizedBox(height: 4),
            if (isSelected)
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: DarkFeedColors.greenEmerald,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsNavItem() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return _buildNavItem(
        index: 3,
        icon: Icons.notifications_outlined,
        activeIcon: Icons.notifications,
        label: 'Alertas',
      );
    }
    final unreadAsync = ref.watch(unreadCountProvider(userId));
    final unreadCount = unreadAsync.valueOrNull ?? 0;
    final isSelected = _currentIndex == 3;

    return GestureDetector(
      onTap: () => _onTabTapped(3),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                if (isSelected)
                  ShaderMask(
                    shaderCallback: (b) =>
                        DarkFeedColors.primaryGradient.createShader(b),
                    blendMode: BlendMode.srcIn,
                    child: const Icon(Icons.notifications,
                        color: Colors.white, size: 26),
                  )
                else
                  const Icon(Icons.notifications_outlined,
                      color: DarkFeedColors.textSecondary, size: 26),
                // Badge con conteo real
                if (unreadCount > 0)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: DarkFeedColors.errorRed,
                        shape: BoxShape.circle,
                      ),
                      constraints:
                          const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        unreadCount > 99 ? '99+' : '$unreadCount',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            if (isSelected)
              ShaderMask(
                shaderCallback: (b) =>
                    DarkFeedColors.primaryGradient.createShader(b),
                blendMode: BlendMode.srcIn,
                child: Text('Alertas',
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              )
            else
              Text('Alertas',
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: DarkFeedColors.textSecondary)),
            const SizedBox(height: 4),
            if (isSelected)
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: DarkFeedColors.greenEmerald,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return GestureDetector(
      onTap: () => _onTabTapped(2),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: DarkFeedColors.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: DarkFeedColors.gradientOrange.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}
