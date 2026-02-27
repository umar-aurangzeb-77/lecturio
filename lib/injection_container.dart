import 'package:get_it/get_it.dart';
import 'package:lecturio/features/dashboard/data/repositories/exam_repository.dart';
import 'package:lecturio/core/data/repositories/subject_repository.dart';
import 'package:lecturio/core/data/repositories/note_repository.dart';
import 'package:lecturio/core/data/repositories/vault_repository.dart';
import 'package:lecturio/features/dashboard/presentation/bloc/exam_bloc.dart';
import 'package:lecturio/features/navigation/presentation/bloc/navigation_bloc.dart';
import 'package:lecturio/core/network/gemini_service.dart';
import 'package:lecturio/core/data/repositories/settings_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Services
  sl.registerLazySingleton(() => GeminiService(sl()));

  // Blocs
  sl.registerFactory(() => ExamBloc(sl()));
  sl.registerFactory(() => NavigationBloc());

  // Repositories
  sl.registerLazySingleton(() => SettingsRepository());
  sl.registerLazySingleton(() => ExamRepository());
  sl.registerLazySingleton(() => SubjectRepository());
  sl.registerLazySingleton(() => NoteRepository());
  sl.registerLazySingleton(() => VaultRepository());
}
