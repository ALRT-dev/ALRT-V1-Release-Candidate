import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Shown the FIRST time someone taps a mic, before the OS microphone prompt.
/// Explains the privacy promise up front. Returns true if the user chose to
/// continue (the OS prompt then follows), false/null if they dismissed.
class VoicePrimingSheet extends StatelessWidget {
  const VoicePrimingSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const VoicePrimingSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF141416), Color(0xFF1E1416), Color(0xFF2A0F0A)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.spMin)),
      ),
      padding: EdgeInsets.fromLTRB(22.spMin, 26.spMin, 22.spMin, 26.spMin),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 66.spMin,
            height: 66.spMin,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B01).withValues(alpha: 0.14),
              border: Border.all(
                color: const Color(0xFFFF6B01).withValues(alpha: 0.4),
              ),
              borderRadius: BorderRadius.circular(20.spMin),
            ),
            child: Icon(
              LucideIcons.mic,
              size: 30.spMin,
              color: const Color(0xFFFF8C42),
            ),
          ),
          SizedBox(height: 18.spMin),
          Text(
            'Speak instead of typing',
            style: TextStyle(
              fontSize: 22.spMin,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.25,
            ),
          ),
          SizedBox(height: 10.spMin),
          Text(
            'Use your voice to search places and hazards. Handy when your '
            'hands are full, which around here is most of the time.',
            style: TextStyle(
              fontSize: 12.spMin,
              color: Colors.white.withValues(alpha: 0.62),
              height: 1.7,
            ),
          ),
          SizedBox(height: 14.spMin),
          Container(
            padding: EdgeInsets.all(13.spMin),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withValues(alpha: 0.1),
              border: Border.all(
                color: const Color(0xFF22C55E).withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(13.spMin),
            ),
            child: Text(
              'The microphone works only while you are speaking, after you tap '
              'it. Speech is recognised on your phone. ALRT never records, '
              'stores or sends audio, and there is no wake word.',
              style: TextStyle(
                fontSize: 10.5.spMin,
                color: const Color(0xFF7EE0B8),
                height: 1.6,
              ),
            ),
          ),
          SizedBox(height: 20.spMin),
          SizedBox(
            width: double.infinity,
            height: 50.spMin,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5000),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.spMin),
                ),
              ),
              child: Text(
                'Continue',
                style: TextStyle(
                  fontSize: 14.spMin,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
