
import 'package:barcode_shopper_controle/models/item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Receipt {
  List<Item> boughtItems; //veranderen door shoppinglist
  String shopName;
  int merchant;
  Timestamp payDate;
  String iid;
  double totalDiscountSum;
  double totalSum;
  Timestamp shopEnterTime;
  Timestamp shopExitTime;

  Receipt({
    @required this.boughtItems,
    @required this.shopName,
    @required this.merchant,
    @required this.totalDiscountSum,
    @required this.totalSum,
    @required this.shopEnterTime,
    @required this.shopExitTime,
    @required this.payDate,
    this.iid,
  });

  double totalPrice() {
    double total = 0;
    for (var item in boughtItems) {
      total += (item.price * item.amount);
    }
    return total;
  }

  double totalProducts() {
    double total = 0;
    for (var item in boughtItems) {
      total += item.amount;
    }
    return total;
  }

  double totalDiscount() {
    return 0;
  }
}
