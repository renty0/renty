import { Component, Input, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { TranslateModule, TranslateService } from '@ngx-translate/core';

export interface ProductCardItem {
  id?: string;
  titleAr?: string;
  titleEn?: string;
  title?: string; // For recommendations
  dailyPrice?: number | null;
  price?: number | null; // For recommendations
  city?: string | null;
  primaryImage?: string | null;
  image?: string | null; // For recommendations
  avgRating?: number;
  type?: string;
  category?: { nameAr?: string; nameEn?: string };
}

@Component({
  selector: 'app-product-card',
  standalone: true,
  imports: [CommonModule, RouterModule, MatIconModule, MatButtonModule, TranslateModule],
  templateUrl: './product-card.component.html',
  styleUrl: './product-card.component.scss'
})
export class ProductCardComponent {
  @Input({ required: true }) item!: ProductCardItem;

  constructor(private translate: TranslateService) {}

  get currentLang() {
    return this.translate.currentLang || 'en';
  }

  localizedTitle = computed(() => {
    if (this.item.title) return this.item.title;
    return this.currentLang === 'ar' ? this.item.titleAr || '' : this.item.titleEn || '';
  });

  localizedCategory = computed(() => {
    if (!this.item.category) return '';
    return this.currentLang === 'ar' ? this.item.category.nameAr || '' : this.item.category.nameEn || '';
  });

  displayPrice = computed(() => {
    return this.item.dailyPrice ?? this.item.price ?? 0;
  });

  displayImage = computed(() => {
    return this.item.primaryImage ?? this.item.image ?? 'assets/images/placeholder.png';
  });
}
