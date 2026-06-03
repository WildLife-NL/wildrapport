import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/data_managers/my_interaction_api.dart';
import 'package:wildrapport/models/api_models/my_interaction.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';
import 'package:wildrapport/widgets/logbook/interaction_logbook_card.dart';
import 'package:wildrapport/utils/interaction_animal_count_store.dart';

/// Recent logbook entries from the backend (`GET interactions/me`).
class RecentSightingsScreen extends StatefulWidget {
  const RecentSightingsScreen({super.key});

  @override
  State<RecentSightingsScreen> createState() => _RecentSightingsScreenState();
}

class _RecentSightingsScreenState extends State<RecentSightingsScreen> {
  late Future<List<MyInteraction>> _interactionsFuture;

  @override
  void initState() {
    super.initState();
    _loadInteractions();
  }

  void _loadInteractions() {
    final api = context.read<MyInteractionApi>();
    _interactionsFuture = InteractionAnimalCountStore.ensureLoaded().then((_) {
      return api.getMyInteractions().then(_sortNewestFirst);
    });
  }

  Future<void> _refresh() async {
    setState(_loadInteractions);
    await _interactionsFuture;
  }

  static List<MyInteraction> _sortNewestFirst(List<MyInteraction> items) {
    final sorted = List<MyInteraction>.from(items);
    sorted.sort((a, b) => b.moment.compareTo(a.moment));
    return sorted;
  }

  void _handleBackNavigation(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F4),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CustomAppBar(
              centerText: 'Recente meldingen',
              
              leftIcon: Icons.arrow_back_ios,
              rightIcon: null,
              showUserIcon: false,
              useFixedText: true,
              onLeftIconPressed: () => _handleBackNavigation(context),
              textColor: AppColors.textPrimary,
              fontScale: 1.1,
              iconScale: 1.15,
              userIconScale: 1.15,
            ),
            Expanded(
              child: FutureBuilder<List<MyInteraction>>(
                future: _interactionsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGreen,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return _ErrorState(
                      message: '${snapshot.error}',
                      onRetry: _refresh,
                    );
                  }

                  final interactions = snapshot.data ?? const <MyInteraction>[];
                  if (interactions.isEmpty) {
                    return _EmptyState(onRetry: _refresh);
                  }

                  return RefreshIndicator(
                    color: AppColors.primaryGreen,
                    onRefresh: _refresh,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: interactions.length,
                      itemBuilder: (context, index) {
                        return InteractionLogbookCard(
                          interaction: interactions[index],
                          height: 220,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final Future<void> Function() onRetry;

  const _EmptyState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inbox_outlined,
              size: 48,
              color: Colors.black45,
            ),
            const SizedBox(height: 12),
            Text(
              'Geen meldingen gevonden',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Na het indienen van een waarneming, schademelding of dieraanrijding verschijnen ze hier.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Opnieuw laden'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            const Text(
              'Kon meldingen niet laden',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Opnieuw proberen'),
            ),
          ],
        ),
      ),
    );
  }
}
