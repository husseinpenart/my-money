class ScheduledAlert {
  final int id;
  final DateTime at; // زمان محلی دستگاه
  final String title, body;
  final String? payload;
  const ScheduledAlert(this.id, this.at, this.title, this.body, {this.payload});
}
