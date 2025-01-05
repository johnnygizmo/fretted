import 'package:example/fretboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fretted/fretted.dart';

Future<void> fingeringDialogBuilder(
    BuildContext context, WidgetRef ref, Fingering fingering) {
  return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("String: ${fingering.string}, Fret: ${fingering.fret}"),
          content: SingleChildScrollView(
            child: Row(
              children: [
                if (fingering.fret != null && fingering.fret! > 0)
                  IconButton(
                      icon: Icon(Icons.bar_chart),
                      tooltip: "Barre",
                      onPressed: () {
                        Fingering temp = fingering;
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
                if (fingering.fret != null && fingering.fret! > 0)
                  IconButton(
                      icon: Icon(Icons.palette),
                      tooltip: "Invert Color",
                      onPressed: () {
                        Fingering temp = fingering;
                        Fingering newFingering;

                        switch (temp.bgColor) {
                          case Colors.black:
                          case null:
                            newFingering = fingering.copyWith(
                                bgColor: Colors.white,
                                textColor: Colors.black,
                                borderColor: Colors.black,
                                borderSize: 2);
                            break;
                          default:
                            newFingering = fingering.copyWith(
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
                          .removeFingering(fingering);
                    }),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
}
