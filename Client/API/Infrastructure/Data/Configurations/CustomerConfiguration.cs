using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Infrastructure.Data.Configurations;

public class CustomerConfiguration : IEntityTypeConfiguration<Customer>
{
    public void Configure(EntityTypeBuilder<Customer> builder)
    {
        builder.ToTable("Customers");

        builder.HasKey(c => c.Id);

        builder.Property(c => c.Prefix)
            .HasMaxLength(10);

        builder.Property(c => c.FirstName)
            .IsRequired()
            .HasMaxLength(100);

        builder.Property(c => c.LastName)
            .IsRequired()
            .HasMaxLength(100);

        builder.Property(c => c.MaritalStatus)
            .HasMaxLength(20);

        builder.Property(c => c.Gender)
            .HasMaxLength(10);

        builder.Property(c => c.EmailAddress)
            .HasMaxLength(256);

        builder.Property(c => c.AnnualIncome)
            .HasPrecision(18, 2);

        builder.Property(c => c.EducationLevel)
            .HasMaxLength(50);

        builder.Property(c => c.Occupation)
            .HasMaxLength(100);

        builder.Ignore(c => c.FullName);

        builder.HasIndex(c => c.EmailAddress);
        builder.HasIndex(c => new { c.LastName, c.FirstName });
    }
}
