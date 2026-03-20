// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentSongHash() => r'd4ad2d670a6b4206816d0856384562967f5b6be6';

/// See also [currentSong].
@ProviderFor(currentSong)
final currentSongProvider = AutoDisposeProvider<Song?>.internal(
  currentSong,
  name: r'currentSongProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentSongHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentSongRef = AutoDisposeProviderRef<Song?>;
String _$audioPlayerHash() => r'6b8d29b09aba22b19637c6130009c8c5eb23e45d';

/// See also [audioPlayer].
@ProviderFor(audioPlayer)
final audioPlayerProvider = AutoDisposeProvider<AudioPlayer>.internal(
  audioPlayer,
  name: r'audioPlayerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$audioPlayerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AudioPlayerRef = AutoDisposeProviderRef<AudioPlayer>;
String _$currentPositionHash() => r'28ae17bd3d0c3742eedf3e7b6217923d9dd02132';

/// See also [currentPosition].
@ProviderFor(currentPosition)
final currentPositionProvider = AutoDisposeStreamProvider<Duration>.internal(
  currentPosition,
  name: r'currentPositionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentPositionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentPositionRef = AutoDisposeStreamProviderRef<Duration>;
String _$totalDurationHash() => r'cd800968057145aa389d5a0040675cb702c9cf8c';

/// See also [totalDuration].
@ProviderFor(totalDuration)
final totalDurationProvider = AutoDisposeStreamProvider<Duration?>.internal(
  totalDuration,
  name: r'totalDurationProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$totalDurationHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TotalDurationRef = AutoDisposeStreamProviderRef<Duration?>;
String _$currentSongIndexHash() => r'020767e3d6c3f1e9e8efe77277740d5a44449d11';

/// See also [CurrentSongIndex].
@ProviderFor(CurrentSongIndex)
final currentSongIndexProvider =
    AutoDisposeNotifierProvider<CurrentSongIndex, int>.internal(
      CurrentSongIndex.new,
      name: r'currentSongIndexProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentSongIndexHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CurrentSongIndex = AutoDisposeNotifier<int>;
String _$playingStateHash() => r'69e843f73c2631c391bb3b5ed03d726ae781a969';

/// See also [PlayingState].
@ProviderFor(PlayingState)
final playingStateProvider =
    AutoDisposeNotifierProvider<PlayingState, bool>.internal(
      PlayingState.new,
      name: r'playingStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$playingStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PlayingState = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
