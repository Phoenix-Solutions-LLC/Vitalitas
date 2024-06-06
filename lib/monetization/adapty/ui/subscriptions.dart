// import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:flutter/material.dart';
import 'package:vitalitas/monetization/adapty/ui/widgets/details_widgets.dart';
import 'package:vitalitas/monetization/adapty/util/value_helper.dart';

class SubscriptionsScreen extends StatelessWidget {
  // final Map<String, AdaptySubscription> subscriptions;
  // SubscriptionsScreen(this.subscriptions);

  // static showAccessLevelsPage(
  //     BuildContext context, Map<String, AdaptySubscription> subscriptions) {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (context) => SubscriptionsScreen(subscriptions),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Container();
    // final subscriptionsKeys = subscriptions.keys.toList();

    // return Material(
    //   child: ListView.builder(
    //     itemBuilder: (ctx, index) {
    //       final subscriptionInfo = subscriptions[subscriptionsKeys[index]]!;
    //       final details = {
    //         'Vendor Product Id':
    //             valueToString(subscriptionInfo.vendorProductId),
    //         'Is Active': valueToString(subscriptionInfo.isActive),
    //         'Store': valueToString(subscriptionInfo.store),
    //         'Activated At': valueToString(subscriptionInfo.activatedAt),
    //         'Renewed At': valueToString(subscriptionInfo.renewedAt),
    //         'Expires At': valueToString(subscriptionInfo.expiresAt),
    //         'Is Lifetime': valueToString(subscriptionInfo.isLifetime),
    //         'Active Introductory Offer Type':
    //             valueToString(subscriptionInfo.activeIntroductoryOfferType),
    //         'Active Promotional Offer Type':
    //             valueToString(subscriptionInfo.activePromotionalOfferType),
    //         'Will Renew': valueToString(subscriptionInfo.willRenew),
    //         'Is In Grace Period':
    //             valueToString(subscriptionInfo.isInGracePeriod),
    //         'Unsubscribed At': valueToString(subscriptionInfo.unsubscribedAt),
    //         'Is Sandbox': valueToString(subscriptionInfo.isSandbox),
    //         'Billing Issue Detected At':
    //             valueToString(subscriptionInfo.billingIssueDetectedAt),
    //         'Vendor Transaction Id':
    //             valueToString(subscriptionInfo.vendorTransactionId),
    //         'Vendor Original Transaction Id':
    //             valueToString(subscriptionInfo.vendorOriginalTransactionId),
    //         'Starts At': valueToString(subscriptionInfo.startsAt),
    //         'Cancellation Reason':
    //             valueToString(subscriptionInfo.cancellationReason),
    //         'Is Refund': valueToString(subscriptionInfo.isRefund),
    //       };
    //       return DetailsContainer(details: details);
    //     },
    //     itemCount: subscriptions.length,
    //   ),
    // );
  }
}
