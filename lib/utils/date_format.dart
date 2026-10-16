/// Lightweight replacement for `intl.DateFormat('d MMM, HH:mm')`.
/// The intl package was dropped (it was used exactly once and adds
/// significant APK weight). English month names are the default.
const List<String> _monthsEn = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

const List<String> _monthsId = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

String formatHistoryDate(DateTime dt, {String code = 'en'}) {
  final months = code == 'id' ? _monthsId : _monthsEn;
  final day = dt.day.toString();
  final month = months[dt.month - 1];
  final hour = dt.hour.toString().padLeft(2, '0');
  final minute = dt.minute.toString().padLeft(2, '0');
  return '$day $month, $hour:$minute';
}

/// Short `d MMM yyyy` label for charts and backups.
String formatShortDate(DateTime dt, {String code = 'en'}) {
  final months = code == 'id' ? _monthsId : _monthsEn;
  return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
}
