using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Infrastructure.Data.Configurations;

public class SaleConfiguration : IEntityTypeConfiguration<Sale>
{
    public void Configure(EntityTypeBuilder<Sale> builder)
    {
        builder.ToTable("Sales");

        builder.HasKey(s => s.Id);

        builder.Property(s => s.OrderNumber)
            .IsRequired()
            .HasMaxLength(50);

        builder.HasOne(s => s.Product)
            .WithMany(p => p.Sales)
            .HasForeignKey(s => s.ProductId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(s => s.Customer)
            .WithMany(c => c.Sales)
            .HasForeignKey(s => s.CustomerId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(s => s.Territory)
            .WithMany(t => t.Sales)
            .HasForeignKey(s => s.TerritoryId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(s => s.OrderCalendar)
            .WithMany(c => c.OrderSales)
            .HasForeignKey(s => s.OrderDate)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(s => s.StockCalendar)
            .WithMany(c => c.StockSales)
            .HasForeignKey(s => s.StockDate)
            .OnDelete(DeleteBehavior.Restrict);

        builder.Ignore(s => s.LineTotal);

        builder.HasIndex(s => s.OrderNumber);
        builder.HasIndex(s => s.OrderDate);
        builder.HasIndex(s => s.ProductId);
        builder.HasIndex(s => s.CustomerId);
        builder.HasIndex(s => s.TerritoryId);
        builder.HasIndex(s => new { s.OrderDate, s.TerritoryId });
    }
}
