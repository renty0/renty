import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatTableModule } from '@angular/material/table';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { MatCardModule } from '@angular/material/card';
import { AdminClient, IGapDto } from '../../../core/api/api-client';
import { TranslateModule } from '@ngx-translate/core';
import { HeaderSectionComponent } from '../../../shared/components/header-section/header-section.component';

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
    TranslateModule,
    HeaderSectionComponent
  ],
  templateUrl: './gap-analysis.html',
  styleUrl: './gap-analysis.scss'
})
export class GapAnalysisComponent implements OnInit {
  private adminClient = inject(AdminClient);

  gaps = signal<IGapDto[]>([]);
  isLoading = signal(true);
  error = signal<string | null>(null);

  displayedColumns: string[] = ['category', 'demand', 'supply', 'gap_score', 'recommendations'];

  ngOnInit(): void {
    this.loadGapAnalysis();
  }

  loadGapAnalysis(): void {
    this.isLoading.set(true);
    this.error.set(null);

    this.adminClient.getAdminGapAnalysis(20, 'all').subscribe({
      next: (response: any) => {
        if (response && response.data && response.data.gaps) {
          this.gaps.set(response.data.gaps);
        } else {
          this.error.set(response?.error || 'Failed to load gap analysis data');
        }
        this.isLoading.set(false);
      },
      error: (err) => {
        this.error.set('An error occurred while fetching gap analysis');
        this.isLoading.set(false);
        console.error('Gap Analysis Error:', err);
      }
    });
  }

  getGapColor(score: number): string {
    if (score > 7) return 'warn';
    if (score > 4) return 'accent';
    return 'primary';
  }
}
