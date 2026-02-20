import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/data/repositories/subject_repository.dart';
import '../../../../core/models/subject.dart';
import '../../../../injection_container.dart';
import '../../domain/models/exam.dart';
import '../bloc/exam_bloc.dart';

class AddExamSheet extends StatefulWidget {
  const AddExamSheet({super.key});

  @override
  State<AddExamSheet> createState() => _AddExamSheetState();
}

class _AddExamSheetState extends State<AddExamSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  DateTime? _selectedDate;
  Subject? _selectedSubject;
  String _notificationFrequency = 'Daily';

  final List<Subject> _subjects = sl<SubjectRepository>().getAllSubjects();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accentCoral,
              onPrimary: AppColors.softWhite,
              surface: AppColors.secondaryNavy,
              onSurface: AppColors.softWhite,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedSubject != null) {
      final exam = Exam(
        id: const Uuid().v4(),
        subjectId: _selectedSubject!.id,
        title: _titleController.text,
        date: _selectedDate!,
        notificationFrequency: _notificationFrequency,
      );

      context.read<ExamBloc>().add(AddExam(exam));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add New Exam',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.softWhite,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Exam Title',
                  hintText: 'e.g. Midterm, Final, Quiz',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: AppColors.secondaryNavy,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.accentCoral),
                  ),
                  filled: true,
                  fillColor: AppColors.secondaryNavy,
                ),
                style: const TextStyle(color: AppColors.softWhite),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a title'
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Subject>(
                initialValue: _selectedSubject,
                decoration: InputDecoration(
                  labelText: 'Subject',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: AppColors.secondaryNavy,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.accentCoral),
                  ),
                  filled: true,
                  fillColor: AppColors.secondaryNavy,
                ),
                dropdownColor: AppColors.secondaryNavy,
                items: _subjects.map((s) {
                  return DropdownMenuItem(
                    value: s,
                    child: Text(
                      s.name,
                      style: const TextStyle(color: AppColors.softWhite),
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedSubject = val),
                validator: (value) =>
                    value == null ? 'Please select a subject' : null,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryNavy,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.secondaryNavy),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: AppColors.accentGold,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate == null
                            ? 'Select Exam Date'
                            : DateFormat('MMM dd, yyyy').format(_selectedDate!),
                        style: TextStyle(
                          color: _selectedDate == null
                              ? AppColors.textSecondary
                              : AppColors.softWhite,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Reminders',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: ['Daily', 'Weekly'].map((freq) {
                  final isSelected = _notificationFrequency == freq;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(freq),
                      selected: isSelected,
                      onSelected: (val) =>
                          setState(() => _notificationFrequency = freq),
                      selectedColor: AppColors.primaryGreen,
                      backgroundColor: AppColors.secondaryNavy,
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentCoral,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Save Exam',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
