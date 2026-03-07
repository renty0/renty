using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Infrastructure.Data.Configurations;

public class ProductSubcategoryConfiguration : IEntityTypeConfiguration<ProductSubcategory>
{
    public void Configure(EntityTypeBuilder<ProductSubcategory> builder)
    {
        builder.ToTable("ProductSubcategories");

        builder.HasKey(s => s.Id);

        builder.Property(s => s.NameEn)
            .IsRequired()
            .HasMaxLength(100);

        builder.Property(s => s.NameAr)
            .IsRequired()
            .HasMaxLength(100);

        builder.Property(s => s.DescEn)
            .HasMaxLength(2000);

        builder.Property(s => s.DescAr)
            .HasMaxLength(2000);

        builder.HasOne(s => s.Category)
            .WithMany(c => c.Subcategories)
            .HasForeignKey(s => s.ProductCategoryId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasIndex(s => s.NameEn);
        builder.HasIndex(s => s.NameAr);
        builder.HasIndex(s => s.ProductCategoryId);
    }
}
