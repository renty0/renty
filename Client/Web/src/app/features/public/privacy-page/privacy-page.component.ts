import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { TranslateModule } from '@ngx-translate/core';
import { MatIconModule } from '@angular/material/icon';
import { RouterLink } from '@angular/router';

@Component({
  selector: 'app-privacy-page',
  standalone: true,
  imports: [CommonModule, TranslateModule, MatIconModule, RouterLink],
  templateUrl: './privacy-page.component.html',
  styleUrl: './privacy-page.component.scss'
})
export class PrivacyPageComponent {
  lastUpdated = '2026-01-01';
}
