import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/src/features/profile/presentation/setup/controllers/profile_setup_controller.dart';
import 'package:myapp/src/features/profile/profile_screen.dart';
import 'package:myapp/src/features/user/data/user_repository.dart';
import 'package:myapp/src/features/user/domain/user_model.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nombreController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _edadController = TextEditingController();

  // State
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
    _tabController = TabController(length: 4, vsync: this);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final user = await ref.read(userRepositoryProvider).getUserProfile(userId);
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
    _tabController.dispose();
    _nombreController.dispose();
    _ciudadController.dispose();
    _edadController.dispose();
    super.dispose();
  }

  void _markAsChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
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
            content: const Text('Perfil actualizado correctamente'),
            backgroundColor: Colors.green[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red[400],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF2D3748)),
          onPressed: () {
            if (_hasChanges) {
              _showDiscardDialog();
            } else {
              context.pop();
            }
          },
        ),
        title: Text(
          'Editar perfil',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3748),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Guardar',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF9B59B6),
                    ),
                  ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF9B59B6),
          unselectedLabelColor: Colors.grey[500],
          indicatorColor: const Color(0xFF9B59B6),
          indicatorWeight: 3,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 13),
          tabs: const [
            Tab(text: 'Info'),
            Tab(text: 'Fotos'),
            Tab(text: 'Intereses'),
            Tab(text: 'Energía'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildInfoTab(),
            _buildPhotosTab(),
            _buildInterestsTab(),
            _buildEnergyTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombre
          _buildLabel('Nombre', Icons.person_outline),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nombreController,
            onChanged: (_) => _markAsChanged(),
            decoration: _inputDecoration('Tu nombre completo'),
            validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
          ),
          const SizedBox(height: 24),

          // Ciudad
          _buildLabel('Ciudad', Icons.location_on_outlined),
          const SizedBox(height: 8),
          TextFormField(
            controller: _ciudadController,
            onChanged: (value) {
              _markAsChanged();
              setState(() {
                _ciudadesSugeridas = CityConstants.search(value);
              });
            },
            decoration: _inputDecoration('Tu ciudad'),
            validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
          ),
          if (_ciudadesSugeridas.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                children: _ciudadesSugeridas.map((ciudad) {
                  return ListTile(
                    dense: true,
                    title: Text(ciudad),
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
          const SizedBox(height: 24),

          // Edad
          _buildLabel('Edad', Icons.cake_outlined),
          const SizedBox(height: 8),
          TextFormField(
            controller: _edadController,
            onChanged: (_) => _markAsChanged(),
            keyboardType: TextInputType.number,
            decoration: _inputDecoration('Tu edad'),
            validator: (v) {
              if (v?.isEmpty == true) return 'Requerido';
              final edad = int.tryParse(v!);
              if (edad == null || edad < 13 || edad > 120) {
                return 'Edad inválida';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosTab() {
    final totalPhotos = (_fotoBase64.isNotEmpty ? 1 : 0) + _fotosAdicionales.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto principal
          _buildLabel('Foto principal', Icons.star_outline),
          const SizedBox(height: 12),
          Center(
            child: GestureDetector(
              onTap: () => _pickMainPhoto(),
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF9B59B6),
                    width: 3,
                  ),
                  image: _fotoBase64.isNotEmpty
                      ? DecorationImage(
                          image: MemoryImage(base64Decode(_fotoBase64)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _fotoBase64.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add_a_photo,
                            size: 40,
                            color: Color(0xFF9B59B6),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Agregar foto',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF9B59B6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    : Stack(
                        children: [
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _fotoBase64 = '');
                                _markAsChanged();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Fotos adicionales
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLabel('Fotos adicionales', Icons.photo_library_outlined),
              Text(
                '${_fotosAdicionales.length}/4',
                style: GoogleFonts.inter(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _fotosAdicionales.length < 4
                ? _fotosAdicionales.length + 1
                : _fotosAdicionales.length,
            itemBuilder: (context, index) {
              if (index == _fotosAdicionales.length && _fotosAdicionales.length < 4) {
                return _buildAddPhotoCard();
              }
              return _buildPhotoCard(index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddPhotoCard() {
    return GestureDetector(
      onTap: _pickAdditionalPhoto,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF3E8FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF9B59B6).withOpacity(0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_rounded,
              size: 40,
              color: Color(0xFF9B59B6),
            ),
            const SizedBox(height: 8),
            Text(
              'Agregar foto',
              style: GoogleFonts.inter(
                color: const Color(0xFF9B59B6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCard(int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: MemoryImage(base64Decode(_fotosAdicionales[index])),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () {
              setState(() => _fotosAdicionales.removeAt(index));
              _markAsChanged();
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInterestsTab() {
    final filteredInterests = InterestConstants.interests;

    return Column(
      children: [
        // Contador
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _intereses.length >= 3
                ? const Color(0xFFE8F5E9)
                : const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                _intereses.length >= 3 ? Icons.check_circle : Icons.info_outline,
                color: _intereses.length >= 3 ? Colors.green[700] : Colors.orange[700],
              ),
              const SizedBox(width: 12),
              Text(
                '${_intereses.length} de mínimo 3 seleccionados (máx. 10)',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  color: _intereses.length >= 3 ? Colors.green[700] : Colors.orange[700],
                ),
              ),
            ],
          ),
        ),

        // Grid de intereses
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: filteredInterests.length,
            itemBuilder: (context, index) {
              final interest = filteredInterests[index];
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
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF9B59B6) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF9B59B6)
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(interest.emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          interest.nombre,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : const Color(0xFF2D3748),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEnergyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Cuál es tu energía social?',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Esto nos ayuda a recomendarte planes acordes a tu estilo',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          _buildEnergyOption(
            level: EnergyLevel.baja,
            emoji: '🌙',
            title: 'Tranquilo',
            description: 'Prefieres actividades relajadas con grupos pequeños',
            color: const Color(0xFF6C5CE7),
          ),
          const SizedBox(height: 16),

          _buildEnergyOption(
            level: EnergyLevel.media,
            emoji: '⚡',
            title: 'Equilibrado',
            description: 'Te adaptas bien a diferentes ambientes',
            color: const Color(0xFF4ECDC4),
          ),
          const SizedBox(height: 16),

          _buildEnergyOption(
            level: EnergyLevel.alta,
            emoji: '🔥',
            title: 'Activo',
            description: 'Te encanta la acción y los grupos grandes',
            color: const Color(0xFFFF6B9D),
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyOption({
    required EnergyLevel level,
    required String emoji,
    required String title,
    required String description,
    required Color color,
  }) {
    final isSelected = _nivelEnergia == level;

    return GestureDetector(
      onTap: () {
        setState(() => _nivelEnergia = level);
        _markAsChanged();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.2) : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 28)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : const Color(0xFF2D3748),
                    ),
                  ),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? color : Colors.transparent,
                border: Border.all(
                  color: isSelected ? color : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF9B59B6), size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3748),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF9B59B6), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
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

  void _showDiscardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '¿Descartar cambios?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Tienes cambios sin guardar. ¿Estás seguro de que quieres salir?',
          style: GoogleFonts.inter(color: Colors.grey[600]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Seguir editando',
              style: GoogleFonts.inter(
                color: const Color(0xFF9B59B6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: Text(
              'Descartar',
              style: GoogleFonts.inter(color: Colors.red[400]),
            ),
          ),
        ],
      ),
    );
  }
}
