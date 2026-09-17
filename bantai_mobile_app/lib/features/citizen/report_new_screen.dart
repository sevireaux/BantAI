import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../data/models/models.dart';
import '../../data/repositories/directory_repository.dart';
import '../../data/repositories/report_repository.dart';
import '../../widgets/shared_widgets.dart';
import 'citizen_report_detail_screen.dart';

/// The centerpiece screen: works identically whether the device is online
/// or offline. ReportRepository decides what actually happens on submit —
/// this screen only needs to react to SubmissionSynced vs.
/// SubmissionQueued, it never checks connectivity itself.
class ReportNewScreen extends StatefulWidget {
  const ReportNewScreen({super.key, this.embedded = false});

  /// true when shown as a bottom-nav tab (no back button needed in that case
  /// since it's not pushed on the navigation stack).
  final bool embedded;

  @override
  State<ReportNewScreen> createState() => _ReportNewScreenState();
}

class _ReportNewScreenState extends State<ReportNewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();

  List<ApiCategory> _categories = [];
  ApiCategory? _selectedCategory;
  Subcategory? _selectedSubcategory;

  List<PublicLgu> _lgus = [];
  PublicLgu? _selectedLgu;
  List<PublicBarangay> _barangays = [];
  PublicBarangay? _selectedBarangay;

  LatLng _pin = const LatLng(14.6760, 121.0437); // sensible default; overwritten by "use my location"
  GoogleMapController? _mapController;

  final List<File> _photos = [];
  bool _loadingDirectory = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadDirectory();
  }

  Future<void> _loadDirectory() async {
    final directory = context.read<DirectoryRepository>();
    final categories = await directory.getCategories();
    final lgus = await directory.getLgus();
    setState(() {
      _categories = categories;
      _lgus = lgus;
      if (lgus.length == 1) _selectedLgu = lgus.first; // only one LGU registered — skip asking
      _loadingDirectory = false;
    });
    if (_selectedLgu != null) _loadBarangays(_selectedLgu!.id);
  }

  Future<void> _loadBarangays(String lguId) async {
    final barangays = await context.read<DirectoryRepository>().getBarangays(lguId);
    setState(() {
      _barangays = barangays;
      _selectedBarangay = null;
    });
  }

  Future<void> _useCurrentLocation() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition();
      final latLng = LatLng(pos.latitude, pos.longitude);
      setState(() => _pin = latLng);
      _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
    } catch (_) {
      // Silently keep the default/manual pin — GPS may be unavailable
      // (common indoors); the citizen can still drop the pin manually.
    }
  }

  Future<void> _pickPhotos() async {
    if (_photos.length >= 5) return;
    final picker = ImagePicker();
    final choice = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(children: [
          ListTile(leading: const Icon(Icons.photo_camera_outlined), title: const Text('Take a photo'), onTap: () => Navigator.pop(context, ImageSource.camera)),
          ListTile(leading: const Icon(Icons.photo_library_outlined), title: const Text('Choose from gallery'), onTap: () => Navigator.pop(context, ImageSource.gallery)),
        ]),
      ),
    );
    if (choice == null) return;
    final file = await picker.pickImage(source: choice, imageQuality: 80, maxWidth: 1600);
    if (file != null) setState(() => _photos.add(File(file.path)));
  }

  bool get _canSubmit =>
      _selectedCategory != null &&
      _selectedSubcategory != null &&
      _descriptionController.text.trim().length > 9 &&
      !_submitting;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _submitting = true);

    try {
      final result = await context.read<ReportRepository>().submitReport(NewReportInput(
            categoryId: _selectedCategory!.id,
            subcategoryId: _selectedSubcategory!.id,
            title: _titleController.text.trim().isEmpty ? '${_selectedCategory!.name} issue' : _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
            lat: _pin.latitude,
            lng: _pin.longitude,
            lguId: _selectedLgu?.id,
            barangayId: _selectedBarangay?.id,
            photos: _photos,
          ));

      if (!mounted) return;

      if (result is SubmissionSynced) {
        _resetForm();
        await Navigator.of(context).push(MaterialPageRoute(builder: (_) => CitizenReportDetailScreen(reportId: result.report.id)));
      } else if (result is SubmissionQueued) {
        _resetForm();
        _showQueuedDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not submit your report. Please try again.')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _addressController.clear();
    setState(() {
      _selectedCategory = null;
      _selectedSubcategory = null;
      _photos.clear();
    });
  }

  void _showQueuedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.cloud_off, color: AppColors.secondary, size: 32),
        title: const Text('Saved offline'),
        content: const Text(
          'No connection right now — your report is saved on this device and will be sent automatically the moment you\'re back online. You can keep using the app normally.',
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Got it'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report an issue'), automaticallyImplyLeading: !widget.embedded),
      body: _loadingDirectory
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                const SyncStatusBanner(),
                const SizedBox(height: AppSpacing.md),
                Text('Category', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<ApiCategory>(
                  initialValue: _selectedCategory,
                  hint: const Text('Select a category'),
                  items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                  onChanged: (c) => setState(() {
                    _selectedCategory = c;
                    _selectedSubcategory = null;
                  }),
                ),
                if (_selectedCategory != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<Subcategory>(
                    initialValue: _selectedSubcategory,
                    hint: const Text('Select a subcategory'),
                    items: _selectedCategory!.subcategories.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                    onChanged: (s) => setState(() => _selectedSubcategory = s),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                Text('Description', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Short summary (optional)'),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'What did you see?', alignLabelWithHint: true),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(child: Text('Location', style: Theme.of(context).textTheme.titleMedium)),
                    TextButton.icon(onPressed: _useCurrentLocation, icon: const Icon(Icons.my_location, size: 16), label: const Text('Use my location')),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  child: SizedBox(
                    height: 220,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(target: _pin, zoom: 15),
                      onMapCreated: (c) => _mapController = c,
                      markers: {Marker(markerId: const MarkerId('pin'), position: _pin, draggable: true, onDragEnd: (p) => setState(() => _pin = p))},
                      onTap: (p) => setState(() => _pin = p),
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(controller: _addressController, decoration: const InputDecoration(labelText: 'Address (optional)')),
                if (_lgus.length > 1) ...[
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<PublicLgu>(
                    initialValue: _selectedLgu,
                    hint: const Text('Select LGU'),
                    items: _lgus.map((l) => DropdownMenuItem(value: l, child: Text(l.name))).toList(),
                    onChanged: (l) {
                      setState(() => _selectedLgu = l);
                      if (l != null) _loadBarangays(l.id);
                    },
                  ),
                ],
                if (_selectedLgu != null && _barangays.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<PublicBarangay>(
                    initialValue: _selectedBarangay,
                    hint: const Text('Select barangay'),
                    items: _barangays.map((b) => DropdownMenuItem(value: b, child: Text(b.name))).toList(),
                    onChanged: (b) => setState(() => _selectedBarangay = b),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                Text('Photos', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 90,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ..._photos.asMap().entries.map((e) => Padding(
                            padding: const EdgeInsets.only(right: AppSpacing.sm),
                            child: Stack(children: [
                              ClipRRect(borderRadius: BorderRadius.circular(AppRadius.input), child: Image.file(e.value, width: 90, height: 90, fit: BoxFit.cover)),
                              Positioned(
                                right: 2,
                                top: 2,
                                child: GestureDetector(
                                  onTap: () => setState(() => _photos.removeAt(e.key)),
                                  child: const CircleAvatar(radius: 10, backgroundColor: Colors.black54, child: Icon(Icons.close, size: 12, color: Colors.white)),
                                ),
                              ),
                            ]),
                          )),
                      if (_photos.length < 5)
                        InkWell(
                          onTap: _pickPhotos,
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(border: Border.all(color: AppColors.border, style: BorderStyle.solid), borderRadius: BorderRadius.circular(AppRadius.input)),
                            child: const Icon(Icons.add_a_photo_outlined, color: AppColors.textMuted),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                ElevatedButton(
                  onPressed: _canSubmit ? _submit : null,
                  child: _submitting
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Submit report'),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
    );
  }
}
