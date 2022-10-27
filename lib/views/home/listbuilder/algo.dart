//Algorithm

void main() {
  final currentDate = DateTime.now();
  final expiryDate = DateTime(2022, 11, 12);
  const firstDay = DateTime.monday;
  List daysBetween(DateTime from, DateTime to, day) {
    List dates = [];
    while (from.isBefore(to)) {
      from = from.add(const Duration(days: 1));
      if (from.weekday == day) {
        dates.insert(0, from);
      }
    }

    return dates;
  }

  final noOfMondays = daysBetween(currentDate, expiryDate, firstDay);

  print(noOfMondays);
}
