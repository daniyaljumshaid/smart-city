import 'package:flutter/material.dart';

import '../complaint_store.dart';
import '../theme/app_theme.dart';

class CommunitySectionScreen extends StatefulWidget {
  const CommunitySectionScreen({super.key});

  @override
  State<CommunitySectionScreen> createState() => _CommunitySectionScreenState();
}

class _CommunitySectionScreenState extends State<CommunitySectionScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _suggestionController = TextEditingController();
  double _feedbackRating = 4;

  @override
  void dispose() {
    _feedbackController.dispose();
    _suggestionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Community Section',
            style: TextStyle(color: AppTheme.headingOnLight),
          ),
          centerTitle: true,
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: AppTheme.primary,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textMuted,
            tabs: [
              Tab(text: 'Polls'),
              Tab(text: 'Feedback'),
              Tab(text: 'Suggestions'),
              Tab(text: 'Announcements'),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
          child: TabBarView(
            children: [
              _pollsView(),
              _feedbackView(),
              _suggestionsView(),
              _announcementsView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pollsView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ComplaintStore.polls.length,
      itemBuilder: (context, index) {
        final poll = ComplaintStore.polls[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                poll.question,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              ...List.generate(poll.options.length, (optionIndex) {
                final option = poll.options[optionIndex];
                final votes = poll.votes[optionIndex];

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F8FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(option),
                    subtitle: Text('Votes: $votes'),
                    trailing: const Icon(Icons.how_to_vote_rounded),
                    onTap: () {
                      setState(() {
                        ComplaintStore.votePoll(poll.id, optionIndex);
                      });
                    },
                  ),
                );
              }),
              Text(
                'Total Votes: ${poll.totalVotes}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _feedbackView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Public Feedback',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: AppTheme.headingOnLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Rate the current city services and share improvements you want to see.',
                style: TextStyle(color: Colors.blueGrey.shade700, height: 1.35),
              ),
              const SizedBox(height: 10),
              Text(
                'Rating: ${_feedbackRating.toStringAsFixed(1)} / 5.0',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Slider(
                min: 1,
                max: 5,
                divisions: 8,
                value: _feedbackRating,
                label: _feedbackRating.toStringAsFixed(1),
                onChanged: (value) {
                  setState(() {
                    _feedbackRating = value;
                  });
                },
              ),
              TextField(
                controller: _feedbackController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Write your feedback',
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final feedback = _feedbackController.text.trim();
                    if (feedback.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please add feedback before sending.'),
                        ),
                      );
                      return;
                    }

                    ComplaintStore.addSuggestion(
                      author: 'Citizen Feedback',
                      message:
                          'Rating ${_feedbackRating.toStringAsFixed(1)}/5: $feedback',
                    );
                    ComplaintStore.pushNotification(
                      message: 'New community feedback submitted.',
                      targetRole: UserRole.admin,
                    );

                    _feedbackController.clear();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Feedback submitted. Thank you!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Submit Feedback'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _suggestionsView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Public Suggestions',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: AppTheme.headingOnLight,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _suggestionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Share an idea for city improvement',
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final suggestion = _suggestionController.text.trim();
                    if (suggestion.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please add a suggestion to submit.'),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      ComplaintStore.addSuggestion(
                        author: 'Citizen',
                        message: suggestion,
                      );
                      _suggestionController.clear();
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Suggestion submitted successfully.'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.lightbulb_outline_rounded),
                  label: const Text('Submit Suggestion'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...ComplaintStore.suggestions.map(
          (suggestion) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withValues(alpha: 0.95),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suggestion.author,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(suggestion.message),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _announcementsView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: ComplaintStore.announcements
          .map(
            (announcement) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.campaign_rounded,
                      color: Color(0xFF0E5A92),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          announcement.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          announcement.details,
                          style: const TextStyle(
                            color: Color(0xFF5A7288),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
