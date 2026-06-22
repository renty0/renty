import { Component, EventEmitter, Input, Output } from '@angular/core';
import { CommonModule } from '@angular/common';
import { TranslateModule } from '@ngx-translate/core';

@Component({
  selector: 'app-terms-and-conditions',
  standalone: true,
  imports: [CommonModule, TranslateModule],
  template: `
    @if (visible) {
    <div class="fixed top-0 left-0 w-full h-full bg-black-alpha-50 flex justify-content-center align-items-center z-5" (click)="closeDialog.emit()">
      <div class="bg-white p-5 border-round-xl max-w-40rem w-11 max-h-screen overflow-y-auto shadow-6 animation-scalein animation-duration-200" (click)="$event.stopPropagation()">
        <h2 class="text-2xl font-bold text-primary mb-4">{{ 'terms.title' | translate }}</h2>
        <div class="text-color-secondary line-height-3 text-sm">
          <p class="mb-4">{{ 'terms.intro' | translate }}</p>
          <h3 class="text-base font-semibold text-primary mb-2">{{ 'terms.section1Title' | translate }}</h3>
          <p class="mb-4">{{ 'terms.section1Body' | translate }}</p>
          <h3 class="text-base font-semibold text-primary mb-2">{{ 'terms.section2Title' | translate }}</h3>
          <p class="mb-4">{{ 'terms.section2Body' | translate }}</p>
          <h3 class="text-base font-semibold text-primary mb-2">{{ 'terms.section3Title' | translate }}</h3>
          <p class="mb-4">{{ 'terms.section3Body' | translate }}</p>
          <h3 class="text-base font-semibold text-primary mb-2">{{ 'terms.section4Title' | translate }}</h3>
          <p class="mb-4">{{ 'terms.section4Body' | translate }}</p>
        </div>
        <div class="flex justify-content-end mt-4 pt-3 border-top-1 border-300">
          <button class="bg-primary text-white border-none border-round-lg px-4 py-2 font-semibold cursor-pointer hover:bg-primary-reverse transition-colors" (click)="closeDialog.emit()">{{ 'terms.close' | translate }}</button>
        </div>
      </div>
    </div>
    }
  `
})
export class TermsAndConditionsComponent {
    @Input() visible = false;
    @Output() closeDialog = new EventEmitter<void>();
}
