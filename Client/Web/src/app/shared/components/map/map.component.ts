import { CommonModule } from '@angular/common';
import {
    Component,
    EventEmitter,
    Input,
    Output,
    OnInit,
    OnChanges,
    OnDestroy,
    SimpleChanges,
    inject,
    ViewChild,
    ElementRef,
    AfterViewInit,
    ChangeDetectionStrategy,
    ChangeDetectorRef,
    NgZone
} from '@angular/core';
import { FormGroup, FormsModule, ReactiveFormsModule } from '@angular/forms';
import { Subscription } from 'rxjs';
import { GoogleMapsModule, GoogleMap } from '@angular/google-maps';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatMenuModule } from '@angular/material/menu';
import { ToastService } from '../../services/toast.service';
import { environment } from '../../../../environments/environment';

export interface MapCoordinates {
    latitude: number;
    longitude: number;
}

@Component({
    selector: 'app-map',
    standalone: true,
    imports: [
        CommonModule,
        FormsModule,
        ReactiveFormsModule,
        GoogleMapsModule,
        TranslateModule,
        MatIconModule,
        MatButtonModule,
        MatMenuModule
    ],
    changeDetection: ChangeDetectionStrategy.OnPush,
    templateUrl: './map.component.html',
    styleUrl: './map.component.scss',
})
export class MapComponent implements OnInit, OnChanges, AfterViewInit, OnDestroy {
    private toastr = inject(ToastService);
    private translate = inject(TranslateService);
    private cdr = inject(ChangeDetectorRef);
    private ngZone = inject(NgZone);

    @ViewChild('searchInput') searchInput!: ElementRef<HTMLInputElement>;
    @ViewChild('googleMap') googleMap!: GoogleMap;

    @Input() latitude: string | number | null | undefined = null;
    @Input() longitude: string | number | null | undefined = null;
    @Input() locationUrl: string | null | undefined = null;
    @Input() readonly = false;
    @Input() height = 400;
    @Input() showActions = false;
    @Input() showCoordinatesBadge = true;
    @Input() defaultZoom = 5;
    @Input() markerZoom = 15;

    @Input() formGroup?: FormGroup;
    @Input() latitudeControlName?: string;
    @Input() longitudeControlName?: string;
    @Input() controlName?: string;

    @Output() locationChanged = new EventEmitter<MapCoordinates>();

    apiLoaded = false;
    coordinateInput = '';
    searchFocused = false;
    coordFocused = false;

    hasCoordinates = false;
    displayCoordinates = '';

    center: google.maps.LatLngLiteral = { lat: 24.7136, lng: 46.6753 };
    zoom = 5;
    markerPosition: google.maps.LatLngLiteral = { lat: 24.7136, lng: 46.6753 };

    mapOptions: google.maps.MapOptions = {
        mapTypeId: 'roadmap',
        mapTypeControl: true,
        streetViewControl: true,
        fullscreenControl: true,
        zoomControl: true,
        gestureHandling: 'greedy'
    };

    markerOptions: google.maps.MarkerOptions = {
        draggable: true
    };

    private autocomplete: google.maps.places.Autocomplete | null = null;
    private autocompleteInitialized = false;
    private mutationObserver: MutationObserver | null = null;
    private positionDropdownFn: (() => void) | null = null;
    private formControlSubscription: Subscription | null = null;

    ngOnInit(): void {
        this.zoom = this.defaultZoom;
        this.updateMarkerOptions();
        this.loadGoogleMapsApi();
        this.initializeFromInputs();
        this.subscribeToFormControl();
    }

    ngAfterViewInit(): void {
        if (!this.readonly) {
            this.waitForApiAndSetupAutocomplete();
        }
    }

    ngOnChanges(changes: SimpleChanges): void {
        if (changes['latitude'] || changes['longitude'] || changes['locationUrl']) {
            this.initializeFromInputs();
        }
        if (changes['readonly']) {
            this.updateMarkerOptions();
        }
    }

    ngOnDestroy(): void {
        if (this.mutationObserver) {
            this.mutationObserver.disconnect();
            this.mutationObserver = null;
        }
        if (this.positionDropdownFn) {
            window.removeEventListener('scroll', this.positionDropdownFn, true);
            window.removeEventListener('resize', this.positionDropdownFn, true);
            this.positionDropdownFn = null;
        }
        if (this.autocomplete) {
            google.maps.event.clearInstanceListeners(this.autocomplete);
            this.autocomplete = null;
        }
        if (this.formControlSubscription) {
            this.formControlSubscription.unsubscribe();
            this.formControlSubscription = null;
        }
        this.autocompleteInitialized = false;
    }

    onSearchFocus(): void {
        this.searchFocused = true;
        this.positionAutocompleteDropdown();
    }

    onSearchBlur(): void {
        this.searchFocused = false;
    }

    onCoordBlur(): void {
        this.parseCoordinateInput();
        this.coordFocused = false;
    }

    onCoordinateInputChange(value: string): void {
        this.coordinateInput = value;
    }

    onMapClick(event: google.maps.MapMouseEvent): void {
        if (this.readonly || !event.latLng) return;
        this.setLocation(event.latLng.lat(), event.latLng.lng());
    }

    onMarkerDragEnd(event: google.maps.MapMouseEvent): void {
        if (!event.latLng) return;
        this.setLocation(event.latLng.lat(), event.latLng.lng());
    }

    parseCoordinateInput(): void {
        if (!this.coordinateInput.trim()) return;

        const parts = this.coordinateInput.split(',').map(s => s.trim());
        if (parts.length === 2) {
            const lat = Number.parseFloat(parts[0]);
            const lng = Number.parseFloat(parts[1]);

            if (!isNaN(lat) && !isNaN(lng) && lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
                this.setLocation(lat, lng);
                this.zoom = this.markerZoom;
                this.cdr.markForCheck();
                return;
            }
        }

        this.toastr.showError('errors.invalidCoordinates');
    }

    clearCoordinateInput(): void {
        this.coordinateInput = '';
        this.cdr.markForCheck();
    }

    openInGoogleMaps(): void {
        const coords = this.getCoordinates();
        if (coords) {
            window.open(`https://www.google.com/maps?q=${coords.lat},${coords.lng}`, '_blank');
        }
    }

    openInAppleMaps(): void {
        const coords = this.getCoordinates();
        if (coords) {
            window.open(`https://maps.apple.com/?q=${coords.lat},${coords.lng}`, '_blank');
        }
    }

    copyCoordinates(): void {
        const coords = this.getCoordinates();
        if (coords) {
            navigator.clipboard.writeText(`${coords.lat}, ${coords.lng}`).then(() => {
                this.toastr.showSuccess('common.coordinatesCopied');
            });
        }
    }

    private loadGoogleMapsApi(): void {
        if (typeof google !== 'undefined' && google.maps) {
            this.apiLoaded = true;
            this.initializeMapOptions();
            this.cdr.markForCheck();
            return;
        }

        const existingScript = document.querySelector('script[src*="maps.googleapis.com"]');
        if (existingScript) {
            existingScript.addEventListener('load', () => {
                this.ngZone.run(() => {
                    this.apiLoaded = true;
                    this.initializeMapOptions();
                    this.cdr.markForCheck();
                });
            });
            return;
        }

        const apiKey = (environment as any).googleMapsApiKey || '';
        if (!apiKey) {
            console.warn('Google Maps API Key not found in environment');
        }

        const script = document.createElement('script');
        script.src = `https://maps.googleapis.com/maps/api/js?key=${apiKey}&libraries=places`;
        script.async = true;
        script.defer = true;
        script.onload = () => {
            this.ngZone.run(() => {
                this.apiLoaded = true;
                this.initializeMapOptions();
                if (!this.readonly) {
                    setTimeout(() => this.setupAutocomplete(), 100);
                }
                this.cdr.markForCheck();
            });
        };
        document.head.appendChild(script);
    }

    private initializeMapOptions(): void {
        if (typeof google === 'undefined' || !google.maps) return;

        this.mapOptions = {
            ...this.mapOptions,
            mapTypeControlOptions: {
                style: google.maps.MapTypeControlStyle.HORIZONTAL_BAR,
                position: google.maps.ControlPosition.TOP_RIGHT
            },
            streetViewControlOptions: {
                position: google.maps.ControlPosition.LEFT_BOTTOM
            }
        };

        this.markerOptions = {
            ...this.markerOptions,
            animation: google.maps.Animation.DROP
        };
    }

    private updateMarkerOptions(): void {
        this.markerOptions = {
            ...this.markerOptions,
            draggable: !this.readonly
        };
    }

    private waitForApiAndSetupAutocomplete(): void {
        if (typeof google !== 'undefined' && google.maps?.places) {
            setTimeout(() => this.setupAutocomplete(), 100);
        } else {
            setTimeout(() => this.waitForApiAndSetupAutocomplete(), 500);
        }
    }

    private setupAutocomplete(): void {
        if (this.autocompleteInitialized || this.autocomplete) return;
        if (!this.searchInput?.nativeElement || this.readonly) return;
        if (typeof google === 'undefined' || !google.maps?.places) return;

        try {
            this.autocompleteInitialized = true;

            this.ngZone.runOutsideAngular(() => {
                this.autocomplete = new google.maps.places.Autocomplete(this.searchInput.nativeElement, {
                    types: ['geocode', 'establishment']
                });

                this.autocomplete.addListener('place_changed', () => {
                    this.ngZone.run(() => {
                        const place = this.autocomplete?.getPlace();
                        if (place?.geometry?.location) {
                            this.setLocation(place.geometry.location.lat(), place.geometry.location.lng());
                            this.zoom = 17;
                            this.cdr.markForCheck();
                        }
                    });
                });

                if (this.googleMap?.googleMap) {
                    this.autocomplete.bindTo('bounds', this.googleMap.googleMap);
                }

                this.setupDropdownObserver();
            });

        } catch {
            this.autocompleteInitialized = false;
        }
    }

    private setupDropdownObserver(): void {
        if (this.mutationObserver) return;

        this.injectAutocompleteStyles();

        this.positionDropdownFn = () => {
            const pacContainers = document.querySelectorAll('.pac-container') as NodeListOf<HTMLElement>;
            if (pacContainers.length > 0 && this.searchInput?.nativeElement) {
                const inputRect = this.searchInput.nativeElement.getBoundingClientRect();
                pacContainers.forEach(pacContainer => {
                    pacContainer.style.setProperty('top', `${inputRect.bottom + 4}px`, 'important');
                    pacContainer.style.setProperty('left', `${inputRect.left}px`, 'important');
                    pacContainer.style.setProperty('width', `${inputRect.width}px`, 'important');
                    pacContainer.style.setProperty('position', 'fixed', 'important');
                    pacContainer.style.setProperty('z-index', '10000', 'important');
                });
            }
        };

        this.searchInput?.nativeElement?.addEventListener('input', () => {
            setTimeout(() => this.positionDropdownFn?.(), 10);
        });

        this.searchInput?.nativeElement?.addEventListener('focus', () => {
            setTimeout(() => this.positionDropdownFn?.(), 10);
        });

        this.mutationObserver = new MutationObserver(() => {
            this.positionDropdownFn?.();
        });

        this.mutationObserver.observe(document.body, {
            childList: true,
            subtree: true,
            attributes: true,
            attributeFilter: ['style', 'class']
        });

        window.addEventListener('scroll', this.positionDropdownFn, true);
        window.addEventListener('resize', this.positionDropdownFn, true);
    }

    private injectAutocompleteStyles(): void {
        const styleId = 'map-autocomplete-override';
        if (document.getElementById(styleId)) return;

        const style = document.createElement('style');
        style.id = styleId;
        style.textContent = `
      .pac-container {
        z-index: 10000 !important;
        border-radius: 8px !important;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15) !important;
        border: none !important;
        margin-top: 0 !important;
      }
      .pac-item {
        padding: 8px 12px !important;
        cursor: pointer !important;
      }
      .pac-item:hover {
        background-color: #f5f5f5 !important;
      }
    `;
        document.head.appendChild(style);
    }

    private positionAutocompleteDropdown(): void {
        if (this.positionDropdownFn) {
            this.positionDropdownFn();
        }
    }

    private initializeFromInputs(): void {
        const coords = this.getCoordinates();
        if (coords) {
            this.center = { lat: coords.lat, lng: coords.lng };
            this.markerPosition = { lat: coords.lat, lng: coords.lng };
            this.coordinateInput = `${coords.lat}, ${coords.lng}`;
            this.zoom = this.markerZoom;
            this.hasCoordinates = true;
            this.displayCoordinates = `${coords.lat.toFixed(6)}, ${coords.lng.toFixed(6)}`;
        } else {
            this.hasCoordinates = false;
            this.displayCoordinates = '';
        }
        this.cdr.markForCheck();
    }

    private subscribeToFormControl(): void {
        if (!this.formGroup || !this.controlName) return;

        const control = this.formGroup.get(this.controlName);
        if (!control) return;

        this.formControlSubscription = control.valueChanges.subscribe((value) => {
            if (value) {
                const coords = this.parseLocationUrl(value);
                if (coords) {
                    this.center = { lat: coords.lat, lng: coords.lng };
                    this.markerPosition = { lat: coords.lat, lng: coords.lng };
                    this.coordinateInput = `${coords.lat}, ${coords.lng}`;
                    this.zoom = this.markerZoom;
                    this.hasCoordinates = true;
                    this.displayCoordinates = `${coords.lat.toFixed(6)}, ${coords.lng.toFixed(6)}`;
                    this.cdr.markForCheck();
                }
            }
        });
    }

    private getCoordinates(): { lat: number; lng: number } | null {
        if (this.latitude != null && this.longitude != null) {
            const lat = typeof this.latitude === 'string' ? Number.parseFloat(this.latitude) : Number(this.latitude);
            const lng = typeof this.longitude === 'string' ? Number.parseFloat(this.longitude) : Number(this.longitude);

            if (!isNaN(lat) && !isNaN(lng)) return { lat, lng };
        }

        if (this.locationUrl) {
            const coords = this.parseLocationUrl(this.locationUrl);
            if (coords) return coords;
        }

        if (this.formGroup && this.controlName) {
            const controlValue = this.formGroup.get(this.controlName)?.value;
            if (controlValue) {
                const coords = this.parseLocationUrl(controlValue);
                if (coords) return coords;
            }
        }

        return null;
    }

    private parseLocationUrl(url: string): { lat: number; lng: number } | null {
        if (!url || !url.trim()) return null;

        const coordPatterns = [
            /@(-?\d+\.?\d*),(-?\d+\.?\d*)/,
            /[?&]q=(-?\d+\.?\d*),(-?\d+\.?\d*)/,
            /[?&]ll=(-?\d+\.?\d*),(-?\d+\.?\d*)/,
            /place\/(-?\d+\.?\d*),(-?\d+\.?\d*)/,
            /^(-?\d+\.?\d*)\s*,\s*(-?\d+\.?\d*)$/,
        ];

        for (const pattern of coordPatterns) {
            const match = url.match(pattern);
            if (match) {
                const lat = Number.parseFloat(match[1]);
                const lng = Number.parseFloat(match[2]);
                if (!isNaN(lat) && !isNaN(lng) && lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
                    return { lat, lng };
                }
            }
        }

        return null;
    }

    private setLocation(lat: number, lng: number): void {
        this.center = { lat, lng };
        this.markerPosition = { lat, lng };
        this.coordinateInput = `${lat.toFixed(6)}, ${lng.toFixed(6)}`;
        this.hasCoordinates = true;
        this.displayCoordinates = `${lat.toFixed(6)}, ${lng.toFixed(6)}`;

        if (this.formGroup) {
            if (this.latitudeControlName && this.longitudeControlName) {
                const latControl = this.formGroup.get(this.latitudeControlName);
                const lngControl = this.formGroup.get(this.longitudeControlName);
                latControl?.setValue(lat);
                lngControl?.setValue(lng);
                latControl?.markAsDirty();
                lngControl?.markAsDirty();
            }

            if (this.controlName) {
                const control = this.formGroup.get(this.controlName);
                control?.setValue(`${lat.toFixed(6)}, ${lng.toFixed(6)}`);
                control?.markAsDirty();
            }
        }

        this.locationChanged.emit({ latitude: lat, longitude: lng });
        this.cdr.markForCheck();
    }
}
