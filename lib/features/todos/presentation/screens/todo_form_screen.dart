import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/todo_item.dart';
import '../../../../models/todo_status.dart';
import '../../../../models/todo_priority.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/custom_text_field.dart';
import '../cubit/todo_cubit.dart';

class TodoFormScreen extends StatefulWidget {
  final TodoItem? initialItem;

  const TodoFormScreen({
    super.key,
    this.initialItem,
  });

  @override
  State<TodoFormScreen> createState() => _TodoFormScreenState();
}

class _TodoFormScreenState extends State<TodoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _categoryController;

  late TodoPriority _selectedPriority;
  late TodoStatus _selectedStatus;
  DateTime? _selectedDueDate;
  bool _isSaving = false;

  final List<String> _suggestedCategories = [
    'Work',
    'Personal',
    'Shopping',
    'Urgent',
    'Health',
    'Study',
  ];

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem;
    _titleController = TextEditingController(text: item?.title ?? '');
    _descriptionController = TextEditingController(text: item?.description ?? '');
    _categoryController = TextEditingController(text: item?.category ?? 'Work');
    _selectedPriority = item?.priority ?? TodoPriority.medium;
    _selectedStatus = item?.status ?? TodoStatus.todo;
    _selectedDueDate = item?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.initialItem != null;

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final initial = _selectedDueDate ?? now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDueDate ?? now),
      );

      final combined = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime?.hour ?? 12,
        pickedTime?.minute ?? 0,
      );

      setState(() {
        _selectedDueDate = combined;
      });
    }
  }

  Future<void> _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSaving = true;
    });

    final cubit = context.read<TodoCubit>();

    if (_isEditing) {
      final updated = widget.initialItem!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _selectedPriority,
        status: _selectedStatus,
        dueDate: _selectedDueDate,
        category: _categoryController.text.trim().isEmpty
            ? 'Work'
            : _categoryController.text.trim(),
      );
      await cubit.updateTodo(updated);
    } else {
      await cubit.addTodo(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _selectedPriority,
        dueDate: _selectedDueDate,
        category: _categoryController.text.trim().isEmpty
            ? 'Work'
            : _categoryController.text.trim(),
      );
    }

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDesktop = MediaQuery.of(context).size.width >= 720;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Task' : 'New Task',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isDesktop ? 600 : double.infinity),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Subtitle banner from Stitch Modal
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.lightContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_note_rounded,
                            size: 18,
                            color: isDark ? AppColors.secondaryFixed : AppColors.secondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Capture work, set deadlines, and organize flow.',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    CustomTextField(
                      controller: _titleController,
                      label: 'Task Title',
                      hint: 'What needs to be done?',
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Task title cannot be empty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _descriptionController,
                      label: 'Description & Notes (Optional)',
                      hint: 'Add subtasks, context, or deliverables...',
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),

                    // Priority Selector (Stitch UI 3-tile Radiogroup)
                    Text(
                      'Priority Level',
                      style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPriorityTile(
                            priority: TodoPriority.low,
                            label: 'Low',
                            dotColor: AppColors.priorityLow,
                            isSelected: _selectedPriority == TodoPriority.low,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildPriorityTile(
                            priority: TodoPriority.medium,
                            label: 'Medium',
                            dotColor: AppColors.priorityMedium,
                            isSelected: _selectedPriority == TodoPriority.medium,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildPriorityTile(
                            priority: TodoPriority.high,
                            label: 'High',
                            dotColor: AppColors.priorityHigh,
                            isSelected: _selectedPriority == TodoPriority.high,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Status selector if editing
                    if (_isEditing) ...[
                      Text(
                        'Status',
                        style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<TodoStatus>(
                        segments: const [
                          ButtonSegment(
                            value: TodoStatus.todo,
                            label: Text('To Do'),
                            icon: Icon(Icons.radio_button_unchecked_rounded, size: 16),
                          ),
                          ButtonSegment(
                            value: TodoStatus.inProgress,
                            label: Text('In Progress'),
                            icon: Icon(Icons.hourglass_top_rounded, size: 16),
                          ),
                          ButtonSegment(
                            value: TodoStatus.completed,
                            label: Text('Done'),
                            icon: Icon(Icons.check_circle_outline_rounded, size: 16),
                          ),
                        ],
                        selected: {_selectedStatus},
                        onSelectionChanged: (set) {
                          setState(() {
                            _selectedStatus = set.first;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Category Section
                    Text(
                      'Category / Tag',
                      style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _suggestedCategories.map((cat) {
                        final isSelected = _categoryController.text.trim().toLowerCase() ==
                            cat.toLowerCase();
                        return ChoiceChip(
                          label: Text('#$cat'),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _categoryController.text = cat;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _categoryController,
                      label: 'Custom Category',
                      hint: 'e.g. Work, Personal, Shopping',
                      prefixIcon: Icons.tag_rounded,
                    ),
                    const SizedBox(height: 24),

                    // Due Date Section
                    Text(
                      'Due Date',
                      style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _pickDueDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : AppColors.lightContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_month_outlined,
                              size: 20,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedDueDate != null
                                    ? DateFormat.yMMMMEEEEd().add_jm().format(_selectedDueDate!)
                                    : 'No deadline set (Tap to choose)',
                                style: TextStyle(
                                  color: _selectedDueDate != null
                                      ? (isDark ? Colors.white : Colors.black87)
                                      : (isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary),
                                  fontWeight: _selectedDueDate != null
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (_selectedDueDate != null)
                              IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  setState(() {
                                    _selectedDueDate = null;
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),

                    CustomButton(
                      text: _isEditing ? 'Save Changes' : 'Create Task',
                      icon: _isEditing ? Icons.check_rounded : Icons.add_task_rounded,
                      isLoading: _isSaving,
                      onPressed: _onSave,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityTile({
    required TodoPriority priority,
    required String label,
    required Color dotColor,
    required bool isSelected,
    required bool isDark,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        setState(() {
          _selectedPriority = priority;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? dotColor.withValues(alpha: isDark ? 0.25 : 0.12)
              : (isDark ? AppColors.darkCard : AppColors.lightContainerLow),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? dotColor
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? dotColor
                    : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
