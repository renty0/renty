using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddAdminAuditFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTimeOffset>(
                name: "financial_resolution_at",
                table: "support_tickets",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "financial_resolution_by_id",
                table: "support_tickets",
                type: "bigint",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "financial_resolution_reason",
                table: "support_tickets",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<DateTimeOffset>(
                name: "ApprovedAt",
                table: "RentableItems",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "ApprovedById",
                table: "RentableItems",
                type: "bigint",
                nullable: true);

            migrationBuilder.AddColumn<DateTimeOffset>(
                name: "RejectedAt",
                table: "RentableItems",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "RejectedById",
                table: "RentableItems",
                type: "bigint",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "RejectionReason",
                table: "RentableItems",
                type: "text",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_support_tickets_financial_resolution_by_id",
                table: "support_tickets",
                column: "financial_resolution_by_id");

            migrationBuilder.CreateIndex(
                name: "IX_RentableItems_ApprovedById",
                table: "RentableItems",
                column: "ApprovedById");

            migrationBuilder.CreateIndex(
                name: "IX_RentableItems_RejectedById",
                table: "RentableItems",
                column: "RejectedById");

            migrationBuilder.AddForeignKey(
                name: "FK_RentableItems_Users_ApprovedById",
                table: "RentableItems",
                column: "ApprovedById",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_RentableItems_Users_RejectedById",
                table: "RentableItems",
                column: "RejectedById",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_support_tickets_Users_financial_resolution_by_id",
                table: "support_tickets",
                column: "financial_resolution_by_id",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_RentableItems_Users_ApprovedById",
                table: "RentableItems");

            migrationBuilder.DropForeignKey(
                name: "FK_RentableItems_Users_RejectedById",
                table: "RentableItems");

            migrationBuilder.DropForeignKey(
                name: "FK_support_tickets_Users_financial_resolution_by_id",
                table: "support_tickets");

            migrationBuilder.DropIndex(
                name: "IX_support_tickets_financial_resolution_by_id",
                table: "support_tickets");

            migrationBuilder.DropIndex(
                name: "IX_RentableItems_ApprovedById",
                table: "RentableItems");

            migrationBuilder.DropIndex(
                name: "IX_RentableItems_RejectedById",
                table: "RentableItems");

            migrationBuilder.DropColumn(
                name: "financial_resolution_at",
                table: "support_tickets");

            migrationBuilder.DropColumn(
                name: "financial_resolution_by_id",
                table: "support_tickets");

            migrationBuilder.DropColumn(
                name: "financial_resolution_reason",
                table: "support_tickets");

            migrationBuilder.DropColumn(
                name: "ApprovedAt",
                table: "RentableItems");

            migrationBuilder.DropColumn(
                name: "ApprovedById",
                table: "RentableItems");

            migrationBuilder.DropColumn(
                name: "RejectedAt",
                table: "RentableItems");

            migrationBuilder.DropColumn(
                name: "RejectedById",
                table: "RentableItems");

            migrationBuilder.DropColumn(
                name: "RejectionReason",
                table: "RentableItems");
        }
    }
}
