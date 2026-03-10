import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

 import '../../../core/theme/empty_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../provider/ambience_provider.dart';
import '../widgets/ambience_card.dart';
import '../widgets/search_bar.dart';
import '../widgets/filter_chips.dart';
import '../widgets/clear_filters_button.dart';
import '../../../shared/widgets/custom_app_bar.dart';
 import '../../../shared/widgets/error_view.dart';
 import '../../../core/constants/app_constants.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {

  // Add this method to refresh ambiences
  Future<void> _refreshAmbiences() async {
    ref.invalidate(ambienceListProvider);
  }

  @override
  Widget build(BuildContext context) {
    final ambiencesAsync = ref.watch(ambienceListProvider);
    final filteredAmbiences = ref.watch(filteredAmbiencesProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final selectedTag = ref.watch(selectedTagProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Ambiences',
        showBackButton: false,
        actions: [
          // History button
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/history'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          const SizedBox(height: 8),
          const SearchBarWidget(),

          // Filter Chips
          const SizedBox(height: 16),
          const FilterChips(),

          // Clear Filters (conditional)
          const ClearFiltersButton(),

          // Content with RefreshIndicator
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshAmbiences,
              child: ambiencesAsync.when(
                data: (_) {
                  if (filteredAmbiences.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.2,
                      ),
                      children: [
                        EmptyState(
                          message: searchQuery.isNotEmpty || selectedTag != null
                              ? 'No ambiences found matching your filters'
                              : 'No ambiences available',
                          buttonText: searchQuery.isNotEmpty || selectedTag != null
                              ? 'Clear Filters'
                              : null,
                          onButtonPressed: searchQuery.isNotEmpty || selectedTag != null
                              ? () {
                            ref.read(searchQueryProvider.notifier).state = '';
                            ref.read(selectedTagProvider.notifier).state = null;
                          }
                              : null,
                        ),
                      ],
                    );
                  }

                  return _buildAmbienceGrid(filteredAmbiences);
                },
                loading: () =>   Center(
                  child: LoadingIndicator(
                    message: 'Loading ambiences...',
                  ),
                ),
                error: (error, stack) => ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.3,
                    ),
                    ErrorView(
                      message: 'Failed to load ambiences: $error',
                      onRetry: () {
                        ref.invalidate(ambienceListProvider);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmbienceGrid(List<dynamic> ambiences) {
    // Ensure ambiences is properly typed
    final ambienceList = ambiences.cast<dynamic>();

    return Padding(
      padding: const EdgeInsets.all(AppConstants.gridSpacing),
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: AppConstants.gridCrossCount,
          crossAxisSpacing: AppConstants.gridSpacing,
          mainAxisSpacing: AppConstants.gridSpacing,
          childAspectRatio: 0.75, // Slightly adjusted for better look
        ),
        itemCount: ambienceList.length,
        itemBuilder: (context, index) {
          final ambience = ambienceList[index];
          return AmbienceCard(
            ambience: ambience,
            onTap: () {
              // Navigate to details screen
              context.push('/details/${ambience.id}');
            },
          );
        },
      ),
    );
  }
}