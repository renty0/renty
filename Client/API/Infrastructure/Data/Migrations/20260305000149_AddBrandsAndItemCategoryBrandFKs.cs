using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddBrandsAndItemCategoryBrandFKs : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "brand_id",
                table: "items",
                type: "integer",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "category_id",
                table: "items",
                type: "integer",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "brands",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Description = table.Column<string>(type: "text", nullable: true),
                    LogoUrl = table.Column<string>(type: "text", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_brands", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_items_brand_id",
                table: "items",
                column: "brand_id");

            migrationBuilder.CreateIndex(
                name: "IX_items_category_id",
                table: "items",
                column: "category_id");

            migrationBuilder.AddForeignKey(
                name: "FK_items_ProductCategories_category_id",
                table: "items",
                column: "category_id",
                principalTable: "ProductCategories",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_items_brands_brand_id",
                table: "items",
                column: "brand_id",
                principalTable: "brands",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_items_ProductCategories_category_id",
                table: "items");

            migrationBuilder.DropForeignKey(
                name: "FK_items_brands_brand_id",
                table: "items");

            migrationBuilder.DropTable(
                name: "brands");

            migrationBuilder.DropIndex(
                name: "IX_items_brand_id",
                table: "items");

            migrationBuilder.DropIndex(
                name: "IX_items_category_id",
                table: "items");

            migrationBuilder.DropColumn(
                name: "brand_id",
                table: "items");

            migrationBuilder.DropColumn(
                name: "category_id",
                table: "items");
        }
    }
}
