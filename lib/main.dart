import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'core/theme/app_theme.dart';
import 'core/models/subject.dart';
import 'features/dashboard/domain/models/exam.dart';
import 'features/study/domain/models/note.dart';
import 'features/vault/domain/models/vault_item.dart';
import 'features/navigation/presentation/pages/splash_page.dart';
import 'injection_container.dart' as di;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/dashboard/presentation/bloc/exam_bloc.dart';
import 'features/navigation/presentation/bloc/navigation_bloc.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Adapters
  Hive.registerAdapter(SubjectAdapter());
  Hive.registerAdapter(ExamAdapter());
  Hive.registerAdapter(NoteAdapter());
  Hive.registerAdapter(VaultItemAdapter());

  // Initialize Boxes with specific types to avoid Box<dynamic> conflicts
  await Hive.openBox<Subject>('subjects');
  await Hive.openBox<Exam>('exams');
  await Hive.openBox<Note>('notes');
  await Hive.openBox<VaultItem>('vault');

  // Initialize DI
  await di.init();

  // Initialize Notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: DarwinInitializationSettings(),
  );
  await flutterLocalNotificationsPlugin.initialize(
    settings: initializationSettings,
  );

  runApp(const LecturioApp());
}

class LecturioApp extends StatelessWidget {
  const LecturioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<NavigationBloc>()),
        BlocProvider(create: (_) => di.sl<ExamBloc>()..add(LoadExams())),
      ],
      child: MaterialApp(
        title: 'Lecturio',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const SplashPage(),
      ),
    );
  }
}
