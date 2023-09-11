import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cupertino_icons/cupertino_icons.dart';

import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:'Actory-Test',
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration =  Duration.zero ;
  //var duration = await audioPlayer.setUrl('file.mp3');
  Duration position = Duration.zero;
  String metadaten = "";
  bool isCircleSee = true;

  @override
  void initState(){
    super.initState();

    setAudio();

    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.PLAYING;
      });
    });

    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });

    audioPlayer.onAudioPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });


    audioPlayer.onPlayerCompletion.listen((event) {
      print('Audio finished');
      isCircleSee = false;
      loadText();
    });
  }

  Future<void> loadText() async {
    String fileText = await rootBundle.loadString('text/meta.txt');

    List<String> lines = fileText.split('\n'); // Die Textdatei in Zeilen aufteilen
    String firstColumn = '';

    if (lines.isNotEmpty) {
      List<String> columns = lines[0].split('\t'); // Annahme: Spalten werden durch ein Tabulatorzeichen getrennt

      if (columns.isNotEmpty) {
        firstColumn = columns[0]; // Die erste Spalte nehmen
      }
    }

    setState(() {
      metadaten = firstColumn;
    });
  }


  Future setAudio() async{

    audioPlayer.setReleaseMode(ReleaseMode.STOP);

    //String url = '//samplelib.com/lib/preview/mp3/sample-12s.mp3';
    //final url = await player.load('assets/audios/1.mp3');
    //String url = 'assets/audios/1.mp3';
    //final player = AudioCache(prefix: 'assets/audios/');
    //final url = await player.load('1.mp3');

    final player = AudioCache(prefix: 'assets/audios/');
    final url = await player.load('9.mp3');
    await audioPlayer.setUrl(url.path, isLocal: true);



  }


  @override
  void dispose(){
    audioPlayer.dispose();

    super.dispose();
  }




  @override
  Widget build(BuildContext context) => Scaffold (
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'images/titelbild.png',
              width: double.infinity,
              height: 350,
              fit: BoxFit.cover,
              semanticLabel: 'Titelbild',
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Das Flüstern im Wald',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          Slider(
            min: 0,
            max: duration.inSeconds.toDouble()+2,
            value: position.inSeconds.toDouble(),
            onChanged: (value) async {
              final position = Duration(seconds: value.toInt());
              await audioPlayer.seek(position);
              },
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatTime(position)),
                Text(formatTime(duration)),
              ],
            ),
          ),
          isCircleSee ? CircleAvatar(
            radius: 35,
            child: IconButton(
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
              ),
              iconSize: 50,
              onPressed: () async {
                if(isPlaying){
                  await audioPlayer.pause();
                }
                else{
                  //String url = '//samplelib.com/lib/preview/mp3/sample-12s.mp3';
                  await audioPlayer.resume();
                }
              },
            ),
          ): SizedBox.shrink(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(metadaten),
              ],
            ),
          ),
        ],
      ),
    ),
  );




  String formatTime(Duration duration) {
    String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    String hours = (duration.inHours).toString().padLeft(2, '0');

    if(duration.inHours > 0){
      return "$hours:$minutes:$seconds";
    }
    else{
      return "$minutes:$seconds";
    }

  }


}