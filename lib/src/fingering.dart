import 'package:flutter/material.dart';
import 'package:fretted/src/color_serialize.dart';

/// An enum that represents the shape of a marker.
enum FingeringShape { circle, square, triangle, diamond, none }

/// A class that represents a marker on the fretboard.
class Fingering {
  Fingering(
      {required this.string,
      this.fret,
      this.radius,
      this.barre,
      this.bgColor,
      this.borderColor,
      this.borderSize,
      this.textColor,
      this.fontFamily,
      this.shape,
      this.text});

  /// The radius of the marker.
  int? radius;

  /// The length of the barre marker in strings covered.
  ///
  /// If null the barre will cover all remaining strings. A value of 1 will
  /// cover the current string only. If the barre is longer than available,
  /// it will be drawn from the current string to the end of the fretboard.
  int? barre;

  /// The background color of the marker.
  Color? bgColor;

  /// The border color of the marker.
  Color? borderColor;

  /// The border size of the marker.
  int? borderSize;

  /// The text color of the marker.
  Color? textColor;

  /// The font family of the marker.
  String? fontFamily;

  /// The shape of the marker.
  FingeringShape? shape;

  /// The text of the marker.
  String? text;

  int string;

  /// Place the fingering on the fret
  ///
  /// Null is muted
  /// 0 Open
  /// 1+ is fret
  int? fret;

  /// Creates a copy of this marker but with the given fields replaced with the new values.
  Fingering copyWith({
    int? radius,
    Color? bgColor,
    Color? borderColor,
    int? borderSize,
    Color? textColor,
    String? fontFamily,
    FingeringShape? shape,
    String? text,
    int? string,
    int? fret,
    // int? barreLength,
    int? barre,
  }) {
    return Fingering(
      string: string ?? this.string,
      fret: fret ?? this.fret,
      radius: radius ?? this.radius,
      barre: barre ?? this.barre,
      bgColor: bgColor ?? this.bgColor,
      borderColor: borderColor ?? this.borderColor,
      borderSize: borderSize ?? this.borderSize,
      textColor: textColor ?? this.textColor,
      fontFamily: fontFamily ?? this.fontFamily,
      shape: shape ?? this.shape,
      text: text ?? this.text,
    );
  }

  Map<String, dynamic> toJson() => {
        'string': string,
        'fret': fret,
        'radius': radius,
        'barre': barre,
        'bgColor': serializeColor(bgColor),
        'borderColor': serializeColor(borderColor),
        'borderSize': borderSize,
        'textColor': serializeColor(textColor),
        'fontFamily': fontFamily,
        'shape': shape?.toString().split('.').last,
        'text': text,
      };

  factory Fingering.fromJson(Map<String, dynamic> json) {
    return Fingering(
      string: json['string'] as int,
      fret: json['fret'] as int,
      radius: json['radius'] as int?,
      barre: json['barre'] as int?,
      bgColor:
          json['bgColor'] != null ? deserializeColor(json['bgColor']) : null,
      borderColor: json['borderColor'] != null
          ? deserializeColor(json['borderColor'])
          : null,
      borderSize: json['borderSize'] as int?,
      textColor: json['textColor'] != null
          ? deserializeColor(json['textColor'])
          : null,
      fontFamily: json['fontFamily'] as String?,
      shape: json['shape'] != null
          ? FingeringShape.values
              .firstWhere((e) => e.toString().split('.').last == json['shape'])
          : null,
      text: json['text'] as String?,
    );
  }
}
