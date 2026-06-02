// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AudioLibraryNotifier)
final audioLibraryProvider = AudioLibraryNotifierProvider._();

final class AudioLibraryNotifierProvider
    extends
        $AsyncNotifierProvider<
          AudioLibraryNotifier,
          List<Map<String, dynamic>>
        > {
  AudioLibraryNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'audioLibraryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$audioLibraryNotifierHash();

  @$internal
  @override
  AudioLibraryNotifier create() => AudioLibraryNotifier();
}

String _$audioLibraryNotifierHash() =>
    r'398148698bb04a39ead0ba31100d5c52b9728f9b';

abstract class _$AudioLibraryNotifier
    extends $AsyncNotifier<List<Map<String, dynamic>>> {
  FutureOr<List<Map<String, dynamic>>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<Map<String, dynamic>>>,
              List<Map<String, dynamic>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<Map<String, dynamic>>>,
                List<Map<String, dynamic>>
              >,
              AsyncValue<List<Map<String, dynamic>>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
