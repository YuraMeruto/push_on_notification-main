class RemaindModel {
  int? id;
  String title = '';
  String memo = '';
  DateTime? remindTime;
  int is_remind;

  RemaindModel(
      {this.id,
      required this.title,
      required this.memo,
      this.remindTime,
      this.is_remind = 0});
  Map<String, dynamic> toMap({bool is_convert_datetime = false}) {
    if (is_convert_datetime) {
      return {
        'id': id,
        'title': title,
        'memo': memo,
        'remaind_time': remindTime.toString(),
        'is_remind': is_remind,
      };
    }
    return {
      'id': id,
      'title': title,
      'memo': memo,
      'remaind_time': remindTime,
      'is_remind': is_remind,
    };
  }
}
