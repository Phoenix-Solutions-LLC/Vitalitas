import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vitalitas/breakpoint.dart';
import 'package:vitalitas/main.dart';
import 'package:vitalitas/monetization/adapty/ui/paywalls.dart';
import 'package:vitalitas/monetization/adapty/ui/products.dart';
import 'package:vitalitas/monetization/adapty/ui/purchaser_info.dart';
import 'package:vitalitas/ui/loading.dart';
import 'package:vitalitas/ui/widgets/animated_bot_screen.dart';

class LandingPaywallScreen extends StatefulWidget {
  final List<String> paywallIds = const ['vitapay'];
  const LandingPaywallScreen({super.key});

  @override
  LandingPaywallScreenState createState() {
    return LandingPaywallScreenState();
  }
}

class LandingPaywallScreenState extends State<LandingPaywallScreen> {
  bool loading = false;
  AdaptyProfile? res;

  @override
  void initState() {
    try {
      Adapty().activate();
    } catch (e) {
      debugPrint('error: $e');
    }
    super.initState();
  }

  Future<bool> callAdaptyMethod(Function method) async {
    bool success = true;
    setState(() {
      loading = true;
    });
    try {
      await method();
    } on AdaptyError catch (adaptyError) {
      success = false;
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text('Error'),
          content: Column(
            children: [
              Text(adaptyError.message),
              if (adaptyError.detail != null) Text(adaptyError.detail!),
            ],
          ),
          actions: [
            CupertinoButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
          ],
        ),
      );
    } catch (e) {
      success = false;
      debugPrint(e.toString());
    }
    setState(() {
      loading = false;
    });
    return success;
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? LoadingPage()
        : Material(
            child: Container(
                color: Vitalitas.theme.bg!,
                child: Column(
                  children: [
                    SizedBox(
                      height: 100,
                    ),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Image.asset('assets/resources/logo.png')),
                    SizedBox(
                      height: 50,
                    ),
                    Align(
                      child: ElevatedButton(
                        onPressed: () {
                          final Map<AdaptyPaywall, List<AdaptyPaywallProduct>>
                              paywallResult = {};
                          callAdaptyMethod(() async {
                            List<AdaptyPaywall> paywalls = [];
                            for (String id in widget.paywallIds) {
                              paywalls.add(await Adapty().getPaywall(id: id));
                            }
                            if (paywalls.isNotEmpty) {
                              for (AdaptyPaywall paywall in paywalls) {
                                List<AdaptyPaywallProduct> products = [];
                                products.addAll(await Adapty()
                                    .getPaywallProducts(paywall: paywall));
                                paywallResult[paywall] = products;
                              }
                            }
                          }).then((value) {
                            if (value) {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (ctx) =>
                                      PaywallsScreen(paywallResult)));
                            }
                          });
                        },
                        child: Text(
                          'Get Paywall',
                          style: TextStyle(
                              fontFamily: 'Comfort', color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ListTile(
                      title: Text(
                        'Get Products',
                        style: TextStyle(fontFamily: 'Comfort'),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios_outlined),
                      onTap: () {
                        // List<AdaptyPaywallProduct>? products;
                        // callAdaptyMethod(() async {
                        //   List<AdaptyPaywall> paywalls = [];
                        //   for (String id in widget.paywallIds) {
                        //     paywalls.add(await Adapty().getPaywall(id: id));
                        //   }
                        //   if (paywalls.isNotEmpty) {
                        //     products = [];
                        //     for (AdaptyPaywall paywall in paywalls) {
                        //       products!.addAll(await Adapty()
                        //           .getPaywallProducts(paywall: paywall));
                        //     }
                        //   }
                        // }).then((value) {
                        //   if (value) {
                        //     ProductsScreen.showProductsPage(context, products!);
                        //   }
                        // });
                        final Map<AdaptyPaywall, List<AdaptyPaywallProduct>>
                            paywallResult = {};
                        callAdaptyMethod(() async {
                          List<AdaptyPaywall> paywalls = [];
                          for (String id in widget.paywallIds) {
                            paywalls.add(await Adapty().getPaywall(id: id));
                          }
                          if (paywalls.isNotEmpty) {
                            for (AdaptyPaywall paywall in paywalls) {
                              List<AdaptyPaywallProduct> products = [];
                              products.addAll(await Adapty()
                                  .getPaywallProducts(paywall: paywall));
                              paywallResult[paywall] = products;
                            }
                          }
                        }).then((value) {
                          if (value) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (ctx) =>
                                    PaywallsScreen(paywallResult)));
                          }
                        });
                      },
                    ),
                    ListTile(
                      title: Text(
                        'Restore Purchases',
                        style: TextStyle(fontFamily: 'Comfort'),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios_outlined),
                      onTap: () {
                        callAdaptyMethod(() async {
                          res = await Adapty().restorePurchases();
                        });
                      },
                    ),
                    if (res != null)
                      ListTile(
                        title: Text(
                          'Purchaser Info',
                          style: TextStyle(fontFamily: 'Comfort'),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios_outlined),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (ctx) => PurchaserInfoScreen(res!)));
                        },
                      )
                  ],
                )));
  }
}
