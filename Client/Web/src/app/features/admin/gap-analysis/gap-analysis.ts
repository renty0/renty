import { Component, inject, signal, computed, DestroyRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatTableModule } from '@angular/material/table';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { MatCardModule } from '@angular/material/card';
import { MatChipsModule } from '@angular/material/chips';
import { rxResource, takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { AdminClient, IGapDto, Gap_AnalysisClient } from '../../../core/api/api-client';
import { TranslateModule } from '@ngx-translate/core';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';
import { map, finalize } from 'rxjs';

@Component({
  selector: 'app-gap-analysis',
  standalone: true,
  imports: [
    CommonModule,
    MatIconModule,
    MatButtonModule,
    MatTableModule,
    MatProgressBarModule,
    MatCardModule,
    MatChipsModule,
    TranslateModule,
    HeaderSectionComponent
  ],
  templateUrl: './gap-analysis.html',
  styleUrl: './gap-analysis.scss'
})
export class GapAnalysisComponent {
  private adminClient = inject(AdminClient);
  private gapAnalysisClient = inject(Gap_AnalysisClient);
  private destroyRef = inject(DestroyRef);

  gapsResource = rxResource({
    stream: () => this.adminClient.getAdminGapAnalysis(20, 'all').pipe(
      map((response) => (response.data?.gaps as IGapDto[]) || [])
    )
  });

  gaps = computed<IGapDto[]>(() => this.gapsResource.value() || []);
  isLoading = computed(() => this.gapsResource.isLoading());
  isRefreshing = signal(false);
  
  // Dashboard Metrics
  totalCategories = computed(() => this.gaps().length);
  highGapCount = computed(() => this.gaps().filter(g => (g.gapScore || 0) > 7).length);
  topGapCategory = computed<IGapDto | undefined>(() => {
    const sorted = [...this.gaps()].sort((a, b) => (b.gapScore || 0) - (a.gapScore || 0));
    return sorted[0];
  });

  displayedColumns: string[] = ['category', 'demand', 'supply', 'gap_score', 'recommendations'];

  triggerAnalysis() {
    this.isRefreshing.set(true);
    this.gapAnalysisClient.triggerGapAnalysis()
      .pipe(
        takeUntilDestroyed(this.destroyRef),
        finalize(() => this.isRefreshing.set(false))
      )
      .subscribe({
        next: () => {
          this.gapsResource.reload();
        },
        error: () => {}
      });
  }

  refresh(): void {
    this.gapsResource.reload();
  }

  getGapColor(score: number | undefined): string {
    if (!score) return 'primary';
    if (score > 7) return 'warn';
    if (score > 4) return 'accent';
    return 'primary';
  }
}
