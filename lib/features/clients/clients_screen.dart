import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/clients_provider.dart';
import 'add_client_screen.dart';

class ClientsScreen extends ConsumerStatefulWidget {
  const ClientsScreen({super.key});

  @override
  ConsumerState<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends ConsumerState<ClientsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final clients = ref.watch(clientsProvider);
    final query = _searchController.text.trim().toLowerCase();

    final filteredClients = clients.where((client) {
      if (query.isEmpty) return true;

      return client.name.toLowerCase().contains(query) ||
          client.email.toLowerCase().contains(query) ||
          client.phone.toLowerCase().contains(query) ||
          client.address.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(t.clientsTitle),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: t.searchClients,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.clear),
                      ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: clients.isEmpty
                ? Center(
                    child: Text(t.noClientsYet),
                  )
                : filteredClients.isEmpty
                    ? Center(
                        child: Text(t.noResultsFound),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredClients.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final client = filteredClients[index];

                          return Card(
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(client.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (client.email.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(client.email),
                                  ],
                                  if (client.phone.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(client.phone),
                                  ],
                                  if (client.address.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(client.address),
                                  ],
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () async {
                                  await ref
                                      .read(clientsProvider.notifier)
                                      .deleteClient(client.id);
                                },
                                tooltip: t.delete,
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddClientScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}