using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddExpertReviewFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<long>(
                name: "AssignedExpertId",
                table: "rentals",
                type: "bigint",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "ExpertReviewFee",
                table: "rentals",
                type: "numeric",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<bool>(
                name: "OwnerWantsExpertReview",
                table: "rentals",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "RenterWantsExpertReview",
                table: "rentals",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.CreateIndex(
                name: "IX_rentals_AssignedExpertId",
                table: "rentals",
                column: "AssignedExpertId");

            migrationBuilder.AddForeignKey(
                name: "FK_rentals_Users_AssignedExpertId",
                table: "rentals",
                column: "AssignedExpertId",
                principalTable: "Users",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_rentals_Users_AssignedExpertId",
                table: "rentals");

            migrationBuilder.DropIndex(
                name: "IX_rentals_AssignedExpertId",
                table: "rentals");

            migrationBuilder.DropColumn(
                name: "AssignedExpertId",
                table: "rentals");

            migrationBuilder.DropColumn(
                name: "ExpertReviewFee",
                table: "rentals");

            migrationBuilder.DropColumn(
                name: "OwnerWantsExpertReview",
                table: "rentals");

            migrationBuilder.DropColumn(
                name: "RenterWantsExpertReview",
                table: "rentals");
        }
    }
}
