import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'reviews_page.dart'; // Eliminado
// import 'signup_page.dart'; // Eliminado
import 'package:image_picker/image_picker.dart';

class VisitorPage extends StatefulWidget {
  const VisitorPage({super.key});

  @override
  State<VisitorPage> createState() => _VisitorPageState();
}

class _VisitorPageState extends State<VisitorPage> {
  final visitasRef = FirebaseFirestore.instance.collection('visitas');
  bool isUploading = false;
  final picker = ImagePicker();
  final TextEditingController nombreVisitanteController = TextEditingController();
  final TextEditingController motivoVisitaController = TextEditingController();
  DateTime? horaVisitaSeleccionada;
  String? fotoVisitanteUrl;

  @override
  void dispose() {
    nombreVisitanteController.dispose();
    motivoVisitaController.dispose();
    super.dispose();
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _pickFotoVisitante({required ImageSource source}) async {
    final XFile? image = await picker.pickImage(source: source);
    if (image == null) return;
    // Validar tipo de archivo
    final ext = image.name.split('.').last.toLowerCase();
    if (!(ext == 'jpg' || ext == 'jpeg' || ext == 'png')) {
      _showSnackBar('Solo se permiten imágenes JPG o PNG');
      return;
    }
    final imageBytes = await image.readAsBytes();
    final sizeMB = imageBytes.length / (1024 * 1024);
    if (sizeMB > 5.0) {
      _showSnackBar('La imagen excede el tamaño máximo de 5MB');
      return;
    }
    setState(() { isUploading = true; });
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      await Supabase.instance.client.storage
        .from('uploads')
        .uploadBinary(fileName, imageBytes);
      final publicUrl = Supabase.instance.client.storage
        .from('uploads')
        .getPublicUrl(fileName);
      setState(() { fotoVisitanteUrl = publicUrl; });
      _showSnackBar('Imagen subida correctamente');
    } catch (e) {
      _showSnackBar('Error al subir imagen: $e');
    } finally {
      setState(() { isUploading = false; });
    }
  }

  void _mostrarFormularioNuevoVisitante() {
    nombreVisitanteController.clear();
    motivoVisitaController.clear();
    horaVisitaSeleccionada = null;
    fotoVisitanteUrl = null;
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white.withOpacity(0.95),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Nuevo visitante', style: TextStyle(color: Color(0xFF4F8FFF), fontWeight: FontWeight.bold, fontSize: 22)),
                  const SizedBox(height: 18),
                  TextField(
                    controller: nombreVisitanteController,
                    decoration: InputDecoration(
                      labelText: 'Nombre del visitante',
                      prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF4F8FFF)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: motivoVisitaController,
                    decoration: InputDecoration(
                      labelText: 'Motivo de la visita',
                      prefixIcon: const Icon(Icons.info_outline, color: Color(0xFF4F8FFF)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          horaVisitaSeleccionada == null
                            ? 'Hora: No seleccionada'
                            : 'Hora: ${DateFormat('yyyy-MM-dd HH:mm').format(horaVisitaSeleccionada!)}',
                          style: const TextStyle(fontSize: 15, color: Color(0xFF4F8FFF)),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.access_time, color: Color(0xFF4F8FFF)),
                        onPressed: () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: now,
                            firstDate: DateTime(now.year - 1),
                            lastDate: DateTime(now.year + 1),
                          );
                          if (picked != null) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(now),
                            );
                            setState(() {
                              horaVisitaSeleccionada = DateTime(
                                picked.year, picked.month, picked.day,
                                time?.hour ?? 0, time?.minute ?? 0,
                              );
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  fotoVisitanteUrl != null
                    ? Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFF4F8FFF), width: 4),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.network(
                                fotoVisitanteUrl!,
                                height: 120,
                                width: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      )
                    : const SizedBox.shrink(),
                  ElevatedButton.icon(
                    onPressed: isUploading ? null : () async {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                        ),
                        builder: (context) {
                          return SafeArea(
                            child: Wrap(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.photo_camera, color: Color(0xFF4F8FFF)),
                                  title: const Text('Tomar foto con la cámara'),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    await _pickFotoVisitante(source: ImageSource.camera);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.photo_library, color: Color(0xFF4F8FFF)),
                                  title: const Text('Elegir de la galería'),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    await _pickFotoVisitante(source: ImageSource.gallery);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.photo_camera, color: Colors.white),
                    label: const Text('Subir foto'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F8FFF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar', style: TextStyle(color: Color(0xFF4F8FFF), fontWeight: FontWeight.bold)),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (nombreVisitanteController.text.isEmpty || motivoVisitaController.text.isEmpty || (horaVisitaSeleccionada == null && fotoVisitanteUrl == null)) {
                            _showSnackBar('Todos los campos son obligatorios');
                            return;
                          }
                          await visitasRef.add({
                            'name': nombreVisitanteController.text,
                            'motivo': motivoVisitaController.text,
                            'hora': (horaVisitaSeleccionada ?? DateTime.now()).toIso8601String(),
                            'foto': fotoVisitanteUrl ?? '',
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const LinearGradient(
                            colors: [Color(0xFF4F8FFF), Color(0xFFB6E0FE)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ).createShader(const Rect.fromLTWH(0, 0, 200, 50)) != null ? null : null, // fallback
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 4,
                        ).copyWith(
                          backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                            return const Color(0xFF4F8FFF);
                          }),
                        ),
                        child: const Text('Guardar', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _cerrarSesion() async {
    try {
      await Supabase.instance.client.auth.signOut();
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      _showSnackBar('Error al cerrar sesión: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.meeting_room, color: Colors.white, size: 28),
            const SizedBox(width: 10),
            const Text('Visitas Oficina', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _cerrarSesion,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Fondo decorativo con gradiente y formas
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4F8FFF), Color(0xFFB6E0FE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            right: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 90),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  children: [
                    const Text(
                      'Registro y control de visitantes',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Gestiona el acceso a tu oficina de forma moderna y visual. Cada registro incluye nombre, motivo, hora y foto.',
                      style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.9)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 16,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: visitasRef.orderBy('hora', descending: true).snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final visitantes = snapshot.data!.docs;
                      if (visitantes.isEmpty) {
                        return const Center(child: Text('No hay visitantes registrados', style: TextStyle(fontSize: 18, color: Color(0xFF4F8FFF))));
                      }
                      return ListView.builder(
                        itemCount: visitantes.length,
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                        itemBuilder: (context, index) {
                          final visitante = visitantes[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFB6E0FE), Color(0xFF4F8FFF).withOpacity(0.85)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                              leading: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.18),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  backgroundImage: (visitante['foto'] != null && visitante['foto'] != '')
                                    ? NetworkImage(visitante['foto'])
                                    : null,
                                  backgroundColor: Colors.white,
                                  radius: 32,
                                  child: (visitante['foto'] == null || visitante['foto'] == '')
                                    ? const Icon(Icons.person, size: 32, color: Color(0xFF4F8FFF))
                                    : null,
                                ),
                              ),
                              title: Text(
                                visitante['name'] ?? 'Sin nombre',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1A237E)),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.info_outline, size: 18, color: Color(0xFF4F8FFF)),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text('Motivo: ${visitante['motivo'] ?? 'Sin motivo'}', style: const TextStyle(fontSize: 15, color: Color(0xFF1A237E))),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time, size: 18, color: Color(0xFF4F8FFF)),
                                        const SizedBox(width: 6),
                                        Text(
                                          visitante['hora'] != null
                                            ? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(visitante['hora']))
                                            : 'Sin hora',
                                          style: const TextStyle(fontSize: 15, color: Color(0xFF1A237E)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarFormularioNuevoVisitante,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Agregar visitante'),
        tooltip: 'Agregar nuevo visitante',
        backgroundColor: const Color(0xFF4F8FFF),
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}