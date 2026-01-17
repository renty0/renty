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

        builder.Property(s => s.SubcategoryName)
            .IsRequired()
            .HasMaxLength(100);

        builder.HasOne(s => s.Category)
            .WithMany(c => c.Subcategories)
            .HasForeignKey(s => s.ProductCategoryId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasIndex(s => s.SubcategoryName);
        builder.HasIndex(s => s.ProductCategoryId);
    }
}
