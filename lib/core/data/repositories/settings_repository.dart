import 'package:hive/hive.dart';

class SettingsRepository {
  final Box _settingsBox = Hive.box('settings');

  String? getGeminiApiKey() {
    return _settingsBox.get('gemini_api_key');
  }

  Future<void> saveGeminiApiKey(String key) async {
    await _settingsBox.put('gemini_api_key', key);
  }
}
