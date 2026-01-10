using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddCategoryLogoAndDescription : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Description",
                table: "ProductCategories",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<Guid>(
                name: "LogoId",
                table: "ProductCategories",
                type: "uuid",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_ProductCategories_LogoId",
                table: "ProductCategories",
                column: "LogoId");

            migrationBuilder.AddForeignKey(
                name: "FK_ProductCategories_MediaFiles_LogoId",
                table: "ProductCategories",
                column: "LogoId",
                principalTable: "MediaFiles",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_ProductCategories_MediaFiles_LogoId",
                table: "ProductCategories");

            migrationBuilder.DropIndex(
                name: "IX_ProductCategories_LogoId",
                table: "ProductCategories");

            migrationBuilder.DropColumn(
                name: "Description",
                table: "ProductCategories");

            migrationBuilder.DropColumn(
                name: "LogoId",
                table: "ProductCategories");
        }
    }
}
