using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddExpertEvaluationFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "ConditionRating",
                table: "item_verifications",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "DepositSuggested",
                table: "item_verifications",
                type: "numeric",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ConditionRating",
                table: "item_verifications");

            migrationBuilder.DropColumn(
                name: "DepositSuggested",
                table: "item_verifications");
        }
    }
}
