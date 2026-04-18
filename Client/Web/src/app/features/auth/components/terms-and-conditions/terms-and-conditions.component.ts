import { Component, EventEmitter, Input, Output } from '@angular/core';
import { CommonModule } from '@angular/common';
import { TranslatePipe } from '@ngx-translate/core';

@Component({
    selector: 'app-terms-and-conditions',
    standalone: true,
    imports: [CommonModule, TranslatePipe],
    template: `
    <div class="terms-overlay" *ngIf="visible" (click)="closeDialog.emit()">
      <div class="terms-content" (click)="$event.stopPropagation()">
        <h2>{{ 'terms.title' | translate }}</h2>
        <div class="terms-body">
          <p>{{ 'terms.intro' | translate }}</p>
          <h3>{{ 'terms.section1Title' | translate }}</h3>
          <p>{{ 'terms.section1Body' | translate }}</p>
          <h3>{{ 'terms.section2Title' | translate }}</h3>
          <p>{{ 'terms.section2Body' | translate }}</p>
          <h3>{{ 'terms.section3Title' | translate }}</h3>
          <p>{{ 'terms.section3Body' | translate }}</p>
          <h3>{{ 'terms.section4Title' | translate }}</h3>
          <p>{{ 'terms.section4Body' | translate }}</p>
        </div>
        <button class="btn-close" (click)="closeDialog.emit()">{{ 'terms.close' | translate }}</button>
      </div>
    </div>
  `,
    styles: [`
    .terms-overlay {
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: rgba(0, 0, 0, 0.5);
      display: flex;
      justify-content: center;
      align-items: center;
      z-index: 1000;
    }
    .terms-content {
      background: white;
      padding: 30px;
      border-radius: 12px;
      max-width: 600px;
      width: 90%;
      max-height: 80vh;
      overflow-y: auto;
    }
    .btn-close {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      margin-top: 20px;
      padding: 10px 18px;
      min-height: 42px;
      font-size: 0.875rem;
      font-weight: 500;
      line-height: 1.4;
      white-space: nowrap;
      background: #0c295e;
      color: white;
      border: none;
      border-radius: 8px;
      cursor: pointer;
      transition: all 0.2s;
    }
    .btn-close:hover {
      background: #1a365d;
    }
  `]
})
export class TermsAndConditionsComponent {
    @Input() visible = false;
    @Output() closeDialog = new EventEmitter<void>();
}
