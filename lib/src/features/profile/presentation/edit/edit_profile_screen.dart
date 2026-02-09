import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/src/common/theme/dark_feed_colors.dart';
import 'package:myapp/src/features/plans/domain/city_constants.dart';
import 'package:myapp/src/features/user/data/user_repository.dart';
import 'package:myapp/src/features/user/domain/interests_constants.dart';
import 'package:myapp/src/features/user/domain/user_model.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _edadController = TextEditingController();

  final _nombreFocus = FocusNode();
  final _ciudadFocus = FocusNode();
  final _edadFocus = FocusNode();


  String _fotoBase64 = '';
  List<String> _fotosAdicionales = [];
  List<String> _intereses = [];
  EnergyLevel _nivelEnergia = EnergyLevel.media;
  bool _isLoading = false;
  bool _hasChanges = false;
  List<String> _ciudadesSugeridas = [];

  @override
  void initState() {
    super.initState();
    for (final fn in [_nombreFocus, _ciudadFocus, _edadFocus]) {
      fn.addListener(() => setState(() {}));
    }
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final user =
        await ref.read(userRepositoryProvider).getUserProfile(userId);
    if (user != null && mounted) {
      setState(() {
        _nombreController.text = user.nombre;
        _ciudadController.text = user.ciudad;
        _edadController.text = user.edad.toString();
        _fotoBase64 = user.foto;
        _fotosAdicionales = List.from(user.fotosAdicionales);
        _intereses = List.from(user.intereses);
        _nivelEnergia = user.nivelEnergia;
      });
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _ciudadController.dispose();
    _edadController.dispose();
    _nombreFocus.dispose();
    _ciudadFocus.dispose();
    _edadFocus.dispose();
    super.dispose();
  }

  void _markAsChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('Usuario no autenticado');

      final user = UserModel(
        id: userId,
        email: FirebaseAuth.instance.currentUser?.email ?? '',
        nombre: _nombreController.text.trim(),
        edad: int.tryParse(_edadController.text) ?? 18,
        ciudad: _ciudadController.text.trim(),
        foto: _fotoBase64,
        fotosAdicionales: _fotosAdicionales,
        intereses: _intereses,
        nivelEnergia: _nivelEnergia,
        fechaCreacion: DateTime.now(),
        ultimaConexion: DateTime.now(),
      );

      await ref.read(userRepositoryProvider).createUserProfile(user);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Perfil actualizado',
                style: GoogleFonts.inter(color: Colors.white)),
            backgroundColor: DarkFeedColors.greenEmerald,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e',
                style: GoogleFonts.inter(color: Colors.white)),
            backgroundColor: DarkFeedColors.errorRed,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickMainPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() => _fotoBase64 = base64Encode(bytes));
      _markAsChanged();
    }
  }

  Future<void> _pickAdditionalPhoto() async {
    if (_fotosAdicionales.length >= 4) return;
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() => _fotosAdicionales.add(base64Encode(bytes)));
      _markAsChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DarkFeedColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            _buildHeader(),

            // ── Scrollable content ──
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildPhotoSection(),
                      const SizedBox(height: 28),
                      _buildDivider(),
                      const SizedBox(height: 20),
                      _buildInfoFields(),
                      const SizedBox(height: 28),
                      _buildDivider(),
                      const SizedBox(height: 20),
                      _buildInterestsSection(),
                      const SizedBox(height: 28),
                      _buildDivider(),
                      const SizedBox(height: 20),
                      _buildEnergySection(),
                      const SizedBox(height: 40),
                    ],
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
  // Header
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (_hasChanges) {
                _showDiscardDialog();
              } else {
                context.pop();
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: DarkFeedColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: DarkFeedColors.borderSubtle),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: DarkFeedColors.textPrimary,
                size: 18,
              ),
            ),
          ),
          const Spacer(),
          Text(
            'Mi perfil',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: DarkFeedColors.textPrimary,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF10B981)),
                    ),
                  )
                : Text(
                    'Guardar',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF10B981),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Photos
  // ═══════════════════════════════════════════════════════════════
  Widget _buildPhotoSection() {
    return Column(
      children: [
        // Main photo with gradient border
        Center(
          child: GestureDetector(
            onTap: _pickMainPhoto,
            child: Stack(
              children: [
                Container(
                  width: 124,
                  height: 124,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF8C42), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: CircleAvatar(
                    radius: 59,
                    backgroundColor: DarkFeedColors.cardBackground,
                    backgroundImage: _fotoBase64.isNotEmpty
                        ? MemoryImage(base64Decode(_fotoBase64))
                        : null,
                    child: _fotoBase64.isEmpty
                        ? const Icon(Icons.person,
                            size: 50, color: DarkFeedColors.textSecondary)
                        : null,
                  ),
                ),
                // Camera button
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: DarkFeedColors.cardBackground,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: DarkFeedColors.borderSubtle, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt,
                        size: 18, color: DarkFeedColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Secondary photos row
        SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ..._fotosAdicionales.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: GestureDetector(
                    onLongPress: () {
                      setState(() => _fotosAdicionales.removeAt(entry.key));
                      _markAsChanged();
                    },
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: DarkFeedColors.surface,
                      backgroundImage:
                          MemoryImage(base64Decode(entry.value)),
                    ),
                  ),
                );
              }),
              if (_fotosAdicionales.length < 4)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: GestureDetector(
                    onTap: _pickAdditionalPhoto,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                        border: Border.all(
                          color: DarkFeedColors.textSecondary,
                          width: 1.5,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: const Icon(Icons.add,
                          color: DarkFeedColors.textSecondary, size: 24),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Info fields
  // ═══════════════════════════════════════════════════════════════
  Widget _buildInfoFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nombre
        _buildFieldLabel('Nombre'),
        const SizedBox(height: 8),
        _buildGlassField(
          controller: _nombreController,
          focusNode: _nombreFocus,
          hint: 'Tu nombre completo',
          onChanged: (_) => _markAsChanged(),
          validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
        ),

        const SizedBox(height: 20),

        // Edad y Ciudad en fila
        Row(
          children: [
            // Edad
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Edad'),
                  const SizedBox(height: 8),
                  _buildGlassField(
                    controller: _edadController,
                    focusNode: _edadFocus,
                    hint: '24',
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _markAsChanged(),
                    validator: (v) {
                      if (v?.isEmpty == true) return 'Req.';
                      final edad = int.tryParse(v!);
                      if (edad == null || edad < 13 || edad > 120) {
                        return 'Invalida';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Ciudad
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Ciudad'),
                  const SizedBox(height: 8),
                  _buildGlassField(
                    controller: _ciudadController,
                    focusNode: _ciudadFocus,
                    hint: 'Tu ciudad',
                    prefixIcon: Icons.location_on_outlined,
                    onChanged: (value) {
                      _markAsChanged();
                      setState(() {
                        _ciudadesSugeridas =
                            CityConstants.searchCities(value);
                      });
                    },
                    validator: (v) =>
                        v?.isEmpty == true ? 'Requerido' : null,
                  ),
                ],
              ),
            ),
          ],
        ),

        // City suggestions
        if (_ciudadesSugeridas.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: DarkFeedColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: DarkFeedColors.borderSubtle),
            ),
            constraints: const BoxConstraints(maxHeight: 150),
            child: ListView(
              shrinkWrap: true,
              children: _ciudadesSugeridas.map((ciudad) {
                return ListTile(
                  dense: true,
                  title: Text(ciudad,
                      style: GoogleFonts.inter(
                          color: DarkFeedColors.textPrimary, fontSize: 14)),
                  onTap: () {
                    _ciudadController.text = ciudad;
                    setState(() => _ciudadesSugeridas = []);
                    _markAsChanged();
                  },
                );
              }).toList(),
            ),
          ),
        ],

      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Interests
  // ═══════════════════════════════════════════════════════════════
  Widget _buildInterestsSection() {
    final allInterests = InterestsConstants.allInterests;

    // Show selected first
    final selected =
        allInterests.where((i) => _intereses.contains(i.id)).toList();
    final unselected =
        allInterests.where((i) => !_intereses.contains(i.id)).toList();
    final sorted = [...selected, ...unselected];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Row(
          children: [
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  colors: [Color(0xFFFF8C42), Color(0xFF8B5CF6)],
                ).createShader(bounds);
              },
              blendMode: BlendMode.srcIn,
              child: const Icon(Icons.interests, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Text(
              'Mis intereses',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: DarkFeedColors.textPrimary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Interest chips
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: sorted.map((interest) {
            final isSelected = _intereses.contains(interest.id);
            final canSelect = _intereses.length < 10 || isSelected;

            return GestureDetector(
              onTap: canSelect
                  ? () {
                      setState(() {
                        if (isSelected) {
                          _intereses.remove(interest.id);
                        } else {
                          _intereses.add(interest.id);
                        }
                      });
                      _markAsChanged();
                    }
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFFFF8C42), Color(0xFF8B5CF6)],
                        )
                      : null,
                  color: isSelected ? null : DarkFeedColors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? null
                      : Border.all(color: DarkFeedColors.borderSubtle),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(interest.emoji,
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      interest.name,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : DarkFeedColors.textSecondary,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.close, size: 14, color: Colors.white),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        // Add button
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            // Could show search/add dialog
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: DarkFeedColors.borderSubtle),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add,
                    size: 16, color: DarkFeedColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  'Anadir',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: DarkFeedColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Energy
  // ═══════════════════════════════════════════════════════════════
  Widget _buildEnergySection() {
    final energyIndex = _nivelEnergia == EnergyLevel.baja
        ? 0.0
        : _nivelEnergia == EnergyLevel.media
            ? 0.5
            : 1.0;

    final bgColor = _nivelEnergia == EnergyLevel.baja
        ? const Color(0xFF6C5CE7).withOpacity(0.08)
        : _nivelEnergia == EnergyLevel.media
            ? const Color(0xFFFF8C42).withOpacity(0.08)
            : const Color(0xFFFF4757).withOpacity(0.08);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DarkFeedColors.borderSubtle),
      ),
      child: Column(
        children: [
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('⚡', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'Energia social hoy',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: DarkFeedColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
              thumbColor: Colors.white,
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
              overlayColor: const Color(0xFFFF8C42).withOpacity(0.2),
              activeTrackColor: Colors.transparent,
              inactiveTrackColor: Colors.transparent,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Gradient track
                Container(
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF6C5CE7), // blue
                        Color(0xFFFF8C42), // orange
                        Color(0xFFFF4757), // red
                      ],
                    ),
                  ),
                ),
                Slider(
                  value: energyIndex,
                  onChanged: (value) {
                    setState(() {
                      if (value < 0.25) {
                        _nivelEnergia = EnergyLevel.baja;
                      } else if (value < 0.75) {
                        _nivelEnergia = EnergyLevel.media;
                      } else {
                        _nivelEnergia = EnergyLevel.alta;
                      }
                    });
                    _markAsChanged();
                  },
                  divisions: 2,
                  min: 0,
                  max: 1,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildEnergyLabel(
                '🌙',
                'Baja',
                const Color(0xFF6C5CE7),
                _nivelEnergia == EnergyLevel.baja,
              ),
              _buildEnergyLabel(
                '⚡',
                'Media',
                const Color(0xFFFF8C42),
                _nivelEnergia == EnergyLevel.media,
              ),
              _buildEnergyLabel(
                '🔥',
                'Alta',
                const Color(0xFFFF4757),
                _nivelEnergia == EnergyLevel.alta,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyLabel(
      String emoji, String label, Color color, bool isActive) {
    return Column(
      children: [
        Text(emoji, style: TextStyle(fontSize: isActive ? 24 : 18)),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive ? color : DarkFeedColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Shared widgets
  // ═══════════════════════════════════════════════════════════════
  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: DarkFeedColors.textSecondary,
      ),
    );
  }

  Widget _buildGlassField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    IconData? prefixIcon,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
    Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    final isFocused = focusNode.hasFocus;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: isFocused
            ? const LinearGradient(
                colors: [Color(0xFFFF8C42), Color(0xFF8B5CF6)])
            : null,
        border: isFocused
            ? null
            : Border.all(color: DarkFeedColors.borderSubtle),
        boxShadow: isFocused
            ? [
                BoxShadow(
                    color: const Color(0xFFFF8C42).withOpacity(0.15),
                    blurRadius: 12),
              ]
            : [],
      ),
      padding: isFocused ? const EdgeInsets.all(1.5) : EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          color: DarkFeedColors.cardBackground.withOpacity(0.6),
          borderRadius: BorderRadius.circular(isFocused ? 12.5 : 14),
        ),
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          onChanged: onChanged,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: DarkFeedColors.textPrimary,
          ),
          cursorColor: const Color(0xFFFF8C42),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
                fontSize: 15, color: const Color(0xFF6B7280)),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon,
                    color: isFocused
                        ? const Color(0xFFFF8C42)
                        : DarkFeedColors.textSecondary,
                    size: 20)
                : null,
            border: InputBorder.none,
            counterText: '',
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            errorStyle:
                GoogleFonts.inter(fontSize: 12, color: DarkFeedColors.errorRed),
          ),
          validator: validator,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: DarkFeedColors.borderSubtle.withOpacity(0.5),
    );
  }

  void _showDiscardDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: DarkFeedColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Descartar cambios?',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: DarkFeedColors.textPrimary,
          ),
        ),
        content: Text(
          'Tienes cambios sin guardar.',
          style: GoogleFonts.inter(color: DarkFeedColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Seguir editando',
              style: GoogleFonts.inter(
                color: const Color(0xFFFF8C42),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.pop();
            },
            child: Text(
              'Descartar',
              style: GoogleFonts.inter(color: DarkFeedColors.errorRed),
            ),
          ),
        ],
      ),
    );
  }
}
