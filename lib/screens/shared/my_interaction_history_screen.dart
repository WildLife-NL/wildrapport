import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/data_managers/my_interaction_api.dart';
import 'package:wildrapport/models/api_models/my_interaction.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';
import 'package:wildrapport/managers/api_managers/interaction_types_manager.dart';
import 'package:wildrapport/models/api_models/interaction_type.dart';
import 'package:wildrapport/widgets/logbook/interaction_logbook_card.dart';

class MyInteractionHistoryScreen extends StatefulWidget {
  const MyInteractionHistoryScreen({super.key});

  @override
  State<MyInteractionHistoryScreen> createState() =>
      _MyInteractionHistoryScreenState();
}

class _MyInteractionHistoryScreenState
    extends State<MyInteractionHistoryScreen> {
  late Future<List<MyInteraction>> _interactionsFuture;
  String _selectedFilterLabel = 'Alle';
  int? _selectedTypeId;
  List<InteractionType> _types = const [];

  @override
  void initState() {
    super.initState();
    final myInteractionApi = context.read<MyInteractionApi>();
    _interactionsFuture = myInteractionApi.getMyInteractions();
    _fetchTypes();
  }

  Future<void> _fetchTypes() async {
    try {
      final typesManager = context.read<InteractionTypesManager>();
      final fetched = await typesManager.ensureFetched();
      if (!mounted) return;
      setState(() {
        _types = fetched;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CustomAppBar(
              leftIcon: Icons.arrow_back_ios,
              centerText: 'Mijn Interacties',
              rightIcon: null,
              showUserIcon: false,
              onLeftIconPressed: () => Navigator.of(context).pop(),
              iconColor: AppColors.textPrimary,
              textColor: AppColors.textPrimary,
              fontScale: 1.15,
              iconScale: 1.15,
              userIconScale: 1.15,
              useFixedText: true,
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  const Icon(
                    Icons.filter_list,
                    size: 20,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(width: 8),

                  Expanded(
                    child: Container(
                      height: 58,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedFilterLabel,
                          isExpanded: true,
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 30,
                            color: AppColors.textPrimary,
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: 'Alle',
                              child: Text('Alle'),
                            ),
                            ..._types.map(
                              (t) => DropdownMenuItem(
                                value: t.name,
                                child: Text(t.name),
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            if (val == null) return;

                            setState(() {
                              _selectedFilterLabel = val;

                              if (val == 'Alle') {
                                _selectedTypeId = null;
                              } else {
                                final match = _types.firstWhere(
                                  (t) => t.name == val,
                                  orElse: () => InteractionType(
                                    id: -1,
                                    name: val,
                                    description: '',
                                  ),
                                );

                                _selectedTypeId =
                                    match.id >= 0 ? match.id : null;
                              }
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Fout bij het laden van interacties',
                              style: Theme.of(context).textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${snapshot.error}',
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.history,
                              color: AppColors.primaryGreen,
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Geen interacties gevonden',
                              style: Theme.of(context).textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'U heeft nog geen interacties gemeld',
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    final all = snapshot.data!;
                    final interactions = _applyFilter(all);

                    return ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: interactions.length,
                      itemBuilder: (context, index) {
                        return InteractionLogbookCard(
                          interaction: interactions[index],
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<MyInteraction> _applyFilter(List<MyInteraction> items) {
    final filtered = _selectedTypeId == null
        ? List<MyInteraction>.from(items)
        : items.where((i) => i.type.id == _selectedTypeId).toList();

    filtered.sort((a, b) => b.moment.compareTo(a.moment));
    return filtered;
  }
}