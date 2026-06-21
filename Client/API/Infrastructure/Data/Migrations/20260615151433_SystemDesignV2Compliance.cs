using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class SystemDesignV2Compliance : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<double>(
                name: "OwnerRating",
                table: "Users",
                type: "double precision",
                nullable: false,
                defaultValue: 0.0);

            migrationBuilder.AddColumn<int>(
                name: "OwnerTotalRatings",
                table: "Users",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<double>(
                name: "RenterRating",
                table: "Users",
                type: "double precision",
                nullable: false,
                defaultValue: 0.0);

            migrationBuilder.AddColumn<int>(
                name: "RenterTotalRatings",
                table: "Users",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<decimal>(
                name: "cancellation_fee",
                table: "rentals",
                type: "numeric(10,2)",
                precision: 10,
                scale: 2,
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<string>(
                name: "delivery_method_to_hub_return",
                table: "rentals",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "evaluation_payer",
                table: "rentals",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "guarantee_method",
                table: "rentals",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<bool>(
                name: "has_hub_evaluation",
                table: "rentals",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<decimal>(
                name: "platform_commission_percent",
                table: "rentals",
                type: "numeric(5,2)",
                precision: 5,
                scale: 2,
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<string>(
                name: "rejection_fault",
                table: "rentals",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "rejection_fee_amount",
                table: "rentals",
                type: "numeric(10,2)",
                precision: 10,
                scale: 2,
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<string>(
                name: "cancellation_policy",
                table: "items",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.CreateTable(
                name: "rental_extensions",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    rental_id = table.Column<Guid>(type: "uuid", nullable: false),
                    requested_by = table.Column<long>(type: "bigint", nullable: false),
                    new_end_date = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    extra_days = table.Column<int>(type: "integer", nullable: false),
                    extra_cost = table.Column<decimal>(type: "numeric(10,2)", precision: 10, scale: 2, nullable: false),
                    status = table.Column<string>(type: "text", nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_rental_extensions", x => x.id);
                    table.ForeignKey(
                        name: "FK_rental_extensions_Users_requested_by",
                        column: x => x.requested_by,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_rental_extensions_rentals_rental_id",
                        column: x => x.rental_id,
                        principalTable: "rentals",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_rental_extensions_rental_id",
                table: "rental_extensions",
                column: "rental_id");

            migrationBuilder.CreateIndex(
                name: "IX_rental_extensions_requested_by",
                table: "rental_extensions",
                column: "requested_by");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "rental_extensions");

            migrationBuilder.DropColumn(
                name: "OwnerRating",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "OwnerTotalRatings",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "RenterRating",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "RenterTotalRatings",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "cancellation_fee",
                table: "rentals");

            migrationBuilder.DropColumn(
                name: "delivery_method_to_hub_return",
                table: "rentals");

            migrationBuilder.DropColumn(
                name: "evaluation_payer",
                table: "rentals");

            migrationBuilder.DropColumn(
                name: "guarantee_method",
                table: "rentals");

            migrationBuilder.DropColumn(
                name: "has_hub_evaluation",
                table: "rentals");

            migrationBuilder.DropColumn(
                name: "platform_commission_percent",
                table: "rentals");

            migrationBuilder.DropColumn(
                name: "rejection_fault",
                table: "rentals");

            migrationBuilder.DropColumn(
                name: "rejection_fee_amount",
                table: "rentals");

            migrationBuilder.DropColumn(
                name: "cancellation_policy",
                table: "items");
        }
    }
}
