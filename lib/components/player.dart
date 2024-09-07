import 'package:flutter/material.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

// Плеер, отображаемый внизу экрана
class Player extends StatelessWidget {
  const Player({super.key, required this.player, required this.duration, required this.item, required this.leaf, required this.play, required this.isPlay});
  final AssetsAudioPlayer player;
  final double duration;
  final Map? item;
  final leaf;
  final play;
  final isPlay;

  @override
  Widget build(BuildContext context){
    return Column(
      children: [
        player.builderCurrentPosition(
          builder: (context, current) {
            return Slider(
              max: duration,
              value: current.inSeconds.toDouble(),
              onChanged: (double value) async {
                player.seek(Duration(seconds: value.toInt()));
              },
              thumbColor: Theme.of(context).colorScheme.primary,
              activeColor: Theme.of(context).colorScheme.primary,
              inactiveColor: Colors.grey,
            );
          }
        ),
        Padding(
          padding: const EdgeInsets.all(0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(5),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: play,
                      child: (isPlay
                          ? const Icon(Icons.pause_circle, size: 43)
                          : const Icon(Icons.play_circle, size: 43)),
                    ),
                    GestureDetector(
                      onTap: leaf,
                      child: const Icon(Icons.skip_next, size: 43),
                    )
                  ],
                )
              ),
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item!['title'],
                          style: const TextStyle(fontSize: 15)),
                      Text(item!['author'],
                          style: const TextStyle(fontSize: 13)),
                    ]
                  )
                ),
            ],
          )
        )
      ],
    );
  }
}