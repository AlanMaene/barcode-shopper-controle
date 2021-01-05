import 'package:flutter/material.dart';

import 'item.dart';

class ShoppingList{
  String name;
  List<Item> items;

  ShoppingList({
    @required this.name,
    @required this.items,
  });

}