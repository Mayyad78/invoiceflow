import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../l10n/app_localizations.dart';
import '../../models/client_model.dart';
import '../../providers/clients_provider.dart';

class AddClientScreen extends ConsumerStatefulWidget {
  const AddClientScreen({super.key, this.client});

  final ClientModel? client;

  @override
  ConsumerState<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends ConsumerState<AddClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  bool get _isEdit => widget.client != null;

  @override
  void initState() {
    super.initState();

    if (widget.client != null) {
      _nameController.text = widget.client!.name;
      _emailController.text = widget.client!.email;
      _phoneController.text = widget.client!.phone;
      _addressController.text = widget.client!.address;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String _normalize(String value) {
    return value.trim().toLowerCase();
  }

  bool _isDuplicateClient(List<ClientModel> clients) {
    final name = _normalize(_nameController.text);
    final email = _normalize(_emailController.text);
    final phone = _normalize(_phoneController.text);

    for (final client in clients) {
      if (_isEdit && client.id == widget.client!.id) {
        continue;
      }

      final sameName = name.isNotEmpty && _normalize(client.name) == name;
      final sameEmail =
          email.isNotEmpty && _normalize(client.email) == email;
      final samePhone =
          phone.isNotEmpty && _normalize(client.phone) == phone;

      if (sameName || sameEmail || samePhone) {
        return true;
      }
    }

    return false;
  }

  Future<void> _saveClient() async {
    final t = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;

    final clients = ref.read(clientsProvider);
    if (_isDuplicateClient(clients)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Client already exists'),
        ),
      );
      return;
    }

    final client = ClientModel(
      id: widget.client?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
    );

    if (_isEdit) {
      await ref.read(clientsProvider.notifier).updateClient(client);
    } else {
      await ref.read(clientsProvider.notifier).addClient(client);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEdit ? t.clientUpdated : t.clientSaved),
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? t.editClient : t.addClient),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: t.clientName,
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
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: t.phone,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
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
                onPressed: _saveClient,
                child: Text(_isEdit ? t.saveChanges : t.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}