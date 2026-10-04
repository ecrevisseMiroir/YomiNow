import 'package:flutter/material.dart';

import 'package:yominow/l10n/app_localizations.dart';

class LicensesScreen extends StatelessWidget {
  const LicensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final rows = [
      _InfoRow(
        label: l10n.licensesScreenAppLabel,
        value: l10n.licensesScreenAppValue,
      ),
      _InfoRow(
        label: l10n.licensesScreenLicenseStatusLabel,
        value: l10n.licensesScreenLicenseStatusValue,
      ),
      _InfoRow(
        label: l10n.licensesScreenAttributionLabel,
        value: l10n.licensesScreenAttributionValue,
      ),
    ];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 30,
                      ),
                      color: colorScheme.onSurface,
                      tooltip: l10n.licensesScreenBackTooltip,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.licensesScreenTitle,
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 32,
                          height: 1,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                          letterSpacing: -1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.licensesScreenProjectCredits,
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.licensesScreenProjectDescription,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          height: 1.5,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                ...rows.map(
                  (row) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _DetailCard(row: row),
                  ),
                ),
                const SizedBox(height: 8),
                _SectionCard(
                  title: l10n.licensesScreenDataSourcesTitle,
                  body: l10n.licensesScreenDataSourcesBody,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.row});

  final _InfoRow row;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            row.label,
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            row.value,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              height: 1.5,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              height: 1.6,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
