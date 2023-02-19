final strToReplaceAdd = '~.9.~';
final strToSpaceUnicAndInfo = '..';
final strToSpaceAttributes = '_';
final strToReplaceImageSpecial = '!&~&!';

class NotificationTopic {
  String businessName = 'E';
  String workerName = 'E';
  String date = 'E'; // str date of waiting list
  String imageUrl = 'E'; // business icon
  String businessId = 'E';
  String workerId = 'E'; // to ensure the waiting list topic is unic

  NotificationTopic({
    this.businessName = 'E',
    this.workerName = 'E',
    this.date = 'E',
    this.imageUrl = 'E',
    this.businessId = 'E',
    this.workerId = 'E',
  });

  void fixEmptyAttributes() {
    this.businessName = this.businessName == '' ? 'E' : this.businessName;
    this.workerName = this.workerName == '' ? 'E' : this.workerName;
    this.date = this.date == '' ? 'E' : this.date;
    this.imageUrl = this.imageUrl == '' ? 'E' : this.imageUrl;
    this.businessId = this.businessId == '' ? 'E' : this.businessId;
    this.workerId = this.workerId == '' ? 'E' : this.workerId;
  }

  NotificationTopic.fromJson(dynamic json) {
    businessName = json['businessName'];
    workerName = json['workerName'];
    date = json['date'];
    imageUrl = json['imageUrl'];
    businessId = json['businessId'];
    workerId = json['workerId'];
    fixEmptyAttributes();
  }

  NotificationTopic.fromTopicStr(String topic) {
    /*
    getting "notification topic" str end extract the data about this object
    businessId_workerId(formated)_date..businessName(encoded)_workerName(encoded)_imageUrl(encoded)
     */
    List<String> data = topic.split(strToSpaceUnicAndInfo);
    // first split the data to unic & info
    List<String> unicData = data[0].split(strToSpaceAttributes);
    List<String> info = data[1].split(strToSpaceAttributes);
    // extract the unic data
    this.businessId = unicData[0];
    this.workerId = unicData[1].replaceAll(strToReplaceAdd, '+');
    this.date = unicData[2];
    // exract info data
    this.businessName = info[0];
    this.workerName = info[1];
    this.imageUrl = info[2].replaceAll(strToReplaceImageSpecial, '_');
    // this.businessName =
    //     utf8.decode(info[0].split('-').map((e) => int.parse(e)).toList());
    // this.workerName =
    //     utf8.decode(info[1].split('-').map((e) => int.parse(e)).toList());
    // this.imageUrl = utf8
    //     .decode(info[2].split('-').map((e) => int.parse(e)).toList())
    //     .replaceAll(strToReplaceStartImage, storageImagesPath);
    fixEmptyAttributes();
  }

  String toStrObject() {
    /* 
    convert this object to str
    names are optional to contain any characters even illegal topic then 
    parse them to utf-8.
    the str ->
      general - businessId_workerId(E empty)_date(E empty)_..businessName_workerName(E empty)_imageUrl
      waitingList - businessId_workerId_date..businessName_workerName_imageUrl
   */
    fixEmptyAttributes();
    String formatedWorkerId = workerId.replaceAll('+', strToReplaceAdd);
    String unicData =
        [businessId, formatedWorkerId, date].join(strToSpaceAttributes);
    String info = [
      businessName,
      workerName,
      imageUrl.replaceAll('_', strToReplaceImageSpecial)
    ].join(strToSpaceAttributes);
    // String info = [
    //   utf8.encode(businessName).join('-'),
    //   utf8.encode(workerName).join('-'),
    //   utf8
    //       .encode(
    //           imageUrl.replaceAll(storageImagesPath, strToReplaceStartImage))
    //       .join('-'),
    // ].join(strToSpaceAttributes);
    return '$unicData$strToSpaceUnicAndInfo$info';
  }

  String toTopicStr() {
    /* 
    convert this object to "notification topic" (1-900 characters & llegal topic)
    names are optional to contain any characters even illegal topic then 
    parse them to utf-8.
    topis str ->
      general - businessId_workerId(E empty)_date(E empty)_..businessName_workerName(E empty)_imageUrl
      waitingList - businessId_workerId_date..businessName_workerName_imageUrl
   */
    fixEmptyAttributes();
    String formatedWorkerId = workerId.replaceAll('+', strToReplaceAdd);
    String unicData =
        [businessId, formatedWorkerId, date].join(strToSpaceAttributes);
    return '$unicData';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['businessName'] = businessName;
    data['workerName'] = workerName;
    data['date'] = date;
    data['imageUrl'] = imageUrl;
    data['businessId'] = businessId;
    data['workerId'] = workerId;
    return data;
  }

  @override
  String toString() {
    return {'topic': toTopicStr(), 'objectData': toJson()}.toString();
  }
}
