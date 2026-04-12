import { Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';

@Component({
  selector: 'app-id-verification',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './id-verification.component.html',
  styleUrls: ['./id-verification.component.scss']
})
export class IdVerificationComponent {
  private http = inject(HttpClient);
  private router = inject(Router);

  frontImage = signal<string | null>(null);
  backImage = signal<string | null>(null);
  
  isLoading = signal(false);
  errorMsg = signal<string | null>(null);
  successMsg = signal<string | null>(null);

  onFileSelected(event: any, side: 'front' | 'back') {
    const file = event.target.files[0];
    if (file) {
      // In a real application, you would upload this file to a pre-signed S3 url
      // or directly to the server via FormData. For demo purposes, we do Base64 
      // or just simulate a URL. Let's create a fake URL.
      const fakeUrl = URL.createObjectURL(file);
      if (side === 'front') this.frontImage.set(fakeUrl);
      if (side === 'back') this.backImage.set(fakeUrl);
    }
  }

  submitDocument() {
    this.isLoading.set(true);
    this.errorMsg.set(null);

    // Provide the assumed valid URLs to the backend command
    const payload = {
      frontImageUrl: this.frontImage() || 'simulate-s3-front.jpg',
      backImageUrl: this.backImage() || 'simulate-s3-back.jpg'
    };

    this.http.post<{ idVerificationId: string }>('/api/v1/user/id/upload', payload)
      .subscribe({
        next: (res) => {
          this.successMsg.set('ID Verification submitted! Waiting for Admin approval.');
          this.isLoading.set(false);
          setTimeout(() => this.router.navigate(['/items']), 3000);
        },
        error: (err) => {
          this.errorMsg.set(err.error?.title || err.error?.detail || 'Failed to submit ID.');
          this.isLoading.set(false);
        }
      });
  }
}
