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
    NgZone,
    ViewEncapsulation
} from '@angular/core';
import { FormGroup, FormsModule, ReactiveFormsModule } from '@angular/forms';
import { Subscription } from 'rxjs';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatMenuModule } from '@angular/material/menu';
import { ToastService } from '../../services/toast.service';
import * as L from 'leaflet';
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
        TranslateModule,
        MatIconModule,
        MatButtonModule,
        MatMenuModule
    ],
    changeDetection: ChangeDetectionStrategy.OnPush,
    encapsulation: ViewEncapsulation.None,
    templateUrl: './map.component.html',
    styleUrl: './map.component.scss',
})
export class MapComponent implements OnInit, OnChanges, AfterViewInit, OnDestroy {
    private toastr = inject(ToastService);
    private translate = inject(TranslateService);
    private cdr = inject(ChangeDetectorRef);
    private ngZone = inject(NgZone);

    @ViewChild('mapContainer') mapContainer!: ElementRef<HTMLDivElement>;

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

    coordinateInput = '';
    searchFocused = false;
    coordFocused = false;

    hasCoordinates = false;
    displayCoordinates = '';

    center = { lat: 24.7136, lng: 46.6753 };
    zoom = 5;
    markerPosition = { lat: 24.7136, lng: 46.6753 };

    // Nominatim Search
    searchQuery = '';
    searchResults: any[] = [];
    isSearching = false;
    private searchDebounceTimeout: any = null;

    private map: L.Map | null = null;
    private marker: L.Marker | null = null;
    private formControlSubscription: Subscription | null = null;

    ngOnInit(): void {
        this.zoom = this.defaultZoom;
        this.initializeFromInputs();
        this.subscribeToFormControl();
    }

    ngAfterViewInit(): void {
        this.ngZone.runOutsideAngular(() => {
            this.initializeMap();
        });
    }

    ngOnChanges(changes: SimpleChanges): void {
        if (changes['latitude'] || changes['longitude'] || changes['locationUrl']) {
            this.initializeFromInputs();
        }
        if (changes['readonly']) {
            this.updateMarkerDraggability();
        }
    }

    ngOnDestroy(): void {
        if (this.searchDebounceTimeout) {
            clearTimeout(this.searchDebounceTimeout);
        }
        if (this.formControlSubscription) {
            this.formControlSubscription.unsubscribe();
            this.formControlSubscription = null;
        }
        if (this.map) {
            this.map.remove();
            this.map = null;
        }
        this.marker = null;
    }

    onSearchFocus(): void {
        this.searchFocused = true;
    }

    onSearchBlur(): void {
        setTimeout(() => {
            this.searchFocused = false;
            this.cdr.markForCheck();
        }, 200);
    }

    onSearchInput(event: Event): void {
        const input = event.target as HTMLInputElement;
        this.searchQuery = input.value;

        if (this.searchDebounceTimeout) {
            clearTimeout(this.searchDebounceTimeout);
        }

        if (!this.searchQuery.trim()) {
            this.searchResults = [];
            this.isSearching = false;
            this.cdr.markForCheck();
            return;
        }

        this.isSearching = true;
        this.cdr.markForCheck();

        this.searchDebounceTimeout = setTimeout(() => {
            const key = environment.locationIqToken || 'pk.8eb219bf6bd5a83ccf8c37d6e76cf0e3';
            const url = `https://us1.locationiq.com/v1/search?key=${key}&q=${encodeURIComponent(this.searchQuery)}&format=json&limit=5`;
            
            fetch(url)
            .then(res => res.json())
            .then(data => {
                this.searchResults = data || [];
                this.isSearching = false;
                this.cdr.markForCheck();
            })
            .catch(() => {
                this.searchResults = [];
                this.isSearching = false;
                this.cdr.markForCheck();
            });
        }, 500);
    }

    selectSearchResult(result: any): void {
        const lat = Number.parseFloat(result.lat);
        const lng = Number.parseFloat(result.lon);

        if (!isNaN(lat) && !isNaN(lng)) {
            this.searchQuery = result.display_name;
            this.searchResults = [];
            this.setLocation(lat, lng);
            this.zoom = this.markerZoom;
            if (this.map) {
                this.map.setView([lat, lng], this.zoom);
            }
            this.cdr.markForCheck();
        }
    }

    onCoordBlur(): void {
        this.parseCoordinateInput();
        this.coordFocused = false;
    }

    onCoordinateInputChange(value: string): void {
        this.coordinateInput = value;
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
                if (this.map) {
                    this.map.setView([lat, lng], this.zoom);
                }
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

    private getCustomIcon(): L.DivIcon {
        const svgPin = `
            <svg width="32" height="42" viewBox="0 0 32 42" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M16 0C7.16 0 0 7.16 0 16C0 26.8 16 42 16 42C16 42 32 26.8 32 16C32 7.16 24.84 0 16 0ZM16 22C12.68 22 10 19.32 10 16C10 12.68 12.68 10 16 10C19.32 10 22 12.68 22 16C22 19.32 19.32 22 16 22Z" fill="#ea4335" stroke="#ffffff" stroke-width="1.5"/>
            </svg>
        `;
        return L.divIcon({
            html: svgPin,
            className: 'custom-map-marker',
            iconSize: [32, 42],
            iconAnchor: [16, 42]
        });
    }

    private initializeMap(): void {
        if (!this.mapContainer?.nativeElement) return;

        const element = this.mapContainer.nativeElement;
        const initialCenter = this.getCoordinates() ?? { lat: this.center.lat, lng: this.center.lng };

        this.map = L.map(element, {
            center: [initialCenter.lat, initialCenter.lng],
            zoom: this.zoom,
            zoomControl: true,
            attributionControl: true
        });

        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            maxZoom: 19,
            attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
        }).addTo(this.map);

        if (this.getCoordinates()) {
            this.createMarker(initialCenter.lat, initialCenter.lng);
        }

        if (!this.readonly) {
            this.map.on('click', (event: L.LeafletMouseEvent) => {
                this.ngZone.run(() => {
                    this.setLocation(event.latlng.lat, event.latlng.lng);
                });
            });
        }

        setTimeout(() => {
            if (this.map) {
                this.map.invalidateSize();
            }
        }, 200);
    }

    private createMarker(lat: number, lng: number): void {
        if (this.marker) {
            this.marker.setLatLng([lat, lng]);
            return;
        }

        if (!this.map) return;

        this.marker = L.marker([lat, lng], {
            icon: this.getCustomIcon(),
            draggable: !this.readonly
        }).addTo(this.map);

        if (!this.readonly) {
            this.marker.on('dragend', (event: any) => {
                const position = event.target.getLatLng();
                this.ngZone.run(() => {
                    this.setLocation(position.lat, position.lng);
                });
            });
        }
    }

    private updateMarkerDraggability(): void {
        if (this.marker) {
            if (this.readonly) {
                this.marker.dragging?.disable();
            } else {
                this.marker.dragging?.enable();
            }
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
            this.updateMapView(coords.lat, coords.lng, this.zoom);
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
                    this.updateMapView(coords.lat, coords.lng, this.zoom);
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

        this.updateMapView(lat, lng, this.markerZoom);

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

    private updateMapView(lat: number, lng: number, zoom: number): void {
        if (this.map) {
            const position: L.LatLngExpression = [lat, lng];
            this.map.setView(position, zoom);
            if (this.marker) {
                this.marker.setLatLng(position);
            } else {
                this.createMarker(lat, lng);
            }
        }
    }
}
