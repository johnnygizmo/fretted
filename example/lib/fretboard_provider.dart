import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fretted/fretted.dart';
import 'package:music_notes/music_notes.dart';

class FretboardNotifier extends StateNotifier<Fretboard> {
  FretboardNotifier()
      : super(Fretboard(
          name: '',
          extension: "",
          strings: 6,
          capo: 0,
          startFret: 1,
          frets: 4,
          tunings: const <Pitch>[
            Pitch(Note.e, octave: 2),
            Pitch(Note.a, octave: 2),
            Pitch(Note.d, octave: 3),
            Pitch(Note.g, octave: 3),
            Pitch(Note.b, octave: 3),
            Pitch(Note.e, octave: 4),
          ],
          fingerings: const [],
        ));

  void updateFretboard(Fretboard newFretboard) => state = newFretboard;

  void addFingering(Fingering fingering) {
    state = state.copyWith(fingerings: [...state.fingerings, fingering]);
  }

  void removeFingering(Fingering fingering) {
    state = state.copyWith(
        fingerings: state.fingerings.where((f) => f != fingering).toList());
  }

  void removeFingeringByPlacement(int string, int fret) {
    state = state.copyWith(
        fingerings: state.fingerings
            .where((f) => f.string != string && f.fret != fret)
            .toList());
  }

  void updateFingering(Fingering oldFingering, Fingering newFingering) {
    state = state.copyWith(
        fingerings: state.fingerings
            .map((f) => f == oldFingering ? newFingering : f)
            .toList());
  }

  void clearFingerings() => state = state.copyWith(fingerings: []);

  void setCapo(int capo) => state = state.copyWith(capo: capo);
  void setStartAt(int startAt) => state = state.copyWith(startFret: startAt);
  void setStrings(int strings) => state = state.copyWith(strings: strings);
  void setFrets(int frets) => state = state.copyWith(frets: frets);

  void setBarre(Fingering fingering, bool barre) {
    state = state.copyWith(
        fingerings: state.fingerings
            .map((f) => f == fingering ? f.copyWith(barre: barre ? 0 : -1) : f)
            .toList());
  }
}

final fretboardProvider =
    StateNotifierProvider<FretboardNotifier, Fretboard>((ref) {
  return FretboardNotifier();
});
