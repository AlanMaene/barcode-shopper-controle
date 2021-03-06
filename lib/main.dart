import 'package:barcode_shopper_controle/models/item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:firebase_core/firebase_core.dart';
import 'models/receipt.dart';

void main() async {
  /* runApp(DevicePreview(
    enabled: !kReleaseMode,
    builder: (context) => MyApp(),
  )); */
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      
      theme: ThemeData(
        primaryColor: Color(0xff1d606e),
        primaryColorDark: Color(0xff003643),
        primaryColorLight: Color(0xff508d9c),
        errorColor: Color(0xffCC2936),
        indicatorColor: Color(0xff10CF98),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Controle'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String result = "";
  Receipt receipt;
  bool receiptScanned = false;
  bool isItemInCart = false;
  List<Item> checkedItems = [];
  Item currentItem ;
  double totalPriceChecked = 0;

  Future<Receipt> getReceipt(String receiptId) async{
    Receipt r;
    String guid = receiptId.substring(0,receiptId.length-26);
    print(receiptId);
    await  FirebaseFirestore.instance.collection("users").doc(guid.toString()).collection("receipts").doc(receiptId).get().then((DocumentSnapshot documentSnapshot ) {
       if (documentSnapshot.exists) {
         print("shop name: " + documentSnapshot.data()["shop name"]);
         r = Receipt(merchant:documentSnapshot.data()["merchant"],shopName: documentSnapshot.data()["shop name"],boughtItems: Item.decodeItems(documentSnapshot.data()["items"]),iid: receiptId );
        
       }
       else{
         r = null;
       }
     });

     return r;
  }

  
  Future<bool> getItem(String barcode, String shop) async {
    CollectionReference _shopCollection =
        FirebaseFirestore.instance.collection(shop);
    bool temp = false;
    await _shopCollection
        .doc(barcode)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print(".");
        
        currentItem = new Item(
            amount: 1,
            price: documentSnapshot.data()["price"],
            unit: "€",
            iid: documentSnapshot.data()["iid"],
            name: documentSnapshot.data()["name"],
            typeDiscount: documentSnapshot.data()["typeDiscount"],
            percentageDiscount: documentSnapshot.data()["percentageDiscount"],
            cumDiscount: documentSnapshot.data()["cumDiscount"]
            );
            
        temp = true;
      } else {
        print('Document does not exist in the database');
        return false;
      }
    });
    return temp;
  }

    Future<bool> saveReceipt() async {
      String guid = receipt.iid.substring(0,receipt.iid.length-26);
    List<String> itemsId = [];
    for (int i = 0; i < receipt.boughtItems.length; i++) {
      itemsId.add(receipt.boughtItems[i].toString());
    }
    await FirebaseFirestore.instance
        .collection("users")
        .doc(guid)
        .collection("receipts")
        .doc(receipt.iid)
        .set({
      "merchant": receipt.merchant,
      "shop name": receipt.shopName,
      "date": receipt.payDate,
      "items": Item.encodeItems(checkedItems),
      "totalSum": receipt.totalSum,
      "totalDiscountSum": receipt.totalDiscountSum,
      "shopEnterTime": receipt.shopEnterTime,
      "shopExitTime": receipt.shopExitTime
    });

    return true;
  }

  Future<bool> isScanned(String iid) async{
    bool check = false;
    receipt.boughtItems.forEach((element) {
      if(element.iid == iid) {
        bool isAlreadyScanned = false;
        for(int i = 0 ; i < checkedItems.length ; i++){
          if(checkedItems[i].iid == element.iid ){
            isAlreadyScanned = true;
            checkedItems[i].amount = checkedItems[i].amount+  1;
            if(checkedItems[i].amount > element.amount){
              checkedItems[i].inCart = false;
            }
          }; 
        };
        print(receipt);
        
        
        check = true;
        if(isAlreadyScanned != true){
          
          Item temp = new Item(iid: element.iid, name: element.name, amount: 1, price: element.price, unit: "€", inCart: true, cumDiscount: element.cumDiscount,percentageDiscount: element.percentageDiscount,typeDiscount: element.typeDiscount);
          checkedItems.add(temp);
        }
        
      }
    });

    if(check == false){
      bool isAlreadyScanned = false;
        for(int i = 0 ; i < checkedItems.length ; i++){
          if(checkedItems[i].iid == iid ){
            isAlreadyScanned = true;
            checkedItems[i].amount += 1;
          }; 
        };
      if(isAlreadyScanned != true){
        await this.getItem(iid, receipt.shopName);
        checkedItems.add(currentItem);
      }
      
    }

    return check;
  }

  void editReceipt(){
    totalPriceChecked = 0;
    for(int i = 0 ; i < checkedItems.length ; i++){
      totalPriceChecked += checkedItems[i].getTotalPrice();
    }
  

    
    print("verschil in prijs " + (totalPriceChecked - receipt.totalPrice()).toString());
  }
  Future<void> _showMyDialog() async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Rekening aanpassen'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Het volgende bedrag moet de klant nog betalen'),
              Text('' ),
              Text('€'+(totalPriceChecked - receipt.totalPrice()).toStringAsFixed(2)),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Rekening wijzigen'),
            onPressed: () {
              saveReceipt();
               result = "";
                receipt;
                receiptScanned = false;
                isItemInCart = false;
                checkedItems = [];
                currentItem ;
                totalPriceChecked = 0;
              Navigator.pop(context);
              setState(() {
                
              });
              
            },
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: receiptScanned == true ? Center(
        child: Container(
          padding:  const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            
            children: <Widget>[
              Text("items van de klant", style: TextStyle(color: Theme.of(context).primaryColorDark, fontWeight: FontWeight.bold, fontSize: 20 ),),
              Expanded(
                child: ListView.builder(
                  itemCount: receipt.boughtItems.length,
                  itemBuilder: (context,i){
                    return ListTile(
                      leading: Text(receipt.boughtItems[i].amount.toStringAsPrecision(1)),
                      title: Text(receipt.boughtItems[i].name),
                    );
                  }),
                flex: 2,),
                Text("nagekeken items" ,style: TextStyle(color: Theme.of(context).primaryColorDark, fontWeight: FontWeight.bold, fontSize: 20 ),),
                Expanded(
                child: ListView.builder(
                  itemCount: checkedItems.length,
                  itemBuilder: (context,i){
                    return ListTile(
                      leading: checkedItems[i].inCart == true ? Icon(Icons.check, color: Colors.green,) : Icon(Icons.close, color: Colors.red,),
                      title: Text(checkedItems[i].name),
                      trailing: Text(checkedItems[i].amount.toStringAsPrecision(1)),
                    );
                  }),
                flex: 2,),
                Row(
                  
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                    child: MaterialButton(
                        
                        child: Text("Done"),
                        color: Colors.green,
                        textColor: Colors.white,
                        height: 48,
                        onPressed: (){
                         
                          setState(() {
                          receiptScanned = false;
                          checkedItems = [];
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: MaterialButton(
                        child: Icon(Icons.qr_code_scanner_rounded, size: 40,),
                        height: 60,
                        color: Theme.of(context).primaryColorLight,
                        textColor: Colors.white,
                        onPressed: ()async{
                result = await FlutterBarcodeScanner.scanBarcode(
                                                    "#ff6666", 
                                                    "CANCEL", 
                                                    true, 
                                                    ScanMode.DEFAULT);
                
                isItemInCart = await isScanned(result);
                setState(() {
                  
                  
                });
              },
                        shape: CircleBorder(),
                      ),
                    ),
                    Expanded(
                    child: MaterialButton(
                        child: Text("Edit receipt"),
                        height: 48,
                        color: Colors.red,
                        textColor: Colors.white,
                        onPressed: (){
                          editReceipt();
                          _showMyDialog();
                        },
                      ),
                    ),
                  ]
                )
              //isItemInCart == true ? Text("Item is correct gescand door de klant") : Text("Item in niet gescand!"),
             /* MaterialButton(
                child: Text("scan item"),
                onPressed: () async{
                  result = await FlutterBarcodeScanner.scanBarcode(
                                                      "#ff6666", 
                                                      "CANCEL", 
                                                      true, 
                                                      ScanMode.DEFAULT);
                  
                  isItemInCart = await isScanned(result);
                  setState(() {
                    
                    
                  });
                }
                ),
                Text("barcode id: "),
                Text(result,textAlign: TextAlign.center,),
                SizedBox(height:18),*/
                //Text("user id: "  ),              
                //Text(receipt.iid.substring(0,result.length-26)),
                //receipt == null ? Text("") : Text(receipt.boughtItems.toString())
            ],
          ),
        ),
      ): Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          
          children: <Widget>[
            MaterialButton(
              child: Text("start scan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20 ),),
              color: Theme.of(context).primaryColorLight,
              onPressed: () async{
                result = await FlutterBarcodeScanner.scanBarcode(
                                                    "#ff6666", 
                                                    "CANCEL", 
                                                    true, 
                                                    ScanMode.DEFAULT);
                Receipt r = await getReceipt(result);
                
                print(r);
                if(r != null){
                receiptScanned = true;
                setState(() {
                  receipt = r;
                  
                });
                }
                
              }
              ),
              
          ],
        ),
      ),
     /* floatingActionButton: FloatingActionButton(
        child: Icon(Icons.qr_code_scanner_rounded,size:32),
        onPressed: ()async{
                result = await FlutterBarcodeScanner.scanBarcode(
                                                    "#ff6666", 
                                                    "CANCEL", 
                                                    true, 
                                                    ScanMode.DEFAULT);
                
                isItemInCart = await isScanned(result);
                setState(() {
                  
                  
                });
              },
              backgroundColor: Theme.of(context).primaryColorLight,
      ),*/
       // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
