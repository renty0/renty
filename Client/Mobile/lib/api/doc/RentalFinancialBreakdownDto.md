# renty_api.model.RentalFinancialBreakdownDto

## Load the model package
```dart
import 'package:renty_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**rentalId** | **String** |  | [optional] 
**initialRentalPrice** | **num** |  | [optional] 
**initialDeposit** | **num** |  | [optional] 
**initialExpertFee** | **num** |  | [optional] 
**escrowRental** | **num** |  | [optional] 
**escrowDeposit** | **num** |  | [optional] 
**escrowExpert** | **num** |  | [optional] 
**distributedToOwner** | **num** |  | [optional] 
**distributedToRenter** | **num** |  | [optional] 
**distributedToExpert** | **num** |  | [optional] 
**platformRevenue** | **num** |  | [optional] 
**penaltiesCollected** | **num** |  | [optional] 
**rentalStatus** | **String** |  | [optional] 
**cancellationReason** | **String** |  | [optional] 
**transactions** | [**List<WalletTransactionDto>**](WalletTransactionDto.md) |  | [optional] [default to const []]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


