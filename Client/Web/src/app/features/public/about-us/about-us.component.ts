import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatIconModule } from '@angular/material/icon';
import { TranslateModule } from '@ngx-translate/core';
import { RouterModule } from '@angular/router';
import { LocalizationService } from '../../../core/services/localization.service';

@Component({
  selector: 'app-about-us',
  standalone: true,
  imports: [CommonModule, MatIconModule, TranslateModule, RouterModule],
  templateUrl: './about-us.component.html',
  styleUrl: './about-us.component.scss'
})
export class AboutUsComponent {
  localization = inject(LocalizationService);
  
  get lang() {
    return this.localization.language();
  }
}
