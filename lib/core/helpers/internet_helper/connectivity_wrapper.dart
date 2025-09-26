import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/core/bloc/internet_check/internet_check_bloc.dart';
import 'package:pizza_boys/core/bloc/internet_check/internet_check_state.dart';
import 'package:pizza_boys/core/helpers/internet_helper/network_issue_helper.dart';


class ConnectivityWrapper extends StatelessWidget {
  final Widget child;

  const ConnectivityWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectivityBloc, ConnectivityState>(
      listener: (context, state) {
        if (!state.hasInternet) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No Internet Connection')),
          );
        } else {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }
      },
      child: BlocBuilder<ConnectivityBloc, ConnectivityState>(
        builder: (context, state) {
          if (!state.hasInternet) {
            return NetworkIssueScreen(
              onRetry: () =>
                  context.read<ConnectivityBloc>().recheckConnection(),
            );
          }
          return child;
        },
      ),
    );
  }
}
