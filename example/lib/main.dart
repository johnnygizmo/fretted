import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:example/fretboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fretted/fretted.dart';
import 'dart:html' as html;

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

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
  GlobalKey _globalKey = GlobalKey();

  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var f = ref.read(fretboardProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
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
                      ref.watch(fretboardProvider);
                      return FretBlockDiagram(
                        width: 300,
                        height: 300,
                        fretboard: f,
                        frets: 3,
                        name: "C Major",
                        // showPitch: true,
                        onClick: (string, fret, distance) {
                          print("${string}, $fret, $distance");

                          if (distance > 100) {
                            return;
                          }

                          var fb = ref.read(fretboardProvider);

                          var existingFinger = fb.fingerings
                              .where(
                                  (f) => f.string == string && f.fret == fret)
                              .firstOrNull;

                          if (existingFinger != null) {
                            ref
                                .read(fretboardProvider.notifier)
                                .removeFingering(existingFinger);
                          } else {
                            ref.read(fretboardProvider.notifier).addFingering(
                                Fingering(
                                    string: string,
                                    fret: fret,
                                    text: _controller.text));
                            _controller.clear();
                            _focusNode.requestFocus();
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
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Column(
                    children: [
                      TextField(
                        autofocus: true,
                        focusNode: _focusNode,
                        controller: _controller,
                      ),
                    ],
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
