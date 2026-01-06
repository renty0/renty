using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Infrastructure.Data.Configurations;

public class RentRequestConfiguration : IEntityTypeConfiguration<RentRequest>
{
    public void Configure(EntityTypeBuilder<RentRequest> builder)
    {
        builder.ToTable("RentRequests");

        builder.HasKey(r => r.Id);

        builder.Property(r => r.DailyRate)
            .HasPrecision(18, 2);

        builder.Property(r => r.TotalAmount)
            .HasPrecision(18, 2);

        builder.Property(r => r.SecurityDeposit)
            .HasPrecision(18, 2);

        builder.Property(r => r.DeliveryFee)
            .HasPrecision(18, 2);

        builder.Property(r => r.GrandTotal)
            .HasPrecision(18, 2);

        builder.Property(r => r.Message)
            .HasMaxLength(1000);

        builder.Property(r => r.OwnerResponse)
            .HasMaxLength(1000);

        builder.Property(r => r.CancellationReason)
            .HasMaxLength(500);

        builder.Property(r => r.DeliveryAddress)
            .HasMaxLength(500);

        builder.Property(r => r.PickupInstructions)
            .HasMaxLength(1000);

        builder.HasOne(r => r.RentableItem)
            .WithMany(i => i.RentRequests)
            .HasForeignKey(r => r.RentableItemId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(r => r.Renter)
            .WithMany(u => u.RentRequestsAsRenter)
            .HasForeignKey(r => r.RenterId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.Ignore(r => r.CanBeCancelled);
        builder.Ignore(r => r.CanBeApproved);
        builder.Ignore(r => r.IsActive);

        builder.HasIndex(r => r.RentableItemId);
        builder.HasIndex(r => r.RenterId);
        builder.HasIndex(r => r.Status);
        builder.HasIndex(r => r.StartDate);
        builder.HasIndex(r => new { r.RentableItemId, r.Status });
        builder.HasIndex(r => new { r.RenterId, r.Status });
    }
}
