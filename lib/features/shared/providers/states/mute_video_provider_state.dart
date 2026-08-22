import 'package:freezed_annotation/freezed_annotation.dart';

part 'mute_video_provider_state.freezed.dart';

@freezed
abstract class MuteVideoProviderState with _$MuteVideoProviderState {
  const factory MuteVideoProviderState({
    @Default(false) final bool isMuted,
  }) = _MuteVideoProviderState;
}
