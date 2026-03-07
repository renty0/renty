using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Infrastructure.Data.Configurations;

public class ProductCategoryConfiguration : IEntityTypeConfiguration<ProductCategory>
{
    public void Configure(EntityTypeBuilder<ProductCategory> builder)
    {
        builder.ToTable("ProductCategories");

        builder.HasKey(c => c.Id);

        builder.Property(c => c.NameEn)
            .IsRequired()
            .HasMaxLength(100);

        builder.Property(c => c.NameAr)
            .IsRequired()
            .HasMaxLength(100);

        builder.Property(c => c.DescEn)
            .HasMaxLength(2000);

        builder.Property(c => c.DescAr)
            .HasMaxLength(2000);

        builder.Property(c => c.LogoId);

        builder.Property(c => c.Created);

        builder.Property(c => c.CreatedBy);

        builder.Property(c => c.LastModified);

        builder.Property(c => c.LastModifiedBy);

        builder.HasIndex(c => c.NameEn)
            .IsUnique()
            .HasDatabaseName("IX_ProductCategories_NameEn");
        
        builder.HasIndex(c => c.NameAr)
            .IsUnique()
            .HasDatabaseName("IX_ProductCategories_NameAr");
    }
}
