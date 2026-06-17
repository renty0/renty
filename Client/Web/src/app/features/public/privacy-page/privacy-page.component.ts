import { Component, HostListener, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { TranslateModule } from '@ngx-translate/core';
import { MatIconModule } from '@angular/material/icon';
import { LocalizationService } from '../../../core/services/localization.service';

@Component({
  selector: 'app-privacy-page',
  standalone: true,
  imports: [CommonModule, TranslateModule, MatIconModule],
  templateUrl: './privacy-page.component.html',
  styleUrl: './privacy-page.component.scss'
})
export class PrivacyPageComponent {
  private localization = inject(LocalizationService);

  get lang() {
    return this.localization.language();
  }

  readingProgress = 0;

  @HostListener('window:scroll', [])
  onWindowScroll() {
    const docElement = document.documentElement;
    const docBody = document.body;
    const scrollTop = docElement.scrollTop || docBody.scrollTop;
    const scrollHeight = docElement.scrollHeight || docBody.scrollHeight;
    const clientHeight = docElement.clientHeight;
    
    if (scrollHeight - clientHeight > 0) {
      const scrolled = (scrollTop / (scrollHeight - clientHeight)) * 100;
      this.readingProgress = Math.min(100, Math.max(0, Math.round(scrolled)));
    }
  }

  scrollToSection(id: string) {
    const element = document.getElementById(id);
    if (element) {
      // Offset scrolling slightly to account for the fixed header
      const yOffset = -90;
      const y = element.getBoundingClientRect().top + window.pageYOffset + yOffset;
      window.scrollTo({ top: y, behavior: 'smooth' });
    }
  }
}
