using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Infrastructure.Data.Configurations;

public class RentableItemConfiguration : IEntityTypeConfiguration<RentableItem>
{
    public void Configure(EntityTypeBuilder<RentableItem> builder)
    {
        builder.ToTable("RentableItems");

        builder.HasKey(r => r.Id);

        builder.Property(r => r.Title)
            .IsRequired()
            .HasMaxLength(200);

        builder.Property(r => r.Description)
            .IsRequired()
            .HasMaxLength(4000);

        builder.Property(r => r.ShortDescription)
            .HasMaxLength(500);

        builder.Property(r => r.PricePerDay)
            .HasPrecision(18, 2);

        builder.Property(r => r.PricePerWeek)
            .HasPrecision(18, 2);

        builder.Property(r => r.PricePerMonth)
            .HasPrecision(18, 2);

        builder.Property(r => r.SecurityDeposit)
            .HasPrecision(18, 2);

        builder.Property(r => r.DeliveryFee)
            .HasPrecision(18, 2);

        builder.Property(r => r.Location)
            .HasMaxLength(500);

        builder.Property(r => r.City)
            .HasMaxLength(100);

        builder.Property(r => r.Country)
            .HasMaxLength(100);

        builder.Property(r => r.Terms)
            .HasMaxLength(2000);

        builder.Property(r => r.CancellationPolicy)
            .HasMaxLength(2000);

        builder.HasOne(r => r.Owner)
            .WithMany(u => u.OwnedItems)
            .HasForeignKey(r => r.OwnerId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(r => r.Category)
            .WithMany()
            .HasForeignKey(r => r.CategoryId)
            .OnDelete(DeleteBehavior.SetNull);

        builder.HasOne(r => r.Subcategory)
            .WithMany()
            .HasForeignKey(r => r.SubcategoryId)
            .OnDelete(DeleteBehavior.SetNull);

        builder.HasIndex(r => r.OwnerId);
        builder.HasIndex(r => r.Status);
        builder.HasIndex(r => r.CategoryId);
        builder.HasIndex(r => r.City);
        builder.HasIndex(r => r.Country);
        builder.HasIndex(r => new { r.Status, r.City });
    }
}
