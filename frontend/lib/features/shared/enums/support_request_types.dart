import 'package:json_annotation/json_annotation.dart';

/// Enum for support request types.
@JsonEnum(valueField: 'value')
enum SupportRequestType {
  /// Support request type.
  support('support'),

  /// Feedback request type.
  feedback('feedback'),

  /// Question request type.
  question('question'),

  /// Other request type.
  other('other');

  const SupportRequestType(this.value);

  /// The string value of the support request type.
  final String value;
}
