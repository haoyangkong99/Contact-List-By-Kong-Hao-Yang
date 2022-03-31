import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
class contactinfo{

String user, phone;
DateTime checkin;

contactinfo ({required this.user,required this.phone, required this.checkin});
contactinfo.fromJson(Map<dynamic,dynamic> json):this(checkin: DateFormat("yyyy-MM-dd hh:mm:ss").parse(json["check-in"].toString()),phone: json["phone"].toString() ,user: json["user"].toString(),) ;

}