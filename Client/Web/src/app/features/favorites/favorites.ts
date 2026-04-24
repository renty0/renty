import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterModule } from '@angular/router';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { MatCardModule } from '@angular/material/card';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { FavoritesClient, FavoriteItemDto } from '../../core/api/api-client';
import { ToastService } from '../../shared/services/toast.service';
import { HeaderSectionComponent } from '../../shared/components/header-section/header-section.component';
import { LoadingButtonComponent } from '../../shared/components/loading-button/loading-button.component';

@Component({
  selector: 'app-favorites',
  standalone: true,
  imports: [
    CommonModule,
    TranslateModule,
    MatCardModule,
    MatProgressSpinnerModule,
    MatIconModule,
    HeaderSectionComponent,
    RouterModule,
    LoadingButtonComponent
  ],
  templateUrl: './favorites.html',
  styleUrl: './favorites.scss'
})
export class FavoritesComponent implements OnInit {
  private favoritesClient = inject(FavoritesClient);
  private toast = inject(ToastService);
  private router = inject(Router);
  public translate = inject(TranslateService);

  isLoading = signal(true);
  favorites = signal<FavoriteItemDto[]>([]);

  ngOnInit() {
    this.loadFavorites();
  }

  loadFavorites() {
    this.isLoading.set(true);
    this.favoritesClient.getMyFavorites().subscribe({
      next: (res) => {
        this.favorites.set(res.data?.items || []);
        this.isLoading.set(false);
      },
      error: (err) => {
        console.error('Failed to load favorites', err);
        this.toast.showError('errors.fetchFailed');
        this.isLoading.set(false);
      }
    });
  }

  removeFavorite(id: string, event: Event) {
    event.stopPropagation();
    const currentFavs = this.favorites();
    this.favorites.set(currentFavs.filter(f => f.id !== id));

    this.favoritesClient.removeFavorite(id).subscribe({
      next: (res) => {
        if (res.error) {
          this.toast.showError(res.messages?.[0] || 'errors.unknownError');
          this.favorites.set(currentFavs);
        } else {
          this.toast.showSuccess('favorites.removeSuccess');
        }
      },
      error: (err) => {
        this.toast.showError('errors.unknownError');
        this.favorites.set(currentFavs);
      }
    });
  }

  viewItem(id: string) {
    this.router.navigate(['/items', id]);
  }
}
