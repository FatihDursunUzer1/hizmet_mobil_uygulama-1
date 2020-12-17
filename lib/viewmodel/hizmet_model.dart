import 'package:flutter/material.dart';
import 'package:hizmet_mobil_uygulama/locator.dart';
import 'package:hizmet_mobil_uygulama/models/Hizmet.dart';
import 'package:hizmet_mobil_uygulama/repository/HizmetRepository.dart';
import 'package:hizmet_mobil_uygulama/services/HizmetBase.dart';

enum ViewState { Idle, Busy }

class HizmetModel with ChangeNotifier implements HizmetBase {
  ViewState _state = ViewState.Idle;
  HizmetRepository _hizmetRepository = locator<HizmetRepository>();
  Hizmet _hizmet;

  set state(ViewState value) {
    _state = value;
    notifyListeners();
  }

  @override
  Future<Hizmet> createHizmet(
      {hizmetID,
      title,
      category,
      subCategory,
      publisher,
      detail,
      address,
      payment}) async {
    try {
      state = ViewState.Busy;
      _hizmet = await _hizmetRepository.createHizmet(
          hizmetID: hizmetID,
          title: title,
          category: category,
          subCategory: subCategory,
          publisher: publisher,
          detail: detail,
          address: address,
          payment: payment);
      return _hizmet;
    } finally {
      state = ViewState.Idle;
    }
  }

  //TEK BİR HİZMETİN DETAYLARINI EKRANDA GÖSTERİRKEN
  @override
  Future<Hizmet> readHizmet(String hizmetID, String category, String subCategory) {
    // TODO: implement readHizmet
    throw UnimplementedError();
  }

  @override
  Future<List<Hizmet>> readFilterHizmet({String category, String subCategory}) {
    try {
      state = ViewState.Busy;
      return _hizmetRepository.readFilterHizmet(category: category, subCategory: subCategory);
    } finally {
      state = ViewState.Idle;
    }
  }


  @override
  Future<Hizmet> setHizmet(Hizmet hizmet) {
    // TODO: implement setHizmet
    throw UnimplementedError();
  }



}