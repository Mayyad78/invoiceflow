import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/clients_provider.dart';
import 'add_client_screen.dart';

class ClientsScreen extends ConsumerWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final clients = ref.watch(clientsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.clientsTitle),
      ),
      body: clients.isEmpty
          ? Center(
              child: Text(t.noClientsYet),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: clients.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final client = clients[index];

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