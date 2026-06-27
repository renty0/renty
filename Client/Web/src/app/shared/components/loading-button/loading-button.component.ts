import { Component, Input, Output, EventEmitter , ChangeDetectionStrategy } from '@angular/core'

import { MatIconModule } from '@angular/material/icon';
import { MatRippleModule } from '@angular/material/core';
import { MatTooltipModule } from '@angular/material/tooltip';

export type ButtonColor = 'primary' | 'secondary' | 'accent' | 'warn' | 'success' | 'info';
export type ButtonVariant = 'filled' | 'outlined' | 'stroked' | 'text';
export type ButtonSize = 'xs' | 'sm' | 'md' | 'lg' | 'xl';

@Component({
  selector: 'app-loading-button',
  standalone: true,
  imports: [MatIconModule, MatRippleModule, MatTooltipModule],
  templateUrl: './loading-button.component.html',
  styleUrls: ['./loading-button.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class LoadingButtonComponent {
  // Loading state
  @Input() loading: boolean = false;
  @Input() disabled: boolean = false;

  // Button type
  @Input() type: 'button' | 'submit' | 'reset' = 'button';

  // Styling
  @Input() color: ButtonColor = 'primary';
  @Input() variant: ButtonVariant = 'filled';
  @Input() size: ButtonSize = 'md';

  // Layout
  @Input() fullWidth: boolean = false;
  @Input() rounded: boolean = false;

  // Icon support
  @Input() icon: string | null = null;
  @Input() matIcon: string | null = null; // Material icon name
  @Input() iconPosition: 'start' | 'end' = 'start';
  @Input() iconOnly: boolean = false;

  // Accessibility / Features
  @Input() customClass: string = '';
  @Input() tooltip: string = '';
  @Input() tooltipPosition: 'above' | 'below' | 'left' | 'right' | 'before' | 'after' = 'above';
  @Input() ariaLabel: string = '';

  @Output() clicked = new EventEmitter<void>();

  get isDisabled(): boolean {
    return this.disabled || this.loading;
  }

  get buttonClasses(): string {
    // Map 'stroked' to 'outlined' for backwards compatibility
    const variantClass = this.variant === 'stroked' ? 'outlined' : this.variant;
    const classes = [
      'btn',
      `btn-${this.color}`,
      `btn-${variantClass}`,
      `btn-${this.size}`,
    ];

    if (this.fullWidth) classes.push('btn-full-width');
    if (this.rounded) classes.push('btn-rounded');
    if (this.loading) classes.push('btn-loading');
    if (this.iconOnly) classes.push('btn-icon-only');
    if (this.customClass) classes.push(this.customClass);

    return classes.join(' ');
  }

  handleClick(): void {
    if (!this.isDisabled) {
      this.clicked.emit();
    }
  }
}
