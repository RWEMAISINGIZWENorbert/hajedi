import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajedi/bloc/customer/customer_bloc.dart';
import 'package:hajedi/bloc/customer/customer_state.dart';
import 'package:hajedi/bloc/customer/customer_event.dart';
import 'package:hajedi/widgets/app_bar.dart';
import 'package:hajedi/l10n/app_localizations.dart';
import 'package:iconly/iconly.dart';
import 'package:hajedi/widgets/loading.dart';

class Customers extends StatefulWidget {
  const Customers({super.key});

  @override
  State<Customers> createState() => _CustomersState();
}

class _CustomersState extends State<Customers> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerBloc>().add(LoadCustomers());
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBarComponent(
        title: loc.customers,
        icon: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(IconlyLight.arrow_left_circle),
        ),
      ),
      body: BlocConsumer<CustomerBloc, CustomerState>(
        listener: (context, state) {

        },
        builder: (context, state) {
          if (state is CustomersLoadingState) {
            return  Center(child: Loading());
          } else if(state is CustomersLoadedState){
             final customers = state.customers;

             if(customers.isEmpty){
               return Center(child: Text(loc.no_customers_found));
             }


          }
           return const SizedBox();
        },
      ),
    );
  }
}
