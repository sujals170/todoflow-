import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../repositories/todo_repository.dart';
import '../../../../widgets/theme_toggle_button.dart';
import '../../../../widgets/todoflow_logo.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/domain/auth_state.dart';
import '../cubit/todo_cubit.dart';
import '../../domain/todo_state.dart';
import '../../domain/todo_filter.dart';
import '../../domain/todo_sort.dart';
import '../widgets/metric_summary_card.dart';
import '../widgets/todo_card.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/active_filter_chips.dart';
import '../widgets/filter_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchExpanded = false;

  final List<TodoTabFilter> _tabs = [
    TodoTabFilter.all,
    TodoTabFilter.today,
    TodoTabFilter.pending,
    TodoTabFilter.completed,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context.read<TodoCubit>().setTab(_tabs[_tabController.index]);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoCubit>().loadTodos();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showSortDialog(BuildContext context, TodoSort currentSort) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Sort Tasks By',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.access_time_rounded),
                title: const Text('Date Created (Newest first)'),
                trailing: currentSort.sortBy == TodoSortBy.createdAt && !currentSort.ascending
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  context.read<TodoCubit>().setSort(
                        const TodoSort(sortBy: TodoSortBy.createdAt, ascending: false),
                      );
                  Navigator.of(sheetCtx).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.event_outlined),
                title: const Text('Due Date (Soonest first)'),
                trailing: currentSort.sortBy == TodoSortBy.dueDate && currentSort.ascending
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  context.read<TodoCubit>().setSort(
                        const TodoSort(sortBy: TodoSortBy.dueDate, ascending: true),
                      );
                  Navigator.of(sheetCtx).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.priority_high_rounded),
                title: const Text('Priority (High to Low)'),
                trailing: currentSort.sortBy == TodoSortBy.priority && !currentSort.ascending
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  context.read<TodoCubit>().setSort(
                        const TodoSort(sortBy: TodoSortBy.priority, ascending: false),
                      );
                  Navigator.of(sheetCtx).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.sort_by_alpha_rounded),
                title: const Text('Alphabetical (A - Z)'),
                trailing: currentSort.sortBy == TodoSortBy.title && currentSort.ascending
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  context.read<TodoCubit>().setSort(
                        const TodoSort(sortBy: TodoSortBy.title, ascending: true),
                      );
                  Navigator.of(sheetCtx).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, TodoFilter currentFilter, List<String> categories) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => FilterBottomSheet(
        initialFilter: currentFilter,
        availableCategories: categories,
        onApply: (newFilter) {
          context.read<TodoCubit>().setFilter(newFilter);
        },
        onReset: () {
          context.read<TodoCubit>().resetFilters();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDesktop = MediaQuery.of(context).size.width >= 720;

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final profile = authState is Authenticated ? authState.profile : null;
        final displayName = (profile?.fullName.isNotEmpty == true)
            ? profile!.fullName
            : 'Sujal';
        final todayStr = DateFormat('EEEE, MMM d').format(DateTime.now());

        return Scaffold(
          appBar: AppBar(
            title: TodoFlowLogo(
              size: 34,
              showText: true,
              isDark: isDark,
            ),
            actions: [
              // Search toggle
              IconButton(
                icon: Icon(_isSearchExpanded ? Icons.close_rounded : Icons.search_rounded),
                tooltip: _isSearchExpanded ? 'Close Search' : 'Search Tasks',
                onPressed: () {
                  setState(() {
                    if (_isSearchExpanded) {
                      _searchController.clear();
                      context.read<TodoCubit>().setSearchQuery('');
                      _isSearchExpanded = false;
                    } else {
                      _isSearchExpanded = true;
                    }
                  });
                },
              ),
              // Filter tune button
              BlocBuilder<TodoCubit, TodoState>(
                builder: (context, state) {
                  final filter = state is TodoLoaded ? state.filter : const TodoFilter();
                  final categories = state is TodoLoaded ? state.availableCategories : <String>[];
                  final hasCustomFilters = filter.hasActiveCustomFilters;

                  return IconButton(
                    icon: Badge(
                      isLabelVisible: hasCustomFilters,
                      backgroundColor: AppColors.primary,
                      smallSize: 8,
                      child: const Icon(Icons.tune_rounded),
                    ),
                    tooltip: 'Filter Tasks',
                    onPressed: () => _showFilterSheet(context, filter, categories),
                  );
                },
              ),
              // Sort button
              BlocBuilder<TodoCubit, TodoState>(
                builder: (context, state) {
                  final sort = state is TodoLoaded ? state.sort : const TodoSort();
                  return IconButton(
                    icon: const Icon(Icons.swap_vert_rounded),
                    tooltip: 'Sort Tasks',
                    onPressed: () => _showSortDialog(context, sort),
                  );
                },
              ),
              // Theme Toggle (White and Dark Mode)
              const ThemeToggleButton(),
              // User Avatar
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => context.push('/profile'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 34,
                      height: 34,
                      color: AppColors.primary.withValues(alpha: 0.15),
                      child: Image.asset(
                        'assets/images/avatar_sujal.png',
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Center(
                          child: Text(
                            displayName.isNotEmpty ? displayName[0].toUpperCase() : 'S',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 4,
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'Add Task',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            onPressed: () => context.push('/todo/new'),
          ),
          body: BlocBuilder<TodoCubit, TodoState>(
            builder: (context, state) {
              if (state is TodoLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is TodoError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline_rounded,
                            size: 48, color: theme.colorScheme.error),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Try Again'),
                          onPressed: () => context.read<TodoCubit>().loadTodos(),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is TodoLoaded) {
                final todos = state.filteredTodos;

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: isDesktop ? 800 : double.infinity),
                    child: RefreshIndicator(
                      onRefresh: () => context.read<TodoCubit>().loadTodos(),
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        children: [
                          // 1. Greeting Section (Stitch Header)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        todayStr.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.8,
                                          color: isDark
                                              ? AppColors.darkTextSecondary
                                              : AppColors.lightTextSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            'Hello, $displayName',
                                            style: theme.textTheme.headlineSmall?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: -0.5,
                                                ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Text('👋', style: TextStyle(fontSize: 22)),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Let\'s get things done today.',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isDark
                                              ? AppColors.darkTextSecondary
                                              : AppColors.lightTextSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Streak Badge (Stitch UI)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondaryContainer.withValues(alpha: isDark ? 0.25 : 0.8),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.bolt_rounded,
                                        size: 16,
                                        color: isDark
                                            ? AppColors.secondaryFixed
                                            : AppColors.onSecondaryContainer,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Streak: 6d',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? AppColors.secondaryFixed
                                              : AppColors.onSecondaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Search Bar (expandable or persistent trigger)
                          if (_isSearchExpanded)
                            Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkCard : AppColors.lightContainerLow,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                ),
                              ),
                              child: TextField(
                                controller: _searchController,
                                autofocus: true,
                                decoration: const InputDecoration(
                                  hintText: 'Search tasks, tags...',
                                  prefixIcon: Icon(Icons.search_rounded, size: 20),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  filled: false,
                                ),
                                onChanged: (query) {
                                  context.read<TodoCubit>().setSearchQuery(query);
                                },
                              ),
                            ),

                          // 2. Stitch Metrics Progress Banner
                          MetricSummaryCard(
                            totalCount: state.totalCount,
                            completedCount: state.completedCount,
                            pendingCount: state.pendingCount,
                          ),
                          const SizedBox(height: 16),

                          // 3. Segmented Status Filter Tabs (Stitch UI)
                          _buildSegmentedStatusTabs(context, state, isDark),
                          const SizedBox(height: 12),

                          // 4. Horizontal Category Chips
                          CategoryFilterBar(
                            categories: state.availableCategories,
                            selectedCategory: state.filter.category,
                            onCategorySelected: (cat) =>
                                context.read<TodoCubit>().setCategory(cat),
                          ),

                          // Active Filter chips if any
                          ActiveFilterChips(
                            filter: state.filter,
                            onClearPriority: () =>
                                context.read<TodoCubit>().setPriority(null),
                            onClearCategory: () =>
                                context.read<TodoCubit>().setCategory(null),
                            onClearDueDate: () => context
                                .read<TodoCubit>()
                                .setDueDateFilter(DueDateFilter.all),
                            onClearSearch: () {
                              _searchController.clear();
                              context.read<TodoCubit>().setSearchQuery('');
                              setState(() {
                                _isSearchExpanded = false;
                              });
                            },
                            onClearAll: () {
                              _searchController.clear();
                              context.read<TodoCubit>().resetFilters();
                              setState(() {
                                _isSearchExpanded = false;
                              });
                            },
                          ),

                          // 5. Active Tasks Stream Header
                          Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Active Tasks',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.secondaryAccent,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${todos.length} items',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 6. Task List
                          if (todos.isEmpty)
                            _buildEmptyState(theme, state.filter.hasActiveFilters)
                          else
                            ...todos.map(
                              (item) => TodoCard(
                                item: item,
                                onTap: () =>
                                    context.push('/todo/detail/${item.id}'),
                                onToggleStatus: () =>
                                    context.read<TodoCubit>().toggleStatus(item),
                                onSelectStatus: (status) => context
                                    .read<TodoCubit>()
                                    .setSpecificStatus(item, status),
                                onEdit: () =>
                                    context.push('/todo/edit', extra: item),
                                onDelete: () =>
                                    context.read<TodoCubit>().deleteTodo(item.id),
                              ),
                            ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }

  Widget _buildSegmentedStatusTabs(
    BuildContext context,
    TodoLoaded state,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: _tabs.map((tab) {
          final isSelected = state.filter.tab == tab;
          int count = 0;
          switch (tab) {
            case TodoTabFilter.all:
              count = state.totalCount;
              break;
            case TodoTabFilter.today:
              count = state.allTodos.where((t) {
                if (t.dueDate == null) return false;
                final now = DateTime.now();
                return t.dueDate!.year == now.year &&
                    t.dueDate!.month == now.month &&
                    t.dueDate!.day == now.day;
              }).length;
              break;
            case TodoTabFilter.pending:
              count = state.pendingCount;
              break;
            case TodoTabFilter.completed:
              count = state.completedCount;
              break;
          }

          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                _tabController.animateTo(_tabs.indexOf(tab));
                context.read<TodoCubit>().setTab(tab);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? AppColors.darkSurface : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      tab.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? AppColors.primary
                            : (isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.12)
                            : (isDark
                                ? AppColors.darkContainerHigh
                                : AppColors.lightContainerHigh),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool hasFilters) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasFilters ? Icons.filter_alt_off_outlined : Icons.check_circle_outline_rounded,
                size: 36,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hasFilters ? 'No matching tasks' : 'All tasks completed!',
              style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Try adjusting your search query or filters.'
                  : 'Tap "+ Add Task" to schedule your next achievement.',
              style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
