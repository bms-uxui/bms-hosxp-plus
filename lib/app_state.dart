import 'package:flutter/material.dart';
import 'backend/supabase/supabase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {}

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  String _pinCode = '';
  String get pinCode => _pinCode;
  set pinCode(String value) {
    _pinCode = value;
  }

  int _maintabmenu = 1;
  int get maintabmenu => _maintabmenu;
  set maintabmenu(int value) {
    _maintabmenu = value;
  }

  int _TabIPDmainpage = 1;
  int get TabIPDmainpage => _TabIPDmainpage;
  set TabIPDmainpage(int value) {
    _TabIPDmainpage = value;
  }

  int _homeopdmenu = 1;
  int get homeopdmenu => _homeopdmenu;
  set homeopdmenu(int value) {
    _homeopdmenu = value;
  }

  int _TabOPDhomepage = 1;
  int get TabOPDhomepage => _TabOPDhomepage;
  set TabOPDhomepage(int value) {
    _TabOPDhomepage = value;
  }

  int _homeipdmenu = 1;
  int get homeipdmenu => _homeipdmenu;
  set homeipdmenu(int value) {
    _homeipdmenu = value;
  }

  bool _fillterRadio = false;
  bool get fillterRadio => _fillterRadio;
  set fillterRadio(bool value) {
    _fillterRadio = value;
  }

  List<int> _PINCode = [123456];
  List<int> get PINCode => _PINCode;
  set PINCode(List<int> value) {
    _PINCode = value;
  }

  void addToPINCode(int value) {
    PINCode.add(value);
  }

  void removeFromPINCode(int value) {
    PINCode.remove(value);
  }

  void removeAtIndexFromPINCode(int index) {
    PINCode.removeAt(index);
  }

  void updatePINCodeAtIndex(
    int index,
    int Function(int) updateFn,
  ) {
    PINCode[index] = updateFn(_PINCode[index]);
  }

  void insertAtIndexInPINCode(int index, int value) {
    PINCode.insert(index, value);
  }

  int _selectbranch = 0;
  int get selectbranch => _selectbranch;
  set selectbranch(int value) {
    _selectbranch = value;
  }

  int _TabMenuPatientInfo = 1;
  int get TabMenuPatientInfo => _TabMenuPatientInfo;
  set TabMenuPatientInfo(int value) {
    _TabMenuPatientInfo = value;
  }

  bool _ExpanVisitListEMR = false;
  bool get ExpanVisitListEMR => _ExpanVisitListEMR;
  set ExpanVisitListEMR(bool value) {
    _ExpanVisitListEMR = value;
  }

  int _EMRVisit = 1;
  int get EMRVisit => _EMRVisit;
  set EMRVisit(int value) {
    _EMRVisit = value;
  }

  int _MenuVitalsign = 1;
  int get MenuVitalsign => _MenuVitalsign;
  set MenuVitalsign(int value) {
    _MenuVitalsign = value;
  }

  int _NursingProblemsTemplateitem = 1;
  int get NursingProblemsTemplateitem => _NursingProblemsTemplateitem;
  set NursingProblemsTemplateitem(int value) {
    _NursingProblemsTemplateitem = value;
  }

  bool _Message = false;
  bool get Message => _Message;
  set Message(bool value) {
    _Message = value;
  }

  String _imageprofile = '';
  String get imageprofile => _imageprofile;
  set imageprofile(String value) {
    _imageprofile = value;
  }

  bool _Connection = false;
  bool get Connection => _Connection;
  set Connection(bool value) {
    _Connection = value;
  }

  bool _Checkboxdelble = true;
  bool get Checkboxdelble => _Checkboxdelble;
  set Checkboxdelble(bool value) {
    _Checkboxdelble = value;
  }

  int _TabNursingrecords = 1;
  int get TabNursingrecords => _TabNursingrecords;
  set TabNursingrecords(int value) {
    _TabNursingrecords = value;
  }

  int _TabMenuPatientInfoER = 1;
  int get TabMenuPatientInfoER => _TabMenuPatientInfoER;
  set TabMenuPatientInfoER(int value) {
    _TabMenuPatientInfoER = value;
  }

  int _ItemTypepatientER = 0;
  int get ItemTypepatientER => _ItemTypepatientER;
  set ItemTypepatientER(int value) {
    _ItemTypepatientER = value;
  }

  int _ItemTriageLevels = 0;
  int get ItemTriageLevels => _ItemTriageLevels;
  set ItemTriageLevels(int value) {
    _ItemTriageLevels = value;
  }

  int _ItemPainScore = 0;
  int get ItemPainScore => _ItemPainScore;
  set ItemPainScore(int value) {
    _ItemPainScore = value;
  }

  int _ItemLevelConsciousness = 0;
  int get ItemLevelConsciousness => _ItemLevelConsciousness;
  set ItemLevelConsciousness(int value) {
    _ItemLevelConsciousness = value;
  }

  String _filtermenuER = 'All';
  String get filtermenuER => _filtermenuER;
  set filtermenuER(String value) {
    _filtermenuER = value;
  }

  String _FastTrack = '';
  String get FastTrack => _FastTrack;
  set FastTrack(String value) {
    _FastTrack = value;
  }

  String _ConditionatERdischarge = '';
  String get ConditionatERdischarge => _ConditionatERdischarge;
  set ConditionatERdischarge(String value) {
    _ConditionatERdischarge = value;
  }

  String _medecationOrder = 'ยา';
  String get medecationOrder => _medecationOrder;
  set medecationOrder(String value) {
    _medecationOrder = value;
  }

  int _remeditem = 0;
  int get remeditem => _remeditem;
  set remeditem(int value) {
    _remeditem = value;
  }

  List<String> _StatusOrganDonation = [
    'ยังไม่ได้เจรจา',
    'เจรจาสำเร็จ',
    'ไม่ได้รับการยินยอม'
  ];
  List<String> get StatusOrganDonation => _StatusOrganDonation;
  set StatusOrganDonation(List<String> value) {
    _StatusOrganDonation = value;
  }

  void addToStatusOrganDonation(String value) {
    StatusOrganDonation.add(value);
  }

  void removeFromStatusOrganDonation(String value) {
    StatusOrganDonation.remove(value);
  }

  void removeAtIndexFromStatusOrganDonation(int index) {
    StatusOrganDonation.removeAt(index);
  }

  void updateStatusOrganDonationAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    StatusOrganDonation[index] = updateFn(_StatusOrganDonation[index]);
  }

  void insertAtIndexInStatusOrganDonation(int index, String value) {
    StatusOrganDonation.insert(index, value);
  }

  String _filterdonorssignature = '';
  String get filterdonorssignature => _filterdonorssignature;
  set filterdonorssignature(String value) {
    _filterdonorssignature = value;
  }

  bool _gender = false;
  bool get gender => _gender;
  set gender(bool value) {
    _gender = value;
  }

  bool _address = false;
  bool get address => _address;
  set address(bool value) {
    _address = value;
  }

  int _ga = 0;
  int get ga => _ga;
  set ga(int value) {
    _ga = value;
  }

  int _HEENT = 0;
  int get HEENT => _HEENT;
  set HEENT(int value) {
    _HEENT = value;
  }

  int _Heart = 0;
  int get Heart => _Heart;
  set Heart(int value) {
    _Heart = value;
  }

  int _Chest = 0;
  int get Chest => _Chest;
  set Chest(int value) {
    _Chest = value;
  }

  int _Abdomen = 0;
  int get Abdomen => _Abdomen;
  set Abdomen(int value) {
    _Abdomen = value;
  }

  int _PR = 0;
  int get PR => _PR;
  set PR(int value) {
    _PR = value;
  }

  int _PV = 0;
  int get PV => _PV;
  set PV(int value) {
    _PV = value;
  }

  int _Genitalia = 0;
  int get Genitalia => _Genitalia;
  set Genitalia(int value) {
    _Genitalia = value;
  }

  int _Neurological = 0;
  int get Neurological => _Neurological;
  set Neurological(int value) {
    _Neurological = value;
  }

  int _Extremities = 0;
  int get Extremities => _Extremities;
  set Extremities(int value) {
    _Extremities = value;
  }

  int _Constitutional = 0;
  int get Constitutional => _Constitutional;
  set Constitutional(int value) {
    _Constitutional = value;
  }

  int _Eyes = 0;
  int get Eyes => _Eyes;
  set Eyes(int value) {
    _Eyes = value;
  }

  int _ENTMounth = 0;
  int get ENTMounth => _ENTMounth;
  set ENTMounth(int value) {
    _ENTMounth = value;
  }

  String _navebar = 'หน้าแรก';
  String get navebar => _navebar;
  set navebar(String value) {
    _navebar = value;
  }
}
