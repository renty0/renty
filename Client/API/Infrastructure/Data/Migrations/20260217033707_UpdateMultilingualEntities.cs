using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class UpdateMultilingualEntities : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Description",
                table: "ProductSubcategories");

            migrationBuilder.DropColumn(
                name: "Description",
                table: "ProductCategories");

            migrationBuilder.RenameColumn(
                name: "SubcategoryName",
                table: "ProductSubcategories",
                newName: "NameEn");

            migrationBuilder.RenameIndex(
                name: "IX_ProductSubcategories_SubcategoryName",
                table: "ProductSubcategories",
                newName: "IX_ProductSubcategories_NameEn");

            migrationBuilder.RenameColumn(
                name: "ProductStyle",
                table: "Products",
                newName: "Style");

            migrationBuilder.RenameColumn(
                name: "ProductPrice",
                table: "Products",
                newName: "RentPricePerDay");

            migrationBuilder.RenameColumn(
                name: "ProductName",
                table: "Products",
                newName: "NameEn");

            migrationBuilder.RenameColumn(
                name: "ProductDescription",
                table: "Products",
                newName: "DescriptionEn");

            migrationBuilder.RenameColumn(
                name: "ProductColor",
                table: "Products",
                newName: "Color");

            migrationBuilder.RenameColumn(
                name: "DiscountPrice",
                table: "Products",
                newName: "RentDiscountPrice");

            migrationBuilder.RenameIndex(
                name: "IX_Products_ProductName",
                table: "Products",
                newName: "IX_Products_NameEn");

            migrationBuilder.RenameColumn(
                name: "CategoryName",
                table: "ProductCategories",
                newName: "NameEn");

            migrationBuilder.RenameIndex(
                name: "IX_ProductCategories_CategoryName",
                table: "ProductCategories",
                newName: "IX_ProductCategories_NameEn");

            migrationBuilder.AddColumn<string>(
                name: "DescriptionAr",
                table: "ProductSubcategories",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "DescriptionEn",
                table: "ProductSubcategories",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "NameAr",
                table: "ProductSubcategories",
                type: "character varying(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<int>(
                name: "BrandId",
                table: "Products",
                type: "integer",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "BrandId1",
                table: "Products",
                type: "bigint",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "DescriptionAr",
                table: "Products",
                type: "character varying(1000)",
                maxLength: 1000,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "NameAr",
                table: "Products",
                type: "character varying(200)",
                maxLength: 200,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "DescriptionAr",
                table: "ProductCategories",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "DescriptionEn",
                table: "ProductCategories",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "NameAr",
                table: "ProductCategories",
                type: "character varying(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "");

            migrationBuilder.CreateTable(
                name: "Brands",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    NameEn = table.Column<string>(type: "text", nullable: false),
                    NameAr = table.Column<string>(type: "text", nullable: false),
                    DescriptionEn = table.Column<string>(type: "text", nullable: true),
                    DescriptionAr = table.Column<string>(type: "text", nullable: true),
                    LogoId = table.Column<Guid>(type: "uuid", nullable: true),
                    Created = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    CreatedBy = table.Column<string>(type: "text", nullable: true),
                    LastModified = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    LastModifiedBy = table.Column<string>(type: "text", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Brands", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Brands_MediaFiles_LogoId",
                        column: x => x.LogoId,
                        principalTable: "MediaFiles",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateIndex(
                name: "IX_Products_BrandId1",
                table: "Products",
                column: "BrandId1");

            migrationBuilder.CreateIndex(
                name: "IX_Brands_LogoId",
                table: "Brands",
                column: "LogoId");

            migrationBuilder.AddForeignKey(
                name: "FK_Products_Brands_BrandId1",
                table: "Products",
                column: "BrandId1",
                principalTable: "Brands",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Products_Brands_BrandId1",
                table: "Products");

            migrationBuilder.DropTable(
                name: "Brands");

            migrationBuilder.DropIndex(
                name: "IX_Products_BrandId1",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "DescriptionAr",
                table: "ProductSubcategories");

            migrationBuilder.DropColumn(
                name: "DescriptionEn",
                table: "ProductSubcategories");

            migrationBuilder.DropColumn(
                name: "NameAr",
                table: "ProductSubcategories");

            migrationBuilder.DropColumn(
                name: "BrandId",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "BrandId1",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "DescriptionAr",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "NameAr",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "DescriptionAr",
                table: "ProductCategories");

            migrationBuilder.DropColumn(
                name: "DescriptionEn",
                table: "ProductCategories");

            migrationBuilder.DropColumn(
                name: "NameAr",
                table: "ProductCategories");

            migrationBuilder.RenameColumn(
                name: "NameEn",
                table: "ProductSubcategories",
                newName: "SubcategoryName");

            migrationBuilder.RenameIndex(
                name: "IX_ProductSubcategories_NameEn",
                table: "ProductSubcategories",
                newName: "IX_ProductSubcategories_SubcategoryName");

            migrationBuilder.RenameColumn(
                name: "Style",
                table: "Products",
                newName: "ProductStyle");

            migrationBuilder.RenameColumn(
                name: "RentPricePerDay",
                table: "Products",
                newName: "ProductPrice");

            migrationBuilder.RenameColumn(
                name: "RentDiscountPrice",
                table: "Products",
                newName: "DiscountPrice");

            migrationBuilder.RenameColumn(
                name: "NameEn",
                table: "Products",
                newName: "ProductName");

            migrationBuilder.RenameColumn(
                name: "DescriptionEn",
                table: "Products",
                newName: "ProductDescription");

            migrationBuilder.RenameColumn(
                name: "Color",
                table: "Products",
                newName: "ProductColor");

            migrationBuilder.RenameIndex(
                name: "IX_Products_NameEn",
                table: "Products",
                newName: "IX_Products_ProductName");

            migrationBuilder.RenameColumn(
                name: "NameEn",
                table: "ProductCategories",
                newName: "CategoryName");

            migrationBuilder.RenameIndex(
                name: "IX_ProductCategories_NameEn",
                table: "ProductCategories",
                newName: "IX_ProductCategories_CategoryName");

            migrationBuilder.AddColumn<string>(
                name: "Description",
                table: "ProductSubcategories",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "Description",
                table: "ProductCategories",
                type: "text",
                nullable: false,
                defaultValue: "");
        }
    }
}
