import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:fretted/fretted.dart';
import 'package:music_notes/music_notes.dart' as music;

class FretboardPainter extends CustomPainter {
  FretboardPainter(this.parent);

  final FretBlockDiagram parent;
  double headerSpacing = 15;
  double sideSpacing = 0;
  EdgeInsets fbPadding = EdgeInsets.zero;
  int frets = 0;
  int startFret = 0;
  double drawWidth = 0;
  double drawHeight = 0;
  double stringSpacing = 0;
  double fretSpacing = 0;

  @override
  void paint(Canvas canvas, Size size) {
    sideSpacing = (size.width - (parent.padding.left + parent.padding.right)) /
        (parent.fretboard.strings + 2);
    fbPadding = parent.padding.copyWith(
        top: parent.padding.top + headerSpacing,
        left: parent.padding.left + sideSpacing,
        right: parent.padding.right + sideSpacing);

    frets = parent.frets ?? parent.fretboard.frets;
    startFret = parent.startFret ?? parent.fretboard.startFret;
    drawWidth = (size.width - fbPadding.left - fbPadding.right);
    drawHeight = (size.height - fbPadding.top - fbPadding.bottom);
    stringSpacing = drawWidth / (parent.fretboard.strings - 1);
    fretSpacing = drawHeight / frets;

    double shapeRadius = (parent.markerSize ?? stringSpacing * .45) as double;

    for (var i = 0; i < parent.fretboard.strings; i++) {
      canvas.drawLine(
          Offset(fbPadding.left + (stringSpacing * i), fbPadding.top),
          Offset(fbPadding.left + (stringSpacing * i),
              size.height - fbPadding.bottom),
          Paint());
    }

    for (var i = 0; i <= frets; i++) {
      var p = startFret == 1 && i == 0
          ? (Paint()..strokeWidth = 7)
          : (Paint()..strokeWidth = 1);
      canvas.drawLine(
          Offset(fbPadding.left, fbPadding.top + (fretSpacing * i)),
          Offset(
              size.width - fbPadding.right, fbPadding.top + (fretSpacing * i)),
          p);
    }

    if (startFret > 1) {
      drawString(
          canvas,
          size,
          Offset(fbPadding.left - sideSpacing, fbPadding.top + fretSpacing / 2),
          startFret.toString(),
          shapeRadius * 2,
          Colors.black,
          parent.fontFamily);
    }
    for (var marker in parent.fretboard.fingerings) {
      if (marker.fret != null && marker.fret! > frets) {
        continue;
      }

      var string = parent.fretboard.strings - marker.string;
      var x = fbPadding.left + (stringSpacing * string);
      double y = 0;
      if (marker.fret == null) {
        var path = Path()
          ..moveTo(x - shapeRadius / 2, y - shapeRadius / 2)
          ..lineTo(x + shapeRadius / 2, y + shapeRadius / 2)
          ..moveTo(x + shapeRadius / 2, y - shapeRadius / 2)
          ..lineTo(x - shapeRadius / 2, y + shapeRadius / 2)
          ..close();
        canvas.drawPath(
            path,
            Paint()
              ..color = Colors.black
              ..strokeWidth = 3
              ..style = PaintingStyle.stroke);
        continue;
      }

      // Marker is an Open String
      if (marker.fret! == 0) {
        if (parent.showPitch) {
          var pitch = parent
              .fretboard.tunings[parent.fretboard.strings - marker.string].note
              .transposeBy(music.Interval.fromSemitones(parent.fretboard.capo));
          String noteOut = "";
          if (parent.spellWith == music.Accidental.flat) {
            noteOut = (pitch.respelledSimple).accidental ==
                    music.Accidental.sharp
                ? pitch.respellByAccidental(music.Accidental.flat).toString()
                : pitch.respelledSimple.toString();
          } else {
            noteOut = (pitch.respelledSimple).accidental ==
                    music.Accidental.flat
                ? pitch.respellByAccidental(music.Accidental.sharp).toString()
                : pitch.respelledSimple.toString();
          }

          drawString(canvas, size, Offset(x, y), noteOut, shapeRadius * 1.75,
              Colors.black, parent.fontFamily);
        } else {
          canvas.drawCircle(
              Offset(x, y),
              shapeRadius * .75,
              Paint()
                ..color = Colors.black
                ..strokeWidth = 3
                ..style = PaintingStyle.stroke);
        }
        continue;
      }

      // Marker is a normal marker

      var fret = marker.fret! - 1;
      y = fbPadding.top + (fretSpacing * fret) + fretSpacing / 2;

      var barreDistance =
          marker.barre == null ? 0 : (parent.fretboard.strings - 1) - string;
      if (marker.barre != null &&
          marker.barre! - 1 < barreDistance &&
          marker.barre! > 0) {
        barreDistance = marker.barre! - 1;
      }

      double radius = marker.radius as double? ?? shapeRadius;

      drawMarker(
          marker, canvas, x, y, radius, size, barreDistance, stringSpacing);
    }
  }

  void drawMarker(Fingering marker, ui.Canvas canvas, double x, double y,
      double radius, ui.Size size, int barreDistance, double stringSpacing) {
    Color bgColor = marker.bgColor ?? parent.markerColor;
    Color txtColor = marker.textColor ?? parent.markerTextColor;
    Color brdColor = marker.borderColor ?? parent.borderColor;
    double borderSize = (marker.borderSize ?? parent.borderSize) as double;
    startFret = parent.startFret ?? parent.fretboard.startFret;

    var solidPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.fill;
    var borderPaint = Paint()
      ..color = brdColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderSize;

    var totalWidth = (barreDistance * stringSpacing) + radius * 2;

    switch (marker.shape ?? FingeringShape.circle) {
      case FingeringShape.circle:
        canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(x - radius, y - radius, totalWidth, radius * 2),
              Radius.circular(radius),
            ),
            solidPaint);
        if ((marker.borderSize ?? parent.borderSize) > 0) {
          canvas.drawRRect(
              RRect.fromRectAndRadius(
                Rect.fromLTWH(x - radius, y - radius, totalWidth, radius * 2),
                Radius.circular(radius),
              ),
              borderPaint);
        }
        break;

      case FingeringShape.triangle:
        var path = Path()
          ..moveTo(x, y - radius)
          ..lineTo(x + (barreDistance * stringSpacing), y - radius)
          ..lineTo(x + (barreDistance * stringSpacing) + radius, y + radius)
          ..lineTo(x - radius, y + radius)
          ..close();

        canvas.drawPath(path, solidPaint);
        if (borderSize > 0) {
          canvas.drawPath(path, borderPaint);
        }

        break;
      case FingeringShape.square:
        canvas.drawRect(
            Rect.fromLTWH(x - radius, y - radius, totalWidth, radius * 2),
            solidPaint);
        if ((marker.borderSize ?? parent.borderSize) > 0) {
          canvas.drawRect(
              Rect.fromLTWH(x - radius, y - radius, totalWidth, radius * 2),
              borderPaint);
        }

        break;
      case FingeringShape.diamond:
        var path = Path()
          ..moveTo(x, y - radius)
          ..lineTo(x + (barreDistance * stringSpacing), y - radius)
          ..lineTo(x + (barreDistance * stringSpacing) + radius, y)
          ..lineTo(x + (barreDistance * stringSpacing), y + radius)
          ..lineTo(x, y + radius)
          ..lineTo(x - radius, y)
          ..close();

        canvas.drawPath(path, solidPaint);
        if (borderSize > 0) {
          canvas.drawPath(path, borderPaint);
        }

        break;
      case FingeringShape.none:
        break;
    }

    if (parent.showPitch) {
      if (barreDistance == 0) {
        var pitch = parent
            .fretboard.tunings[parent.fretboard.strings - marker.string]
            .transposeBy(music.Interval.fromSemitones(
                marker.fret! + parent.fretboard.capo + (startFret) - 1));

        String noteOut = "";
        if (parent.spellWith == music.Accidental.flat) {
          noteOut = (pitch.note.respelledSimple).accidental ==
                  music.Accidental.sharp
              ? pitch.note.respellByAccidental(music.Accidental.flat).toString()
              : pitch.note.respelledSimple.toString();
        } else {
          noteOut =
              (pitch.note.respelledSimple).accidental == music.Accidental.flat
                  ? pitch.note
                      .respellByAccidental(music.Accidental.sharp)
                      .toString()
                  : pitch.note.respelledSimple.toString();
        }

        drawString(canvas, size, Offset(x, y), noteOut, radius * 1.2, txtColor,
            parent.fontFamily);
      } else {
        for (var i = 0; i <= barreDistance; i++) {
          var pitch = parent
              .fretboard.tunings[parent.fretboard.strings - marker.string + i]
              .transposeBy(music.Interval.fromSemitones(
                  marker.fret! + parent.fretboard.capo + (startFret) - 1));

          String noteOut = "";
          if (parent.spellWith == music.Accidental.flat) {
            noteOut = (pitch.note.respelledSimple).accidental ==
                    music.Accidental.sharp
                ? pitch.note
                    .respellByAccidental(music.Accidental.flat)
                    .toString()
                : pitch.note.respelledSimple.toString();
          } else {
            noteOut =
                (pitch.note.respelledSimple).accidental == music.Accidental.flat
                    ? pitch.note
                        .respellByAccidental(music.Accidental.sharp)
                        .toString()
                    : pitch.note.respelledSimple.toString();
          }

          drawString(canvas, size, Offset(x + (i * stringSpacing), y), noteOut,
              radius * 1.2, txtColor, parent.fontFamily);
        }
      }
    } else if (marker.text != null) {
      drawString(
          canvas,
          size,
          Offset(x + (barreDistance * stringSpacing) / 2, y),
          marker.text ?? "",
          marker.radius as double? ?? radius * 1.2,
          txtColor,
          marker.fontFamily ?? parent.fontFamily);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  void drawString(Canvas canvas, Size size, Offset offset, String character,
      double fontSize, Color color, String fontFamily) {
    final textSpan = TextSpan(
      text: character,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
        fontFamily: fontFamily,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );

    textPainter.paint(
      canvas,
      Offset(offset.dx - textPainter.width / 2,
          offset.dy - textPainter.height / 2),
    );
  }
}
