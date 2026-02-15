import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/models/exam.dart';
import '../../data/repositories/exam_repository.dart';

// Events
abstract class ExamEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadExams extends ExamEvent {}

class AddExam extends ExamEvent {
  final Exam exam;
  AddExam(this.exam);

  @override
  List<Object> get props => [exam];
}

class DeleteExam extends ExamEvent {
  final int index;
  DeleteExam(this.index);

  @override
  List<Object> get props => [index];
}

// State
abstract class ExamState extends Equatable {
  @override
  List<Object> get props => [];
}

class ExamInitial extends ExamState {}

class ExamLoading extends ExamState {}

class ExamLoaded extends ExamState {
  final List<Exam> exams;
  ExamLoaded(this.exams);

  @override
  List<Object> get props => [exams];
}

class ExamError extends ExamState {
  final String message;
  ExamError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class ExamBloc extends Bloc<ExamEvent, ExamState> {
  final ExamRepository repository;

  ExamBloc(this.repository) : super(ExamInitial()) {
    on<LoadExams>((event, emit) {
      emit(ExamLoading());
      try {
        final exams = repository.getAllExams();
        emit(ExamLoaded(exams));
      } catch (e) {
        emit(ExamError(e.toString()));
      }
    });

    on<AddExam>((event, emit) async {
      try {
        await repository.addExam(event.exam);
        add(LoadExams());
      } catch (e) {
        emit(ExamError(e.toString()));
      }
    });

    on<DeleteExam>((event, emit) async {
      try {
        await repository.deleteExam(event.index);
        add(LoadExams());
      } catch (e) {
        emit(ExamError(e.toString()));
      }
    });
  }
}
