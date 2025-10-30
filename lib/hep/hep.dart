import 'package:flutter/foundation.dart';

extension PrintLog on String{
  log(){
    if(kDebugMode){
      print(this);
    }
  }
}

String todayTimeStr(){
  var dateTime = DateTime.now();
  return "${dateTime.year}-${dateTime.month}-${dateTime.day}";
}

extension TodayNum on String{
  int getTodayNum(){
    try{
      var list = split("_");
      if(list.first==todayTimeStr()){
        return list.last.toInt();
      }
      return 0;
    }catch(e){
      return 0;
    }
  }
}

extension Str2Int on String{
  int toInt({int defaultInt=0}){
    try{
      return int.parse(this);
    }catch(e){
      return defaultInt;
    }
  }
}