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
          padding: const EdgeInsets.symmetric(horizontal: 12),
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
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: state.selectedCategory == null ? Colors.black : Colors.black,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  side: BorderSide.none,
                ),
              ),
              ...AppConstants.categories.map((category) {
                final isSelected = state.selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      context.read<SearchFilterCubit>().updateCategory(
                            selected ? category : null,
                          );
                    },
                    backgroundColor: Colors.white,
                    labelStyle: const TextStyle(color: Colors.black),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    side: BorderSide.none,
                    selectedColor: const Color(0xFFF7C35F),
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
