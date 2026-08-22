import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/others/app_theme.dart';

class EmojiText extends ConsumerWidget {
  const EmojiText(
    this.data, {
    super.key,
    this.style,
    this.emojiStyle,
    this.maxLines,
    this.overflow,
  });

  final String data;

  final TextStyle? style;

  final TextStyle? emojiStyle;

  final int? maxLines;

  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Text.rich(
      TextSpan(
        children: _parseEmojiText(
          context: context,
          input: data,
          style: style,
          emojiStyle: emojiStyle,
        ),
      ),
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  List<InlineSpan> _parseEmojiText({
    required BuildContext context,
    required String input,
    final TextStyle? style,
    final TextStyle? emojiStyle,
  }) {
    // default styles: keep fontFamily for normal text, but avoid forcing fontFamily on emojiStyle
    final normalStyle = style ??
        TextStyle(
          fontSize: 14.sp,
          fontFamily: AppTheme.defaultFontFamily,
          height: 1.0,
        );
    final defaultEmojiStyle = emojiStyle ??
        TextStyle(
          fontSize: (normalStyle.fontSize ?? 14.sp) * 1.25,
          height: 1.0,
        );

    bool isEmojiRune(int code) {
      // common emoji/ pictograph ranges + modifiers, ZWJ, variation selectors, regional indicators
      const ranges = [
        [0x203C, 0x3299],
        [0x2600, 0x26FF],
        [0x2700, 0x27BF],
        [0xFE00, 0xFE0F], // variation selectors
        [0x1F000, 0x1FAFF],
        [0x1F300, 0x1F6FF],
        [0x1F900, 0x1F9FF],
        [0x1F1E6, 0x1F1FF], // regional indicators (flags)
        [0x1F3FB, 0x1F3FF], // skin tones
        [0x200D, 0x200D], // zero width joiner
      ];

      for (final r in ranges) {
        if (code >= r[0] && code <= r[1]) return true;
      }
      return false;
    }

    bool isEmojiCluster(String cluster) {
      for (final r in cluster.runes) {
        if (isEmojiRune(r)) return true;
      }
      return false;
    }

    final spans = <InlineSpan>[];
    final chars = input.characters;

    // build grouped spans (fewer TextSpans than per-character)
    final buffer = StringBuffer();
    bool? lastWasEmoji;
    for (final ch in chars) {
      final isEmoji = isEmojiCluster(ch);
      if (lastWasEmoji == null) {
        lastWasEmoji = isEmoji;
        buffer.write(ch);
      } else if (isEmoji == lastWasEmoji) {
        buffer.write(ch);
      } else {
        // flush
        if (lastWasEmoji) {
          spans
              .add(TextSpan(text: buffer.toString(), style: defaultEmojiStyle));
        } else {
          spans.add(TextSpan(text: buffer.toString(), style: normalStyle));
        }
        buffer.clear();
        lastWasEmoji = isEmoji;
        buffer.write(ch);
      }
    }

    if (buffer.isNotEmpty) {
      if (lastWasEmoji == true) {
        spans.add(TextSpan(text: buffer.toString(), style: defaultEmojiStyle));
      } else {
        spans.add(TextSpan(text: buffer.toString(), style: normalStyle));
      }
    }

    return spans;
  }
}
