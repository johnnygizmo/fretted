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
      this.onClick});

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

  final Function(int string, int fret, double distance)? onClick;

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
        Text(name + extension,
            style: TextStyle(
                fontSize: headerSize,
                color: Colors.black,
                fontFamily: fontFamily)),
        if (fretboard.capo > 0) Text("Capo ${fretboard.capo}"),
        SizedBox(height: 18),
        GestureDetector(
          onTapDown: (details) {
            var fbpos1 =
                (details.localPosition - Offset(fbPadding.left, fbPadding.top));
            var fbpos = Offset((fbpos1.dx / stringSpacing).roundToDouble(),
                (fbpos1.dy / fretSpacing).roundToDouble());

            if (onClick != null) {
              Offset actualPos = Offset(fbpos.dx * stringSpacing,
                  fbpos.dy * fretSpacing - fretSpacing / 2);
              var distance = ((fbpos1 - actualPos).distanceSquared);
              onClick!(fretboard.strings - (fbpos.dx as int), fbpos.dy as int,
                  distance);
            }
          },
          child: CustomPaint(
            size: Size(width.toDouble(), height.toDouble()),
            painter: FretboardPainter(this),
          ),
        ),
      ],
    );
  }
}

void fingeringPrinter(Fingering f) {
  print("string:${f.string} fret:${f.fret}");
}
