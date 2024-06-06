// import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vitalitas/main.dart';
import 'package:vitalitas/monetization/adapty/util/value_helper.dart';
import 'package:vitalitas/ui/appstate/home.dart';

class PaywallsScreen extends StatefulWidget {
  // final Map<AdaptyPaywall, List<AdaptyPaywallProduct>> paywalls;
  // const PaywallsScreen(this.paywalls, {super.key});
  @override
  PaywallsScreenState createState() {
    return PaywallsScreenState();
  }
}

class PaywallsScreenState extends State<PaywallsScreen> {
  // AdaptyPaywallProduct? selectedProduct;
  @override
  Widget build(BuildContext context) {
    return Container();
    // List<Widget> pU = [];
    // pU.add(SizedBox(
    //   height: 20,
    // ));
    // pU.add(InkWell(
    //   onTap: () {
    //     Navigator.pop(context);
    //   },
    //   child: Padding(
    //       padding: EdgeInsets.only(bottom: 10, top: 20),
    //       child: Align(
    //           alignment: Alignment.centerLeft,
    //           child: Row(children: [
    //             Icon(Icons.arrow_back_ios_new_outlined),
    //             DefaultTextStyle(
    //                 style: TextStyle(
    //                     fontFamily: 'Comfort',
    //                     fontSize: 10,
    //                     color: Vitalitas.theme.txt),
    //                 child: Text(
    //                   'Back',
    //                   textAlign: TextAlign.center,
    //                 ))
    //           ]))),
    // ));
    // pU.add(SizedBox(
    //   height: 40,
    // ));
    // pU.add(Padding(
    //     padding: EdgeInsets.symmetric(horizontal: 20),
    //     child: Image.asset('assets/resources/logo.png')));
    // pU.add(SizedBox(
    //   height: 40,
    // ));
    // for (AdaptyPaywall paywall in widget.paywalls.keys) {
    //   pU.add(Divider());
    //   pU.add(SizedBox(
    //     height: 20,
    //   ));
    //   pU.add(Center(
    //       child: Text(
    //     paywall.name,
    //     style: TextStyle(fontSize: 25),
    //   )));
    //   pU.add(SizedBox(
    //     height: 20,
    //   ));
    //   for (AdaptyPaywallProduct product in widget.paywalls[paywall]!) {
    //     pU.add(InkWell(
    //         onTap: () {
    //           setState(() {
    //             selectedProduct = product;
    //           });
    //         },
    //         child: Card(
    //           shape: RoundedRectangleBorder(
    //               borderRadius: BorderRadius.circular(15),
    //               side: selectedProduct?.vendorProductId ==
    //                       product.vendorProductId
    //                   ? BorderSide(color: Vitalitas.theme.fg!, width: 2)
    //                   : BorderSide.none),
    //           child: Padding(
    //             padding: EdgeInsets.all(8),
    //             child: ListTile(
    //               leading: Wrap(
    //                 children: [
    //                   Text(
    //                     adaptyPeriodToString(product.subscriptionPeriod),
    //                     style: TextStyle(
    //                         fontFamily: 'Comfort',
    //                         fontWeight: FontWeight.bold,
    //                         color: Vitalitas.theme.txt),
    //                   ),
    //                   SizedBox(
    //                     width: 10,
    //                   ),
    //                   Text(
    //                     valueToString(product.currencySymbol),
    //                     style: TextStyle(
    //                         fontFamily: 'Comfort', color: Vitalitas.theme.txt),
    //                   ),
    //                   Text(
    //                     valueToString(product.price),
    //                     style: TextStyle(
    //                         fontFamily: 'Comfort', color: Vitalitas.theme.txt),
    //                   )
    //                 ],
    //               ),
    //               trailing: selectedProduct?.vendorProductId ==
    //                       product.vendorProductId
    //                   ? Icon(
    //                       Icons.check_circle,
    //                       color: Vitalitas.theme.fg,
    //                     )
    //                   : null,
    //             ),
    //           ),
    //         )));
    //     pU.add(SizedBox(
    //       height: 10,
    //     ));
    //   }
    //   pU.add(SizedBox(
    //     height: 10,
    //   ));
    //   pU.add(ElevatedButton(
    //       onPressed: selectedProduct != null
    //           ? () async {
    //               try {
    //                 if (!(HomeAppState
    //                         .profile?.accessLevels['premium']?.isActive ??
    //                     false)) {
    //                   await Adapty().makePurchase(product: selectedProduct!);
    //                 }
    //               } on AdaptyError catch (adaptyError) {
    //                 if (adaptyError.code != AdaptyErrorCode.paymentCancelled) {
    //                   showCupertinoDialog(
    //                     context: context,
    //                     builder: (ctx) => CupertinoAlertDialog(
    //                       title: Text('Error'),
    //                       content: Column(
    //                         children: [
    //                           Text(adaptyError.message),
    //                           if (adaptyError.detail != null)
    //                             Text(adaptyError.detail!),
    //                         ],
    //                       ),
    //                       actions: [
    //                         CupertinoButton(
    //                             child: Text('OK'),
    //                             onPressed: () {
    //                               Navigator.of(context).pop();
    //                             }),
    //                       ],
    //                     ),
    //                   );
    //                 }
    //               } catch (e) {
    //                 debugPrint('Make Purchase with ${e.toString()}');
    //               }
    //             }
    //           : null,
    //       child: Text('Continue',
    //           style: TextStyle(fontFamily: 'Comfort', color: Colors.white))));
    //   pU.add(Divider());
    // }
    // return Material(
    //     child: SingleChildScrollView(
    //   child: Column(
    //     children: pU,
    //   ),
    // ));
    // return widget.paywalls.isNotEmpty
    //     ? Material(
    //         child: ListView.builder(
    //             itemCount: widget.paywalls.length,
    //             itemBuilder: (ctx, index) {
    //               MapEntry<AdaptyPaywall, List<AdaptyPaywallProduct>> entry =
    //                   widget.paywalls.entries.elementAt(index);
    //               return Center(
    //                   child: Padding(
    //                 padding: const EdgeInsets.all(8),
    //                 child: Column(
    //                   mainAxisSize: MainAxisSize.min,
    //                   children: [
    //                     Padding(
    //                         padding: EdgeInsets.symmetric(horizontal: 20),
    //                         child: Image.asset('assets/resources/logo.png')),
    //                     SizedBox(
    //                       height: 40,
    //                     ),
    //                     Text(
    //                       'Available Plans',
    //                       style: TextStyle(
    //                           fontFamily: 'Comfort',
    //                           fontSize: 25,
    //                           fontWeight: FontWeight.bold,
    //                           color: Vitalitas.theme.txt),
    //                     ),
    //                     SizedBox(
    //                       height: 10,
    //                     ),
    //                     ListView.builder(
    //                         itemCount: entry.value.length,
    //                         itemBuilder: (ctx, index) {
    //                           final product = entry.value[index];
    //                           return GestureDetector(
    //                             onTap: () {
    //                               setState(() {
    //                                 selectedIndex = index;
    //                               });
    //                             },
    //                             child: Card(
    //                               shape: RoundedRectangleBorder(
    //                                   borderRadius: BorderRadius.circular(15),
    //                                   side: selectedIndex == index
    //                                       ? BorderSide(
    //                                           color: Vitalitas.theme.fg!,
    //                                           width: 2)
    //                                       : BorderSide.none),
    //                               child: Padding(
    //                                 padding: EdgeInsets.all(8),
    //                                 child: ListTile(
    //                                   leading: Wrap(
    //                                     children: [
    //                                       Text(
    //                                         adaptyPeriodToString(
    //                                             product.subscriptionPeriod),
    //                                         style: TextStyle(
    //                                             fontFamily: 'Comfort',
    //                                             fontWeight: FontWeight.bold,
    //                                             color: Vitalitas.theme.txt),
    //                                       ),
    //                                       SizedBox(
    //                                         width: 10,
    //                                       ),
    //                                       Text(
    //                                         valueToString(
    //                                             product.currencySymbol),
    //                                         style: TextStyle(
    //                                             fontFamily: 'Comfort',
    //                                             color: Vitalitas.theme.txt),
    //                                       ),
    //                                       Text(
    //                                         valueToString(product.price),
    //                                         style: TextStyle(
    //                                             fontFamily: 'Comfort',
    //                                             color: Vitalitas.theme.txt),
    //                                       )
    //                                     ],
    //                                   ),
    //                                   trailing: selectedIndex == index
    //                                       ? Icon(
    //                                           Icons.check_circle,
    //                                           color: Vitalitas.theme.fg,
    //                                         )
    //                                       : null,
    //                                 ),
    //                               ),
    //                             ),
    //                           );
    //                         }),
    //                     ElevatedButton(
    //                         onPressed: selectedIndex != null
    //                             ? () async {
    //                                 try {
    //                                   await Adapty().makePurchase(
    //                                       product: entry.value[selectedIndex!]);
    //                                 } on AdaptyError catch (adaptyError) {
    //                                   if (adaptyError.code !=
    //                                       AdaptyErrorCode.paymentCancelled) {
    //                                     showCupertinoDialog(
    //                                       context: context,
    //                                       builder: (ctx) =>
    //                                           CupertinoAlertDialog(
    //                                         title: Text('Error'),
    //                                         content: Column(
    //                                           children: [
    //                                             Text(adaptyError.message),
    //                                             if (adaptyError.detail != null)
    //                                               Text(adaptyError.detail!),
    //                                           ],
    //                                         ),
    //                                         actions: [
    //                                           CupertinoButton(
    //                                               child: Text('OK'),
    //                                               onPressed: () {
    //                                                 Navigator.of(context).pop();
    //                                               }),
    //                                         ],
    //                                       ),
    //                                     );
    //                                   }
    //                                 } catch (e) {
    //                                   debugPrint(
    //                                       'Make Purchase with ${e.toString()}');
    //                                 }
    //                               }
    //                             : null,
    //                         child: Text('Continue',
    //                             style: TextStyle(
    //                                 fontFamily: 'Comfort',
    //                                 color: Colors.white))),
    //                     const Divider(),
    //                     Padding(
    //                         padding: EdgeInsets.symmetric(horizontal: 100),
    //                         child: Image.asset('assets/resources/heart.png')),
    //                   ],
    //                 ),
    //               ));
    //             }))
    //     : Container(
    //         color: Colors.white,
    //         child: Center(
    //           child: Text('Paywalls not recieved.',
    //               style: TextStyle(
    //                   fontFamily: 'Comfort',
    //                   color: Vitalitas.theme.txt,
    //                   fontSize: 30)),
    //         ),
    //       );
  }
}
