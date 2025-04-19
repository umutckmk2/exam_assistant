int toSeconds(DateTime dateTime) {
  return dateTime.millisecondsSinceEpoch ~/ 1000;
}

DateTime fromSeconds(int seconds) {
  return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
}
