from django.core.management.base import BaseCommand

from common.services.chat_service import ChatService


class Command(BaseCommand):
    help = "Create missing chat conversation documents for existing friendships."

    def handle(self, *args, **options):
        result = ChatService.backfill_friend_conversations()
        self.stdout.write(
            self.style.SUCCESS(
                "Backfill complete: "
                f"created={result['created']}, "
                f"skipped={result['skipped']}, "
                f"invalid={result['invalid']}"
            )
        )
