import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fothello/game.dart';
import "package:fothello/types.dart";

void main() => runApp(Fothello());



class Fothello extends StatelessWidget {
  final game = Game();
  @override
  Widget build(BuildContext context) {
    
    final gameKey = GlobalKey<OBoardState>();
    return MaterialApp(
        theme: Theme.of(context).copyWith(primaryColor: Colors.green),
        title: 'FOthello',
        home: Scaffold(
          appBar: AppBar(title: Text("Othello in Flutter")),
          body: OBoardWidget(game, key: gameKey),
          drawer: FOthelloDrawer(gameKey),
        ));
  }
}

///Provides the Drawer. We can't create it directly in the FOthelloWidget because we need to
///create it in the build method of a widget below the ...something? so that when we call
///Navigator.pop(context) it doesnt throw an exception complaining
///"Navigator operation requested with a context that does not include a Navigator
class FOthelloDrawer extends StatelessWidget {
  GlobalKey<OBoardState> _gameKey;

  FOthelloDrawer(this._gameKey) {}

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      children: <Widget>[
        ListTile(
            title: Text("New Game"),
            trailing: Icon(Icons.scatter_plot),
            onTap: () {
              print(
                  "new game clicked, gameKey.currentState=${_gameKey.currentState}");
              _gameKey.currentState.newGame();
              Navigator.pop(context);
            }),
      ],
    ));
  }
}

class OBoardWidget extends StatefulWidget {
  Game _game;

  OBoardWidget(this._game, {Key key}) : super(key: key) {}

  @override
  State<StatefulWidget> createState() {
    return OBoardState(_game);
  }
}

class OBoardState extends State<OBoardWidget> {
  Game _game;

  OBoardState(this._game) {}

  //Currently we are going to be rebuilding the entire widget tree every time a move is made.
  //Not a big deal actually for this app, but bad practice in general, so we should try and redeign it
  //so only stuff that needs to change gets rebuilt! (Although, to be fair, that actually is most about
  //everything!)

  @override
  Widget build(BuildContext context) {
    print(
        " *** SIZE= ${MediaQuery.of(context).size.width} x ${MediaQuery.of(context).size.height}");
    return Container(
      //alignment: Alignment.topRight,
      color: Colors.cyanAccent,
      child: Column(children: <Widget>[
        _buildHeaderMargin(context),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildScoreMargin(context, Player.blue),
            _buildBoardLayout(context),
            _buildScoreMargin(context, Player.red),
          ],
        ),
        _buildFooterMargin(context),
      ]),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  clickBoard(final int row, final int column) {
    print("clickBoard row=$row, column=$column");
    final Location location = Location(row, column);
    setState(() {
      if (_game.moveIsValid(location)) {
        _game.move(location);
        print("moved");
      } else {
        print("(not a valid move)");
      }
    });
  }

  pass() {
    print("pass clicked");
    if (_game.anyValidMoves == false) {
      print("no valid moves, so calling pass()");
      setState(() {
        _game.pass();
      });
    }
  }

  newGame() {
    setState(() {
      _game.startNewGame();
    });
  }

  Widget _buildBoardLayout(final BuildContext context) {
    return Container(
        //constraints: BoxConstraints.tightFor(),
        alignment: Alignment.center,
        color: Colors.greenAccent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List<Widget>.generate(8, (row) {
            return Row(
                mainAxisSize: MainAxisSize.min,
                children: List<Widget>.generate(8, (column) {
                  return GestureDetector(
                    onTap: () => clickBoard(row, column),
                    child: _imageFor(_game.getTile(Location(row, column))),
                  );
                }));
          }),
        ));
  }

  Widget _buildScoreMargin(final BuildContext context, final Player player) {
    Column column = Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: new SizedBox(
            width: 48,
            child: Container(
              alignment: Alignment.center,
              color:
                  player == Player.blue ? Colors.blueAccent : Colors.redAccent,
              child: Text("${_game.scoreFor(player)}",
                  style: TextStyle(fontSize: 32)),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 32),
          child: (player == _game.currentPlayer)
              ? Icon(Icons.account_circle)
              : Icon(null),
        ),
        SizedBox(
          width: 48,
          child: RaisedButton(
            onPressed: _game.anyValidMoves || (player != _game.currentPlayer)
                ? null
                : () => pass(),
            child: Text("Pass",style: TextStyle(
              fontSize: 16,
              
            )),
          ),
        ),
      ],
    );
    return column;
  }

  Widget _buildHeaderMargin(final BuildContext context) {
    final int margin = (_game.redScore - _game.blueScore).abs();
    String text;
    if (_game.gameState == GameState.inProgress) {
      final leader = _game.blueScore > _game.redScore
          ? "Blue leads by $margin"
          : (margin == 0 ? "Tied!" : "Red leads by $margin");
      text = "Turn ${_game.turn} : $leader";
    } else {
      final winner = _game.blueScore > _game.redScore
          ? "Blue wins by $margin"
          : (margin == 0 ? "Game ends in a tie" : "Red wins by $margin");
      text = "$winner on turn ${_game.turn}!";
    }
    return Text(text,
        style: TextStyle(
          fontSize: 24, 
        ));
    ;
  }

  Widget _buildFooterMargin(final BuildContext context) {
    String text;
    Color color;
    switch (_game.gameState) {
      case GameState.inProgress:
        if (_game.currentPlayer == Player.blue) {
          text = _game.anyValidMoves ? "Blue to move" : "Blue cannot move!";
          color = Colors.blue;
        } else {
          text = _game.anyValidMoves ? "Red to move" : "Red cannot move!";
          color = Colors.red;
        }
        break;
      case GameState.complete:
        text = "Game Over!";
        color = Colors.black;
        break;
    }
    return Text(text,
        style: TextStyle(
          fontSize: 32,
          color: color,
        ));
    ;
  }

  Widget _imageFor(Tile tile) {
    const double size = 32;
    switch (tile) {
      case Tile.empty:
        return Image.asset("assets/empty.png", width: size, height: size);
      case Tile.blue:
        return Image.asset("assets/blue.png", width: size, height: size);
      case Tile.red:
        return Image.asset("assets/red.png", width: size, height: size);

      default:
        return Image.asset("assets/empty.png", width: size, height: size);
    }
  }
}
