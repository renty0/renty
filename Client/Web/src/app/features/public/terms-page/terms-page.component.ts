import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { TranslateModule } from '@ngx-translate/core';
import { MatIconModule } from '@angular/material/icon';
import { RouterLink } from '@angular/router';

@Component({
  selector: 'app-terms-page',
  standalone: true,
  imports: [CommonModule, TranslateModule, MatIconModule, RouterLink],
  templateUrl: './terms-page.component.html',
  styleUrl: './terms-page.component.scss'
})
export class TermsPageComponent {
  lastUpdated = '2026-01-01';
}
