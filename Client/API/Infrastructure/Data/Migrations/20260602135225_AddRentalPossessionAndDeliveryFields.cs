using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddRentalPossessionAndDeliveryFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "CurrentPossession",
                table: "rentals",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "DeliveryMethod",
                table: "rentals",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<string>(
                name: "DeliveryNotes",
                table: "rentals",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "DesiredDeliveryDate",
                table: "rentals",
                type: "timestamp with time zone",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CurrentPossession",
                table: "rentals");

            migrationBuilder.DropColumn(
                name: "DeliveryMethod",
                table: "rentals");

            migrationBuilder.DropColumn(
                name: "DeliveryNotes",
                table: "rentals");

            migrationBuilder.DropColumn(
                name: "DesiredDeliveryDate",
                table: "rentals");
        }
    }
}
