---
name: flutter-dev-guide
description: "Use when: asking about Flutter/Dart development including architecture decisions, widget building, state management patterns, debugging errors, UI/UX implementation, performance optimization, code organization, best practices, or step-by-step help building Flutter features. Triggers on: 'how do I build X in Flutter', 'my Flutter app is crashing', 'what's the best way to structure this', audio player questions, or any mobile development topic."
---

# Flutter Development Guidance Skill

## Overview

This skill provides **detailed explanations and runnable code examples** for Flutter/Dart development. Always explain the *why* behind architectural decisions, not just the *what*. Prefer complete, tested code snippets over pseudocode or conceptual descriptions.

---

## Core Principles

1. **Explain with examples** — Every concept followed by working code snippet
2. **Explain the why** — Don't say "use X", explain why X beats Y in this context
3. **Progressive complexity** — Start simple, layer in features, handle edge cases last
4. **Point out pitfalls** — Always mention common mistakes and how to avoid them
5. **Complete examples** — Show integration points, not isolated fragments

---

## 1. Architecture & Project Structure

### Feature-First Folder Structure
For any app beyond toy-scale, use feature-based organization:

```
lib/
├── core/                   # Shared across features
│   ├── theme/
│   │   └── app_theme.dart
│   ├── utils/
│   │   └── constants.dart
│   └── services/           # Singleton services
│       ├── audio_service.dart
│       └── storage_service.dart
│
├── features/               # Feature modules
│   ├── player/
│   │   ├── data/
│   │   │   └── models/
│   │   │       └── song.dart
│   │   ├── logic/          # Business logic layer
│   │   │   └── providers/
│   │   │       └── player_provider.dart
│   │   └── ui/
│   │       ├── screens/
│   │       │   └── player_screen.dart
│   │       └── widgets/
│   │           ├── play_button.dart
│   │           └── progress_bar.dart
│   │
│   └── playlist/
│       ├── data/
│       ├── logic/
│       └── ui/
│
└── main.dart
```

**Why this structure?**
- Each feature is self-contained → easy to test, reuse, or remove
- Clear separation: data → logic → UI
- Scaling is predictable: add features, don't flatten the tree
- Team collaboration: features can be worked on independently

---

### State Management Selection

Choose based on app complexity:

| App Type | Recommended | Why |
|----------|------------|-----|
| Single screen, simple state | `setState` / `ValueNotifier` | No external dependency, good for prototypes |
| Medium app (5-10 screens) | `Provider` + `ChangeNotifier` or `Riverpod` | Good balance: simple API, testable, scalable |
| Large app (10+ features) | `Bloc/Cubit` or `Riverpod` with generators | Enforces patterns, great for teams |
| Real-time sync | `Firebase` + `StreamProvider` | Reactive by default |

---

## 2. Common Flutter Errors & Debugging

### Error: "Bad state: No ProviderScope found"
```dart
// ❌ WRONG: Missing ProviderScope
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyWidget(), // ← throws error if using Riverpod
    );
  }
}

// ✅ RIGHT: Wrap with ProviderScope
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(  // ← Add this
      child: MaterialApp(
        home: MyWidget(),
      ),
    );
  }
}
```

**Why?** Riverpod requires a `ProviderScope` to manage provider lifecycle and state.

---

### Error: "setState called after dispose"
```dart
// ❌ WRONG: Can crash if widget is disposed
Future<void> loadData() async {
  final data = await fetchData();
  setState(() {
    _data = data; // ← Crash if widget disposed during fetch
  });
}

// ✅ RIGHT: Check mounted first
Future<void> loadData() async {
  final data = await fetchData();
  if (mounted) { // ← Safe guard
    setState(() {
      _data = data;
    });
  }
}
```

**Why?** Async operations can complete after widget disposal. Always check `mounted`.

---

### Error: "RenderFlex overflowed by X pixels"
```dart
// ❌ WRONG: Row/Column don't handle overflow
Row(
  children: [
    Text('This text might be very long...'),
    Icon(Icons.star),
  ],
)

// ✅ RIGHT: Use Expanded to constrain width
Row(
  children: [
    Expanded(child: Text('This text might be very long...')),
    Icon(Icons.star),
  ],
)

// Alternative: Use SingleChildScrollView
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: [...]
  ),
)
```

**Why?** `Expanded` gives child a max width. `SingleChildScrollView` allows overflow.

---

### Error: "Null check operator on null"
```dart
// ❌ WRONG: Crashes if null
final name = user!.name.toUpperCase();

// ✅ RIGHT: Handle null gracefully
final name = user?.name?.toUpperCase() ?? 'Unknown';

// Even better: Use pattern matching (Dart 3+)
final name = switch(user?.name) {
  null => 'Unknown',
  final name => name.toUpperCase(),
};
```

**Why?** Null safety prevents runtime crashes. Use null-coalescing operators.

---

## 3. UI/UX Best Practices

### Widget Selection Quick Reference

| Goal | Widget |
|------|--------|
| List with many items | `ListView.builder` (not `ListView(children: [...])`) |
| Grid of items | `GridView.builder` with `SliverGridDelegateWithFixedCrossAxisCount` |
| Scrollable layout | `SingleChildScrollView` or `CustomScrollView` |
| Conditional rendering | Collection-if: `if (condition) widget` |
| Fixed/flexible space | `SizedBox` (fixed), `Spacer` (flexible) |
| Overlapping elements | `Stack` with `Positioned` |
| Animated transitions | `AnimatedSwitcher`, `AnimatedOpacity` |
| Form inputs | `TextFormField` (auto-validation) vs `TextField` |

### Responsive Design Pattern
```dart
// ❌ WRONG: Hardcoded sizes
Container(width: 200, height: 100)

// ✅ RIGHT: Responsive
Container(
  width: MediaQuery.of(context).size.width * 0.8,
  height: MediaQuery.of(context).size.height * 0.5,
)

// BEST: Use LayoutBuilder for fine-grained control
LayoutBuilder(
  builder: (context, constraints) {
    return Container(
      width: constraints.maxWidth * 0.9,
      height: constraints.maxHeight * 0.5,
      child: MyContent(),
    );
  },
)
```

---

### Dark Theme Setup
```dart
ThemeData.dark().copyWith(
  scaffoldBackgroundColor: const Color(0xFF121212),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1E1E1E),
    elevation: 0,
  ),
  colorScheme: ColorScheme.dark(
    primary: Colors.blue,
    surface: const Color(0xFF2C2C2E),
    onSurface: Colors.white,
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    bodyMedium: TextStyle(
      fontSize: 16,
      color: Color(0xFFB0B0B0),
    ),
  ),
)
```

---

## 4. Code Quality & Best Practices

### ✅ Performance Checklist

- [ ] Use `const` constructors for widgets that don't change
  ```dart
  const Text('Static text')  // ✓ Good
  Text('Static text')        // ✗ Rebuilds every time
  ```

- [ ] Extract heavy widget builds into separate classes
  ```dart
  // ✓ Good
  class MyExpensiveWidget extends StatelessWidget {
    @override
    Widget build(BuildContext context) => ...
  }

  // ✗ Bad (rebuilds parent, rebuilds expensive widget)
  Widget _buildExpensive() => ...
  ```

- [ ] Use `ListView.builder` instead of `ListView(children: [...])`
  ```dart
  ListView.builder(          // ✓ Lazy-loaded, efficient
    itemCount: 1000,
    itemBuilder: (ctx, i) => ...,
  )

  ListView(children: [       // ✗ Builds all 1000 at once
    for (int i = 0; i < 1000; i++) ...,
  ])
  ```

- [ ] Memoize expensive computations
  ```dart
  @riverpod
  int expensiveComputation(ExpensiveComputationRef ref) {
    // This result is cached and only recalculates when dependencies change
    return complexMath();
  }
  ```

---

### ✅ Readability Checklist

- [ ] Extract widgets >50 lines into their own class
- [ ] Name methods as verbs: `playAudio()`, `fetchSongs()`, `validateInput()`
- [ ] Name booleans as questions: `isPlaying`, `hasError`, `canSubmit`
- [ ] Use meaningful variable names
  ```dart
  final dp = 300;       // ✗ What is dp?
  final duration = Duration(milliseconds: 300);  // ✓ Clear
  ```

- [ ] Group related properties, methods together
- [ ] Add comments for *why*, not *what*
  ```dart
  // ✗ Comments the code
  // Add 1 to count
  count++;

  // ✓ Comments the intent
  // Increment to move to next song
  currentIndex++;
  ```

---

### ✅ State Management Hygiene

- [ ] Dispose controllers and listeners
  ```dart
  @override
  void dispose() {
    _audioPlayerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  ```

- [ ] Never hold `BuildContext` in non-widget classes
- [ ] Check `mounted` before calling `setState` after async operations
- [ ] Use `final` instead of `var` for immutable values
  ```dart
  final song = songs[0];    // ✓ Won't change
  var player = AudioPlayer(); // ✓ Fine for mutable objects
  ```

---

## 5. Step-by-Step Feature Building

### Pattern: Data → Logic → UI

Always follow this order:

**Step 1: Define the data model**
```dart
class Song {
  final String id;
  final String title;
  final String artist;
  final Duration duration;
  final String filePath;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.duration,
    required this.filePath,
  });
}
```

**Step 2: Business logic (State Management)**
```dart
@riverpod
class PlayerLogic extends _$PlayerLogic {
  @override
  bool build() => false; // Initial state: not playing

  Future<void> play() async {
    // Implement logic
    state = true;
  }

  Future<void> pause() async {
    state = false;
  }
}
```

**Step 3: UI (Consume the logic)**
```dart
class PlayerScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying = ref.watch(playerLogicProvider);
    final notifier = ref.read(playerLogicProvider.notifier);

    return Column(
      children: [
        if (isPlaying) Text('Now Playing') else Text('Paused'),
        ElevatedButton(
          onPressed: () {
            if (isPlaying) {
              notifier.pause();
            } else {
              notifier.play();
            }
          },
          child: Text(isPlaying ? 'Pause' : 'Play'),
        ),
      ],
    );
  }
}
```

---

## 6. Debugging Tools & Techniques

### Must-Know Tools

**1. Flutter DevTools**
```bash
flutter pub global activate devtools
flutter pub global run devtools
# Visit http://localhost:9100 in browser
```
- Inspect widget tree
- Debug memory leaks
- Profile performance

**2. Debug Print**
```dart
// Use debugPrint, not print (throttles output)
debugPrint('User tapped button'); // ✓
print('User tapped button');       // ✗ Can spam logs

// Pretty print complex objects
debugPrint('Song: ${jsonEncode(song.toJson())}');
```

**3. Dump Widget Tree**
```dart
// In debug console
>> debugDumpApp()  // Prints entire widget tree
```

**4. Hot Reload vs Hot Restart**
- **Hot Reload** (Ctrl+S): Fast, keeps state → good for UI changes
- **Hot Restart** (Shift+R): Slow, resets state → need this for const changes, service initialization

---

## 7. Riverpod-Specific Patterns

### Watch vs Read

```dart
// ❌ WRONG: Using watch in non-reactive context
Future<void> loadData() async {
  final songs = ref.watch(playlistProvider); // ← Rebuilds on change
}

// ✅ RIGHT: Use watch in build(), read in callbacks
@override
Widget build(BuildContext context, WidgetRef ref) {
  final songs = ref.watch(playlistProvider); // ← OK here
  return Button(
    onPressed: () {
      final songs = ref.read(playlistProvider); // ← Use read in callbacks
    },
  );
}
```

**Why?** `watch` rebuilds when dependency changes (ok in build). `read` gets current value without listening (use in callbacks).

---

### StreamProvider vs FutureProvider

```dart
// Use StreamProvider for continuous updates
@riverpod
Stream<Duration> audioPosition(AudioPositionRef ref) {
  return ref.watch(audioServiceProvider).positionStream;
}

// Use FutureProvider for one-time async operations
@riverpod
Future<List<Song>> fetchPlaylists(FetchPlaylistsRef ref) async {
  return ref.watch(apiServiceProvider).getPlaylists();
}
```

---

## 8. Common Gotchas & Solutions

| Problem | Gotcha | Solution |
|---------|--------|----------|
| Audio doesn't play | Forgot to load song before play | Call `loadSong()` before `play()` |
| Provider not updating | Watching in callback, not build | Use `watch` in build(), `read` in callbacks |
| Memory leak | AudioPlayer not disposed | Use `ref.onDispose()` in @riverpod |
| UI doesn't update | Not using `setState` in StatefulWidget | Use `setState(() { ... })` or switch to Riverpod |
| Code generation fails | Didn't run build_runner | `flutter pub run build_runner build` |
| Hot reload doesn't work | Changed const values | Use hot restart (Shift+R) instead |

---

## 9. Package Recommendations

| Purpose | Package | Pub Points | Notes |
|---------|---------|-----------|-------|
| Audio playback | `just_audio` | 160+ | Best for basic audio, good docs |
| State management | `riverpod` | 160+ | Type-safe, code generation |
| Local storage | `hive` | 150+ | Fast, no setup needed |
| HTTP requests | `dio` | 140+ | Retry, interceptors, easy |
| Navigation | `go_router` | 150+ | Declarative, deep linking |
| Logging | `logger` | 140+ | Pretty output, configurable |

Always prefer packages with:
- Pub points ≥ 120
- Popularity ≥ 80%  
- Recent updates (within 6 months)

---

## Quick Reference: Code Patterns

### Dispose Pattern
```dart
@override
void dispose() {
  // 1. Controllers
  _textController.dispose();
  _scrollController.dispose();
  
  // 2. Animations
  _animController.dispose();
  
  // 3. Streams
  _streamSubscription?.cancel();
  
  super.dispose();
}
```

### Async + Mounted Pattern
```dart
void _loadData() async {
  final data = await fetchData();
  if (mounted) {
    setState(() => _data = data);
  }
}
```

### List Building Pattern (No hardcoded lists)
```dart
@riverpod
class MyListNotifier extends _$MyListNotifier {
  @override
  List<Item> build() => [];

  void add(Item item) => state = [...state, item];
  void remove(String id) => state = state.where((i) => i.id != id).toList();
  void clear() => state = [];
}
```

---

## When to Refactor

Ask yourself:
- ✅ Is this widget >60 lines? → Extract to new class
- ✅ Do I repeat this pattern 3+ times? → Create helper/mixin
- ✅ Is this testable? → If no, separate logic from UI
- ✅ Can someone understand this in 1 minute? → If no, add docs or simplify

---

## References

- [Flutter Official Docs](https://flutter.dev/docs)
- [Riverpod Docs](https://riverpod.dev)
- [Pub.dev](https://pub.dev) — Package search
- [Stack Overflow: Flutter Tag](https://stackoverflow.com/questions/tagged/flutter)
