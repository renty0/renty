using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class RemoveLegacyFieldsAndRefactorMedia : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_ProductSubcategories_SubcategoryName",
                table: "ProductSubcategories");

            migrationBuilder.DropIndex(
                name: "IX_ProductCategories_CategoryName",
                table: "ProductCategories");

            migrationBuilder.DropColumn(
                name: "ImageUrl",
                table: "RentableItemImages");

            migrationBuilder.DropColumn(
                name: "Description",
                table: "ProductSubcategories");

            migrationBuilder.DropColumn(
                name: "SubcategoryName",
                table: "ProductSubcategories");

            migrationBuilder.DropColumn(
                name: "ProductDescription",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "ImageUrl",
                table: "ProductImages");

            migrationBuilder.DropColumn(
                name: "CategoryName",
                table: "ProductCategories");

            migrationBuilder.DropColumn(
                name: "Description",
                table: "ProductCategories");

            migrationBuilder.DropColumn(
                name: "DescriptionAr",
                table: "items");

            migrationBuilder.DropColumn(
                name: "title",
                table: "items");

            migrationBuilder.DropColumn(
                name: "image_url",
                table: "item_images");

            migrationBuilder.DropColumn(
                name: "Description",
                table: "brands");

            migrationBuilder.DropColumn(
                name: "LogoUrl",
                table: "brands");

            migrationBuilder.DropColumn(
                name: "Name",
                table: "brands");

            migrationBuilder.RenameColumn(
                name: "Title",
                table: "RentableItems",
                newName: "TitleEn");

            migrationBuilder.RenameColumn(
                name: "Description",
                table: "RentableItems",
                newName: "DescEn");

            migrationBuilder.RenameColumn(
                name: "ProductName",
                table: "Products",
                newName: "NameEn");

            migrationBuilder.RenameIndex(
                name: "IX_Products_ProductName",
                table: "Products",
                newName: "IX_Products_NameEn");

            migrationBuilder.RenameColumn(
                name: "TitleEn",
                table: "items",
                newName: "title_en");

            migrationBuilder.RenameColumn(
                name: "TitleAr",
                table: "items",
                newName: "title_ar");

            migrationBuilder.RenameColumn(
                name: "description",
                table: "items",
                newName: "desc_en");

            migrationBuilder.RenameColumn(
                name: "DescriptionEn",
                table: "items",
                newName: "desc_ar");

            migrationBuilder.AddColumn<string>(
                name: "DescAr",
                table: "RentableItems",
                type: "character varying(4000)",
                maxLength: 4000,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "TitleAr",
                table: "RentableItems",
                type: "character varying(200)",
                maxLength: 200,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<Guid>(
                name: "ImageId",
                table: "RentableItemImages",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.AlterColumn<string>(
                name: "NameEn",
                table: "ProductSubcategories",
                type: "character varying(100)",
                maxLength: 100,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "text");

            migrationBuilder.AlterColumn<string>(
                name: "NameAr",
                table: "ProductSubcategories",
                type: "character varying(100)",
                maxLength: 100,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "text");

            migrationBuilder.AlterColumn<string>(
                name: "DescEn",
                table: "ProductSubcategories",
                type: "character varying(2000)",
                maxLength: 2000,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "text",
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "DescAr",
                table: "ProductSubcategories",
                type: "character varying(2000)",
                maxLength: 2000,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "text",
                oldNullable: true);

            migrationBuilder.AddColumn<string>(
                name: "DescAr",
                table: "Products",
                type: "character varying(4000)",
                maxLength: 4000,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "DescEn",
                table: "Products",
                type: "character varying(4000)",
                maxLength: 4000,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "NameAr",
                table: "Products",
                type: "character varying(200)",
                maxLength: 200,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<Guid>(
                name: "ImageId",
                table: "ProductImages",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.AlterColumn<string>(
                name: "NameEn",
                table: "ProductCategories",
                type: "character varying(100)",
                maxLength: 100,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "text");

            migrationBuilder.AlterColumn<string>(
                name: "NameAr",
                table: "ProductCategories",
                type: "character varying(100)",
                maxLength: 100,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "text");

            migrationBuilder.AlterColumn<string>(
                name: "DescEn",
                table: "ProductCategories",
                type: "character varying(2000)",
                maxLength: 2000,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "text",
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "DescAr",
                table: "ProductCategories",
                type: "character varying(2000)",
                maxLength: 2000,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "text",
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "title_en",
                table: "items",
                type: "character varying(200)",
                maxLength: 200,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "text");

            migrationBuilder.AlterColumn<string>(
                name: "title_ar",
                table: "items",
                type: "character varying(200)",
                maxLength: 200,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "text");

            migrationBuilder.AddColumn<Guid>(
                name: "image_id",
                table: "item_images",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.AlterColumn<string>(
                name: "NameEn",
                table: "brands",
                type: "character varying(100)",
                maxLength: 100,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "text");

            migrationBuilder.AlterColumn<string>(
                name: "NameAr",
                table: "brands",
                type: "character varying(100)",
                maxLength: 100,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "text");

            migrationBuilder.AddColumn<Guid>(
                name: "LogoId",
                table: "brands",
                type: "uuid",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_RentableItemImages_ImageId",
                table: "RentableItemImages",
                column: "ImageId");

            migrationBuilder.CreateIndex(
                name: "IX_ProductSubcategories_NameAr",
                table: "ProductSubcategories",
                column: "NameAr");

            migrationBuilder.CreateIndex(
                name: "IX_ProductSubcategories_NameEn",
                table: "ProductSubcategories",
                column: "NameEn");

            migrationBuilder.CreateIndex(
                name: "IX_Products_NameAr",
                table: "Products",
                column: "NameAr");

            migrationBuilder.CreateIndex(
                name: "IX_ProductImages_ImageId",
                table: "ProductImages",
                column: "ImageId");

            migrationBuilder.CreateIndex(
                name: "IX_ProductCategories_NameAr",
                table: "ProductCategories",
                column: "NameAr",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_ProductCategories_NameEn",
                table: "ProductCategories",
                column: "NameEn",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_item_images_image_id",
                table: "item_images",
                column: "image_id");

            migrationBuilder.CreateIndex(
                name: "IX_brands_LogoId",
                table: "brands",
                column: "LogoId");

            migrationBuilder.AddForeignKey(
                name: "FK_brands_MediaFiles_LogoId",
                table: "brands",
                column: "LogoId",
                principalTable: "MediaFiles",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_item_images_MediaFiles_image_id",
                table: "item_images",
                column: "image_id",
                principalTable: "MediaFiles",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_ProductImages_MediaFiles_ImageId",
                table: "ProductImages",
                column: "ImageId",
                principalTable: "MediaFiles",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_RentableItemImages_MediaFiles_ImageId",
                table: "RentableItemImages",
                column: "ImageId",
                principalTable: "MediaFiles",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_brands_MediaFiles_LogoId",
                table: "brands");

            migrationBuilder.DropForeignKey(
                name: "FK_item_images_MediaFiles_image_id",
                table: "item_images");

            migrationBuilder.DropForeignKey(
                name: "FK_ProductImages_MediaFiles_ImageId",
                table: "ProductImages");

            migrationBuilder.DropForeignKey(
                name: "FK_RentableItemImages_MediaFiles_ImageId",
                table: "RentableItemImages");

            migrationBuilder.DropIndex(
                name: "IX_RentableItemImages_ImageId",
                table: "RentableItemImages");

            migrationBuilder.DropIndex(
                name: "IX_ProductSubcategories_NameAr",
                table: "ProductSubcategories");

            migrationBuilder.DropIndex(
                name: "IX_ProductSubcategories_NameEn",
                table: "ProductSubcategories");

            migrationBuilder.DropIndex(
                name: "IX_Products_NameAr",
                table: "Products");

            migrationBuilder.DropIndex(
                name: "IX_ProductImages_ImageId",
                table: "ProductImages");

            migrationBuilder.DropIndex(
                name: "IX_ProductCategories_NameAr",
                table: "ProductCategories");

            migrationBuilder.DropIndex(
                name: "IX_ProductCategories_NameEn",
                table: "ProductCategories");

            migrationBuilder.DropIndex(
                name: "IX_item_images_image_id",
                table: "item_images");

            migrationBuilder.DropIndex(
                name: "IX_brands_LogoId",
                table: "brands");

            migrationBuilder.DropColumn(
                name: "DescAr",
                table: "RentableItems");

            migrationBuilder.DropColumn(
                name: "TitleAr",
                table: "RentableItems");

            migrationBuilder.DropColumn(
                name: "ImageId",
                table: "RentableItemImages");

            migrationBuilder.DropColumn(
                name: "DescAr",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "DescEn",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "NameAr",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "ImageId",
                table: "ProductImages");

            migrationBuilder.DropColumn(
                name: "image_id",
                table: "item_images");

            migrationBuilder.DropColumn(
                name: "LogoId",
                table: "brands");

            migrationBuilder.RenameColumn(
                name: "TitleEn",
                table: "RentableItems",
                newName: "Title");

            migrationBuilder.RenameColumn(
                name: "DescEn",
                table: "RentableItems",
                newName: "Description");

            migrationBuilder.RenameColumn(
                name: "NameEn",
                table: "Products",
                newName: "ProductName");

            migrationBuilder.RenameIndex(
                name: "IX_Products_NameEn",
                table: "Products",
                newName: "IX_Products_ProductName");

            migrationBuilder.RenameColumn(
                name: "title_en",
                table: "items",
                newName: "TitleEn");

            migrationBuilder.RenameColumn(
                name: "title_ar",
                table: "items",
                newName: "TitleAr");

            migrationBuilder.RenameColumn(
                name: "desc_en",
                table: "items",
                newName: "description");

            migrationBuilder.RenameColumn(
                name: "desc_ar",
                table: "items",
                newName: "DescriptionEn");

            migrationBuilder.AddColumn<string>(
                name: "ImageUrl",
                table: "RentableItemImages",
                type: "character varying(1000)",
                maxLength: 1000,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AlterColumn<string>(
                name: "NameEn",
                table: "ProductSubcategories",
                type: "text",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "character varying(100)",
                oldMaxLength: 100);

            migrationBuilder.AlterColumn<string>(
                name: "NameAr",
                table: "ProductSubcategories",
                type: "text",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "character varying(100)",
                oldMaxLength: 100);

            migrationBuilder.AlterColumn<string>(
                name: "DescEn",
                table: "ProductSubcategories",
                type: "text",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "character varying(2000)",
                oldMaxLength: 2000,
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "DescAr",
                table: "ProductSubcategories",
                type: "text",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "character varying(2000)",
                oldMaxLength: 2000,
                oldNullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Description",
                table: "ProductSubcategories",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "SubcategoryName",
                table: "ProductSubcategories",
                type: "character varying(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "ProductDescription",
                table: "Products",
                type: "character varying(1000)",
                maxLength: 1000,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ImageUrl",
                table: "ProductImages",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AlterColumn<string>(
                name: "NameEn",
                table: "ProductCategories",
                type: "text",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "character varying(100)",
                oldMaxLength: 100);

            migrationBuilder.AlterColumn<string>(
                name: "NameAr",
                table: "ProductCategories",
                type: "text",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "character varying(100)",
                oldMaxLength: 100);

            migrationBuilder.AlterColumn<string>(
                name: "DescEn",
                table: "ProductCategories",
                type: "text",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "character varying(2000)",
                oldMaxLength: 2000,
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "DescAr",
                table: "ProductCategories",
                type: "text",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "character varying(2000)",
                oldMaxLength: 2000,
                oldNullable: true);

            migrationBuilder.AddColumn<string>(
                name: "CategoryName",
                table: "ProductCategories",
                type: "character varying(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "Description",
                table: "ProductCategories",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AlterColumn<string>(
                name: "TitleEn",
                table: "items",
                type: "text",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "character varying(200)",
                oldMaxLength: 200);

            migrationBuilder.AlterColumn<string>(
                name: "TitleAr",
                table: "items",
                type: "text",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "character varying(200)",
                oldMaxLength: 200);

            migrationBuilder.AddColumn<string>(
                name: "DescriptionAr",
                table: "items",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "title",
                table: "items",
                type: "character varying(200)",
                maxLength: 200,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "image_url",
                table: "item_images",
                type: "character varying(500)",
                maxLength: 500,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AlterColumn<string>(
                name: "NameEn",
                table: "brands",
                type: "text",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "character varying(100)",
                oldMaxLength: 100);

            migrationBuilder.AlterColumn<string>(
                name: "NameAr",
                table: "brands",
                type: "text",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "character varying(100)",
                oldMaxLength: 100);

            migrationBuilder.AddColumn<string>(
                name: "Description",
                table: "brands",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "LogoUrl",
                table: "brands",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Name",
                table: "brands",
                type: "character varying(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "");

            migrationBuilder.CreateIndex(
                name: "IX_ProductSubcategories_SubcategoryName",
                table: "ProductSubcategories",
                column: "SubcategoryName");

            migrationBuilder.CreateIndex(
                name: "IX_ProductCategories_CategoryName",
                table: "ProductCategories",
                column: "CategoryName",
                unique: true);
        }
    }
}
