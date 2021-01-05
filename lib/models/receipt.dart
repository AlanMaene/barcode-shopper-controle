import 'item.dart';
import 'package:flutter/cupertino.dart';

class Receipt {
  List<Item> boughtItems; //veranderen door shoppinglist
  String shopName;
  int merchant;
  DateTime payDate;
  String iid;

  Receipt({
    @required this.boughtItems,
    @required this.shopName,
    @required this.merchant,
    this.payDate,
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
