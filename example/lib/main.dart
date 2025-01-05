import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:example/fretboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fretted/fretted.dart';
import 'dart:html' as html;

import 'package:music_notes/music_notes.dart' as music;
import 'package:flutter_spinbox/material.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

final showPitchProvider = StateProvider<bool>((ref) {
  return false;
});

final spellWithProvider = StateProvider<music.Accidental>((ref) {
  return music.Accidental.flat;
});

final fretsProvider = StateProvider<int>((ref) {
  return 4;
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

    var f = ref.watch(fretboardProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
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
                  SizedBox(
                    width: 50,
                  ),
                  Text("Extension: "),
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _extController,
                      focusNode: _focusNode,
                      onChanged: (value) {
                        var fb = ref.read(fretboardProvider);

                        ref
                            .read(fretboardProvider.notifier)
                            .updateFretboard(fb.copyWith(extension: value));
                      },
                    ),
                  ),
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
                          headerSize: 40,
                          width: 300,
                          height: 300,
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
                        width: 500,
                        height: 500,
                        child: ListView.builder(
                          clipBehavior: Clip.antiAlias,
                          padding: EdgeInsets.all(5),
                          itemBuilder: (context, index) {
                            TextEditingController tempController =
                                TextEditingController(
                                    text: f.fingerings[index].text);
                            return Card(
                              key: ValueKey((
                                f.fingerings[index].string,
                                f.fingerings[index].fret
                              )),
                              child: ListTile(
                                  trailing: SizedBox(
                                    width: 125,
                                    child: Row(
                                      children: [
                                        if (f.fingerings[index].fret != null &&
                                            f.fingerings[index].fret! > 0)
                                          IconButton(
                                              icon: Icon(Icons.bar_chart),
                                              tooltip: "Barre",
                                              onPressed: () {
                                                Fingering temp =
                                                    f.fingerings[index];
                                                if (temp.barre == null) {
                                                  ref
                                                      .read(fretboardProvider
                                                          .notifier)
                                                      .setBarre(temp, true);
                                                } else {
                                                  ref
                                                      .read(fretboardProvider
                                                          .notifier)
                                                      .setBarre(temp, false);
                                                }
                                              }),
                                        if (f.fingerings[index].fret != null &&
                                            f.fingerings[index].fret! > 0)
                                          IconButton(
                                              icon: Icon(Icons.palette),
                                              tooltip: "Invert Color",
                                              onPressed: () {
                                                Fingering temp =
                                                    f.fingerings[index];
                                                Fingering newFingering;

                                                switch (temp.bgColor) {
                                                  case Colors.black:
                                                  case null:
                                                    newFingering = f
                                                        .fingerings[index]
                                                        .copyWith(
                                                            bgColor:
                                                                Colors.white,
                                                            textColor:
                                                                Colors.black,
                                                            borderColor:
                                                                Colors.black,
                                                            borderSize: 2);
                                                    break;
                                                  default:
                                                    newFingering = f
                                                        .fingerings[index]
                                                        .copyWith(
                                                            bgColor:
                                                                Colors.black,
                                                            textColor:
                                                                Colors.white,
                                                            borderColor:
                                                                Colors.black,
                                                            borderSize: 2);
                                                    break;
                                                }

                                                ref
                                                    .read(fretboardProvider
                                                        .notifier)
                                                    .updateFingering(
                                                        temp, newFingering);
                                              }),
                                        IconButton(
                                            icon: Icon(Icons.delete),
                                            tooltip: "Delete",
                                            onPressed: () {
                                              ref
                                                  .read(fretboardProvider
                                                      .notifier)
                                                  .removeFingering(
                                                      f.fingerings[index]);
                                            }),
                                      ],
                                    ),
                                  ),
                                  subtitle: SizedBox(
                                      width: 100,
                                      child: SegmentedButton<FingeringShape>(
                                        segments: <ButtonSegment<
                                            FingeringShape>>[
                                          ButtonSegment<FingeringShape>(
                                              value: FingeringShape.circle,
                                              icon: Icon(
                                                Icons.circle,
                                                size: 12,
                                              )),
                                          ButtonSegment<FingeringShape>(
                                              value: FingeringShape.square,
                                              icon:
                                                  Icon(Icons.square, size: 12)),
                                          ButtonSegment<FingeringShape>(
                                              value: FingeringShape.diamond,
                                              icon: Icon(Icons.diamond,
                                                  size: 12)),
                                          ButtonSegment<FingeringShape>(
                                              value: FingeringShape.triangle,
                                              icon: Icon(
                                                  Icons.change_history_outlined,
                                                  size: 12)),
                                        ],
                                        onSelectionChanged: (selection) {
                                          ref
                                              .read(fretboardProvider.notifier)
                                              .updateFingering(
                                                  f.fingerings[index],
                                                  f.fingerings[index].copyWith(
                                                      shape: selection.first));
                                        },
                                        selected: {
                                          f.fingerings[index].shape ??
                                              FingeringShape.circle
                                        },
                                      )),
                                  title: Row(
                                    children: [
                                      Text(
                                        "String: ${f.fingerings[index].string}, Fret: ${f.fingerings[index].fret}, Text:",
                                        style: TextStyle(fontSize: 24),
                                      ),
                                      SizedBox(
                                          width: 55,
                                          child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(7)),
                                                border: Border.all()),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: TextField(
                                                textAlign: TextAlign.center,
                                                style: TextStyle(fontSize: 20),
                                                controller: tempController,
                                                onChanged: (value) {
                                                  ref
                                                      .read(fretboardProvider
                                                          .notifier)
                                                      .updateFingering(
                                                          f.fingerings[index],
                                                          f.fingerings[index]
                                                              .copyWith(
                                                                  text: value));
                                                },
                                              ),
                                            ),
                                          ))
                                    ],
                                  )),
                            );
                          },
                          itemCount: f.fingerings.length,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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

  Future<void> _capturePng() async {
    try {
      RenderRepaintBoundary? boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary?;

      ui.Image image = await boundary!.toImage(pixelRatio: 2);

      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      Uint8List pngBytes = byteData!.buffer.asUint8List();
      final blob = html.Blob([pngBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.Url.revokeObjectUrl(url);
    } catch (e) {}
  }
}
