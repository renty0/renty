using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class FixSchemaMappings : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_items_Users_ApplicationUserId",
                table: "items");

            migrationBuilder.DropIndex(
                name: "IX_items_ApplicationUserId",
                table: "items");

            migrationBuilder.DropColumn(
                name: "ApplicationUserId",
                table: "items");

            migrationBuilder.RenameColumn(
                name: "MessageType",
                table: "chat_messages",
                newName: "message_type");

            migrationBuilder.RenameColumn(
                name: "MediaUrl",
                table: "chat_messages",
                newName: "media_url");

            migrationBuilder.RenameColumn(
                name: "ContextItemId",
                table: "chat_messages",
                newName: "context_item_id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "message_type",
                table: "chat_messages",
                newName: "MessageType");

            migrationBuilder.RenameColumn(
                name: "media_url",
                table: "chat_messages",
                newName: "MediaUrl");

            migrationBuilder.RenameColumn(
                name: "context_item_id",
                table: "chat_messages",
                newName: "ContextItemId");

            migrationBuilder.AddColumn<long>(
                name: "ApplicationUserId",
                table: "items",
                type: "bigint",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_items_ApplicationUserId",
                table: "items",
                column: "ApplicationUserId");

            migrationBuilder.AddForeignKey(
                name: "FK_items_Users_ApplicationUserId",
                table: "items",
                column: "ApplicationUserId",
                principalTable: "Users",
                principalColumn: "Id");
        }
    }
}
