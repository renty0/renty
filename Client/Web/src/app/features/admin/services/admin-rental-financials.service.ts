import { Injectable, Inject, Optional, InjectionToken, inject } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';
import { API_BASE_URL } from '../../../core/api/api-client';

export interface WalletTransactionDto {
  id: string;
  userId: number;
  amount: number;
  type: string;
  description: string;
  isPending: boolean;
  createdAt: string;
}

export interface RentalFinancialBreakdownDto {
  rentalId: string;
  initialRentalPrice: number;
  initialDeposit: number;
  initialExpertFee: number;
  escrowRental: number;
  escrowDeposit: number;
  escrowExpert: number;
  distributedToOwner: number;
  distributedToRenter: number;
  distributedToExpert: number;
  platformRevenue: number;
  penaltiesCollected: number;
  rentalStatus: string;
  cancellationReason?: string;
  transactions: WalletTransactionDto[];
}

export interface ApiResponse<T> {
  success: boolean;
  message?: string;
  data: T;
  errors?: string[];
}

@Injectable({
  providedIn: 'root'
})
export class AdminRentalFinancialsService {
  private http = inject(HttpClient);
  private baseUrl = inject(API_BASE_URL, { optional: true }) ?? 'http://localhost:5106';

  getRentalFinancialBreakdown(rentalId: string): Observable<ApiResponse<RentalFinancialBreakdownDto>> {
    let url_ = `${this.baseUrl}/api/v1/admin/rentals/${rentalId}/financials`;
    url_ = url_.replace(/[?&]$/, '');

    const options_ = {
      headers: new HttpHeaders({
        Accept: 'application/json'
      })
    };

    return this.http.get<ApiResponse<RentalFinancialBreakdownDto>>(url_, options_);
  }
}
