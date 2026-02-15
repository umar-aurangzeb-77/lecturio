import 'package:hive/hive.dart';
import '../../domain/models/exam.dart';

class ExamRepository {
  final Box<Exam> _examBox = Hive.box<Exam>('exams');

  List<Exam> getAllExams() {
    return _examBox.values.toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<void> addExam(Exam exam) async {
    await _examBox.add(exam);
  }

  Future<void> deleteExam(int index) async {
    await _examBox.deleteAt(index);
  }

  Future<void> updateExam(int index, Exam exam) async {
    await _examBox.putAt(index, exam);
  }
}
