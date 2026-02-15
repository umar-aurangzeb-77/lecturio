import 'package:get_it/get_it.dart';
import 'features/dashboard/data/repositories/exam_repository.dart';
import 'core/data/repositories/subject_repository.dart';
import 'features/dashboard/presentation/bloc/exam_bloc.dart';
import 'features/navigation/presentation/bloc/navigation_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Blocs
  sl.registerFactory(() => ExamBloc(sl()));
  sl.registerFactory(() => NavigationBloc());

  // Repositories
  sl.registerLazySingleton(() => ExamRepository());
  sl.registerLazySingleton(() => SubjectRepository());
}
