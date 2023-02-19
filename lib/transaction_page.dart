import 'package:flutter/material.dart';
import 'package:management_system_app/ui/transaction_card.dart';

class TransactionPage extends StatelessWidget {
  const TransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: Theme.of(context).colorScheme.background,
      alignment: Alignment.center,
      child: TransactionCard(
        destinationWalletId: 'ewallet_1f38c9a2be61ba19173abf6c6b9420e6',
        sourceWalletId: 'ewallet_17d5d3d345be484fb01bcee975cfd3f4',
      ),
    ));
  }
}
