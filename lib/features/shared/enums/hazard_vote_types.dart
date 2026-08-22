import 'package:freezed_annotation/freezed_annotation.dart';

enum HazardVoteType {
  @JsonValue('upvote')
  upvote,

  @JsonValue('downvote')
  downvote,
}
