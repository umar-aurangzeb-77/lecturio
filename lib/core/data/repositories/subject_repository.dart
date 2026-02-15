import 'package:hive/hive.dart';
import '../../models/subject.dart';

class SubjectRepository {
  final Box<Subject> _subjectBox = Hive.box<Subject>('subjects');

  List<Subject> getAllSubjects() {
    if (_subjectBox.isEmpty) {
      _seedDefaultSubjects();
    }
    return _subjectBox.values.toList();
  }

  void _seedDefaultSubjects() {
    final defaults = [
      Subject(
        id: '1',
        name: 'Computer Science',
        icon: 'laptop_code',
        color: '0xFF2196F3',
      ),
      Subject(
        id: '2',
        name: 'Mathematics',
        icon: 'calculator',
        color: '0xFF4CAF50',
      ),
      Subject(
        id: '3',
        name: 'Biology',
        icon: 'microscope',
        color: '0xFFFF9800',
      ),
      Subject(id: '4', name: 'History', icon: 'scroll', color: '0xFF9C27B0'),
    ];
    for (var subject in defaults) {
      _subjectBox.put(subject.id, subject);
    }
  }

  Future<void> addSubject(Subject subject) async {
    await _subjectBox.put(subject.id, subject);
  }
}
