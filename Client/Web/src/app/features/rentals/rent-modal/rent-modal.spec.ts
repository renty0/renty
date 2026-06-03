import { ComponentFixture, TestBed } from '@angular/core/testing';

import { RentModalComponent } from './rent-modal';

describe('RentModalComponent', () => {
  let component: RentModalComponent;
  let fixture: ComponentFixture<RentModalComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [RentModalComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(RentModalComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
