import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/colors.dart';
import '../../domain/models/exam.dart';

class ExamCard extends StatelessWidget {
  final Exam exam;
  final String subjectName;

  const ExamCard({super.key, required this.exam, required this.subjectName});

  @override
  Widget build(BuildContext context) {
    final daysLeft = exam.daysUntil;
    final isUrgent = daysLeft <= 3;

    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryNavy,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isUrgent
              ? AppColors.accentCoral
              : AppColors.accentGold.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          if (isUrgent)
            BoxShadow(
              color: AppColors.accentCoral.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isUrgent ? AppColors.accentCoral : AppColors.accentGold,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$daysLeft Days Left',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          Text(
            subjectName,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.softWhite,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            exam.title,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.notifications_active_outlined,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                exam.notificationFrequency,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
