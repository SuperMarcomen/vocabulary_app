import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vocabularyapp/word_manager.dart';

import 'database_manager.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vocabulary',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();

}

class _MyHomePageState extends State<MyHomePage> {

  var screenWidth;
  var screenHeight;
  List<Word> words;

  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        body: Container(
          height: double.infinity,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color.fromRGBO(204, 43, 94, 1),
                    Color.fromRGBO(117, 58, 136, 1)
                  ]
              )
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => WordManager()),
                      );
                    },
                    padding: EdgeInsets.only(top: 20),
                    icon: Icon(Icons.settings),
                    color: Colors.white,
                  )
                ],
              ),
              SizedBox(height: screenHeight/8),

              FutureBuilder(
                  future: getNewWord(),
                  builder: (BuildContext context, AsyncSnapshot<Word> result) {
                    if (result.connectionState != ConnectionState.done) {
                      return SizedBox(width: 200, height: 30, child: CircularProgressIndicator());
                    }

                    if (result.data == null) {
                      return Text(
                        'Nessuna parola è stata trovata :(',
                        style: TextStyle(
                            shadows: <Shadow>[
                              Shadow(
                                offset: Offset(0.0, 4.0),
                                blurRadius: 3,
                                color: Color.fromRGBO(0, 0, 0, 0.25),
                              ),
                            ],
                            fontSize: 48.0,
                            fontWeight: FontWeight.w300,
                            color: Colors.white
                        ),
                        textAlign: TextAlign.center,
                      );
                    }

                    return Column(
                      children: [
                        Text(
                          result.data.word,
                          style: TextStyle(
                              shadows: <Shadow>[
                                Shadow(
                                  offset: Offset(0.0, 4.0),
                                  blurRadius: 3,
                                  color: Color.fromRGBO(0, 0, 0, 0.25),
                                ),
                              ],
                              fontSize: 48.0,
                              fontWeight: FontWeight.w300,
                              color: Colors.white
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: screenHeight/2.2),

                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ArticleButton(buttonWidth: screenWidth-20, buttonHeight: screenHeight/14, article: "der", color: Color.fromRGBO(80, 95, 178, 1), word: result.data),
                            SizedBox(height: 10),
                            ArticleButton(buttonWidth: screenWidth-20, buttonHeight: screenHeight/14, article: "die", color: Color.fromRGBO(178, 80, 80, 1), word: result.data),
                            SizedBox(height: 10),
                            ArticleButton(buttonWidth: screenWidth-20, buttonHeight: screenHeight/14, article: "das", color: Color.fromRGBO(111, 178, 80, 1), word: result.data),
                          ],
                        ),
                      ],
                    );
                  }
              ),

            ],
          ),
        )
    );
  }

  Random _random = new Random();
  Future<Word> getNewWord() async {
    if (words == null) {
      words = await DatabaseManager.instance.queryAllWords();
    }

    words.sort((a, b) => b.getRightPercentage().compareTo(a.getRightPercentage()));
    int max = 20;
    if (words.length < 20) max = words.length;

    Word word = words[_random.nextInt(max)];
    while (_oldWord != null && _oldWord.word == word.word) {
      word = words[_random.nextInt(max)];
    }

    _oldWord = word;
    return word;
  }

}

Word _oldWord;

class ArticleButton extends StatelessWidget {
  const ArticleButton({
    Key key,
    @required this.buttonWidth,
    @required this.buttonHeight,
    @required this.article,
    @required this.color,
    @required this.word
  }) : super(key: key);

  final double buttonWidth;
  final double buttonHeight;
  final String article;
  final Color color;
  final Word word;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: RaisedButton(
        color: color,
        onPressed: (){
          if (article == word.article) {
            word.increaseRight();
            DatabaseManager.instance.updateWord(word);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyHomePage()),
            );
            print('correct');
          } else {
            word.increaseWrong();
            DatabaseManager.instance.updateWord(word);

            Widget okButton = FlatButton(
              child: Text('Ok'),
              onPressed:  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyHomePage()),
                );
              },
            );

            // set up the AlertDialog
            AlertDialog alert = AlertDialog(
              title: Text('Attenzione'),
              content: Text('L\'articolo corretto è ${word.article}'),
              actions: [
                okButton,
              ],
            );

            // show the dialog
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return alert;
              },
            );
            print('wrong');
          }
        },
        child: Text(
          article,
          style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w300,
              color: Colors.white
          ),
        ),
      ),
    );
  }
}
