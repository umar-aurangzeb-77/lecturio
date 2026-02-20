import 'package:flutter_bloc/flutter_bloc.dart';

enum AppThemeMode { green, dark }

class ThemeState {
  final AppThemeMode themeMode;
  ThemeState(this.themeMode);
}

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeState(AppThemeMode.green)) {
    on<ToggleTheme>((event, emit) {
      if (state.themeMode == AppThemeMode.green) {
        emit(ThemeState(AppThemeMode.dark));
      } else {
        emit(ThemeState(AppThemeMode.green));
      }
    });
  }
}

abstract class ThemeEvent {}

class ToggleTheme extends ThemeEvent {}
