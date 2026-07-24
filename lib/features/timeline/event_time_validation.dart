const Duration eventFutureTolerance = Duration(minutes: 2);

bool isEventTimeInFuture(DateTime value, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  return value.isAfter(reference.add(eventFutureTolerance));
}

DateTime clampEventPickerInitialDate(DateTime value, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  return value.isAfter(reference) ? reference : value;
}

String futureEventMessage(String label) {
  return '$label nelze uložit s časem v budoucnosti.';
}
