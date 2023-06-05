import 'dart:convert';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:dart_openai/openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:google_nav_bar/src/gbutton.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:vitalitas/data/data.dart';
import 'package:vitalitas/data/mayoclinic/conditon.dart';
import 'package:vitalitas/data/mayoclinic/drug.dart';
import 'package:vitalitas/data/misc/quote.dart';
import 'package:vitalitas/main.dart';
import 'package:vitalitas/monetization/adapty/ui/landing.dart';
import 'package:vitalitas/monetization/ads.dart';
import 'package:vitalitas/ui/appstate/appstate.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vitalitas/ui/appstate/home.dart';
import 'package:vitalitas/ui/auth/landing.dart';

class BotAppState extends VitalitasAppState {
  static Future<void> load() async {
    OpenAI.apiKey = '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';
    OpenAI.organization = 'org-4ZSecZhP5Y6b7mfXnmbU0hxE';
    int monthlyMaxTokens = 125000;
    dynamic monthlyTokens = await Data.getUserField('MonthlyTokens');
    if (!(monthlyTokens is int)) {
      await Data.setUserField('MonthlyTokens', monthlyMaxTokens);
      monthlyTokens = monthlyMaxTokens;
    }
    DateTime now = DateTime.now();
    if (now.day > 0 && now.day < 4 && monthlyTokens < monthlyMaxTokens * 0.7) {
      monthlyTokens = monthlyMaxTokens;
      await Data.setUserField('MonthlyTokens', monthlyMaxTokens);
    }
    allowedTokens = monthlyTokens;

    if (!(HomeAppState.profile?.accessLevels['premium']?.isActive ??
        false || HomeAppState.bypassIntendedObstacles)) {
      Monetization.loadNewInterstitial().future.then((ad) {
        interstitialAd0 = ad;
      });
    }
  }

  static TextEditingController submitController = new TextEditingController();
  static Map<String, dynamic> data = {};

  static String time = 'nil';
  static List<Message> messages = [];
  static int allowedTokens = 0;

  static InterstitialAd? interstitialAd0;

  @override
  Widget? getBody(State state) {
    if (time == 'nil') {
      DateTime now = DateTime.now();
      int hour = now.hour;
      String ampm = hour > 10 ? ' PM' : ' AM';
      String minute = now.minute.toString();
      if (now.minute < 10) {
        minute = '0' + minute;
      }
      if (hour == 12) {
        time = (12).toString() + ':' + minute + ampm;
      } else if (hour > 11) {
        time = (hour - 12).toString() + ':' + minute + ampm;
      } else {
        time = (hour + 1).toString() + ':' + minute + ampm;
      }
    }

    if (interstitialAd0 != null) {
      interstitialAd0!.show().then((v) {
        interstitialAd0 = null;
      });
    }

    Map<String, dynamic> preface = {};
    List<String> addedDrugs = [];
    for (Drug drug in Drug.drugs) {
      if (drug.added) {
        addedDrugs.add(drug.name);
      }
    }
    preface['my-medications'] = addedDrugs;
    List<String> addedConditions = [];
    for (Condition condition in Condition.conditions) {
      if (condition.added) {
        addedConditions.add(condition.name);
      }
    }
    preface['my-conditions'] = addedConditions;
    Data.getUserField('Age').then((age) {
      preface['my-age-years'] = age;
    });
    Data.getUserField('Height').then((height) {
      preface['my-height-inches'] = height;
    });
    Data.getUserField('Weight').then((weight) {
      preface['my-weight-pounds'] = weight;
    });

    // Quote? quote;
    // for (DateTime date in Quote.quotes.keys) {
    //   if (date.day == DateTime.now().day &&
    //       date.month == DateTime.now().month) {
    //     quote = Quote.quotes[date];
    //     break;
    //   }
    // }
    // if (quote != null) {
    //   encode['todays-quote'] = '\"' + quote.quote + '\"' + ' by ' + quote.name;
    // }

    Function(String) submit = (text) {
      if (!(HomeAppState.profile?.accessLevels['premium']?.isActive ??
          false || HomeAppState.bypassIntendedObstacles)) {
        Navigator.push(state.context,
            MaterialPageRoute(builder: (context) => LandingPaywallScreen()));
        return;
      }
      state.setState(() {
        if (messages.isEmpty || messages[messages.length - 1].text != '...') {
          messages.add(Message(user: true, text: text));
          messages.add(Message(user: false, text: '...'));
        }
      });
      Future(() async {
        if (allowedTokens > 0) {
          List<OpenAIChatCompletionChoiceMessageModel> chat = [];
          chat.add(OpenAIChatCompletionChoiceMessageModel(
              role: 'system',
              content:
                  'You are a helpful doctor from the Vitalitas organization to solve daily at home problems. Your data should preferably be sourced from the Mayo Clinic, nonetheless, include links to your sources at the bottom of your responses. This data represents the person you are talking to ' +
                      jsonEncode(preface) +
                      '.'));
          for (Message message in messages) {
            if (message.text != '...') {
              chat.add(OpenAIChatCompletionChoiceMessageModel(
                  role: message.user ? 'user' : 'assistant',
                  content: message.text));
            }
          }
          OpenAIChatCompletionModel completion =
              await OpenAI.instance.chat.create(
            model: "gpt-3.5-turbo",
            messages: chat,
            maxTokens: 1000,
          );
          allowedTokens -= completion.usage.totalTokens;
          await Data.setUserField('MonthlyTokens', allowedTokens);
          return completion.choices[0].message.content;
        }
        return 'Vitalitas cannot process this request at this time. Try again later.';
      }).then((text) {
        state.setState(() {
          for (int i = messages.length - 1; i >= 0; i--) {
            Message message = messages[i];
            if (!message.user && message.text == '...') {
              message.text = text as String;
              break;
            }
          }
        });
      });
    };
    List<Widget> messageWidgets = [];
    for (int i = 0; i < messages.length; i++) {
      Message message = messages[i];
      Widget child = DefaultTextStyle(
          style: TextStyle(
              fontFamily: 'Comfort', fontSize: 16, color: Vitalitas.theme.txt),
          child: Text(message.text));
      if (i + 1 == messages.length &&
          !message.user &&
          !(message.finished ?? false)) {
        child = DefaultTextStyle(
            style: TextStyle(
                fontFamily: 'Comfort',
                fontSize: 16,
                color: Vitalitas.theme.txt),
            child: AnimatedTextKit(
                key: ValueKey(message.text),
                repeatForever: message.text == '...',
                totalRepeatCount: 1,
                onFinished: message.text == '...'
                    ? null
                    : () {
                        message.finished = true;
                      },
                animatedTexts: [
                  message.text == '...'
                      ? WavyAnimatedText(
                          message.text,
                          speed: const Duration(milliseconds: 250),
                        )
                      : TyperAnimatedText(
                          message.text,
                          speed: const Duration(milliseconds: 15),
                        )
                ]));
      }
      messageWidgets.add(ChatBubble(
        alignment: message.user ? Alignment.centerRight : Alignment.centerLeft,
        clipper: ChatBubbleClipper4(
            type: message.user
                ? BubbleType.sendBubble
                : BubbleType.receiverBubble),
        backGroundColor:
            message.user ? Vitalitas.theme.acc : const Color(0xffE7E7ED),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(state.context).size.width * 0.6,
          ),
          child: child,
        ),
      ));
      messageWidgets.add(SizedBox(
        height: 10,
      ));
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
            child: SingleChildScrollView(
                child: Column(
          children: [
            Container(
              height: 200,
              child: Center(
                child: Text(
                  time,
                  style: TextStyle(
                      fontFamily: 'Comfort',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Vitalitas.theme.txt),
                ),
              ),
            ),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: messageWidgets,
                ))
          ],
        ))),
        Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(0.1))
            ], color: const Color.fromARGB(255, 221, 221, 221)),
            child: Padding(
                padding: EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                        child: TextField(
                      cursorColor: Vitalitas.theme.fg,
                      cursorWidth: 3,
                      cursorRadius: Radius.circular(6),
                      controller: submitController,
                      style: TextStyle(
                          fontFamily: 'Comfort',
                          fontSize: 15,
                          color: Vitalitas.theme.txt),
                      decoration: InputDecoration(
                        hintText: 'Tell me about my conditions...',
                        contentPadding: const EdgeInsets.all(15),
                        filled: true,
                        fillColor: Vitalitas.theme.bg,
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Vitalitas.theme.acc!, width: 3),
                            borderRadius: BorderRadius.circular(25)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Vitalitas.theme.fg!, width: 3),
                            borderRadius: BorderRadius.circular(25)),
                      ),
                      onSubmitted: submit,
                    )),
                    SizedBox(
                      width: 10,
                    ),
                    InkWell(
                      onTap: () {
                        submit(submitController.text.trim());
                      },
                      onHover: (enter) {
                        state.setState(() {
                          data['SubmitColor'] =
                              enter ? Vitalitas.theme.fg : Vitalitas.theme.acc;
                          data['SubmitIconColor'] =
                              enter ? Vitalitas.theme.bg : Vitalitas.theme.fg;
                        });
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        child: Center(
                            child: Icon(
                          Icons.send,
                          size: 30,
                          color: data['SubmitIconColor'] ?? Vitalitas.theme.fg,
                        )),
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 3, color: Vitalitas.theme.fg!),
                            shape: BoxShape.circle,
                            color: data['SubmitColor'] ?? Vitalitas.theme.acc),
                      ),
                    ),
                  ],
                ))),
      ],
    );
  }

  @override
  GButton getNavButton() {
    return GButton(
        icon: Icons.message_outlined,
        text: 'Bot',
        iconActiveColor:
            HSLColor.fromColor(Colors.grey).withLightness(0.2).toColor(),
        backgroundColor:
            HSLColor.fromColor(Colors.grey).withLightness(0.8).toColor(),
        iconColor: Vitalitas.theme.bg);
  }
}

class Message {
  bool user;
  bool? finished;
  String text;
  Function onClick = () {};

  Message({required this.user, required this.text});
}
