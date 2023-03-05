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
}
