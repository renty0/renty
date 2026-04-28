import { Component, inject, OnInit, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, RouterModule } from '@angular/router';
import { MatIconModule } from '@angular/material/icon';
import { MatTabsModule } from '@angular/material/tabs';
import { MatButtonModule } from '@angular/material/button';
import { MatChipsModule } from '@angular/material/chips';
import { Public_ProfileClient } from '../../core/api/api-client';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { finalize } from 'rxjs';

@Component({
  selector: 'app-public-profile',
  standalone: true,
  imports: [
    CommonModule, 
    RouterModule, 
    MatIconModule, 
    MatTabsModule, 
    MatButtonModule,
    MatChipsModule,
    TranslateModule
  ],
  templateUrl: './public-profile.html',
  styleUrl: './public-profile.scss'
})
export class PublicProfileComponent implements OnInit {
  private route = inject(ActivatedRoute);
  private publicProfileClient = inject(Public_ProfileClient);
  public translate = inject(TranslateService);

  profile = signal<any>(null);
  isLoading = signal(true);

  // MOCK DATA until backend is ready
  mockReviews = signal<any[]>([
    {
      id: '1',
      reviewerName: 'Ahmed Ali',
      reviewerImage: 'assets/profile.webp',
      rating: 5,
      comment: 'Great person to deal with. The item was exactly as described and in perfect condition.',
      createdAt: new Date(Date.now() - 86400000 * 2),
      role: 'owner'
    },
    {
      id: '2',
      reviewerName: 'Sara Kamel',
      reviewerImage: '',
      rating: 4,
      comment: 'Very smooth transaction. Was a bit late for pickup but overall great.',
      createdAt: new Date(Date.now() - 86400000 * 10),
      role: 'renter'
    }
  ]);

  ownerRating = computed(() => {
    const p = this.profile();
    return p?.ownerRating || 4.8; // Fallback mock
  });

  renterRating = computed(() => {
    const p = this.profile();
    return p?.renterRating || 4.5; // Fallback mock
  });

  ngOnInit() {
    this.route.params.subscribe(params => {
      const id = params['id'];
      if (id) {
        this.loadProfile(id);
      }
    });
  }

  loadProfile(userId: number) {
    this.isLoading.set(true);
    this.publicProfileClient.getPublicProfile(userId).subscribe((res: any) => {
      this.profile.set(res?.data);
      this.isLoading.set(false);
    });
  }

  getLocalizedTitle(item: any) {
    const isAr = this.translate.currentLang === 'ar';
    return isAr ? item.titleAr : item.titleEn;
  }
}
