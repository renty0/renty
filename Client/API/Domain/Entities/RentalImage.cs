using Domain.Enums;

namespace Domain.Entities;

public enum RentalImageType
{
    Handover = 1,
    Return = 2
}

public class RentalImage
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid RentalId { get; set; }
    public Guid ImageId { get; set; }
    public virtual MediaFile Image { get; set; } = null!;
    public RentalImageType Type { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation
    public Rental Rental { get; set; } = null!;
}
