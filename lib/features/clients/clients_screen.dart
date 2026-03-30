import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../models/client_model.dart';
import '../../providers/clients_provider.dart';
import 'add_client_screen.dart';
import 'client_details_screen.dart';

class ClientsScreen extends ConsumerStatefulWidget {
  const ClientsScreen({super.key});

  @override
  ConsumerState<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends ConsumerState<ClientsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _sortAscending = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<bool?> _confirmDelete(
    BuildContext context,
    AppLocalizations t,
    String message,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.confirmDelete),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t.delete),
          ),
        ],
      ),
    );
  }

  void _openAddClient([ClientModel? client]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddClientScreen(client: client),
      ),
    );
  }

  void _openClientDetails(ClientModel client) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ClientDetailsScreen(client: client),
      ),
    );
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
    }).toList()
      ..sort((a, b) {
        final compare = a.name.toLowerCase().compareTo(b.name.toLowerCase());
        return _sortAscending ? compare : -compare;
      });

    return Scaffold(
      appBar: AppBar(
        title: Text(t.clientsTitle),
        actions: [
          IconButton(
            tooltip: t.addClient,
            onPressed: () => _openAddClient(),
            icon: const Icon(Icons.person_add_alt_1_outlined),
          ),
        ],
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
                        tooltip: t.cancel,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          _ClientSummaryItem(
                            label: t.clientsTitle,
                            value: filteredClients.length.toString(),
                          ),
                          if (query.isNotEmpty)
                            _ClientSummaryItem(
                              label: t.searchClients,
                              value: query,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: t.searchClients,
                      onPressed: () {
                        setState(() {
                          _sortAscending = !_sortAscending;
                        });
                      },
                      icon: Icon(
                        _sortAscending
                            ? Icons.sort_by_alpha
                            : Icons.sort_by_alpha_outlined,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _openAddClient(),
                      icon: const Icon(Icons.add),
                      label: Text(t.addClient),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: clients.isEmpty
                ? _EmptyState(
                    icon: Icons.people_outline,
                    title: t.noClientsYet,
                    subtitle: t.startByAddingClient,
                  )
                : filteredClients.isEmpty
                    ? _EmptyState(
                        icon: Icons.search_off,
                        title: t.noResultsFound,
                        subtitle: t.searchClients,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: filteredClients.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final client = filteredClients[index];

                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        child: Text(
                                          client.name.isNotEmpty
                                              ? client.name[0].toUpperCase()
                                              : '?',
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () => _openClientDetails(client),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                client.name,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                              ),
                                              if (client.email.isNotEmpty) ...[
                                                const SizedBox(height: 6),
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
                                              const SizedBox(height: 8),
                                              Text(
                                                t.tapToViewDetails,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      PopupMenuButton<String>(
                                        onSelected: (value) async {
                                          if (value == 'edit') {
                                            _openAddClient(client);
                                            return;
                                          }

                                          if (value == 'delete') {
                                            final confirmed = await _confirmDelete(
                                              context,
                                              t,
                                              t.deleteClientMessage,
                                            );
                                            if (confirmed == true) {
                                              await ref
                                                  .read(clientsProvider.notifier)
                                                  .deleteClient(client.id);
                                            }
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          PopupMenuItem(
                                            value: 'edit',
                                            child: Text(t.edit),
                                          ),
                                          PopupMenuItem(
                                            value: 'delete',
                                            child: Text(t.delete),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: () => _openClientDetails(client),
                                        icon: const Icon(Icons.visibility_outlined),
                                        label: Text(t.preview),
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: () => _openAddClient(client),
                                        icon: const Icon(Icons.edit_outlined),
                                        label: Text(t.edit),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddClient(),
        icon: const Icon(Icons.add),
        label: Text(t.addClient),
      ),
    );
  }
}

class _ClientSummaryItem extends StatelessWidget {
  const _ClientSummaryItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 72),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}