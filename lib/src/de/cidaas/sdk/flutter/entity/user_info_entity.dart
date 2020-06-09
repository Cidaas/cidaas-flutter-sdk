import 'package:flutter/material.dart';

class UserInfoEntity with ChangeNotifier {
  String email;
  String mobileNumber;
  String picture;
  String givenName;
  String familyName;
  String sub;
  String gender;
  String birthYear;
  UserInfoEntity(
      {this.email,
        this.mobileNumber,
        this.picture,
        this.givenName,
        this.familyName,
        this.sub,
        this.birthYear,
        this.gender});
  UserInfoEntity.fromJson(Map<String, dynamic> json)
      : sub = json['sub'],
        givenName = json['given_name'],
        email = json['email'],
        familyName = json['family_name'],
        picture = json['picture'],
        mobileNumber = json['mobile_number'],
        birthYear = json['birthYear'],
        gender = json['gender'];

  Map<String, dynamic> toJson() => {
    'sub': sub,
    'given_name': givenName,
    'family_name': familyName,
    'email': email,
    'picture': picture,
    'mobile_number': mobileNumber,
    'birthYear': birthYear,
    'gender': gender
  };
}
