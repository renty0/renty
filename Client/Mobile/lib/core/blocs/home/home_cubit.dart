import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/services/api_service.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  Future<void> loadHomeData() async {
    emit(state.copyWith(isLoading: true, errorMessage: ''));
    try {
      final results = await Future.wait([
        _loadNewItems(),
        _loadPopularItems(),
        _loadSuggestedItems(),
        _loadCategories(),
      ]);

      emit(state.copyWith(
        isLoading: false,
        errorMessage: '',
        newItems: results[0] as List<ItemListDto>,
        popularItems: results[1] as List<ItemListDto>,
        suggestedItems: results[2] as List<ItemListDto>,
        categories: results[3] as List<ProductCategoryDto>,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load data. Pull to refresh.',
      ));
    }
  }

  Future<List<ItemListDto>> _loadNewItems() async {
    try {
      final response = await ApiService.items.getItems(
        1,
        4,
        sort: 'newest',
        sortOrder: 'desc',
      );
      if (response?.data != null) return response!.data!;
    } catch (_) {}
    return state.newItems;
  }

  Future<List<ItemListDto>> _loadPopularItems() async {
    try {
      final response = await ApiService.items.getItems(
        1,
        4,
        sort: 'popular',
        sortOrder: 'desc',
      );
      if (response?.data != null) return response!.data!;
    } catch (_) {}
    return state.popularItems;
  }

  Future<List<ItemListDto>> _loadSuggestedItems() async {
    try {
      final response = await ApiService.recommendations.getRecommendationsV1();
      if (response != null && response.data != null) {
        final entries = response.data!.recommendations;
        final list = entries
            .map((entry) => ItemListDto(
                  id: entry.item?.id,
                  titleEn: entry.item?.title,
                  titleAr: entry.item?.title,
                  dailyPrice: entry.item?.price,
                  primaryImage: entry.item?.image,
                  city: entry.item?.city,
                ))
            .toList();
        return list;
      }
    } catch (_) {}
    return state.suggestedItems;
  }

  Future<List<ProductCategoryDto>> _loadCategories() async {
    try {
      final response = await ApiService.categories.getCategories(1, 50);
      if (response?.data != null) return response!.data!;
    } catch (_) {}
    return state.categories;
  }

  Future<void> refreshHome() async => loadHomeData();
}
