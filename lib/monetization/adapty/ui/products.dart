// import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vitalitas/monetization/adapty/ui/widgets/details_widgets.dart';
import 'package:vitalitas/monetization/adapty/util/value_helper.dart';

class ProductsScreen extends StatefulWidget {
  // final List<AdaptyPaywallProduct>? products;
  // ProductsScreen(this.products);

  // static showProductsPage(
  //     BuildContext context, List<AdaptyPaywallProduct> products) {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (context) => ProductsScreen(products),
  //   );
  // }

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Container();
    // final products = widget.products;
    // return Material(
    //   child: loading
    //       ? Center(child: CircularProgressIndicator())
    //       : (products != null && products.isNotEmpty)
    //           ? SingleChildScrollView(
    //               child: ListView.builder(
    //               itemCount: products.length,
    //               itemBuilder: (ctx, index) {
    //                 final product = products[index];
    //                 final details = {
    //                   'Product Id': valueToString(product.vendorProductId),
    //                   'Description':
    //                       valueToString(product.localizedDescription),
    //                   'Title': valueToString(product.localizedTitle),
    //                   'Region Code': valueToString(product.regionCode),
    //                   'Price': valueToString(product.localizedPrice),
    //                   'Subscription Period':
    //                       valueToString(product.localizedSubscriptionPeriod),
    //                   'Paywall Name': valueToString(product.paywallName),
    //                 };
    //                 final purchaseButton = ElevatedButton(
    //                   onPressed: () async {
    //                     setState(() {
    //                       loading = true;
    //                     });
    //                     try {
    //                       await Adapty().makePurchase(product: product);
    //                     } on AdaptyError catch (adaptyError) {
    //                       if (adaptyError.code !=
    //                           AdaptyErrorCode.paymentCancelled) {
    //                         showCupertinoDialog(
    //                           context: context,
    //                           builder: (ctx) => CupertinoAlertDialog(
    //                             title: Text('Error'),
    //                             content: Column(
    //                               children: [
    //                                 Text(adaptyError.message),
    //                                 if (adaptyError.detail != null)
    //                                   Text(adaptyError.detail!),
    //                               ],
    //                             ),
    //                             actions: [
    //                               CupertinoButton(
    //                                   child: Text('OK'),
    //                                   onPressed: () {
    //                                     Navigator.of(context).pop();
    //                                   }),
    //                             ],
    //                           ),
    //                         );
    //                       }
    //                     } catch (e) {
    //                       print('#MakePurchase# ${e.toString()}');
    //                     }
    //                     setState(() {
    //                       loading = false;
    //                     });
    //                   },
    //                   child: Text(
    //                     'Make Purchase',
    //                     style: TextStyle(
    //                         fontFamily: 'Comfort', color: Colors.white),
    //                   ),
    //                 );
    //                 return DetailsContainer(
    //                   details: details,
    //                   bottomWidget: purchaseButton,
    //                 );
    //               },
    //             ))
    //           : Center(
    //               child: Text('Products were not received.'),
    //             ),
    // );
  }
}
