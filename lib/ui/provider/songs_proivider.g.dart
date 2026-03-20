// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'songs_proivider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$audioQueryServiceHash() => r'648b79a9efa436b6a3eceff62d9f442d718ca79c';

/// See also [audioQueryService].
@ProviderFor(audioQueryService)
final audioQueryServiceProvider =
    AutoDisposeProvider<AudioQueryService>.internal(
      audioQueryService,
      name: r'audioQueryServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$audioQueryServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AudioQueryServiceRef = AutoDisposeProviderRef<AudioQueryService>;
String _$playlistHash() => r'dc1630ae959e1a3dcad60bc3d54f7dfe300ab9a5';

/// Shortcut for accessing the playlist
///
/// Copied from [playlist].
@ProviderFor(playlist)
final playlistProvider = AutoDisposeProvider<List<Song>>.internal(
  playlist,
  name: r'playlistProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$playlistHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PlaylistRef = AutoDisposeProviderRef<List<Song>>;
String _$permissionHash() => r'604b998b4a71eeefe4160aeb075d0743e396a5b1';

/// Provider to check and request permissions
///
/// Copied from [permission].
@ProviderFor(permission)
final permissionProvider = AutoDisposeFutureProvider<bool>.internal(
  permission,
  name: r'permissionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$permissionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PermissionRef = AutoDisposeFutureProviderRef<bool>;
String _$playlistNotifierHash() => r'49fcb70de3e7584115a59cef37fda29af09cbd0f';

/// Provider to store the playlist (starts empty)
///
/// Copied from [PlaylistNotifier].
@ProviderFor(PlaylistNotifier)
final playlistNotifierProvider =
    AutoDisposeNotifierProvider<PlaylistNotifier, List<Song>>.internal(
      PlaylistNotifier.new,
      name: r'playlistNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$playlistNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PlaylistNotifier = AutoDisposeNotifier<List<Song>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
