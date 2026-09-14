import 'package:flutter/material.dart';
import 'package:hajedi/widgets/app_bar.dart';
import 'package:hajedi/l10n/app_localizations.dart';
import 'package:iconly/iconly.dart';

class Customers extends StatelessWidget {
  const Customers({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return  Scaffold(
       appBar: AppBarComponent(
              title: loc.customers,
              icon: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
              child: const Icon(IconlyLight.arrow_left_circle),
             ),
         ),
      body: Center(
         child: Text('Customers')
      )   
    );
  }
}