from django.core.management.base import BaseCommand
from django.utils import timezone
from apps.recipes.models import Challenge, ChallengeEntry


class Command(BaseCommand):
    help = 'Process challenges: update statuses and select winners'

    def handle(self, *args, **options):
        now = timezone.now()
        self.stdout.write('Processing challenges...\n')

        # Update upcoming challenges to active
        upcoming_challenges = Challenge.objects.filter(
            status='upcoming',
            start_date__lte=now
        )
        for challenge in upcoming_challenges:
            challenge.status = 'active'
            challenge.save()
            self.stdout.write(
                self.style.SUCCESS(
                    f'✓ Challenge "{challenge.title}" is now ACTIVE'
                )
            )

        # Update active challenges to voting phase
        active_challenges = Challenge.objects.filter(
            status='active',
            end_date__lte=now
        )
        for challenge in active_challenges:
            challenge.status = 'voting'
            challenge.save()
            self.stdout.write(
                self.style.WARNING(
                    f'⚡ Challenge "{challenge.title}" entered VOTING PHASE'
                )
            )

        # Process completed voting and select winners
        voting_challenges = Challenge.objects.filter(
            status='voting',
            voting_end_date__lte=now
        )

        for challenge in voting_challenges:
            self._select_winner(challenge)

        self.stdout.write(
            self.style.SUCCESS(
                f'\n✅ Processed {len(upcoming_challenges) + len(active_challenges) + len(voting_challenges)} challenges'
            )
        )

    def _select_winner(self, challenge):
        """Select winner based on votes"""
        # Get entry with highest votes
        winner_entry = challenge.entries.order_by('-votes_count').first()

        if winner_entry:
            challenge.winner_recipe = winner_entry.recipe
            challenge.status = 'completed'
            challenge.save()

            # Update rankings for all entries
            entries = challenge.entries.order_by('-votes_count')
            for rank, entry in enumerate(entries, start=1):
                entry.ranking = rank
                entry.save()

            self.stdout.write(
                self.style.SUCCESS(
                    f'🏆 Winner selected for "{challenge.title}"'
                )
            )
            self.stdout.write(
                self.style.SUCCESS(
                    f'   Winner: "{winner_entry.recipe.title}" by {winner_entry.user.username}'
                )
            )
            self.stdout.write(
                self.style.SUCCESS(
                    f'   Votes: {winner_entry.votes_count} | Participants: {challenge.participants_count}'
                )
            )
        else:
            # No entries, mark as completed anyway
            challenge.status = 'completed'
            challenge.save()
            self.stdout.write(
                self.style.WARNING(
                    f'⚠ Challenge "{challenge.title}" completed with no entries'
                )
            )
