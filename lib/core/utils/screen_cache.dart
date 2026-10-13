/// In-memory cache of the last loaded screen data, so screens can render
/// instantly when revisited and refresh quietly in the background.
class ScreenCache {
  ScreenCache._();

  static final Map<String, Object> _store = {};

  static T? read<T>(String key) {
    final value = _store[key];
    return value is T ? value : null;
  }

  static void write(String key, Object value) => _store[key] = value;

  static void clear() => _store.clear();
}
