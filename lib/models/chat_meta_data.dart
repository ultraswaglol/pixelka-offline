import 'package:hive/hive.dart';

part 'chat_meta_data.g.dart';

@HiveType(typeId: 1)
class ChatMetaData extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  final DateTime createdAt;

  ChatMetaData({
    required this.id,
    required this.title,
    required this.createdAt,
  });
}
