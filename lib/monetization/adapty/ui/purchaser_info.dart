import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:flutter/material.dart';
import 'package:vitalitas/monetization/adapty/ui/subscriptions.dart';
import 'package:vitalitas/monetization/adapty/ui/widgets/details_widgets.dart';
import 'package:vitalitas/monetization/adapty/util/value_helper.dart';

class PurchaserInfoScreen extends StatefulWidget {
  final AdaptyProfile purchaserInfo;
  PurchaserInfoScreen(this.purchaserInfo);
  @override
  _PurchaserInfoScreenState createState() => _PurchaserInfoScreenState();
}

class _PurchaserInfoScreenState extends State<PurchaserInfoScreen> {
  @override
  Widget build(BuildContext context) {
    final details = {
      'Profile Id': valueToString(widget.purchaserInfo.profileId),
      'Customer User Id': valueToString(widget.purchaserInfo.customerUserId),
    };

    final detailPages = {
      'Subscriptions': () => Navigator.of(context).push(MaterialPageRoute(
          builder: (ctx) =>
              SubscriptionsScreen(widget.purchaserInfo.subscriptions))),
    };

    return Scaffold(
        appBar: AppBar(
          title: const Text('Purchaser Info'),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_outlined,
              size: 24,
            ),
            onPressed: Navigator.of(context).pop,
          ),
        ),
        body: Material(
            child: ListView(
          children: [
            DetailsContainer(
              details: details,
              detailPages: detailPages,
            ),
          ],
        )));
  }
}
