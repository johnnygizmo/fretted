import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:example/fretboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fretted/fretted.dart';
import 'dart:html' as html;

import 'package:music_notes/music_notes.dart' as music;

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

final showPitchProvider = StateProvider<bool>((ref) {
  return false;
});

GlobalKey _globalKey = GlobalKey();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    var f = FretBlockDiagram(
      width: 300,
      height: 300,
      fretboard: Fretboard(),
      frets: ref.read(fretboardProvider).frets,
      name: "C Major",
      showPitch: ref.read(showPitchProvider),
      onLongPress: (string, fret, distance) {
        if (distance > 100) {
          return;
        }
        var fb = ref.read(fretboardProvider);
        var existingFinger = fb.fingerings
            .where((f) => f.string == string && f.fret == fret)
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
        ref.read(fretboardProvider.notifier).removeFingering(existingFinger);

        ref.read(fretboardProvider.notifier).addFingering(
            existingFinger.copyWith(
                bgColor: newBg,
                borderColor: borderColor,
                borderSize: border,
                textColor: newTxtColor));
      },
      updateName: (name, fret, frets, strings) {
        var fb = ref.read(fretboardProvider);

        ref.read(fretboardProvider.notifier).updateFretboard(fb.copyWith(
            name: name, startFret: fret, strings: strings, frets: frets));
      },
      onClick: (string, fret, distance) {
        print("${string}, $fret, $distance");

        var fb = ref.read(fretboardProvider);

        var existingFinger = fb.fingerings
            .where((f) =>
                f.string == string &&
                (f.fret == fret || fret == 0 && f.fret == null))
            .firstOrNull;
        print(existingFinger.toString());
        if (existingFinger != null) {
          if (existingFinger.fret == 0) {
            ref
                .read(fretboardProvider.notifier)
                .removeFingering(existingFinger);

            ref
                .read(fretboardProvider.notifier)
                .addFingering(Fingering(string: existingFinger.string));
          } else if (existingFinger.fret == null) {
            ref
                .read(fretboardProvider.notifier)
                .removeFingering(existingFinger);
          } else {
            var newText = "";
            switch (existingFinger.text) {
              case "":
                newText = "1";
                break;
              case "1":
                newText = "2";
                break;
              case "2":
                newText = "3";
                break;
              case "3":
                newText = "4";
                break;
              case "4":
                newText = "";
                break;
            }
            if (newText == "") {
              ref
                  .read(fretboardProvider.notifier)
                  .removeFingering(existingFinger);
            } else {
              ref
                  .read(fretboardProvider.notifier)
                  .removeFingering(existingFinger);

              ref
                  .read(fretboardProvider.notifier)
                  .addFingering(existingFinger.copyWith(text: newText));
            }
          }
        } else {
          ref.read(fretboardProvider.notifier).addFingering(
              Fingering(string: string, fret: fret, text: _controller.text));
        }
      },
    );

    // Future.delayed(Duration(milliseconds: 55), () {
    //   ref
    //       .read(fretBlockDiagramProvider(ref.read(fretboardProvider)).notifier)
    //       .updateFretblock(f.copyWith(fretboard: ref.read(fretboardProvider)));
    // });
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
    var f = ref.read(fretboardProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          Switch(
              value: ref.read(showPitchProvider),
              onChanged: (value) {
                ref.read(showPitchProvider.notifier).state = value;
              })
        ],
      ),
      body: Center(
        child: Column(
          children: [
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
                        width: 300,
                        height: 300,
                        fretboard: f,
                        frets: ref.read(fretboardProvider).frets,
                        name: "C Major",
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

                          ref.read(fretboardProvider.notifier).updateFretboard(
                              fb.copyWith(
                                  name: name,
                                  startFret: fret,
                                  strings: strings,
                                  frets: frets));
                        },
                        onClick: (string, fret, distance) {
                          print("${string}, $fret, $distance");

                          var fb = ref.read(fretboardProvider);

                          var existingFinger = fb.fingerings
                              .where((f) =>
                                  f.string == string &&
                                  (f.fret == fret ||
                                      fret == 0 && f.fret == null))
                              .firstOrNull;
                          print(existingFinger.toString());
                          if (existingFinger != null) {
                            if (existingFinger.fret == 0) {
                              ref
                                  .read(fretboardProvider.notifier)
                                  .removeFingering(existingFinger);

                              ref.read(fretboardProvider.notifier).addFingering(
                                  Fingering(string: existingFinger.string));
                            } else if (existingFinger.fret == null) {
                              ref
                                  .read(fretboardProvider.notifier)
                                  .removeFingering(existingFinger);
                            } else {
                              var newText = "";
                              switch (existingFinger.text) {
                                case "":
                                  newText = "1";
                                  break;
                                case "1":
                                  newText = "2";
                                  break;
                                case "2":
                                  newText = "3";
                                  break;
                                case "3":
                                  newText = "4";
                                  break;
                                case "4":
                                  newText = "";
                                  break;
                              }
                              if (newText == "") {
                                ref
                                    .read(fretboardProvider.notifier)
                                    .removeFingering(existingFinger);
                              } else {
                                ref
                                    .read(fretboardProvider.notifier)
                                    .removeFingering(existingFinger);

                                ref
                                    .read(fretboardProvider.notifier)
                                    .addFingering(
                                        existingFinger.copyWith(text: newText));
                              }
                            }
                          } else {
                            ref.read(fretboardProvider.notifier).addFingering(
                                Fingering(
                                    string: string,
                                    fret: fret,
                                    text: _controller.text));
                          }
                        },
                      );
                    }),
                  ),
                ),
                SizedBox(
                  width: 400,
                  height: 500,
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                            subtitle: Text("Text: ${f.fingerings[index].text}"),
                            title: Text(
                                "String: ${f.fingerings[index].string}, Fret: ${f.fingerings[index].fret}")),
                      );
                    },
                    itemCount: f.fingerings.length,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _capturePng,
        tooltip: 'Increment',
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
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "frets.png")
        ..click();
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      print(e.toString());
    }
  }
}
