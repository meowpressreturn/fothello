import 'package:test/test.dart';
import 'package:fothello/game.dart';
import "package:fothello/types.dart";

expectInitialTileLayout(Game game) {
  for (int i = 0; i < 64; i++) {
    final int row = i ~/ 8;
    int column = i % 8;
    final actual = game.getTile(Location(row, column));
    switch (i) {
      case 27: //row 3, column 3, should be red
        expect(actual, Tile.red);
        break;
      case 28: //row 3, column 4, should be blue
        expect(actual, Tile.blue);
        break;
      case 35: //row 4, column 3, should be blue
        expect(actual, Tile.blue);
        break;
      case 36: //row 4, column 4, should be red
        expect(actual, Tile.red);
        break;
      default: //any other tile should be empty
        expect(actual, Tile.empty);
        break;
    }
  }
}

void main() {
  test('New game has initial tile layout', () {
    expectInitialTileLayout(Game());
  });

  test('startNewGame restores initial tile layout', () {
    final game = Game();
    game.startNewGame();
    expectInitialTileLayout(game);
    //todo - how should we allow for tests to manipulate the board?
    game.board.setTile(Location(3, 3), Tile.empty);
    game.board.setTile(Location(0, 0), Tile.red);
    game.startNewGame();
    expectInitialTileLayout(game);
  });

  test('First move() with valid move' ,() {
    final game = Game();
    game.move(Location(4,5));
    expect(Tile.blue, game.getTile(Location(4,5)));
    expect(Tile.blue, game.getTile(Location(4,4)));
    expect(Tile.red, game.getTile(Location(3,3)));
    expect(Player.red, game.currentPlayer);
    expect(4, game.blueScore);
    expect(1, game.redScore);
  });

  test('Expected valid initial moves', () {
    final game = Game();
    expect(true, game.moveIsValid(Location(4,5)));
    expect(true, game.moveIsValid(Location(3,2)));
    expect(false, game.moveIsValid(Location(4,2)));
    expect(false, game.moveIsValid(Location(5,5)));
  });
}
