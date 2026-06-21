using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddChatMessageContextItemFK : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateIndex(
                name: "IX_chat_messages_context_item_id",
                table: "chat_messages",
                column: "context_item_id");

            migrationBuilder.AddForeignKey(
                name: "FK_chat_messages_items_context_item_id",
                table: "chat_messages",
                column: "context_item_id",
                principalTable: "items",
                principalColumn: "id",
                onDelete: ReferentialAction.SetNull);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_chat_messages_items_context_item_id",
                table: "chat_messages");

            migrationBuilder.DropIndex(
                name: "IX_chat_messages_context_item_id",
                table: "chat_messages");
        }
    }
}
