import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/shared/services/voice_command.dart';

/// Speak to ALRT (ruling 16 Oct 2026, one mic). What a sentence is taken to
/// mean decides whether something is saved or sent, so the parsing is pinned.
void main() {
  VoiceCommand p(final String s) => VoiceCommand.parse(s);

  test('a place name is a search', () {
    final c = p('Scarborough Beach Road');
    expect(c.kind, VoiceCommandKind.search);
    expect(c.place, 'Scarborough Beach Road');
    expect(c.needsConfirmation, isFalse);
  });

  test('save a place, asking first', () {
    final c = p('Save Scarborough as a place');
    expect(c.kind, VoiceCommandKind.savePlace);
    expect(c.place, 'Scarborough');
    expect(c.needsConfirmation, isTrue);
    expect(p('add my mum\'s place to my saved places').kind,
        VoiceCommandKind.savePlace);
    expect(p('Remember Trigg as a location').place, 'Trigg');
    expect(p('save the Perth CBD as a place').place, 'Perth CBD');
  });

  test('send an alert to a group, asking first', () {
    final c = p('Send this alert to my group');
    expect(c.kind, VoiceCommandKind.sendAlert);
    expect(c.alertWords, '');
    expect(c.groupWords, '');
    expect(c.needsConfirmation, isTrue);
    final d = p('share the Neerabup fire with the Nixon group');
    expect(d.kind, VoiceCommandKind.sendAlert);
    expect(d.alertWords, 'neerabup fire');
    expect(d.groupWords, 'nixon');
  });

  test('check in, asking first', () {
    expect(p('Check in').kind, VoiceCommandKind.checkIn);
    expect(p('check in').needsConfirmation, isTrue);
    expect(p("tell my group I'm here").kind, VoiceCommandKind.checkIn);
  });

  test('SOS is never done by voice', () {
    expect(p('send an SOS to my group').kind, VoiceCommandKind.sosRefused);
    expect(p('S.O.S').kind, VoiceCommandKind.sosRefused);
    expect(p('send an SOS to my group').needsConfirmation, isFalse);
  });

  test('a hazard description opens Post an ALRT, never posts', () {
    expect(p('there is a tree down on Smith Street').kind,
        VoiceCommandKind.report);
    expect(p('I can see smoke near the school').kind, VoiceCommandKind.report);
    expect(p('there is a tree down').needsConfirmation, isFalse);
  });

  test('read, near me, route and questions', () {
    expect(p('Read the warning near me').kind, VoiceCommandKind.readAlert);
    expect(p("What's near me?").kind, VoiceCommandKind.nearMe);
    final r = p('Take me to Perth CBD');
    expect(r.kind, VoiceCommandKind.route);
    expect(r.place, 'Perth CBD');
    expect(p('take me to perth cbd').place, 'Perth Cbd');
    expect(p('what does Watch and Act mean?').kind, VoiceCommandKind.ask);
    expect(p('should I leave now?').kind, VoiceCommandKind.ask);
  });

  test('send needs a group or an alert word, so directions are not a send', () {
    expect(p('send me directions to Joondalup').kind,
        isNot(VoiceCommandKind.sendAlert));
  });

  test('a question about a hazard is a question, not a report', () {
    expect(p('is there a fire near the school?').kind, VoiceCommandKind.ask);
  });

  test('never throws on empty or odd input', () {
    expect(p('').kind, VoiceCommandKind.search);
    expect(p('   ').kind, VoiceCommandKind.search);
    expect(p('!!!').kind, VoiceCommandKind.search);
  });
}
