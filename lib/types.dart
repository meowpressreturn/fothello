import 'package:meta/meta.dart';

enum Player { red, blue }

Player opponentOf(final Player player) {
  switch (player) {
    case Player.red:
      return Player.blue;
    case Player.blue:
      return Player.red;
  }
  return null;
}

enum Tile { empty, red, blue }

Tile tileFor(Player player) {
  switch (player) {
    case Player.red:
      return Tile.red;
    case Player.blue:
      return Tile.blue;
  }
  return null;
}

Player playerFor(Tile tile) {
  switch (tile) {
    case Tile.red:
      return Player.red;
    case Tile.blue:
      return Player.blue;
    case Tile.empty:
      return null; //TODO - or should we throw an exception?
  }
  return null;
}

enum Direction {
  north,
  northeast,
  east,
  southeast,
  south,
  southwest,
  west,
  northwest
}

@immutable
class InvalidLocationException implements Exception {
  final int row;
  final int column;

  InvalidLocationException(this.row, this.column);
}

@immutable
class Location {
  final int row;
  final int column;

  Location(this.row, this.column) {
    if (row > 7 || column > 7 || row < 0 || column < 0) {
      throw InvalidLocationException(row, column);
    }
  }

  Location neighbour(Direction direction) {
    try {
      switch (direction) {
        case Direction.north:
          return Location(row - 1, column);
        case Direction.northeast:
          return Location(row - 1, column + 1);
        case Direction.east:
          return Location(row, column + 1);
        case Direction.southeast:
          return Location(row + 1, column + 1);
        case Direction.south:
          return Location(row + 1, column);
        case Direction.southwest:
          return Location(row + 1, column - 1);
        case Direction.west:
          return Location(row, column - 1);
        case Direction.northwest:
          return Location(row - 1, column - 1);
      }
    } on InvalidLocationException {}
    return null;
  }
}

class GameBoard {
  List<List<Tile>> _tiles;

  static GameBoard forNewGame() {
    return GameBoard(
      blue: Set.of([Location(4, 3), Location(3, 4)]),
      red: Set.of([Location(3, 3), Location(4, 4)]),
    );
  }

  GameBoard({Set<Location> blue, Set<Location> red, Set<Location> empty}) {
    _tiles = List<List<Tile>>.generate(8, (int row) {
      return List.generate(8, (int column) => Tile.empty);
    });
    _setTiles(blue, Tile.blue);
    _setTiles(red, Tile.red);
    _setTiles(empty, Tile.empty);
  }

  _setTiles(Set<Location> locations, Tile color) {
    if (locations != null) {
      for (Location location in locations) {
        setTile(location, color);
      }
    }
  }

  void setTile(Location location, Tile tile) {
    _tiles[location.row][location.column] = tile;
  }

  Tile getTile(Location location) {
    return _tiles[location.row][location.column];
  }

  void forEach(void f(Location location)) {
    for (int row = 0; row < 8; row++) {
      for (int column = 0; column < 8; column++) {
        f(Location(row, column));
      }
    }
  }
}

class NoValidMovesException implements Exception {}

class MoveNotValidException implements Exception {}

enum GameState { inProgress, complete }
