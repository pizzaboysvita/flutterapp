import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/features/onboard.dart/bloc/location/store_selection_bloc.dart';
import 'package:pizza_boys/features/onboard.dart/bloc/location/store_selection_state.dart';

class StoreSelectionPage extends StatelessWidget {
  const StoreSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Your Store")),
      body: BlocBuilder<StoreSelectionBloc, StoreSelectionState>(
        builder: (context, state) {
          if (state is StoreSelectionLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is StoreSelectionLoaded) {
            return ListView.builder(
              itemCount: state.stores.length,
              itemBuilder: (context, index) {
                final store = state.stores[index];
                final isSelected = store.id == state.selectedStoreId;

                return ListTile(
                  title: Text(store.name),
                  subtitle: Text(store.address),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                  onTap: () {
                    context
                        .read<StoreSelectionBloc>()
                        .add(SelectStoreEvent(store.id));
                  },
                );
              },
            );
          } else if (state is StoreSelectionError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        },
      ),
    );
  }
}
