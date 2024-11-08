class RemaindModel {
  String _memo = '';
  DateTime _remaindTime;
  String get memo => _memo;
  DateTime get remaindTime => _remaindTime;
  RemaindModel(String this._memo, DateTime this._remaindTime);

  Map<String, dynamic> toMap() {
    return {
      'memo': memo,
      'remaind_time': remaindTime,
    };
  }
}
