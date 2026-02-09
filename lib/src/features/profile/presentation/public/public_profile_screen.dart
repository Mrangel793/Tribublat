import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myapp/src/common/theme/dark_feed_colors.dart';
import 'package:myapp/src/features/user/data/user_repository.dart';
import 'package:myapp/src/features/user/domain/interests_constants.dart';
import 'package:myapp/src/features/user/domain/user_model.dart';

class PublicProfileScreen extends ConsumerStatefulWidget {
  final String userId;
  const PublicProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<PublicProfileScreen> createState() =>
      _PublicProfileScreenState();
}

class _PublicProfileScreenState extends ConsumerState<PublicProfileScreen> {
  UserModel? _otherUser;
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final repo = ref.read(userRepositoryProvider);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    final results = await Future.wait([
      repo.getUserProfile(widget.userId),
      if (currentUserId != null) repo.getUserProfile(currentUserId),
    ]);

    if (mounted) {
      setState(() {
        _otherUser = results[0];
        if (results.length > 1) _currentUser = results[1];
        _isLoading = false;
      });
    }
  }

  int _calculateUserCompatibility(UserModel currentUser, UserModel otherUser) {
    final currentSet = currentUser.intereses.toSet();
    final otherSet = otherUser.intereses.toSet();
    final common = currentSet.intersection(otherSet).length;
    final total = currentSet.union(otherSet).length;
    final interestScore = total > 0 ? (common / total * 70).round() : 0;

    int energyScore = 0;
    if (currentUser.nivelEnergia == otherUser.nivelEnergia) {
      energyScore = 30;
    } else if ((currentUser.nivelEnergia.index - otherUser.nivelEnergia.index)
            .abs() ==
        1) {
      energyScore = 15;
    }

    return interestScore + energyScore;
  }

  String _compatibilityLabel(int score) {
    if (score >= 80) return 'Muy compatible';
    if (score >= 60) return 'Buena conexion';
    if (score >= 40) return 'Algo en comun';
    return 'Poco en comun';
  }

  bool _isOnline(DateTime? lastSeen) {
    if (lastSeen == null) return false;
    return DateTime.now().difference(lastSeen).inMinutes < 5;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: DarkFeedColors.background,
        body: Center(
          child: CircularProgressIndicator(
            color: DarkFeedColors.gradientOrange,
          ),
        ),
      );
    }

    final user = _otherUser;
    if (user == null) {
      return Scaffold(
        backgroundColor: DarkFeedColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Text(
            'Usuario no encontrado',
            style: GoogleFonts.inter(color: DarkFeedColors.textSecondary),
          ),
        ),
      );
    }

    final compatibility = _currentUser != null
        ? _calculateUserCompatibility(_currentUser!, user)
        : 0;

    return Scaffold(
      backgroundColor: DarkFeedColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // 1. Hero image
              _buildHeroSliver(user),
              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // 2. Compatibility + Energy
                      _buildCompatibilityRow(user, compatibility),
                      const SizedBox(height: 28),
                      // 3. Interests
                      _buildInterestsSection(user),
                      const SizedBox(height: 28),
                      // 4. Reviews
                      _buildReviewsSection(user),
                      const SizedBox(height: 28),
                      // 5. Gallery
                      if (user.fotosAdicionales.isNotEmpty) ...[
                        _buildGallerySection(user),
                        const SizedBox(height: 28),
                      ],
                      // Bottom padding for floating buttons
                      const SizedBox(height: 140),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // 6. Floating buttons
          _buildFloatingButtons(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 1. Hero Image SliverAppBar
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHeroSliver(UserModel user) {
    return SliverAppBar(
      expandedHeight: 350,
      pinned: true,
      backgroundColor: DarkFeedColors.background,
      leading: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 18),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () => _showOptionsSheet(),
          child: Container(
            margin: const EdgeInsets.all(8),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.more_horiz, color: Colors.white, size: 20),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Photo
            if (user.foto.isNotEmpty)
              Image.memory(
                base64Decode(user.foto),
                fit: BoxFit.cover,
              )
            else
              Container(
                color: DarkFeedColors.cardBackground,
                child: const Icon(Icons.person,
                    size: 100, color: DarkFeedColors.textSecondary),
              ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                    Colors.black,
                  ],
                  stops: const [0.0, 0.4, 0.75, 1.0],
                ),
              ),
            ),
            // Name + info overlay
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + verified
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.nombre,
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (user.verificado) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: DarkFeedColors.greenEmerald,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check,
                              color: Colors.white, size: 14),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Age + city + online
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: DarkFeedColors.textSecondary, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${user.edad} anos  •  ${user.ciudad}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: DarkFeedColors.textSecondary,
                        ),
                      ),
                      if (_isOnline(user.ultimaConexion)) ...[
                        const SizedBox(width: 12),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: DarkFeedColors.greenEmerald,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Online',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: DarkFeedColors.greenEmerald,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 2. Compatibility + Energy Row
  // ═══════════════════════════════════════════════════════════════
  Widget _buildCompatibilityRow(UserModel user, int compatibility) {
    return Row(
      children: [
        // Compatibility card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DarkFeedColors.cardBackground.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: DarkFeedColors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'COMPATIBILIDAD',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: DarkFeedColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return DarkFeedColors.primaryGradient
                        .createShader(bounds);
                  },
                  blendMode: BlendMode.srcIn,
                  child: Text(
                    '$compatibility%',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _compatibilityLabel(compatibility),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: DarkFeedColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Energy card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DarkFeedColors.cardBackground.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: DarkFeedColors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ENERGIA SOCIAL',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: DarkFeedColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _energyLabel(user.nivelEnergia),
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: DarkFeedColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(3, (i) {
                    final isActive = i <= user.nivelEnergia.index;
                    return Container(
                      width: 28,
                      height: 8,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: isActive
                            ? _energyColor(user.nivelEnergia)
                            : DarkFeedColors.borderSubtle,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _energyLabel(EnergyLevel level) {
    switch (level) {
      case EnergyLevel.baja:
        return 'Baja 🌙';
      case EnergyLevel.media:
        return 'Media ⚡';
      case EnergyLevel.alta:
        return 'Alta 🔥';
    }
  }

  Color _energyColor(EnergyLevel level) {
    switch (level) {
      case EnergyLevel.baja:
        return const Color(0xFF6C5CE7);
      case EnergyLevel.media:
        return const Color(0xFFFF8C42);
      case EnergyLevel.alta:
        return const Color(0xFFFF4757);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 3. Interests
  // ═══════════════════════════════════════════════════════════════
  Widget _buildInterestsSection(UserModel user) {
    final currentInterests = _currentUser?.intereses.toSet() ?? {};
    final interests = InterestsConstants.getInterestsByIds(user.intereses);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Row(
          children: [
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return DarkFeedColors.primaryGradient.createShader(bounds);
              },
              blendMode: BlendMode.srcIn,
              child:
                  const Icon(Icons.interests, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Text(
              'Intereses',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: DarkFeedColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Chips horizontal scroll
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: interests.map((interest) {
              final isCommon = currentInterests.contains(interest.id);
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _buildInterestChip(interest, isCommon),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildInterestChip(Interest interest, bool isCommon) {
    if (isCommon) {
      // Gradient border chip for common interests
      return Container(
        padding: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          gradient: DarkFeedColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: DarkFeedColors.gradientOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(18.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(interest.emoji, style: const TextStyle(fontSize: 15)),
              const SizedBox(width: 6),
              Text(
                interest.name,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Regular chip
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: DarkFeedColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DarkFeedColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(interest.emoji, style: const TextStyle(fontSize: 15)),
          const SizedBox(width: 6),
          Text(
            interest.name,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: DarkFeedColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 4. Reviews
  // ═══════════════════════════════════════════════════════════════
  Widget _buildReviewsSection(UserModel user) {
    final rating = user.reputacion;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return DarkFeedColors.primaryGradient.createShader(bounds);
              },
              blendMode: BlendMode.srcIn,
              child: const Icon(Icons.star_rounded,
                  size: 22, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Text(
              'Resenas',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: DarkFeedColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: DarkFeedColors.cardBackground.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: DarkFeedColors.borderSubtle),
          ),
          child: Row(
            children: [
              // Stars
              ...List.generate(5, (i) {
                if (i < rating.floor()) {
                  return const Icon(Icons.star_rounded,
                      color: Color(0xFFFFD700), size: 24);
                } else if (i < rating.ceil() && rating % 1 >= 0.5) {
                  return const Icon(Icons.star_half_rounded,
                      color: Color(0xFFFFD700), size: 24);
                }
                return Icon(Icons.star_outline_rounded,
                    color: DarkFeedColors.textSecondary.withOpacity(0.4),
                    size: 24);
              }),
              const SizedBox(width: 12),
              Text(
                rating.toStringAsFixed(1),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: DarkFeedColors.textPrimary,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'resenas',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: DarkFeedColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 5. Gallery
  // ═══════════════════════════════════════════════════════════════
  Widget _buildGallerySection(UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return DarkFeedColors.primaryGradient.createShader(bounds);
              },
              blendMode: BlendMode.srcIn,
              child: const Icon(Icons.photo_library_rounded,
                  size: 20, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Text(
              'Fotos',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: DarkFeedColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: user.fotosAdicionales.length,
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(
                base64Decode(user.fotosAdicionales[index]),
                fit: BoxFit.cover,
              ),
            );
          },
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 6. Floating Buttons
  // ═══════════════════════════════════════════════════════════════
  Widget _buildFloatingButtons() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              DarkFeedColors.background.withOpacity(0.0),
              DarkFeedColors.background,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Send message button
            GestureDetector(
              onTap: () {
                // TODO: Navigate to chat
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: DarkFeedColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: DarkFeedColors.gradientOrange.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_arrow_rounded,
                        color: Colors.white, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Enviar mensaje',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Common plans button (ghost)
            GestureDetector(
              onTap: () {
                // TODO: Navigate to common plans
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: DarkFeedColors.primaryGradient,
                ),
                child: Container(
                  margin: const EdgeInsets.all(1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14.5),
                  decoration: BoxDecoration(
                    color: DarkFeedColors.background,
                    borderRadius: BorderRadius.circular(14.5),
                  ),
                  child: Center(
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return DarkFeedColors.primaryGradient
                            .createShader(bounds);
                      },
                      blendMode: BlendMode.srcIn,
                      child: Text(
                        'Ver planes en comun',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
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

  // ═══════════════════════════════════════════════════════════════
  // Options sheet
  // ═══════════════════════════════════════════════════════════════
  void _showOptionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: DarkFeedColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: DarkFeedColors.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.flag_outlined,
                  color: DarkFeedColors.textSecondary),
              title: Text('Reportar usuario',
                  style: GoogleFonts.inter(color: DarkFeedColors.textPrimary)),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.block_outlined,
                  color: DarkFeedColors.errorRed),
              title: Text('Bloquear usuario',
                  style: GoogleFonts.inter(color: DarkFeedColors.errorRed)),
              onTap: () => Navigator.pop(ctx),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
