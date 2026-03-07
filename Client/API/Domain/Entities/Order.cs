using Domain.Enums;

namespace Domain.Entities;

/// <summary>Matches the `orders` table.</summary>
public class Order
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public long UserId { get; set; }
    public decimal? TotalAmount { get; set; }
    public OrderStatus Status { get; set; } = OrderStatus.Pending;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    // Navigation
    public ApplicationUser User { get; set; } = null!;
    public ICollection<OrderItem> Items { get; set; } = new List<OrderItem>();
    public ICollection<Payment> Payments { get; set; } = new List<Payment>();
    public ICollection<DeliveryTracking> DeliveryTrackings { get; set; } = new List<DeliveryTracking>();
    public ICollection<Rental> Rentals { get; set; } = new List<Rental>();
}

/// <summary>Matches the `order_items` table.</summary>
public class OrderItem
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid OrderId { get; set; }
    public Guid ItemId { get; set; }
    public int Quantity { get; set; } = 1;
    public decimal PriceAtTime { get; set; }

    // Navigation
    public Order Order { get; set; } = null!;
    public Item Item { get; set; } = null!;
}
