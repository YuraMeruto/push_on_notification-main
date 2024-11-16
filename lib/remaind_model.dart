class RemaindModel {
  int? id;
  String title = '';
  String memo = '';
  DateTime? remindTime;

  RemaindModel(
      {this.id, required this.title, required this.memo, this.remindTime});
  Map<String, dynamic> toMap({bool is_convert_datetime = false}) {
    if (is_convert_datetime) {
      return {
        'id': id,
        'title': title,
        'memo': memo,
        'remaind_time': remindTime.toString(),
      };
    }
    return {
      'id': id,
      'title': title,
      'memo': memo,
      'remaind_time': remindTime,
    };
  }
}
