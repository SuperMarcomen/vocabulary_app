import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vocabularyapp/database_manager.dart';
import 'package:vocabularyapp/main.dart';

import 'insert_word.dart';

class WordManager extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    DatabaseManager database = DatabaseManager.instance;
    print(database.queryAllWords().toString());
    return Scaffold(
      backgroundColor: Color.fromRGBO(44, 62, 80, 1.0),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  padding: EdgeInsets.only(top: 20),
                  icon: Icon(Icons.arrow_back),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyHomePage()),
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  padding: EdgeInsets.only(top: 20),
                  icon: Icon(Icons.add),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => InsertWord()),
                    );
                  },
                ),
              ),
            ],
          ),

          Expanded(
            child: ListView(
                children: [
                  FutureBuilder(
                      future: database.queryAllWords(),
                      builder: (BuildContext context, AsyncSnapshot<List<Word>> result) {
                        if (result.connectionState != ConnectionState.done) {
                          return SizedBox(width: 200, height: 30, child: CircularProgressIndicator());
                        }

                        if (result.data == null || result.data.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 250),
                              child: Text(
                                  'Nessuna parola è stata trovata',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0,
                                  )
                              ),
                            ),
                          );
                        }

                        return Column(

                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            for (var word in result.data) WordContainer(word)
                          ],
                        );

                      }
                  )
                ]
            ),
          ),
        ],
      ),

    );
  }
}

class WordContainer extends StatelessWidget {

  Word word;

  WordContainer(this.word);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
            padding: EdgeInsets.only(left: 10),
            child:
            Text(
                word.article + ' ' + word.word,
              style: TextStyle(
                color: Colors.white
              ),
            )
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.cancel),
              color: Colors.white,
              onPressed: () {
                // set up the buttons
                Widget stopButton = FlatButton(
                  child: Text('Annulla'),
                  onPressed:  () {
                    Navigator.of(context).pop(); // dismiss dialog
                  },
                );
                Widget cancelButton = FlatButton(
                  child: Text('Cancella'),
                  onPressed:  () {
                    DatabaseManager.instance.deleteWord(word.word);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WordManager()),
                    );
                  },
                );

                // set up the AlertDialog
                AlertDialog alert = AlertDialog(
                  title: Text('Attenzione'),
                  content: Text('Vuoi davvero cancellare la parola "${word.article} ${word.word}"'),
                  actions: [
                    stopButton,
                    cancelButton,
                  ],
                );

                // show the dialog
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return alert;
                  },
                );
              },
            ),
            IconButton(
                icon: Icon(Icons.edit),
                color: Colors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => InsertWord().setWordAndArticle(word.word, word.article)),
                  );
                }
            )
          ],
        ),
      ],
    );
  }
}