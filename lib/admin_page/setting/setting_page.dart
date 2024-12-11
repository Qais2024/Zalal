import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../language_settigns/languagechangeconttroler.dart';
enum Language { English, Farsi, Pashto }
class homescren extends StatefulWidget {
  const homescren({super.key});
  @override
  State<homescren> createState() => _homescrenState();
}
class _homescrenState extends State<homescren> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: Text(AppLocalizations.of(context)!.language,style: TextStyle(color: Colors.blueAccent),),
                trailing: Consumer<LanguageChange>(builder: (context, provider, child) {
                  return PopupMenuButton(
                    icon: Icon(Icons.language,color: Colors.blueAccent,),
                    onSelected: (Language item) {
                      if (Language.English.name == item.name) {
                        provider.changeLanguage(Locale("en"));
                      } else if (Language.Farsi.name == item.name) {
                        provider.changeLanguage(Locale("fa"));
                      } else if (Language.Pashto.name == item.name) {
                        provider.changeLanguage(Locale("ps"));
                      }
                    },
                    itemBuilder: (context) => <PopupMenuEntry<Language>>[
                      const PopupMenuItem(
                        value: Language.Farsi,
                        child: Row(
                          children: [
                            Text("فارسی"),
                            SizedBox(width: 10,),
                            Text("🇦🇫"),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: Language.Pashto,
                        child: Row(
                          children: [
                            Text("پښتو"),
                            SizedBox(width: 10,),
                            Text("🇦🇫"),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: Language.English,
                        child: Row(
                          children: [
                            Text("English"),
                            SizedBox(width: 10,),
                            Text("🇺🇸"),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}