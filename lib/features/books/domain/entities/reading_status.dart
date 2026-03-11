enum ReadingStatus {
  wantToRead,
  currentlyReading,
  finished;

  String get displayName {
    switch (this) {
      case ReadingStatus.wantToRead:
        return 'Want to Read';
      case ReadingStatus.currentlyReading:
        return 'Currently Reading';
      case ReadingStatus.finished:
        return 'Finished';
    }
  }
}
