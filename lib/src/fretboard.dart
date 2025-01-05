import 'package:fretted/fretted.dart';
import 'package:music_notes/music_notes.dart';

class Fretboard {
  Fretboard(
      {this.name = "",
      this.extension = "",
      this.strings = 6,
      this.capo = 0,
      this.startFret = 1,
      this.frets = 4,
      this.tunings = const <Pitch>[
        Pitch(Note.e, octave: 2),
        Pitch(Note.a, octave: 2),
        Pitch(Note.d, octave: 3),
        Pitch(Note.g, octave: 3),
        Pitch(Note.b, octave: 3),
        Pitch(Note.e, octave: 4),
      ],
      this.fingerings = const <Fingering>[]}) {
    if (tunings.length != strings) {
      throw ArgumentError(
          'Number of tunings (${tunings.length}) must match number of strings ($strings)');
    }
    for (var f in fingerings) {
      if ((f.fret != null && f.fret! < 0) ||
          f.string < 0 ||
          f.string > strings) {
        throw ArgumentError(
            'Fingering (Fret:${f.fret} String:${f.string}) is invalid');
      }
    }
  }

  String name;
  String extension;
  int strings;
  int capo;
  int startFret;
  int frets;
  List<Pitch> tunings;
  List<Fingering> fingerings;

  Note? getNote(Fingering fingering) {
    if (fingering.fret == null) {
      return null;
    }

    return tunings[strings - fingering.string]
        .transposeBy(Interval.fromSemitones(fingering.fret!))
        .note;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'extension': extension,
        'strings': strings,
        'capo': capo,
        'startFret': startFret,
        'frets': frets,
        'tunings': tunings.map((pitch) => pitch.toString()).toList(),
        'fingerings': fingerings.map((f) => f.toJson()).toList(),
      };

  factory Fretboard.fromJson(Map<String, dynamic> json) {
    return Fretboard(
      name: json['name'] as String? ?? '',
      extension: json['extension'] as String? ?? '',
      strings: json['strings'] as int? ?? 6,
      capo: json['capo'] as int? ?? 0,
      frets: json['frets'] as int? ?? 4,
      startFret: json['startFret'] as int? ?? 1,
      tunings: (json['tunings'] as List<dynamic>?)
              ?.map((t) => Pitch.parse(t as String))
              .toList() ??
          const <Pitch>[
            Pitch(Note.e, octave: 2),
            Pitch(Note.a, octave: 2),
            Pitch(Note.d, octave: 3),
            Pitch(Note.g, octave: 3),
            Pitch(Note.b, octave: 3),
            Pitch(Note.e, octave: 4),
          ],
      fingerings: (json['fingerings'] as List<dynamic>?)
              ?.map((f) => Fingering.fromJson(f as Map<String, dynamic>))
              .toList() ??
          const <Fingering>[],
    );
  }

  Fretboard copyWith({
    String? name,
    String? extension,
    int? strings,
    int? capo,
    int? startFret,
    int? frets,
    List<Pitch>? tunings,
    List<Fingering>? fingerings,
  }) {
    var ret = Fretboard(
      name: name ?? this.name,
      extension: extension ?? this.extension,
      strings: strings ?? this.strings,
      capo: capo ?? this.capo,
      startFret: startFret ?? this.startFret,
      frets: frets ?? this.frets,
      tunings: tunings ?? this.tunings,
      fingerings: fingerings ?? this.fingerings,
    );
    return ret;
  }
}
