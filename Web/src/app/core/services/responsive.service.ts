import { MediaMatcher } from '@angular/cdk/layout';
import { inject, Injectable, signal } from '@angular/core';

@Injectable({
  providedIn: 'root',
})
export class ResponsiveService {
  private readonly _mobileQuery: MediaQueryList;
  private readonly _mobileQueryListener: () => void = () => {};
  readonly isMobile = signal(false);
  constructor() {
    const media = inject(MediaMatcher);
    this._mobileQuery = media.matchMedia('(max-width: 600px)');
    this.isMobile.set(this._mobileQuery.matches);
    this._mobileQueryListener = () => this.isMobile.set(this._mobileQuery.matches);
    this._mobileQuery.addEventListener('change', this._mobileQueryListener);
  }
}
