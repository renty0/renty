namespace Domain.Entities;

/// <summary>Matches the `reviews` table. One review per rental (UNIQUE on rental_id).</summary>
public class Review
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid RentalId { get; set; }
    public long ReviewerId { get; set; }
    public int Rating { get; set; }   // 1–5
    public string? Comment { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation
    public Rental Rental { get; set; } = null!;
    public ApplicationUser Reviewer { get; set; } = null!;
}
