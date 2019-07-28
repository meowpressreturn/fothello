import "package:fothello/types.dart";
import 'package:meta/meta.dart';

class Game {
  GameState _gameState;
  GameBoard _board;
  Player _currentPlayer;
  int _turn;
  bool _anyValidMoves;
  int _blueScore;
  int _redScore;

  GameBoard get board => _board; //todo: we expose the board, but its mutable! (dont!)
  // @visibleForTesting
  // void set board(newBoard) => _board = newBoard;
  GameState get gameState => _gameState;
  Player get currentPlayer => _currentPlayer;
  int get turn => _turn;
  bool get anyValidMoves => _anyValidMoves;
  int get blueScore => _blueScore;
  int get redScore => _redScore;

  Game() {
    startNewGame();
  }

  startNewGame() {
    _gameState = GameState.inProgress;
    _board = GameBoard.forNewGame();
    _currentPlayer = Player.blue;
    _turn = 0;
    _updateValidMoves();
    _updateScore();
  }

  int scoreFor(final Player player) {
    switch (player) {
      case Player.red:
        return _redScore;
      case Player.blue:
        return _blueScore;
      default:
        throw player;
    }
  }

  Tile getTile(final Location location) => _board.getTile(location);

  void move(final Location location) {
    print(
        "move row=${location.row}, column=${location.column} for ${currentPlayer.toString()} anyValidMoves=$_anyValidMoves");
    if (!anyValidMoves) {
      print("There are no valid moves, throwing exception");
      throw NoValidMovesException;
    } else if (moveIsValid(location)) {
      print("move is valid, proceeding to flip");
      _doFlip(location);
      _nextTurn();
    } else {
      print("move is not valid, throwing an exception");
      throw MoveNotValidException;
    }
  }

  void pass() {
    if (anyValidMoves) {
      throw NoValidMovesException;
    } else {
      _nextTurn();
    }
  }

  bool moveIsValid(final Location location) {
    //TODO - cache the valid moves in _updateValidMoves
    //we can use a Set of Location to record them
    print("call to moveIsValid for ${location.row},${location.column}");
    bool isValid = _canFlip(location);
    print("moveIsValid returning $isValid");
    return isValid;
  }

  void _nextTurn() {
    final lastPlayerHadNoValidMoves = !anyValidMoves;
    _turn += 1;
    _currentPlayer = _currentPlayer == Player.red ? Player.blue : Player.red;
    _updateValidMoves();
    _updateScore();
    if (!anyValidMoves && lastPlayerHadNoValidMoves) {
      _endGame();
    }
  }

  void _updateScore() {
    _blueScore = 0;
    _redScore = 0;
    _board.forEach((location) {
      switch (_board.getTile(location)) {
        case Tile.red:
          _redScore++;
          break;
        case Tile.blue:
          _blueScore++;
          break;
        case Tile.empty:
          break;
      }
    });
  }

  void _updateValidMoves() {
    _anyValidMoves = false;
    _board.forEach((location) {
      if (_canFlip(location)) {
        _anyValidMoves = true;
        //would like to break the loop here, but this isnt possible in a forEach callback!
        //another way we could look at doing this is to have board return an immutable all set
        //and iterate that with a normal for loop. (TODO)
      }
    });
    print("At completion of _updateValidMoves, _anyValidMoves=$_anyValidMoves");
  }

  void _endGame() {
    _gameState = GameState.complete;
  }

  ///Logic to flip counters to current players colour. nb: this does NOT re-validate whether the move is
  ///valid.
  void _doFlip(final Location location) {
    print("_doFlip row=${location.row}, column=${location.column}");
    final Tile colour = tileFor(currentPlayer);
    final Tile opponentColour = tileFor(opponentOf(currentPlayer));
    for (final Direction direction in Direction.values) {
      if (_canFlipInDirection(location, direction)) {
        print("doFlipInDirection to ${direction.toString()}");
        var nextLocation = location.neighbour(direction);
        while (_board.getTile(nextLocation) == opponentColour) {
          _board.setTile(nextLocation, colour);
          nextLocation = nextLocation.neighbour(direction);
        }
      }
    }
    _board.setTile(location, colour);
  }

  bool _canFlip(final Location location) {
    print("_canFlip row=${location.row}, column=${location.column}");
    if (_board.getTile(location) != Tile.empty) {
      return false;
    } else {
      for (final direction in Direction.values) {
        print("_canFlip is checking direction ${direction.toString()}");
        if (_canFlipInDirection(location, direction)) {
          return true; //Return as soon as we find any flippable direction
        }
      }
      //If we get here, no direction allowed for any flipping
      return false;
    }
  }

  bool _canFlipInDirection(final Location location, final Direction direction) {
    //Our tile colour that we are looking to meet again
    final colour = tileFor(currentPlayer);
    bool crossedOpponentTiles = false;
    Location nextLocation = location;
    while (null != (nextLocation = nextLocation.neighbour(direction))) {
      final nextTile = _board.getTile(nextLocation);
      print(
          "directionCanFlip is checking ${nextLocation.row}, ${nextLocation.column} which is ${nextTile.toString()} for ${colour.toString()}");
      if (nextTile == Tile.empty) {
        //If we hit an empty tile on our journey, then we can't flip tiles in that direction
        print("directionCanFlip found empty tile and is returning false");
        return false;
      } else if (nextTile == colour) {
        //When we reach our colour again, then whether any can flip any tiles in this direction
        //depends on whether we crossed opponent tiles to get here
        print(
            "directionCanFlip found tile of our colour ${colour.toString()} and is returning sawOpponent which is $crossedOpponentTiles");
        return crossedOpponentTiles;
      } else {
        //An opponent tile. Whether it is flipable depends on whether we reach a tile of
        //our own colour in a later iteration, for now we record that we saw the opponent
        print("directionCanFlip saw an opponent tile");
        crossedOpponentTiles = true;
      }
    }
    //If we get here we reached the edge of the board without encountering another
    //empty tile or tile of our own colour, which means none the opponent tiles (if any)
    //we crossed can't be flipped.
    print("directionCanFlip reached the edge of the board, returning false");
    return false;
  } //end of directionCanFlip
}
