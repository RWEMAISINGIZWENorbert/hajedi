
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajedi/bloc/theme/theme_bloc.dart';
import 'package:hajedi/bloc/theme/theme_event.dart';
import 'package:hajedi/bloc/theme/theme_state.dart';
import 'package:hajedi/l10n/app_localizations.dart';
import 'package:hajedi/widgets/app_bar.dart';
import 'package:iconly/iconly.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBarComponent(
        icon: InkWell(
           onTap: () => Navigator.pop(context),
           child: const Icon(
            IconlyLight.arrow_left_circle
           ),
        ), 
        title: loc.settings
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            InkWell(
              onTap: (){
                Navigator.pushNamed(context, '/choose-language');
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(loc.choose_language),
                  const Icon(IconlyLight.arrow_right_2)
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Appearance',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, state) {
                return ListTile(
                  leading: Icon(
                    // state.themeType == ThemeType.dark
                    state.themeMode == ThemeMode.dark
                        ? IconlyBold.home
                        : IconlyBold.home,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(
                    'Dark Mode',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  trailing: Switch(
                    // value: state.themeType == ThemeType.dark,
                    value: state.themeMode == ThemeMode.dark,
                    activeColor: Theme.of(context).primaryColor,
                    onChanged: (value) {
                      context.read<ThemeBloc>().add(ToggleThemeEvent());
                    },
                  ),
                );
              },
            ),
          ],
        ),
      )
    );
  }
}