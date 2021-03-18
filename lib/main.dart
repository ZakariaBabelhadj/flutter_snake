import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final int squareR = 20;
  final int squareC = 40;
  final fontStyle = TextStyle(color: Colors.white, fontSize: 20);
  final randomGen = Random();

  var snake = [
    [0, 1],
    [0, 0]
  ];
  var food = [0, 2];
  var direction = 'up';
  var isPlaying = false;

  void startGame() {
    const duration = Duration(milliseconds: 100);
    snake = [
      [(squareR / 2).floor(), (squareC / 2).floor()]
    ];
    snake.add([snake.first[0], snake.first[1] + 1]);
    createFood();
    isPlaying = true;
    Timer.periodic(duration, (Timer timer) {
      moveSnake();
      if (gameChecked()) {
        timer.cancel();
        endGame();
      }
    });
  }

  void moveSnake() {
    setState(() {
      switch (direction) {
        case "up":
          snake.insert(0, [snake.first[0], snake.first[1] - 1]);
          break;
        case "down":
          snake.insert(0, [snake.first[0], snake.first[1] + 1]);
          break;
        case "right":
          snake.insert(0, [snake.first[0] + 1, snake.first[1]]);
          break;
        case "left":
          snake.insert(0, [snake.first[0] - 1, snake.first[1]]);
          break;
      }
      if (snake.first[0] != food[0] || snake.first[1] != food[1]) {
        snake.removeLast();
      } else {
        createFood();
      }
    });
  }

  void createFood() {
    food = [randomGen.nextInt(squareR), randomGen.nextInt(squareC)];
  }

  bool gameChecked() {
    if (!isPlaying ||
        snake.first[1] < 0 ||
        snake.first[1] >= squareC ||
        snake.first[0] < 0 ||
        snake.first[0] >= squareR) {
      return true;
    }

    for (var i = 1; i < snake.length; i++) {
      if (snake[i][0] == snake.first[0] && snake[i][1] == snake.first[1]) {
        return true;
      }
    }

    return false;
  }

  void endGame() {
    isPlaying = false;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Game Over"),
            content: Text(
              "Score: ${snake.length - 2}",
              style: TextStyle(fontSize: 20),
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Close"))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (direction != 'up' && details.delta.dy > 0) {
                  direction = 'down';
                } else if (direction != 'down' && details.delta.dy < 0) {
                  direction = 'up';
                }
              },
              onHorizontalDragUpdate: (details) {
                if (direction != 'left' && details.delta.dx > 0) {
                  direction = 'right';
                } else if (direction != 'right' && details.delta.dx < 0) {
                  direction = 'left';
                }
              },
              child: AspectRatio(
                aspectRatio: squareR / (squareC + 2),
                child: GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: squareR),
                  itemCount: squareR * squareC,
                  itemBuilder: (BuildContext context, int index) {
                    var color;
                    var x = index % squareR;
                    var y = (index / squareR).floor();

                    bool isSnakeBody = false;
                    for (var pos in snake) {
                      if (pos[0] == x && pos[1] == y) {
                        isSnakeBody = true;
                        break;
                      }
                    }

                    if (snake.first[0] == x && snake.first[1] == y) {
                      color = Colors.green;
                    } else if (isSnakeBody) {
                      color = Colors.green[300];
                    } else if (food[0] == x && food[1] == y) {
                      color = Colors.red;
                    } else {
                      color = Colors.grey[800];
                    }

                    return Container(
                        margin: EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ));
                  },
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              FlatButton(
                  color: isPlaying ? Colors.red : Colors.blue,
                  onPressed: () {
                    if (isPlaying) {
                      isPlaying = false;
                    } else {
                      startGame();
                    }
                  },
                  child: Text(
                    isPlaying ? "End" : "Start",
                    style: fontStyle,
                  )),
              Text(
                "Score: ${snake.length - 2}",
                style: fontStyle,
              )
            ],
          )
        ],
      ),
    );
  }
}
