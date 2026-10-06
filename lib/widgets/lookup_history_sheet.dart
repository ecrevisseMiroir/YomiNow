import 'package:flutter/material.dart';

import '../services/lookup_history.dart';

class LookupHistorySheet extends StatelessWidget {
  const LookupHistorySheet({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: LookupHistory.instance.load(),
      builder: (context, snapshot) {
        final records = LookupHistory.instance.records;
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (context, scrollController) => ListView(
            controller: scrollController,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Recent Lookups',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              ...records.map(
                (r) => ListTile(
                  title: Text(r.word),
                  subtitle: Text('${r.reading} — ${r.gloss}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.note_add),
                    tooltip: 'Add to Anki',
                    onPressed: () {
                      // Placeholder for Anki integration
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Added "${r.word}" to Anki')),
                      );
                    },
                  ),
                ),
              ),
              if (records.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No recent lookups yet.'),
                ),
            ],
          ),
        );
      },
    );
  }
}
