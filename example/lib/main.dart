import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:example/control_drawer.dart';
import 'package:example/fretboard_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
//import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:fretted/fretted.dart';
import 'package:music_notes/music_notes.dart' as music;
import 'package:flutter_spinbox/material.dart';
import 'package:web_image_downloader/web_image_downloader.dart';
import 'dart:convert' show base64Encode, utf8;
import 'package:web/web.dart' as web;
import 'dart:html' as html;
import "dart:js" as js;

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
      debugShowCheckedModeBanner: false,
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

    //_controller.text = f.name;
    return Scaffold(
      drawer: ControlDrawer(ref: ref),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            tooltip: "Settings",
            icon: const Icon(Icons.settings),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
              tooltip: "Save Image",
              onPressed: _capturePng,
              icon: Icon(Icons.image)),
          IconButton(
              tooltip: "Copy Image to Clipboard",
              onPressed: (){_capturePng(clipboard: true);},
              icon: Icon(Icons.copy)),
              VerticalDivider(),
          IconButton(
              tooltip: "Save Block Definition",
              onPressed: () {
                saveTextFile(jsonEncode(ref.read(fretboardProvider).toJson()),
                    "${ref.read(fretboardProvider).name}.json");
              },
              icon: Icon(Icons.save)),
          IconButton(
              tooltip: "Load Block Definition",
              onPressed: () async {
                try {
                  String fileContent = await uploadTextFile();
                  var f = Fretboard.fromJson(jsonDecode(fileContent));
                  ref.read(fretboardProvider.notifier).updateFretboard(f);
                  _controller.text = f.name;
                } catch (e) {
                  showToast("Error reading file", context: context);
                }
              },
              icon: Icon(Icons.folder_open)),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
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
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
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
            ],
          ),
        ),
      ),
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

  Future<void> _capturePng({bool clipboard = false}) async {
    if (clipboard) {
      RenderRepaintBoundary? boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary?;
      ui.Image image = await boundary!.toImage(pixelRatio: 2);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
    if (pngBytes != null) {
    final base64Image = base64Encode(pngBytes);
    js.context.callMethod('copyBase64ImageToClipboard', [base64Image]);
  }

    } else {
      try {
        await WebImageDownloader.downloadImage(_globalKey,
            "${ref.read(fretboardProvider).name == "" ? "ChordBlock" : ref.read(fretboardProvider).name}.png");
        return;
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
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

void saveTextFile(String text, String filename) {
  final bytes = utf8.encode(text);
  final web.HTMLAnchorElement anchor =
      web.document.createElement('a') as web.HTMLAnchorElement
        ..href = "data:application/octet-stream;base64,${base64Encode(bytes)}"
        ..style.display = 'none'
        ..download = filename;

  web.document.body!.appendChild(anchor);
  anchor.click();
  web.document.body!.removeChild(anchor);
}

Future<String> uploadTextFile() {
  final uploadInput = html.FileUploadInputElement()..accept = '.json';
  final completer = Completer<String>();

  uploadInput.onChange.listen((event) {
    final file = uploadInput.files?.first;
    if (file != null) {
      final reader = html.FileReader();
      reader.readAsText(file);
      reader.onLoad.listen((event) {
        completer.complete(reader.result as String);
      });
    }
  });

  uploadInput.click();
  return completer.future;
}
