class AtMessageModel {
  late String? userID;
  late String? nickName;
  late bool? isAll;
  late List<AtMessageModel>? members;

  AtMessageModel({
    this.userID,
    this.nickName,
    this.isAll,
    this.members,
  });

  AtMessageModel.fromJson(Map<String, dynamic> json) {
    userID = json['userID'];
    nickName = json['nickName'];
    isAll = json['isAll'];
    if (json['members'] != null) {
      members = [];
      json['members'].forEach((v) {
        members?.add(AtMessageModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userID'] = this.userID;
    data['nickName'] = this.nickName;
    data['isAll'] = this.isAll;
    data['members'] = this.members?.map((v) => v.toJson()).toList();
    return data;
  }

  String toShowString() {
    return nickName?.isNotEmpty == true ? nickName! : userID ?? '';
  }
}