using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class SyncModelChanges : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_ProductCategories_MediaFiles_logoid",
                table: "ProductCategories");

            migrationBuilder.RenameColumn(
                name: "logoid",
                table: "ProductCategories",
                newName: "LogoId");

            migrationBuilder.RenameColumn(
                name: "lastmodifiedby",
                table: "ProductCategories",
                newName: "LastModifiedBy");

            migrationBuilder.RenameColumn(
                name: "lastmodified",
                table: "ProductCategories",
                newName: "LastModified");

            migrationBuilder.RenameColumn(
                name: "description",
                table: "ProductCategories",
                newName: "Description");

            migrationBuilder.RenameColumn(
                name: "createdby",
                table: "ProductCategories",
                newName: "CreatedBy");

            migrationBuilder.RenameColumn(
                name: "created",
                table: "ProductCategories",
                newName: "Created");

            migrationBuilder.RenameColumn(
                name: "categoryname",
                table: "ProductCategories",
                newName: "CategoryName");

            migrationBuilder.RenameIndex(
                name: "IX_ProductCategories_logoid",
                table: "ProductCategories",
                newName: "IX_ProductCategories_LogoId");

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

            migrationBuilder.RenameColumn(
                name: "LogoId",
                table: "ProductCategories",
                newName: "logoid");

            migrationBuilder.RenameColumn(
                name: "LastModifiedBy",
                table: "ProductCategories",
                newName: "lastmodifiedby");

            migrationBuilder.RenameColumn(
                name: "LastModified",
                table: "ProductCategories",
                newName: "lastmodified");

            migrationBuilder.RenameColumn(
                name: "Description",
                table: "ProductCategories",
                newName: "description");

            migrationBuilder.RenameColumn(
                name: "CreatedBy",
                table: "ProductCategories",
                newName: "createdby");

            migrationBuilder.RenameColumn(
                name: "Created",
                table: "ProductCategories",
                newName: "created");

            migrationBuilder.RenameColumn(
                name: "CategoryName",
                table: "ProductCategories",
                newName: "categoryname");

            migrationBuilder.RenameIndex(
                name: "IX_ProductCategories_LogoId",
                table: "ProductCategories",
                newName: "IX_ProductCategories_logoid");

            migrationBuilder.AddForeignKey(
                name: "FK_ProductCategories_MediaFiles_logoid",
                table: "ProductCategories",
                column: "logoid",
                principalTable: "MediaFiles",
                principalColumn: "Id");
        }
    }
}
