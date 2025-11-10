import 'package:flutter_android_ad_plugins/hep/hep.dart';
import 'package:get_storage/get_storage.dart';

class AdNumHep{
  static final AdNumHep _instance = AdNumHep();
  static AdNumHep get instance => _instance;

  var _maxShow=100,_maxClick=100,_todayShow=0,_todayClick=0,_fkMaxShow=60;
  final StorageData<String> _showNumStorage = StorageData(key: "flutter_ios_ad_show_num", defaultValue: "");
  final StorageData<String> _clickNumStorage = StorageData(key: "flutter_ios_ad_click_num", defaultValue: "");

  setMaxNum(int maxShow, int maxClick){
    _maxShow=maxShow;
    _maxClick=maxClick;
    _todayShow=_showNumStorage.getData().getTodayNum();
    _todayClick=_clickNumStorage.getData().getTodayNum();
    "flutter ios ad --->setMaxNum--->_maxShow:$_maxShow--->_maxClick:$_maxClick--->_todayShow:$_todayShow--->_todayClick:$_todayClick".log();
  }

  setFkMaxShowNum(int maxShow){
    _fkMaxShow=maxShow;
    "flutter ios ad --->setMaxShowNum--->_maxShow:$_maxShow--->_maxClick:$_maxClick--->_todayShow:$_todayShow--->_todayClick:$_todayClick".log();
  }

  notLoad(){
    "flutter ios ad --->notLoad--->_maxShow:$_maxShow--->_maxClick:$_maxClick--->_todayShow:$_todayShow--->_todayClick:$_todayClick".log();
    return _todayShow>=_maxShow||_todayClick>=_maxClick||_todayShow>=_fkMaxShow;
  }

  updateShowNum(){
    _todayShow++;
    _showNumStorage.saveData("${todayTimeStr()}_$_todayShow");
    "flutter ios ad --->updateShowNum--->_maxShow:$_maxShow--->_maxClick:$_maxClick--->_todayShow:$_todayShow--->_todayClick:$_todayClick".log();
  }

  updateClickNum(){
    _todayClick++;
    _clickNumStorage.saveData("${todayTimeStr()}_$_todayClick");
    "flutter ios ad --->updateClickNum--->_maxShow:$_maxShow--->_maxClick:$_maxClick--->_todayShow:$_todayShow--->_todayClick:$_todayClick".log();
  }
}

final GetStorage _getStorage=GetStorage();

class StorageData<T>{
  String key;
  final T _defaultValue;
  StorageData({
    required this.key,
    required T defaultValue
  }):_defaultValue=defaultValue;

  saveData(T t){
    _getStorage.write(key, t);
  }

  T getData()=>_getStorage.read(key)??_defaultValue;
}
