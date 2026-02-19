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

        builder.Property(p => p.NameEn)
            .IsRequired()
            .HasMaxLength(200);

        builder.Property(p => p.NameAr)
            .HasMaxLength(200);

        builder.Property(p => p.ModelName)
            .HasMaxLength(100);

        builder.Property(p => p.DescriptionEn)
            .HasMaxLength(1000);

        builder.Property(p => p.DescriptionAr)
            .HasMaxLength(1000);

        builder.Property(p => p.Color)
            .HasMaxLength(50);

        builder.Property(p => p.Style)
            .HasMaxLength(50);

        builder.Property(p => p.ProductCost)
            .HasPrecision(18, 2);

        builder.Property(p => p.RentPricePerDay)
            .HasPrecision(18, 2);

        builder.Property(p => p.RentDiscountPrice)
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
        builder.HasIndex(p => p.NameEn);
        builder.HasIndex(p => p.ProductSubcategoryId);
    }
}
