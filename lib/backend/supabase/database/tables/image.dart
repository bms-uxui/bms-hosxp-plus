import '../database.dart';

class ImageTable extends SupabaseTable<ImageRow> {
  @override
  String get tableName => 'image';

  @override
  ImageRow createRow(Map<String, dynamic> data) => ImageRow(data);
}

class ImageRow extends SupabaseDataRow {
  ImageRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ImageTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get url => getField<String>('url');
  set url(String? value) => setField<String>('url', value);
}
