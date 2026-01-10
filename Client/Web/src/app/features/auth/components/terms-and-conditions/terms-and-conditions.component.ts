import { Component, EventEmitter, Input, Output } from '@angular/core';
import { CommonModule } from '@angular/common';
import { TranslatePipe } from '@ngx-translate/core';

@Component({
    selector: 'app-terms-and-conditions',
    standalone: true,
    imports: [CommonModule, TranslatePipe],
    template: `
    <div class="terms-overlay" *ngIf="visible">
      <div class="terms-content">
        <h2>{{ 'register.terms' | translate }}</h2>
        <div class="terms-text">
          <p>Please read our terms and conditions...</p>
          <p>This is a placeholder for the actual terms and conditions text.</p>
        </div>
        <button class="btn-close" (click)="closeDialog.emit()">Close</button>
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
      margin-top: 20px;
      padding: 10px 20px;
      background: #2563eb;
      color: white;
      border: none;
      border-radius: 6px;
      cursor: pointer;
    }
  `]
})
export class TermsAndConditionsComponent {
    @Input() visible = false;
    @Output() closeDialog = new EventEmitter<void>();
}
