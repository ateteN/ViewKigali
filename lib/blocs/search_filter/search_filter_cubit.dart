import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

class SearchFilterState extends Equatable {
  final String searchQuery;
  final String? selectedCategory;

  const SearchFilterState({
    this.searchQuery = '',
    this.selectedCategory,
  });

  @override
  List<Object?> get props => [searchQuery, selectedCategory];

  SearchFilterState copyWith({
    String? searchQuery,
    String? selectedCategory,
    bool clearCategory = false,
  }) {
    return SearchFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
    );
  }
}

class SearchFilterCubit extends Cubit<SearchFilterState> {
  SearchFilterCubit() : super(const SearchFilterState());

  void updateSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void updateCategory(String? category) {
    if (category == null) {
      emit(state.copyWith(clearCategory: true));
    } else {
      emit(state.copyWith(selectedCategory: category));
    }
  }

  void reset() {
    emit(const SearchFilterState());
  }
}
