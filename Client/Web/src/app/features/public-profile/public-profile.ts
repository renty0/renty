import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, RouterModule } from '@angular/router';
import { MatIconModule } from '@angular/material/icon';
import { MatTabsModule } from '@angular/material/tabs';
import { MatButtonModule } from '@angular/material/button';
import { MatChipsModule } from '@angular/material/chips';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../environments/environment';
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
  private http = inject(HttpClient);
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
    this.http.get<any>(`${environment.apiUrl}/api/v1/public-profile/${userId}`)
      .pipe(finalize(() => this.isLoading.set(false)))
      .subscribe({
        next: (res: any) => this.profile.set(res?.data ?? res),
        error: (err: any) => console.error('Failed to load profile', err)
      });
  }

  getLocalizedTitle(item: any) {
    const isAr = this.translate.currentLang === 'ar';
    return isAr ? item.titleAr : item.titleEn;
  }
}
