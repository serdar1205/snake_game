import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_snake_game/blank_pixel.dart';
import 'package:firebase_snake_game/food_pixel.dart';
import 'package:firebase_snake_game/highscore_tile.dart';
import 'package:firebase_snake_game/snake_pixel.dart';
import 'package:flutter/material.dart';

// ignore: constant_identifier_names, camel_case_types
enum snakeDirection { UP, DOWN, LEFT, RIGHT }

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final int rowSize = 10;

  final int totalSquareNumber = 100;
  int currentScore = 0;

  List<int> snakePos = [
    0,
    1,
    2,
  ];

  int foodPos = 20;
  bool gameHasStarted = false;

  //SNAKE DIRECTION DEFAULT
  var currentDirection = snakeDirection.RIGHT;

  final _nameController = TextEditingController();

  //high score list
  List<String> highScoreDocIds = [];
  late final Future? getDocIds;

  @override
  void initState() {
    super.initState();
    getDocIds = getDocId();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future getDocId() async {
    await FirebaseFirestore.instance
        .collection('highscores')
        .orderBy('score', descending: true)
        .limit(5)
        .get()
        .then((value) => value.docs.forEach((element) {
              highScoreDocIds.add(element.reference.id);
            }));
  }

  void startGame() {
    gameHasStarted = true;
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        moveSnake();

        //check game is over
        if (gameOver()) {
          timer.cancel();

          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                    title: const Text("Game over"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Your score is: $currentScore'),
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(hintText: 'Enter name'),
                        )
                      ],
                    ),
                    actions: [
                      MaterialButton(
                        onPressed: () {
                          Navigator.pop(context);
                          submitScore();
                          newGame();
                        },
                        child: const Text('Submit'),
                        color: Colors.pink,
                      )
                    ],
                  ));
        }
      });
    });
  }

  void submitScore() {
    //get access to the collection
    var database = FirebaseFirestore.instance;
    database.collection('highscores').add({
      "name": _nameController.text,
      "score": currentScore,
    });
  }

  void newGame() async{
    highScoreDocIds = [];
    await getDocId();
    setState(() {
      snakePos = [
        0,
        1,
        2,
      ];
      foodPos = 25;
      currentDirection = snakeDirection.RIGHT;
      gameHasStarted = false;
    });
  }

  void eatFood() {
    currentScore++;
    //making sure the new food is not where the snake is
    while (snakePos.contains(foodPos)) {
      foodPos = Random().nextInt(totalSquareNumber);
      print('///////////////////////////');
    }
  }

  bool gameOver() {
    //the game is over when the snake runs inot itself
    // this occurs when there is a duplicate position in the snake list

    // this list is the body of the snake (no head)
    List<int> bodySnake = snakePos.sublist(0, snakePos.length - 1);

    if (bodySnake.contains((snakePos.last))) {
      return true;
    } else {
      return false;
    }
  }

  void moveSnake() {
    switch (currentDirection) {
      case snakeDirection.RIGHT:
        {
          if (snakePos.last % rowSize == 9) {
            snakePos.add(snakePos.last + 1 - rowSize);
          } else {
            //add a new head
            snakePos.add(snakePos.last + 1);
          }
        }
        break;
      case snakeDirection.LEFT:
        {
          if (snakePos.last % rowSize == 0) {
            snakePos.add(snakePos.last - 1 + rowSize);
          } else {
            //add a new head
            snakePos.add(snakePos.last - 1);
          }
        }
        break;
      case snakeDirection.UP:
        {
          if (snakePos.last < rowSize) {
            snakePos.add(snakePos.last - rowSize + totalSquareNumber);
          } else {
            snakePos.add(snakePos.last - rowSize);
          }
        }
        break;
      case snakeDirection.DOWN:
        {
          if (snakePos.last + rowSize > totalSquareNumber) {
            snakePos.add(snakePos.last + rowSize - totalSquareNumber);
          } else {
            snakePos.add(snakePos.last + rowSize);
          }
        }
        break;
      default:
    }
    if (snakePos.last == foodPos) {
      eatFood();
    } else {
      snakePos.removeAt(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          //high scores
          Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Current Score'),
                    Text(currentScore.toString())
                  ],
                ),
              ),
              const SizedBox(width: 30),
              Expanded(
                child: gameHasStarted ? Container() : FutureBuilder(
                    future: getDocIds,
                    builder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ListView.builder(
                            itemCount: highScoreDocIds.length,
                            itemBuilder: (context, index) {
                              return HighScoreTile(docId: highScoreDocIds[index]);
                            }),
                      );
                    }),
              ),
            ],
          )),
          Expanded(
              flex: 3,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (details.delta.dy > 0 &&
                      currentDirection != snakeDirection.UP) {
                    currentDirection = snakeDirection.DOWN;
                    print('move down');
                  } else if (details.delta.dy < 0 &&
                      currentDirection != snakeDirection.DOWN) {
                    currentDirection = snakeDirection.UP;
                    print('move up');
                  }
                },
                onHorizontalDragUpdate: (details) {
                  if (details.delta.dx > 0 &&
                      currentDirection != snakeDirection.LEFT) {
                    print('move right');
                    currentDirection = snakeDirection.RIGHT;
                  } else if (details.delta.dx < 0 &&
                      currentDirection != snakeDirection.RIGHT) {
                    print('move left');
                    currentDirection = snakeDirection.LEFT;
                  }
                },
                child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: totalSquareNumber,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: rowSize),
                    itemBuilder: (context, index) {
                      if (snakePos.contains(index)) {
                        return const SnakePixel();
                      } else if (foodPos == index) {
                        return const FoodPixel();
                      } else {
                        return const BlankPixel();
                      }
                    }),
              )),
          Expanded(
              child: Center(
            child: MaterialButton(
              onPressed: gameHasStarted ? () {} : startGame,
              color: gameHasStarted ? Colors.grey : Colors.pink,
              child: const Text('Play'),
            ),
          )),
        ],
      ),
    );
  }
}
