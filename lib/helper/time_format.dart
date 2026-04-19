class TimeFormat {
  //time formate
  String formatTime(String milliseconds) {
    final dt = DateTime.fromMillisecondsSinceEpoch(int.parse(milliseconds));
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

}