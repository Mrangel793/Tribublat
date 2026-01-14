import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/src/common/widgets/base64_image_widget.dart';
import 'package:myapp/src/common/widgets/star_rating.dart';
import 'group_affinity_indicator.dart';

/// Fila con información del organizador
class OrganizerRow extends StatelessWidget {
  final String name;
  final String photo;
  final double rating;
  final int? totalEvents;
  final double? groupAffinity;

  const OrganizerRow({
    super.key,
    required this.name,
    required this.photo,
    required this.rating,
    this.totalEvents,
    this.groupAffinity,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar del organizador
        photo.isNotEmpty
            ? Base64CircleAvatar(base64String: photo, radius: 18)
            : CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFE0E0E0),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF636E72),
                  ),
                ),
              ),

        const SizedBox(width: 10),

        // Nombre y rating
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Organizado por ',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF636E72),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D3436),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  StarRating(rating: rating, size: 14),
                  if (totalEvents != null) ...[
                    const SizedBox(width: 4),
                    Text(
                      '($totalEvents eventos)',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: const Color(0xFF636E72),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        // Indicador de afinidad grupal
        if (groupAffinity != null) ...[
          const SizedBox(width: 8),
          GroupAffinityIndicator(affinity: groupAffinity!),
        ],
      ],
    );
  }
}
