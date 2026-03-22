import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:myapp/src/common/theme/dark_feed_colors.dart';
import 'package:myapp/src/features/reviews/data/review_repository.dart';
import 'package:myapp/src/features/reviews/domain/review_model.dart';

/// Bottom sheet para dejar una reseña con estrellas + comentario
class ReviewFormSheet extends ConsumerStatefulWidget {
  final String planId;
  final String planTitulo;

  const ReviewFormSheet({
    super.key,
    required this.planId,
    required this.planTitulo,
  });

  @override
  ConsumerState<ReviewFormSheet> createState() => _ReviewFormSheetState();
}

class _ReviewFormSheetState extends ConsumerState<ReviewFormSheet> {
  int _selectedRating = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  static const _ratingLabels = ['', 'Malo', 'Regular', 'Bueno', 'Muy bueno', '¡Excelente!'];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: DarkFeedColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: DarkFeedColors.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'Deja tu reseña',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: DarkFeedColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.planTitulo,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: DarkFeedColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Estrellas interactivas
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return GestureDetector(
                  onTap: () => setState(() => _selectedRating = starIndex),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      starIndex <= _selectedRating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 44,
                      color: starIndex <= _selectedRating
                          ? const Color(0xFFFFD700)
                          : DarkFeedColors.borderSubtle,
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),

          // Label de la calificación
          Center(
            child: Text(
              _selectedRating > 0
                  ? _ratingLabels[_selectedRating]
                  : 'Toca una estrella para calificar',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: _selectedRating > 0
                    ? FontWeight.w600
                    : FontWeight.normal,
                color: _selectedRating > 0
                    ? const Color(0xFFFFD700)
                    : DarkFeedColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Campo de comentario
          Container(
            decoration: BoxDecoration(
              color: DarkFeedColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: DarkFeedColors.borderSubtle),
            ),
            child: TextField(
              controller: _commentController,
              style: GoogleFonts.inter(
                  color: DarkFeedColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Cuéntanos cómo fue la experiencia... (opcional)',
                hintStyle: GoogleFonts.inter(
                  color: DarkFeedColors.textSecondary,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 4,
              maxLength: 300,
              buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                  Text(
                    '$currentLength/$maxLength',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: DarkFeedColors.textSecondary,
                    ),
                  ),
            ),
          ),
          const SizedBox(height: 20),

          // Botón publicar
          GestureDetector(
            onTap: (_selectedRating == 0 || _isSubmitting) ? null : _submitReview,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: _selectedRating > 0
                    ? DarkFeedColors.primaryGradient
                    : null,
                color: _selectedRating == 0 ? DarkFeedColors.borderSubtle : null,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(
                        'Publicar reseña',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitReview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _selectedRating == 0) return;

    setState(() => _isSubmitting = true);

    try {
      final review = ReviewModel(
        id: '',
        planId: widget.planId,
        userId: user.uid,
        userName: user.displayName ?? 'Usuario',
        userPhoto: user.photoURL ?? '',
        rating: _selectedRating,
        comentario: _commentController.text.trim(),
        fechaCreacion: DateTime.now(),
      );

      await ref.read(reviewRepositoryProvider).createReview(review);

      if (mounted) {
        Navigator.pop(context, true); // true = éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Reseña publicada!',
                style: GoogleFonts.inter(color: Colors.white)),
            backgroundColor: DarkFeedColors.greenEmerald,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString(),
                style: GoogleFonts.inter(color: Colors.white)),
            backgroundColor: DarkFeedColors.errorRed,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
