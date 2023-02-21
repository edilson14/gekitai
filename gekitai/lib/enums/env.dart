class Env {
  static const List<int> topBorder = <int>[0, 1, 2, 3, 4, 5];
  static const List<int> rightBorder = <int>[5, 11, 17, 23, 29, 35];
  static const List<int> leftBorder = <int>[0, 6, 12, 18, 24, 30];
  static const List<int> bottomBorder = <int>[30, 31, 32, 33, 34, 35];

  static bool isOnBorder(int index) {
    return topBorder.contains(index) ||
        rightBorder.contains(index) ||
        leftBorder.contains(index) ||
        bottomBorder.contains(index);
  }

  static bool isNearFromBorder(int index) {
    return topBorder.contains(index - 1) ||
        topBorder.contains(index + 1) ||
        topBorder.contains(index + 5) ||
        topBorder.contains(index - 7) ||
        rightBorder.contains(index - 1) ||
        rightBorder.contains(index + 1) ||
        rightBorder.contains(index + 6) ||
        leftBorder.contains(index - 1) ||
        leftBorder.contains(index + 1) ||
        leftBorder.contains(index - 6) ||
        bottomBorder.contains(index - 1) ||
        bottomBorder.contains(index + 1) ||
        bottomBorder.contains(index - 5) ||
        bottomBorder.contains(index + 7);
  }

  static List<int> getBorderIndexes(int index) {
    List<int> borderIndexes = [];
    if (topBorder.contains(index - 1)) borderIndexes.add(index - 1);
    if (topBorder.contains(index + 1)) borderIndexes.add(index + 1);
    if (topBorder.contains(index + 5)) borderIndexes.add(index + 5);
    if (topBorder.contains(index - 5)) borderIndexes.add(index - 5);
    if (topBorder.contains(index - 7)) borderIndexes.add(index - 7);
    if (topBorder.contains(index - 6)) borderIndexes.add(index - 6);
    if (rightBorder.contains(index - 1)) borderIndexes.add(index - 1);
    if (rightBorder.contains(index + 1)) borderIndexes.add(index + 1);
    if (rightBorder.contains(index + 6)) borderIndexes.add(index + 6);
    if (rightBorder.contains(index + 7)) borderIndexes.add(index + 7);
    if (leftBorder.contains(index - 1)) borderIndexes.add(index - 1);
    if (leftBorder.contains(index + 1)) borderIndexes.add(index + 1);
    if (leftBorder.contains(index - 6)) borderIndexes.add(index - 6);
    if (bottomBorder.contains(index - 1)) borderIndexes.add(index - 1);
    if (bottomBorder.contains(index + 1)) borderIndexes.add(index + 1);
    if (bottomBorder.contains(index - 5)) borderIndexes.add(index - 5);
    if (bottomBorder.contains(index + 5)) borderIndexes.add(index + 5);
    if (bottomBorder.contains(index + 6)) borderIndexes.add(index + 6);
    if (bottomBorder.contains(index + 7)) borderIndexes.add(index + 7);
    return borderIndexes;
  }

  static bool isOnLeftBorder(int index) {
    return leftBorder.contains(index);
  }
}
