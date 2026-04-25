import { Component, inject, OnInit, signal } from '@angular/core';
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
