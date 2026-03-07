using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddLocalizationFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "DescAr",
                table: "ProductSubcategories",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "DescEn",
                table: "ProductSubcategories",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "NameAr",
                table: "ProductSubcategories",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "NameEn",
                table: "ProductSubcategories",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "DescAr",
                table: "ProductCategories",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "DescEn",
                table: "ProductCategories",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "NameAr",
                table: "ProductCategories",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "NameEn",
                table: "ProductCategories",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "DescriptionAr",
                table: "items",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "DescriptionEn",
                table: "items",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "TitleAr",
                table: "items",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "TitleEn",
                table: "items",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "DescAr",
                table: "brands",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "DescEn",
                table: "brands",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "NameAr",
                table: "brands",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "NameEn",
                table: "brands",
                type: "text",
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "DescAr",
                table: "ProductSubcategories");

            migrationBuilder.DropColumn(
                name: "DescEn",
                table: "ProductSubcategories");

            migrationBuilder.DropColumn(
                name: "NameAr",
                table: "ProductSubcategories");

            migrationBuilder.DropColumn(
                name: "NameEn",
                table: "ProductSubcategories");

            migrationBuilder.DropColumn(
                name: "DescAr",
                table: "ProductCategories");

            migrationBuilder.DropColumn(
                name: "DescEn",
                table: "ProductCategories");

            migrationBuilder.DropColumn(
                name: "NameAr",
                table: "ProductCategories");

            migrationBuilder.DropColumn(
                name: "NameEn",
                table: "ProductCategories");

            migrationBuilder.DropColumn(
                name: "DescriptionAr",
                table: "items");

            migrationBuilder.DropColumn(
                name: "DescriptionEn",
                table: "items");

            migrationBuilder.DropColumn(
                name: "TitleAr",
                table: "items");

            migrationBuilder.DropColumn(
                name: "TitleEn",
                table: "items");

            migrationBuilder.DropColumn(
                name: "DescAr",
                table: "brands");

            migrationBuilder.DropColumn(
                name: "DescEn",
                table: "brands");

            migrationBuilder.DropColumn(
                name: "NameAr",
                table: "brands");

            migrationBuilder.DropColumn(
                name: "NameEn",
                table: "brands");
        }
    }
}
