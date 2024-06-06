import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:vitalitas/data/data.dart';

class Quote {
  static Uri api = Uri.https(
      'www.phoenixsolve.com', '/webapps/vitalitas/api/quotes/data.json');
  static Future<void> load() async {
    quotes.clear();

    var doc = await http.get(api);
    var json = jsonDecode(doc.body);

    int i = 0;
    while (i < json.length) {
      Map<String, dynamic> obj = json[i];
      if (obj['name'] == null || obj['quote'] == null || obj['date'] == null) {
        print('Cannot parse required elements for ' +
            (obj['name'] ?? 'unnamed') +
            ' of date ' +
            (obj['date'] ?? 'no date') +
            '.');
        continue;
      }
      Quote q = Quote(
        name: obj['name'].toString(),
        quote: obj['quote'].toString(),
      );

      String mmDd = obj['date'];
      int mm = int.parse(mmDd.split('/')[0]) + 1;
      int dd = int.parse(mmDd.split('/')[1]);
      DateTime date = DateTime(1970, mm, dd);
      quotes[date] = q;

      i++;
    }
    print('Loaded ' + i.toString() + ' quotes.');
  }

  static Map<DateTime, Quote> quotes = {};

  final String name;
  final String quote;

  Quote({
    required this.name,
    required this.quote,
  });
}
