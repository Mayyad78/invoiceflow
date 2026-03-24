import 'dart:convert';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../l10n/app_localizations.dart';
import '../../models/business_profile_model.dart';
import '../../providers/business_profile_provider.dart';

class BusinessProfileScreen extends ConsumerStatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  ConsumerState<BusinessProfileScreen> createState() =>
      _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends ConsumerState<BusinessProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  String? _logoBase64;
  bool _isPickingLogo = false;

  @override
  void initState() {
    super.initState();

    final profile = ref.read(businessProfileProvider);

    _nameController = TextEditingController(text: profile.name);
    _emailController = TextEditingController(text: profile.email);
    _phoneController = TextEditingController(text: profile.phone);
    _addressController = TextEditingController(text: profile.address);
    _logoBase64 = profile.logoBase64;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Uint8List? get _logoBytes {
    final value = _logoBase64;
    if (value == null || value.isEmpty) {
      return null;
    }

    try {
      return base64Decode(value);
    } catch (_) {
      return null;
    }
  }

  bool get _useDesktopFilePicker {
    if (kIsWeb) return true;

    return defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux;
  }

  Future<void> _pickLogo() async {
    if (_isPickingLogo) return;

    setState(() {
      _isPickingLogo = true;
    });

    try {
      Uint8List? bytes;

      if (_useDesktopFilePicker) {
        const typeGroup = XTypeGroup(
          label: 'images',
          extensions: <String>[
            'png',
            'jpg',
            'jpeg',
            'webp',
          ],
        );

        final XFile? file = await openFile(
          acceptedTypeGroups: <XTypeGroup>[typeGroup],
          confirmButtonText: 'Select logo',
        );

        if (file != null) {
          bytes = await file.readAsBytes();
        }
      } else {
        final XFile? file = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
          maxWidth: 1200,
        );

        if (file != null) {
          bytes = await file.readAsBytes();
        }
      }

      if (!mounted) return;

      if (bytes == null || bytes.isEmpty) {
        setState(() {
          _isPickingLogo = false;
        });
        return;
      }

      setState(() {
        _logoBase64 = base64Encode(bytes!);
        _isPickingLogo = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isPickingLogo = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick logo: $e'),
        ),
      );
    }
  }

  void _removeLogo() {
    setState(() {
      _logoBase64 = null;
    });
  }

  Future<void> _save() async {
    final t = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;

    final profile = BusinessProfileModel(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      logoBase64: _logoBase64,
    );

    await ref.read(businessProfileProvider.notifier).save(profile);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.profileSaved)),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final logoBytes = _logoBytes;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.businessProfile),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (logoBytes != null)
                      Container(
                        width: 120,
                        height: 120,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Image.memory(
                          logoBytes,
                          fit: BoxFit.contain,
                        ),
                      )
                    else
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.business,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isPickingLogo ? null : _pickLogo,
                        icon: _isPickingLogo
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.image_outlined),
                        label: Text(
                          logoBytes == null ? 'Upload logo' : 'Change logo',
                        ),
                      ),
                    ),
                    if (logoBytes != null) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _removeLogo,
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Remove logo'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: t.businessName,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return t.requiredField;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: t.email,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: t.phone,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: t.address,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              child: Text(t.saveChanges),
            ),
          ],
        ),
      ),
    );
  }
}