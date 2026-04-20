class TimeFormat {
  //time formate
  String formatTime(String milliseconds) {
    final dt = DateTime.fromMillisecondsSinceEpoch(int.parse(milliseconds));
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String getLastMessageTime(String milliseconds) {
    final dt = DateTime.fromMillisecondsSinceEpoch(int.parse(milliseconds));
    final dtNow = DateTime.now();

    if (dt.day == dtNow.day &&
        dt.month == dtNow.month &&
        dt.year == dtNow.year) {
      return formatTime(milliseconds);
    } else {
      final month = switch (dt.month){
        1 => 'Jan',
        2 => 'Feb',
        3 => 'Mar',
        4 => 'Apr',
        5 => 'May',
        6 => 'Jun',
        7 => 'Jul',
        8 => 'Aug',
        9 => 'Sep',
        10 => 'Oct',
        11 => 'Nov',
        12 => 'Dec',
        _ => 'NA',
      };
      return '${dt.day} $month ${dt.year}';
    }
  }
}
