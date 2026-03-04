import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../utils/constants.dart';
import '../blocs/search_filter/search_filter_cubit.dart';

class CategoryFilterChips extends StatelessWidget {
  const CategoryFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchFilterCubit, SearchFilterState>(
      builder: (context, state) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: FilterChip(
                  label: const Text('All'),
                  selected: state.selectedCategory == null,
                  onSelected: (selected) {
                    if (selected) {
                      context.read<SearchFilterCubit>().updateCategory(null);
                    }
                  },
                ),
              ),
              ...AppConstants.categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: FilterChip(
                    label: Text(category),
                    selected: state.selectedCategory == category,
                    onSelected: (selected) {
                      context.read<SearchFilterCubit>().updateCategory(
                            selected ? category : null,
                          );
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
