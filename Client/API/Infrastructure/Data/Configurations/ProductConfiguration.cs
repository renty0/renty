using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Infrastructure.Data.Configurations;

public class ProductConfiguration : IEntityTypeConfiguration<Product>
{
    public void Configure(EntityTypeBuilder<Product> builder)
    {
        builder.ToTable("Products");

        builder.HasKey(p => p.Id);

        builder.Property(p => p.ProductSku)
            .IsRequired()
            .HasMaxLength(50);

        builder.Property(p => p.ProductName)
            .IsRequired()
            .HasMaxLength(200);

        builder.Property(p => p.ModelName)
            .HasMaxLength(100);

        builder.Property(p => p.ProductDescription)
            .HasMaxLength(1000);

        builder.Property(p => p.ProductColor)
            .HasMaxLength(50);

        builder.Property(p => p.ProductStyle)
            .HasMaxLength(50);

        builder.Property(p => p.ProductCost)
            .HasPrecision(18, 2);

        builder.Property(p => p.ProductPrice)
            .HasPrecision(18, 2);

        builder.Property(p => p.DiscountPrice)
            .HasPrecision(18, 2);

        builder.Property(p => p.SkuType)
            .HasMaxLength(50);

        builder.HasOne(p => p.Subcategory)
            .WithMany(s => s.Products)
            .HasForeignKey(p => p.ProductSubcategoryId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.Ignore(p => p.EffectivePrice);
        builder.Ignore(p => p.ProfitMargin);

        builder.HasIndex(p => p.ProductSku).IsUnique();
        builder.HasIndex(p => p.ProductName);
        builder.HasIndex(p => p.ProductSubcategoryId);
    }
}
