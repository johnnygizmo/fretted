import 'package:example/fretboard_provider.dart';
import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_notes/music_notes.dart' as music;
import 'package:flutter_spinbox/material.dart';

class ControlDrawer extends StatelessWidget {
  const ControlDrawer({
    super.key,
    required this.ref,
  });

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            title: Text("Frets"),
            trailing: SizedBox(
              width: 150,
              child: SpinBox(
                min: 1,
                max: 24,
                value: ref.read(fretboardProvider).frets.toDouble(),
                onChanged: (value) {
                  ref
                      .read(fretboardProvider.notifier)
                      .setFrets(value.toInt());
                },
              ),
            ),
          ),
          ListTile(
            title: Text("Capo"),
            trailing: SizedBox(
              width: 150,
              child: SpinBox(
                min: 0,
                max: 24,
                value: ref.read(fretboardProvider).capo.toDouble(),
                onChanged: (value) {
                  ref.read(fretboardProvider.notifier).setCapo(value.toInt());
                },
              ),
            ),
          ),
          ListTile(
            title: Text("Starting Fret"),
            trailing: SizedBox(
              width: 150,
              child: SpinBox(
                min: 1,
                max: 24,
                value: ref.read(fretboardProvider).startFret.toDouble(),
                onChanged: (value) {
                  ref
                      .read(fretboardProvider.notifier)
                      .setStartAt(value.toInt());
                },
              ),
            ),
          ),
          ListTile(
            title: Text("Show Pitch"),
            trailing: Switch(
              value: ref.read(showPitchProvider),
              onChanged: (value) {
                ref.read(showPitchProvider.notifier).state = value;
              },
            ),
          ),
          ListTile(
            title: Text("Spell with Flats/Sharps"),
            trailing: Switch(
              value: ref.read(spellWithProvider) == music.Accidental.sharp,
              onChanged: (value) {
                if (value) {
                  ref.read(spellWithProvider.notifier).state =
                      music.Accidental.sharp;
                } else {
                  ref.read(spellWithProvider.notifier).state =
                      music.Accidental.flat;
                }
              },
            ),
          ),
          ListTile(
            title: Text("Height"),
            trailing: SizedBox(
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
          ),
          ListTile(
            title: Text("Width"),
            trailing: SizedBox(
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
          ),
          ListTile(
            title: Text("Header Size"),
            trailing: SizedBox(
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
          ),
        ],
      ),
    );
  }
}