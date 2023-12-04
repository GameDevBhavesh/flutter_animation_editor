extension DurationExtensions on Duration {
  double toSeconds() {
    return this.inMilliseconds / 1000.0;
  }
}
