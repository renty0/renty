using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddItemSubcategoryId : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "subcategory_id",
                table: "items",
                type: "integer",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_items_subcategory_id",
                table: "items",
                column: "subcategory_id");

            migrationBuilder.AddForeignKey(
                name: "FK_items_ProductSubcategories_subcategory_id",
                table: "items",
                column: "subcategory_id",
                principalTable: "ProductSubcategories",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_items_ProductSubcategories_subcategory_id",
                table: "items");

            migrationBuilder.DropIndex(
                name: "IX_items_subcategory_id",
                table: "items");

            migrationBuilder.DropColumn(
                name: "subcategory_id",
                table: "items");
        }
    }
}
