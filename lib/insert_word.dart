import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vocabularyapp/database_manager.dart';
import 'package:vocabularyapp/word_manager.dart';

class InsertWord extends StatelessWidget {

  bool _editing = false;
  String _originalWord;
  var screenWidth;
  var screenHeight;

  String word = '';
  String article = '';

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    DatabaseManager database = DatabaseManager.instance;
    return Scaffold(
      backgroundColor: Color.fromRGBO(52, 73, 94, 1.0),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                    icon: Icon(Icons.arrow_back),
                    color: Colors.white,
                    onPressed: () {
                      Navigator.of(context).pop(); // dismiss dialog
                    }
                ),
              ],
            ),
          ),
          SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: article),
                    onChanged: (value) => article = value,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        hintStyle: TextStyle(color: Colors.white),
                        border: InputBorder.none,
                        hintText: 'Articolo'
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: word),
                    onChanged: (value) => word = value,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintStyle: TextStyle(color: Colors.white),
                      border: InputBorder.none,
                      hintText: 'Parola',
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 50),

          SizedBox(
            height: screenHeight/14,
            width: screenWidth-20,
            child: RaisedButton(
              color: Color.fromRGBO(44, 62, 80, 1.0),

              child: Text(
                _editing? 'Aggiorna' : 'Aggiungi',

                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w300,
                    color: Colors.white
                ),
              ),

              onPressed: () {
                if (!_isArticleValid(article)) {
                  Widget okButton = FlatButton(
                    child: Text('Ok'),
                    onPressed:  () {
                      Navigator.of(context).pop(); // dismiss dialog
                    },
                  );

                  // set up the AlertDialog
                  AlertDialog alert = AlertDialog(
                    title: Text('Attenzione'),
                    content: Text('Articolo invalido'),
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
                  return;
                }

                if (_editing) {
                  database.updateWordAlternative(_originalWord, word, article);
                } else {
                  Word word = new Word();
                  word.word = this.word;
                  word.article = article;
                  word.right = 0;
                  word.wrong = 0;
                  database.insertWord(word);
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WordManager()),
                );
              },
            ),
          )
        ],
      ),

    );
  }

  InsertWord setWordAndArticle(String word, String article) {
    word = word;
    article = article;
    _editing = true;
    _originalWord = word;
    return this;
  }

  bool _isArticleValid(String article) {
    if (article == 'der' || article == 'die' || article == 'das') return true;
    else return false;
  }

}
