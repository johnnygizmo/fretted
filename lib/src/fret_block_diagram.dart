import 'package:flutter/material.dart';
import 'package:fretted/fretted.dart';
import 'package:fretted/src/fretboard_painter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_notes/music_notes.dart' as music;

final String sharp = String.fromCharCode((0x268D));
final String natural = String.fromCharCode((0x267D));
final String flat = String.fromCharCode((0x266));

/// The Frets widget is used to display a fretboard with markers for chords.
class FretBlockDiagram extends ConsumerWidget {
  const FretBlockDiagram(
      {required this.fretboard,
      this.name = "",
      super.key,
      this.markerSize,
      this.height = 200,
      this.width = 200,
      this.padding = const EdgeInsets.all(8.0),
      this.frets,
      this.extension = "",
      this.markerColor = Colors.black,
      this.markerTextColor = Colors.white,
      this.borderColor = Colors.black,
      this.borderSize = 0,
      this.headerSize = 25,
      this.showPitch = false,
      this.startFret,
      this.spellWith = music.Accidental.sharp,
      this.fontFamily = "packages/fretted/MuseJazzText",
      this.onClick,
      this.onLongPress,
      this.updateName});

  final Fretboard fretboard;
  final String name;
  final int? startFret;

  /// Widget Height
  final int height;

  /// Widget Width
  final int width;

  /// Padding around the widget
  final EdgeInsets padding;

  /// Number of frets
  final int? frets;

  /// The chord extension in superscript
  final String extension;

  /// The size of the header text
  final double headerSize;

  final int? markerSize;

  /// The default color of the markers
  final Color markerColor;

  /// The default text color of the markers
  final Color markerTextColor;

  /// The default border color of the markers
  final Color borderColor;

  /// The default border size of the markers
  final int borderSize;

  /// The default font family to use for the text
  final String fontFamily;
  final bool showPitch;
  final music.Accidental spellWith;

  final Function(int string, int? fret, double distance)? onClick;
  final Function(int string, int? fret, double distance)? onLongPress;
  final Function(String name, int? startFret, int? frets, int? strings)?
      updateName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double headerSpacing = 15;
    var sideSpacing =
        (width - (padding.left + padding.right)) / (fretboard.strings + 2);
    var fbPadding = padding.copyWith(
        top: padding.top + headerSpacing,
        left: padding.left + sideSpacing,
        right: padding.right + sideSpacing);

    var frets = this.frets ?? fretboard.frets;
    var startFret = this.startFret ?? fretboard.startFret;
    var drawWidth = (width - fbPadding.left - fbPadding.right);
    var drawHeight = (height - fbPadding.top - fbPadding.bottom);
    var stringSpacing = drawWidth / (fretboard.strings - 1);
    var fretSpacing = drawHeight / frets;

    double shapeRadius = (markerSize ?? stringSpacing * .45) as double;
    return Column(
      children: [
        GestureDetector(
          onDoubleTap: () {
            final textController = TextEditingController(text: fretboard.name);
            final textController2 =
                TextEditingController(text: fretboard.startFret.toString());
            final textController3 =
                TextEditingController(text: fretboard.frets.toString());
            final textController4 =
                TextEditingController(text: fretboard.strings.toString());
            showDialog(
              context: context,
              builder: (dialogContext) {
                return AlertDialog(
                  title: const Text('Edit Fretboard'),
                  content: Column(
                    children: [
                      Text("Name"),
                      TextField(controller: textController),
                      Text("Frets"),
                      TextField(controller: textController3),
                      Text("Strings"),
                      TextField(controller: textController4),
                      Text("Starting Fret"),
                      TextField(controller: textController2),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        if (updateName != null) {
                          updateName!(
                            textController.text,
                            int.tryParse(textController2.text),
                            int.tryParse(textController3.text),
                            int.tryParse(textController4.text),
                          );
                        }
                        Navigator.of(dialogContext).pop();
                      },
                      child: const Text('Save'),
                    ),
                  ],
                );
              },
            );
          },
          child: Text(
            '${fretboard.name}$extension',
            style: TextStyle(
              fontSize: headerSize,
              color: Colors.black,
              fontFamily: fontFamily,
            ),
          ),
        ),
        if (fretboard.capo > 0) Text("Capo ${fretboard.capo}"),
        SizedBox(height: 18),
        Container(
          //ecoration: BoxDecoration(border: Border.all(color: Colors.black)),
          child: GestureDetector(
            onTapDown: (details) {
              print(details.localPosition.toString());
              var fbpos1 = (details.localPosition -
                  Offset(fbPadding.left, fbPadding.top));

              print(fbpos1.toString());

              var fretString = Offset(
                  (fbpos1.dx / stringSpacing).roundToDouble(),
                  (fbpos1.dy / fretSpacing).ceilToDouble());

              if (onClick != null) {
                Offset actualPos = Offset(fretString.dx * stringSpacing,
                    fretString.dy * fretSpacing - fretSpacing / 2);
                var distance = ((fbpos1 - actualPos).distanceSquared);
                onClick!(fretboard.strings - (fretString.dx as int),
                    fretString.dy.abs() as int, distance);
              }
            },
            onLongPressStart: (details) {
              var fbpos = (details.localPosition -
                  Offset(fbPadding.left, fbPadding.top));
              var fretString = Offset(
                  (fbpos.dx / stringSpacing).roundToDouble(),
                  (fbpos.dy / fretSpacing).ceilToDouble());

              if (onLongPress != null) {
                Offset actualPos = Offset(fretString.dx * stringSpacing,
                    fretString.dy * fretSpacing - fretSpacing / 2);
                var distance = ((fbpos - actualPos).distanceSquared);
                onLongPress!(fretboard.strings - (fretString.dx as int),
                    fretString.dy as int, distance);
              }
            },
            child: CustomPaint(
              size: Size(width.toDouble(), height.toDouble()),
              painter: FretboardPainter(this),
            ),
          ),
        ),
      ],
    );
  }

  FretBlockDiagram copyWith({
    Fretboard? fretboard,
    String? name,
    int? startFret,
    int? height,
    int? width,
    EdgeInsets? padding,
    int? frets,
    String? extension,
    double? headerSize,
    int? markerSize,
    Color? markerColor,
    Color? markerTextColor,
    Color? borderColor,
    int? borderSize,
    String? fontFamily,
    bool? showPitch,
    music.Accidental? spellWith,
    Function(int string, int? fret, double distance)? onClick,
    Function(int string, int? fret, double distance)? onLongPress,
    Function(String name, int? startFret, int? frets, int? strings)? updateName,
  }) {
    return FretBlockDiagram(
      fretboard: fretboard ?? this.fretboard,
      name: name ?? this.name,
      startFret: startFret ?? this.startFret,
      height: height ?? this.height,
      width: width ?? this.width,
      padding: padding ?? this.padding,
      frets: frets ?? this.frets,
      extension: extension ?? this.extension,
      headerSize: headerSize ?? this.headerSize,
      markerSize: markerSize ?? this.markerSize,
      markerColor: markerColor ?? this.markerColor,
      markerTextColor: markerTextColor ?? this.markerTextColor,
      borderColor: borderColor ?? this.borderColor,
      borderSize: borderSize ?? this.borderSize,
      fontFamily: fontFamily ?? this.fontFamily,
      showPitch: showPitch ?? this.showPitch,
      spellWith: spellWith ?? this.spellWith,
      onClick: onClick ?? this.onClick,
      onLongPress: onLongPress ?? this.onLongPress,
      updateName: updateName ?? this.updateName,
    );
  }
}

void fingeringPrinter(Fingering f) {
  print("string:${f.string} fret:${f.fret}");
}
