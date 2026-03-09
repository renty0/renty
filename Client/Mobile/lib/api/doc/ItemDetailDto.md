# renty_api.model.ItemDetailDto

## Load the model package
```dart
import 'package:renty_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | [optional] 
**titleAr** | **String** |  | [optional] 
**titleEn** | **String** |  | [optional] 
**descAr** | **String** |  | [optional] 
**descEn** | **String** |  | [optional] 
**type** | **String** |  | [optional] 
**status** | **String** |  | [optional] 
**condition** | **String** |  | [optional] 
**defaultDeposit** | **num** |  | [optional] 
**location** | **String** |  | [optional] 
**city** | **String** |  | [optional] 
**lat** | **num** |  | [optional] 
**lng** | **num** |  | [optional] 
**createdAt** | [**DateTime**](DateTime.md) |  | [optional] 
**owner** | [**OwnerDto**](OwnerDto.md) |  | [optional] 
**pricing** | [**List<ItemPricingDto>**](ItemPricingDto.md) |  | [optional] [default to const []]
**images** | [**List<ItemImageDto>**](ItemImageDto.md) |  | [optional] [default to const []]
**avgRating** | **double** |  | [optional] 
**reviewCount** | **int** |  | [optional] 
**category** | [**ItemListDtoCategory**](ItemListDtoCategory.md) |  | [optional] 
**subcategory** | [**ItemListDtoSubcategory**](ItemListDtoSubcategory.md) |  | [optional] 
**brand** | [**ItemListDtoBrand**](ItemListDtoBrand.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


