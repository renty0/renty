import { Component } from '@angular/core';

import { TranslateModule } from '@ngx-translate/core';
import { MatIconModule } from '@angular/material/icon';
import { RouterLink } from '@angular/router';

@Component({
  selector: 'app-privacy-page',
  standalone: true,
  imports: [TranslateModule, MatIconModule, RouterLink],
  templateUrl: './privacy-page.component.html',
  styleUrl: './privacy-page.component.scss'
})
export class PrivacyPageComponent {
  lastUpdated = '2026-01-01';
}
