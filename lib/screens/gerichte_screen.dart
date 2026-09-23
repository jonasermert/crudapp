import 'package:crudapp/database/dbHelper.dart';
import 'package:crudapp/model/gericht.dart';
import 'package:flutter/material.dart';

class GerichteScreen extends StatefulWidget {
  const GerichteScreen({super.key});

  @override
  State<GerichteScreen> createState() => _GerichteScreenState();
}

class _GerichteScreenState extends State<GerichteScreen> {
  late Future<List<Gericht>> _gerichte = DBHelper.instance.alle();

  void _laden() {
    setState(() => _gerichte = DBHelper.instance.alle());
  }

  Future<void> _formular([Gericht? gericht]) async {
    final name = TextEditingController(text: gericht?.name);
    final beschreibung = TextEditingController(text: gericht?.beschreibung);
    final preis = TextEditingController(
      text: gericht?.preis.toStringAsFixed(2).replaceAll('.', ','),
    );
    final formKey = GlobalKey<FormState>();
    try {
      final gespeichert = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(gericht == null ? 'Gericht hinzufügen' : 'Gericht bearbeiten'),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: name,
                      autofocus: true,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'Bitte einen Namen eingeben'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: beschreibung,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Beschreibung'),
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'Bitte eine Beschreibung eingeben'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: preis,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Preis in €'),
                      validator: (value) {
                        final number = double.tryParse((value ?? '').trim().replaceAll(',', '.'));
                        return number == null || !number.isFinite || number < 0
                            ? 'Bitte einen gültigen Preis eingeben'
                            : null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                try {
                  await DBHelper.instance.speichern(Gericht(
                    id: gericht?.id,
                    name: name.text.trim(),
                    beschreibung: beschreibung.text.trim(),
                    preis: double.parse(preis.text.trim().replaceAll(',', '.')),
                  ));
                  if (dialogContext.mounted) Navigator.pop(dialogContext, true);
                } catch (_) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(content: Text('Speichern fehlgeschlagen')),
                    );
                  }
                }
              },
              child: const Text('Speichern'),
            ),
          ],
        ),
      );
      if (gespeichert == true && mounted) _laden();
    } finally {
      name.dispose();
      beschreibung.dispose();
      preis.dispose();
    }
  }

  Future<void> _loeschen(Gericht gericht) async {
    final bestaetigt = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Gericht löschen?'),
        content: Text('„${gericht.name}“ wird dauerhaft entfernt.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (bestaetigt != true || !mounted) return;
    try {
      await DBHelper.instance.loeschen(gericht.id!);
      if (mounted) _laden();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Löschen fehlgeschlagen')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meine Gerichte')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _formular(),
        icon: const Icon(Icons.add),
        label: const Text('Hinzufügen'),
      ),
      body: FutureBuilder<List<Gericht>>(
        future: _gerichte,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Gerichte konnten nicht geladen werden.'),
                  TextButton(onPressed: _laden, child: const Text('Erneut versuchen')),
                ],
              ),
            );
          }
          final gerichte = snapshot.data!;
          if (gerichte.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Noch keine Gerichte vorhanden. Füge dein erstes Gericht hinzu.'),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: gerichte.length,
            itemBuilder: (context, index) {
              final gericht = gerichte[index];
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            child: const Icon(Icons.restaurant, color: Colors.deepOrange),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(gericht.name, style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 4),
                                Text(gericht.beschreibung),
                                const SizedBox(height: 8),
                                Text(
                                  '${gericht.preis.toStringAsFixed(2).replaceAll('.', ',')} €',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            tooltip: 'Aktionen für ${gericht.name}',
                            onSelected: (action) => action == 'edit'
                                ? _formular(gericht)
                                : _loeschen(gericht),
                            itemBuilder: (context) => const [
                              PopupMenuItem(value: 'edit', child: Text('Bearbeiten')),
                              PopupMenuItem(value: 'delete', child: Text('Löschen')),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
