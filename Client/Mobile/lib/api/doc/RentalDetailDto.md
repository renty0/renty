# renty_api.model.RentalDetailDto

## Load the model package
```dart
import 'package:renty_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | [optional] 
**itemId** | **String** |  | [optional] 
**itemTitle** | **String** |  | [optional] 
**itemImageUrl** | **String** |  | [optional] 
**ownerId** | **int** |  | [optional] 
**ownerFirstName** | **String** |  | [optional] 
**ownerCity** | **String** |  | [optional] 
**renterId** | **int** |  | [optional] 
**renterFirstName** | **String** |  | [optional] 
**startDate** | [**DateTime**](DateTime.md) |  | [optional] 
**endDate** | [**DateTime**](DateTime.md) |  | [optional] 
**actualReturnDate** | [**DateTime**](DateTime.md) |  | [optional] 
**rentalPrice** | **num** |  | [optional] 
**depositAmount** | **num** |  | [optional] 
**lateFee** | **num** |  | [optional] 
**status** | **String** |  | [optional] 
**depositStatus** | **String** |  | [optional] 
**notes** | **String** |  | [optional] 
**createdAt** | [**DateTime**](DateTime.md) |  | [optional] 
**renterWantsExpertReview** | **bool** |  | [optional] 
**ownerWantsExpertReview** | **bool** |  | [optional] 
**expertReviewFee** | **num** |  | [optional] 
**assignedExpertId** | **int** |  | [optional] 
**assignedExpertName** | **String** |  | [optional] 
**handoverImages** | [**List<RentalImageDto>**](RentalImageDto.md) |  | [optional] [default to const []]
**returnImages** | [**List<RentalImageDto>**](RentalImageDto.md) |  | [optional] [default to const []]
**transfers** | [**List<RentalTransferDto>**](RentalTransferDto.md) |  | [optional] [default to const []]
**verifications** | [**List<VerificationDto>**](VerificationDto.md) |  | [optional] [default to const []]
**currentPossession** | **String** |  | [optional] 
**currentTransferSequence** | **int** |  | [optional] 
**deliveryMethodFromExpert** | **String** |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


