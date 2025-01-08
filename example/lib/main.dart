import 'dart:convert';

import 'package:example/fretboard_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fretted/fretted.dart';

import 'package:music_notes/music_notes.dart' as music;
import 'package:flutter_spinbox/material.dart';
import 'package:web_image_downloader/web_image_downloader.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

final sizeProvider = StateProvider<Size>(
  (ref) => Size(300, 300),
);

final showPitchProvider = StateProvider<bool>((ref) {
  return false;
});

final spellWithProvider = StateProvider<music.Accidental>((ref) {
  return music.Accidental.flat;
});

final fretsProvider = StateProvider<int>((ref) {
  return 4;
});

final headerSizeProvider = StateProvider<double>((ref) {
  return 40;
});

GlobalKey _globalKey = GlobalKey();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fretboard Maker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Fretboard Maker'),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  late TextEditingController _controller;
  late TextEditingController _extController;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: ref.read(fretboardProvider).name);
    _extController =
        TextEditingController(text: ref.read(fretboardProvider).extension);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(showPitchProvider);
    ref.watch(spellWithProvider);
    ref.watch(sizeProvider);
    ref.watch(headerSizeProvider);
    var f = ref.watch(fretboardProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: () {
                //print(jsonEncode(ref.read(fretboardProvider).toJson()));
              },
              icon: Icon(Icons.download)),
          IconButton(
              onPressed: () {
                String s = _extController.text;

                var f =
                    Fretboard.fromJson(jsonDecode(s) as Map<String, dynamic>);
                ref.read(fretboardProvider.notifier).updateFretboard(f);

                _extController.text = "";
              },
              icon: Icon(Icons.upload))
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Size - Height:"),
                  SizedBox(
                    height: 45,
                    width: 150,
                    child: SpinBox(
                      min: 100,
                      max: 1000,
                      value: ref.read(sizeProvider).height,
                      onChanged: (value) {
                        ref.read(sizeProvider.notifier).state =
                            Size(ref.read(sizeProvider).width, value);
                      },
                    ),
                  ),
                  Text(" Width: "),
                  SizedBox(
                    height: 45,
                    width: 150,
                    child: SpinBox(
                      min: 100,
                      max: 1000,
                      value: ref.read(sizeProvider).width,
                      onChanged: (value) {
                        ref.read(sizeProvider.notifier).state = Size(
                          value,
                          ref.read(sizeProvider).height,
                        );
                      },
                    ),
                  ),
                  Text(" Header Size: "),
                  SizedBox(
                    height: 45,
                    width: 150,
                    child: SpinBox(
                      min: 1,
                      max: 1000,
                      value: ref.read(headerSizeProvider),
                      onChanged: (value) {
                        ref.read(headerSizeProvider.notifier).state = value;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 300,
                    child: Row(
                      children: [
                        Text("Frets: "),
                        SizedBox(
                          width: 150,
                          child: SpinBox(
                              min: 1,
                              max: 24,
                              value:
                                  ref.read(fretboardProvider).frets.toDouble(),
                              onChanged: (value) => ref
                                  .read(fretboardProvider.notifier)
                                  .setFrets(value.toInt())),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    child: Row(
                      children: [
                        Text("Capo At: "),
                        SizedBox(
                          width: 150,
                          child: SpinBox(
                              min: 0,
                              max: 24,
                              value:
                                  ref.read(fretboardProvider).capo.toDouble(),
                              onChanged: (value) => ref
                                  .read(fretboardProvider.notifier)
                                  .setCapo(value.toInt())),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    child: Row(
                      children: [
                        Text("Starting Fret: "),
                        SizedBox(
                          width: 150,
                          child: SpinBox(
                              min: 1,
                              max: 24,
                              value: ref
                                  .read(fretboardProvider)
                                  .startFret
                                  .toDouble(),
                              onChanged: (value) => ref
                                  .read(fretboardProvider.notifier)
                                  .setStartAt(value.toInt())),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Show Dots"),
                  Switch(
                      value: ref.read(showPitchProvider),
                      onChanged: (value) {
                        ref.read(showPitchProvider.notifier).state = value;
                      }),
                  Text("Show Pitch"),
                  SizedBox(
                    width: 35,
                  ),
                  Text("Spell with Flats"),
                  Switch(
                      value:
                          ref.read(spellWithProvider) == music.Accidental.sharp,
                      onChanged: (value) {
                        if (value) {
                          ref.read(spellWithProvider.notifier).state =
                              music.Accidental.sharp;
                        } else {
                          ref.read(spellWithProvider.notifier).state =
                              music.Accidental.flat;
                        }
                      }),
                  Text("Spell with Sharps"),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Title: "),
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      onChanged: (value) {
                        var fb = ref.read(fretboardProvider);

                        ref
                            .read(fretboardProvider.notifier)
                            .updateFretboard(fb.copyWith(name: value));
                      },
                    ),
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            var f = ref.read(fretboardProvider);
                            ref
                                .read(fretboardProvider.notifier)
                                .updateFretboard(
                                    f.copyWith(name: "${f.name}♭"));
                            _controller.text = "${_controller.text}♭";
                          },
                          child: Text("♭")),
                      ElevatedButton(
                          onPressed: () {
                            var f = ref.read(fretboardProvider);
                            ref
                                .read(fretboardProvider.notifier)
                                .updateFretboard(
                                    f.copyWith(name: "${f.name}♯"));
                            _controller.text = "${_controller.text}♯";
                          },
                          child: Text("♯")),
                      ElevatedButton(
                          onPressed: () {
                            var f = ref.read(fretboardProvider);
                            ref
                                .read(fretboardProvider.notifier)
                                .updateFretboard(
                                    f.copyWith(name: "${f.name}♮"));
                            _controller.text = "${_controller.text}♮";
                          },
                          child: Text("♮"))
                    ],
                  )
                  // SizedBox(
                  //   width: 50,
                  // ),
                  // Text("Extension: "),
                  // SizedBox(
                  //   width: 200,
                  //   child: TextField(
                  //     controller: _extController,
                  //     focusNode: _focusNode,
                  //     onChanged: (value) {
                  //       var fb = ref.read(fretboardProvider);

                  //       ref
                  //           .read(fretboardProvider.notifier)
                  //           .updateFretboard(fb.copyWith(extension: value));
                  //     },
                  //   ),
                  //),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Builder(builder: (context) {
                  //   var notes = <sheet.ChordNotePart>[];
                  //   var fretboard = ref.read(fretboardProvider);

                  //   for (int i = 0; i < fretboard.strings; i++) {
                  //     var open = fretboard.tunings[i].transposeBy(
                  //         music.Interval.fromSemitones(
                  //             fretboard.capo + (fretboard.startFret - 1)));

                  //     print(open.toString());
                  //     var fing = fretboard.fingerings.where((f) {
                  //       return f.string == fretboard.strings - i;
                  //     });

                  //     for (var f in fing) {
                  //       if (f.fret == null) {
                  //         continue;
                  //       }

                  //       var p = open
                  //           .transposeBy(music.Interval.fromSemitones(f.fret!));

                  //       sheet.Accidental? accidental;
                  //       if (p.note.accidental == music.Accidental.flat) {
                  //         accidental = sheet.Accidental.flat;
                  //       } else if (p.note.accidental ==
                  //           music.Accidental.sharp) {
                  //         accidental = sheet.Accidental.sharp;
                  //       } else if (p.note.accidental ==
                  //           music.Accidental.doubleFlat) {
                  //         accidental = sheet.Accidental.doubleFlat;
                  //       } else if (p.note.accidental ==
                  //           music.Accidental.doubleSharp) {
                  //         accidental = sheet.Accidental.doubleSharp;
                  //       }

                  //       print(noteToPitch(p));

                  //       if (ref.read(spellWithProvider) ==
                  //           music.Accidental.sharp) {
                  //         if (p.note.accidental == music.Accidental.flat) {
                  //           sheet.ChordNotePart cnp = sheet.ChordNotePart(
                  //               sheet.Pitch.a0.upN(noteToPitch(p) - 1),
                  //               accidental: sheet.Accidental.sharp);
                  //           notes.add(cnp);
                  //         } else {
                  //           sheet.ChordNotePart cnp = sheet.ChordNotePart(
                  //               sheet.Pitch.a0.upN(noteToPitch(p)),
                  //               accidental: accidental);

                  //           notes.add(cnp);
                  //         }
                  //       } else {
                  //         if (p.note.accidental == music.Accidental.sharp) {
                  //           sheet.ChordNotePart cnp = sheet.ChordNotePart(
                  //               sheet.Pitch.a0.upN(noteToPitch(p) + 1),
                  //               accidental: sheet.Accidental.flat);
                  //           notes.add(cnp);
                  //         } else {
                  //           sheet.ChordNotePart cnp = sheet.ChordNotePart(
                  //               sheet.Pitch.a0.upN(noteToPitch(p)),
                  //               accidental: accidental);

                  //           notes.add(cnp);
                  //         }
                  //       }
                  //     }
                  //   }

                  //   return sheet.SimpleSheetMusic(
                  //     width: 150,
                  //     height: 400,
                  //     measures: [
                  //       sheet.Measure([
                  //         const sheet.KeySignature(
                  //             sheet.KeySignatureType.cMajor),
                  //         const sheet.Clef(sheet.ClefType.treble),
                  //         if (f.fingerings.isNotEmpty) sheet.ChordNote(notes),
                  //       ])
                  //     ],
                  //   );
                  // }),
                  RepaintBoundary(
                    key: _globalKey,
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white),
                      child: Builder(builder: (context) {
                        var f = ref.watch(fretboardProvider);
                        // var fbd = ref.watch(fretBlockDiagramProvider(f));
                        // return fbd;
                        return FretBlockDiagram(
                          headerSize: ref.read(headerSizeProvider).toDouble(),
                          width: ref.read(sizeProvider).width.toInt(),
                          height: ref.read(sizeProvider).height.toInt(),
                          fretboard: f,
                          name: "C Major",
                          spellWith: ref.read(spellWithProvider),
                          showPitch: ref.read(showPitchProvider),
                          onLongPress: (string, fret, distance) {
                            if (distance > 100) {
                              return;
                            }
                            var fb = ref.read(fretboardProvider);
                            var existingFinger = fb.fingerings
                                .where(
                                    (f) => f.string == string && f.fret == fret)
                                .firstOrNull;

                            if (existingFinger == null) {
                              return;
                            }

                            Color newBg = Colors.white;
                            Color newTxtColor = Colors.black;
                            Color borderColor = Colors.black;
                            int border = 2;

                            if (existingFinger.bgColor == Colors.white) {
                              newBg = Colors.black;
                              newTxtColor = Colors.white;
                              borderColor = Colors.black;
                              border = 2;
                            }
                            ref
                                .read(fretboardProvider.notifier)
                                .removeFingering(existingFinger);

                            ref.read(fretboardProvider.notifier).addFingering(
                                existingFinger.copyWith(
                                    bgColor: newBg,
                                    borderColor: borderColor,
                                    borderSize: border,
                                    textColor: newTxtColor));
                          },
                          updateName: (name, fret, frets, strings) {
                            var fb = ref.read(fretboardProvider);

                            ref
                                .read(fretboardProvider.notifier)
                                .updateFretboard(fb.copyWith(
                                    name: name,
                                    startFret: fret,
                                    strings: strings,
                                    frets: frets));
                          },
                          onClick: (string, fret, distance) {
                            var fb = ref.read(fretboardProvider);
                            var existingFinger = fb.fingerings
                                .where((f) =>
                                    f.string == string &&
                                    (f.fret == fret ||
                                        fret == 0 && f.fret == null))
                                .firstOrNull;
                            if (existingFinger == null) {
                              ref.read(fretboardProvider.notifier).addFingering(
                                  Fingering(
                                      string: string, fret: fret, text: ""));
                            }
                          },
                        );
                      }),
                    ),
                  ),
                  SizedBox(
                    width: 50,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: SizedBox(
                        width: 550,
                        height: 500,
                        child: buildControlList(f),
                      ),
                    ),
                  ),
                ],
              ),
              // Text(f.getNotes().toString()),
              // Builder(
              //   builder: (context) {
              //     var notes = f.getNotes().map((e) => e.note).toList();
              //     var results = possibleChords(notes);

              //     if (results.isEmpty) {
              //       return Container();
              //     }

              //     return Column(
              //       children: results.map((e) => Text(e)).toList() ?? [],
              //     );
              //     return Container();
              //   },
              // )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _capturePng,
        tooltip: 'Save PNG',
        child: const Icon(Icons.save),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  ListView buildControlList(Fretboard f) {
    return ListView.builder(
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.all(5),
      itemBuilder: (context, index) {
        TextEditingController tempController =
            TextEditingController(text: f.fingerings[index].text);
        return Card(
          key: ValueKey((f.fingerings[index].string, f.fingerings[index].fret)),
          child: ListTile(
              trailing: SizedBox(
                width: 125,
                child: Row(
                  children: [
                    if (f.fingerings[index].fret == null)
                      IconButton(
                        onPressed: () {
                          Fingering temp = f.fingerings[index];
                          ref
                              .read(fretboardProvider.notifier)
                              .updateFingering(temp, temp.copyWith(fret: 0));
                        },
                        icon: Icon(Icons.circle),
                        tooltip: "Change to Open",
                      )
                    else if (f.fingerings[index].fret == 0)
                      IconButton(
                        onPressed: () {
                          Fingering temp = f.fingerings[index];
                          ref
                              .read(fretboardProvider.notifier)
                              .updateFingering(temp, temp.copyWith(fret: -1));
                        },
                        icon: Icon(Icons.close),
                        tooltip: "Change to Muted/Unplayed",
                      ),
                    if (f.fingerings[index].fret != null &&
                        f.fingerings[index].fret! > 0)
                      IconButton(
                          icon: Icon(Icons.bar_chart),
                          tooltip: "Barre",
                          onPressed: () {
                            Fingering temp = f.fingerings[index];
                            if (temp.barre == null) {
                              ref
                                  .read(fretboardProvider.notifier)
                                  .setBarre(temp, true);
                            } else {
                              ref
                                  .read(fretboardProvider.notifier)
                                  .setBarre(temp, false);
                            }
                          }),
                    if (f.fingerings[index].fret != null &&
                        f.fingerings[index].fret! > 0)
                      IconButton(
                          icon: Icon(Icons.palette),
                          tooltip: "Invert Color",
                          onPressed: () {
                            Fingering temp = f.fingerings[index];
                            Fingering newFingering;

                            switch (temp.bgColor) {
                              case Colors.black:
                              case null:
                                newFingering = f.fingerings[index].copyWith(
                                    bgColor: Colors.white,
                                    textColor: Colors.black,
                                    borderColor: Colors.black,
                                    borderSize: 2);
                                break;
                              default:
                                newFingering = f.fingerings[index].copyWith(
                                    bgColor: Colors.black,
                                    textColor: Colors.white,
                                    borderColor: Colors.black,
                                    borderSize: 2);
                                break;
                            }

                            ref
                                .read(fretboardProvider.notifier)
                                .updateFingering(temp, newFingering);
                          }),
                    IconButton(
                        icon: Icon(Icons.delete),
                        tooltip: "Delete",
                        onPressed: () {
                          ref
                              .read(fretboardProvider.notifier)
                              .removeFingering(f.fingerings[index]);
                        }),
                  ],
                ),
              ),
              subtitle: f.fingerings[index].fret != null &&
                      f.fingerings[index].fret! > 0
                  ? SizedBox(
                      width: 100,
                      child: SegmentedButton<FingeringShape>(
                        segments: <ButtonSegment<FingeringShape>>[
                          ButtonSegment<FingeringShape>(
                              value: FingeringShape.circle,
                              icon: Icon(
                                Icons.circle,
                                size: 12,
                              )),
                          ButtonSegment<FingeringShape>(
                              value: FingeringShape.square,
                              icon: Icon(Icons.square, size: 12)),
                          ButtonSegment<FingeringShape>(
                              value: FingeringShape.diamond,
                              icon: Icon(Icons.diamond, size: 12)),
                          ButtonSegment<FingeringShape>(
                              value: FingeringShape.triangle,
                              icon: Icon(Icons.change_history_outlined,
                                  size: 12)),
                        ],
                        onSelectionChanged: (selection) {
                          ref.read(fretboardProvider.notifier).updateFingering(
                              f.fingerings[index],
                              f.fingerings[index]
                                  .copyWith(shape: selection.first));
                        },
                        selected: {
                          f.fingerings[index].shape ?? FingeringShape.circle
                        },
                      ))
                  : null,
              title: Row(
                children: [
                  Text("String: ${f.fingerings[index].string}, Fret: ",
                      style: TextStyle(fontSize: 24)),
                  if (f.fingerings[index].fret == null)
                    Text("Muted", style: TextStyle(fontSize: 24))
                  else if (f.fingerings[index].fret == 0)
                    Text("Open", style: TextStyle(fontSize: 24))
                  else
                    Text(
                      "${f.fingerings[index].fret}",
                      style: TextStyle(fontSize: 24),
                    ),
                  if (f.fingerings[index].fret != null &&
                      f.fingerings[index].fret! > 0)
                    Text(
                      ", Text: ",
                      style: TextStyle(fontSize: 24),
                    ),
                  if (f.fingerings[index].fret != null &&
                      f.fingerings[index].fret! > 0)
                    SizedBox(
                        width: 55,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(7)),
                              border: Border.all()),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: TextField(
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20),
                              controller: tempController,
                              onChanged: (value) {
                                ref
                                    .read(fretboardProvider.notifier)
                                    .updateFingering(
                                        f.fingerings[index],
                                        f.fingerings[index].copyWith(
                                            text: tempController.text
                                                .split('')
                                                .reversed
                                                .join('')));
                              },
                            ),
                          ),
                        ))
                ],
              )),
        );
      },
      itemCount: f.fingerings.length,
    );
  }

  Future<void> _capturePng() async {
    try {
      await WebImageDownloader.downloadImage(_globalKey,
          "${ref.read(fretboardProvider).name == "" ? "ChordBlock" : ref.read(fretboardProvider).name}.png");
      return;

      // RenderRepaintBoundary? boundary = _globalKey.currentContext!
      //     .findRenderObject() as RenderRepaintBoundary?;

      // ui.Image image = await boundary!.toImage(pixelRatio: 1);

      // ByteData? byteData =
      //     await image.toByteData(format: ui.ImageByteFormat.png);

      // Uint8List pngBytes = byteData!.buffer.asUint8List();
      // //   final blob = html.Blob([pngBytes]);
      // //   final url = html.Url.createObjectUrlFromBlob(blob);
      // //   html.Url.revokeObjectUrl(url);
      // Share.shareXFiles([
      //   XFile.fromData(pngBytes,
      //       mimeType: "image/png",
      //       name: ref.read(fretboardProvider).name + ".png")
      // ]);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}

List<String> possibleChords(List<music.Note> notes) {
  if (notes.length < 3) {
    return [];
  }
  var permResults = permutations(notes).map((p) => music.Chord(p)).toList();

  final seen = <String>[];
  //final uniqueChords = <music.Chord>[];

  for (final chord in permResults) {
    if (chord.pattern.abbreviation == '?') {
      continue;
    }
    final chordname = '${chord.root}-${chord.pattern.abbreviation}';

    String slash = "";
    if (chord.root != notes.first) slash = ' / ${notes.first}';

    List<String> extensions = [];
    for (var note in chord.items) {
      music.Interval i = music.Interval.fromSemitones(
          chord.root.difference(note) < 0
              ? chord.root.difference(note) + 12
              : chord.root.difference(note));

      if (chord.pattern.rootTriad.intervals.contains(i) || chord.root == note) {
        continue;
      }

      if (!extensions.contains(i.toString())) {
        extensions.add(i.toString());
      }
    }

    final signature = "$chordname${extensions.join("")}$slash";

    if (!seen.contains(signature)) {
      seen.add(signature);
    }
  }

  return seen;
}

List<List<T>> permutations<T>(List<T> list) {
  if (list.length <= 1) return [list];
  final result = <List<T>>[];
  for (int i = 0; i < list.length; i++) {
    final element = list[i];
    final remaining = [...list]..removeAt(i);
    for (final perm in permutations(remaining)) {
      result.add([element, ...perm]);
    }
  }
  return result;
}

int noteToPitch(music.Pitch n) {
  int letterNum = 0;
  if (kDebugMode) {
    print("Octave: ${n.octave}");
  }
  if (kDebugMode) {
    print("Note: ${n.note.baseNote.name}");
  }
  switch (n.note.baseNote.name) {
    case "a":
      letterNum = 0;
      break;
    case "b":
      letterNum = 1;
      break;
    case "c":
      letterNum = 2;
      break;
    case "d":
      letterNum = 3;
      break;
    case "e":
      letterNum = 4;
      break;
    case "f":
      letterNum = 5;
      break;
    case "g":
      letterNum = 6;
      break;
    default:
      break;
  }

  return (letterNum < 2 ? (n.octave + 1) : n.octave) * 7 + letterNum;
}
