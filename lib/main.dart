import 'package:flutter/material.dart';
import 'line.dart';
import 'line_divider.dart';
import 'note.dart';
import 'song_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Piano Tiles',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  // AudioCache player = new AudioCache();
  List<Note> notes = initNotes();
  AnimationController animationController;
  int currentNoteIndex = 0;
  int points = 0;
  bool hasStarted = false;
  bool isPlaying = true;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && isPlaying) {
        if (notes[currentNoteIndex].state != NoteState.tapped) {
          //game over
          setState(() {
            isPlaying = false;
            notes[currentNoteIndex].state = NoteState.missed;
          });
          animationController.reverse().then((_) => _showFinishDialog());
        } else if (currentNoteIndex == notes.length - 5) {
          //song finished
          _showFinishDialog();
        } else {
          setState(() => ++currentNoteIndex);
          animationController.forward(from: 0);
        }
      }
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        child: Stack(
          fit: StackFit.passthrough,
          children: <Widget>[
            ElevatedButton(onPressed: () {}, child: Text('H')),
            Image.asset(
              'assets/background.jpg',
              fit: BoxFit.cover,
            ),
            Row(
              children: <Widget>[
                _drawLine(0),
                LineDivider(),
                _drawLine(1),
                LineDivider(),
                _drawLine(2),
                LineDivider(),
                _drawLine(3),
              ],
            ),
            _drawPoints(),
          ],
        ),
      ),
    );
  }

  void _restart() {
    setState(() {
      hasStarted = false;
      isPlaying = true;
      notes = initNotes();
      points = 0;
      currentNoteIndex = 0;
    });
    animationController.reset();
  }

  void _showFinishDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String pt = 'point' + ((points > 1) ? 's' : '');
        return AlertDialog(
          title: Text('Game over!'),
          content: Text(
            'You scored $points $pt',
            style: TextStyle(fontSize: 20),
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Icon(
                Icons.repeat,
                color: Colors.black,
              ),
            ),
          ],
        );
      },
    ).then((_) => _restart());
  }

  void _onTap(Note note) {
    bool areAllPreviousTapped = notes
        .sublist(0, note.orderNumber)
        .every((n) => n.state == NoteState.tapped);
    print(areAllPreviousTapped);
    if (areAllPreviousTapped) {
      if (!hasStarted) {
        setState(() => hasStarted = true);
        animationController.forward();
      }
      _playNote(note);
      setState(() {
        note.state = NoteState.tapped;
        ++points;
      });
    }
  }

  _drawLine(int lineNumber) {
    return Expanded(
      child: Line(
        lineNumber: lineNumber,
        currentNotes: notes.sublist(currentNoteIndex, currentNoteIndex + 5),
        onTileTap: _onTap,
        animation: animationController,
      ),
    );
  }

  _drawPoints() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 32.0),
        child: Text(
          "$points",
          style: TextStyle(color: Colors.red, fontSize: 60),
        ),
      ),
    );
  }

  _playNote(Note note) {
    switch (note.line) {
      // case 0:
      //   player.play('a.wav');
      //   print('@@@@@');
      //   print('${note.line}');
      //   return;
      // case 1:
      //   player.play('c.wav');
      //   print('@@@@@');
      //   print('${note.line}');
      //   return;
      // case 2:
      //   player.play('e.wav');
      //   print('@@@@@');
      //   print('${note.line}');
      //   return;
      // case 3:
      //   player.play('f.wav');
      //   print('@@@@@');
      //   print('${note.line}');
      //   return;
    }
  }
}
