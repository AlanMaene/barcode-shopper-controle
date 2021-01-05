import 'dart:convert';

import 'package:flutter/material.dart';

class Item {
  String iid;
  String name;
  //String brand;
  int amount;
  double price;
  String unit;
  bool inCart = false;
  //bool discount = false;
  //0 = geen korting, 1 = percentage korting, 2 = x+x gratis
  int typeDiscount = 0;
  List<dynamic> cumDiscount = [0, 0];
  int percentageDiscount = 0;
  double amountOfDiscount = 0;
  //DateTime timeStamp;


  Item({
    @required this.iid,
    @required this.name,
    @required this.amount,
    @required this.price,
    @required this.unit,
    this.inCart = false,
    this.typeDiscount = 0,
    this.percentageDiscount,
    this.cumDiscount,
  

    //this.timeStamp,
  });

  @override
  String toString() {
    return "iid: " +
        iid +
        '\n\t' +
        "name:     " +
        name.toString() +
        '\n\t' +
        "amount:   " +
        amount.toString() +
        '\n\t' +
        "price:  " +
        price.toString() +
        '\n\t' +
        "unit: " +
        //timeStamp.toString() +
        //'\n\t' +
        //"timestamp: " +
        unit.toString() +
        '\n\t' +
        "In cart: " +
        inCart.toString();
  }

  factory Item.fromJson(Map<String, dynamic> jsonData) {
    return Item(
      iid: jsonData['iid'],
      name: jsonData['name'],
      amount: jsonData['amount'],
      price: jsonData['price'],
      unit: jsonData['unit'],
      inCart: jsonData['inCart'],
    );
  }

  static Map<String, dynamic> toMap(Item item) => {
        'iid': item.iid,
        'name': item.name,
        'amount': item.amount,
        'price': item.price,
        'unit': item.unit,
        'inCart': item.inCart
      };

  static String encodeItems(List<Item> items) => json.encode(
        items.map<Map<String, dynamic>>((item) => Item.toMap(item)).toList(),
      );

  static List<Item> decodeItems(String items) =>
      (json.decode(items) as List<dynamic>)
          .map<Item>((item) => Item.fromJson(item))
          .toList();

  void addAmount() {
    this.amount += 1;
    checkDiscount();
  }

  void minAmount() {
    if (this.amount > 1) {
      this.amount -= 1;
    }

    checkDiscount();
  }

  void setPrice() {
    //price = _price;
  }

  double getTotalPrice() {
    return (price * amount) - amountOfDiscount;
  }

  void checkDiscount() {
    //percentage koring
    if (typeDiscount == 1) {
      amountOfDiscount = ((price / 100) * percentageDiscount);
      amountOfDiscount = amount * amountOfDiscount;
      print((price / 100) * percentageDiscount);
    }
    //x + y
    else if (typeDiscount == 2) {
      int timesOfDiscount =
          (amount / (cumDiscount[0] + cumDiscount[1])).floor();
      print((amount / (cumDiscount[0] + cumDiscount[1])).floor());
      print(timesOfDiscount * (cumDiscount[1] * price));
      amountOfDiscount = timesOfDiscount * (cumDiscount[1] * price);
    }
  }

  int customRound(double toRound) {}

  Item.copy(Item other) {
    this.iid = other.iid;
    this.name = other.name;
    this.amount = other.amount;
    this.price = other.price;
    this.unit = other.unit;
    //this.timeStamp = other.timeStamp;
  }
}
