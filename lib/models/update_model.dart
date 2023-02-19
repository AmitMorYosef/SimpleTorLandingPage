import 'dart:convert';

class Update {
  String title = '', content = '', lastModified = '';

  Update(
      {required this.title, required this.content, required this.lastModified});

  Update.fromJson(Map<String, dynamic> json) {
    this.title = json['title'];
    this.content = json['content'];
    this.lastModified = json['lastModified'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['title'] = title;
    data['content'] = content;
    data['lastModified'] = lastModified;
    return data;
  }

  bool isValid() => title != '' && content != '';

  @override
  String toString() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }
}
