using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class UpdateSubcategorySchema : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Description",
                table: "ProductSubcategories",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<Guid>(
                name: "LogoId",
                table: "ProductSubcategories",
                type: "uuid",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_ProductSubcategories_LogoId",
                table: "ProductSubcategories",
                column: "LogoId");

            migrationBuilder.AddForeignKey(
                name: "FK_ProductSubcategories_MediaFiles_LogoId",
                table: "ProductSubcategories",
                column: "LogoId",
                principalTable: "MediaFiles",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_ProductSubcategories_MediaFiles_LogoId",
                table: "ProductSubcategories");

            migrationBuilder.DropIndex(
                name: "IX_ProductSubcategories_LogoId",
                table: "ProductSubcategories");

            migrationBuilder.DropColumn(
                name: "Description",
                table: "ProductSubcategories");

            migrationBuilder.DropColumn(
                name: "LogoId",
                table: "ProductSubcategories");
        }
    }
}
