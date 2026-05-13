using Domain.Enums;
using Microsoft.AspNetCore.Identity;

namespace Domain.Entities;

public class ApplicationUser : IdentityUser<long>
{
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string? ProfilePictureUrl { get; set; }
    public string? Address { get; set; }
    public string? City { get; set; }
    public string? Country { get; set; }
    public string? Bio { get; set; }
    public double Rating { get; set; } = 0;
    public int TotalRatings { get; set; } = 0;
    public bool IsActive { get; set; } = true;
    public bool IsVerified { get; set; } = false;
    public bool IdVerified { get; set; } = false;
    public bool PhoneVerified { get; set; } = false;
    public double FraudScore { get; set; } = 0.0;
    public decimal WalletBalance { get; set; } = 0.0m;
    public DateTimeOffset CreatedAt { get; set; } = DateTimeOffset.UtcNow;
    public DateTimeOffset? LastLoginAt { get; set; }

    public string FullName => $"{FirstName} {LastName}".Trim();

    // Navigation properties
    public virtual ICollection<RefreshToken> RefreshTokens { get; set; } = new List<RefreshToken>();
    public virtual ICollection<RentableItem> OwnedItems { get; set; } = new List<RentableItem>();
    public virtual ICollection<Item> Items { get; set; } = new List<Item>();
    public virtual ICollection<RentRequest> RentRequestsAsRenter { get; set; } = new List<RentRequest>();
}
