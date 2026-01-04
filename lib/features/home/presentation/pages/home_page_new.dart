import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../../../../core/widgets/neumorphic_button.dart';
import '../../../../core/widgets/neumorphic_section.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../habits/presentation/bloc/habit_bloc.dart';
import '../../../habits/presentation/bloc/habit_event.dart';
import '../widgets/welcome_header.dart';
import '../widgets/motivational_quote_card.dart';
import '../widgets/stats_overview_card.dart';
import '../widgets/todays_habits_list.dart';
import '../widgets/quick_actions_grid.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentQuoteIndex = 0;
  bool _isLoadingQuote = false;

  final List<Map<String, String>> _motivationalQuotes = [
    {
      'quote': 'The only way to do great work is to love what you do.',
      'author': 'Steve Jobs'
    },
    {'quote': 'Your habits define your future.', 'author': 'WellnessFlow'},
    {'quote': 'Small progress is still progress.', 'author': 'Anonymous'},
    {
      'quote': 'Success is the sum of small efforts repeated daily.',
      'author': 'Robert Collier'
    },
    {
      'quote':
          'We are what we repeatedly do. Excellence, then, is not an act, but a habit.',
      'author': 'Aristotle'
    },
    {
      'quote': 'The secret of getting ahead is getting started.',
      'author': 'Mark Twain'
    },
    {
      'quote':
          'You don\'t have to be great to start, but you have to start to be great.',
      'author': 'Zig Ziglar'
    },
    {
      'quote':
          'Motivation is what gets you started. Habit is what keeps you going.',
      'author': 'Jim Ryun'
    },
    {
      'quote':
          'The only person you are destined to become is the person you decide to be.',
      'author': 'Ralph Waldo Emerson'
    },
    {
      'quote':
          'Success is not final, failure is not fatal: it is the courage to continue that counts.',
      'author': 'Winston Churchill'
    },
    {
      'quote': 'Believe you can and you\'re halfway there.',
      'author': 'Theodore Roosevelt'
    },
    {
      'quote': 'The future depends on what you do today.',
      'author': 'Mahatma Gandhi'
    },
    {
      'quote': 'Don\'t watch the clock; do what it does. Keep going.',
      'author': 'Sam Levenson'
    },
    {
      'quote': 'Everything you\'ve ever wanted is on the other side of fear.',
      'author': 'George Addair'
    },
    {
      'quote':
          'It does not matter how slowly you go as long as you do not stop.',
      'author': 'Confucius'
    },
    {
      'quote':
          'The harder you work for something, the greater you\'ll feel when you achieve it.',
      'author': 'Anonymous'
    },
    {'quote': 'Dream bigger. Do bigger.', 'author': 'Anonymous'},
    {
      'quote': 'Success doesn\'t just find you. You have to go out and get it.',
      'author': 'Anonymous'
    },
    {
      'quote': 'Great things never come from comfort zones.',
      'author': 'Anonymous'
    },
    {'quote': 'Dream it. Wish it. Do it.', 'author': 'Anonymous'},
    {
      'quote':
          'Success is not how high you have climbed, but how you make a positive difference to the world.',
      'author': 'Roy T. Bennett'
    },
    {
      'quote':
          'The best time to plant a tree was 20 years ago. The second best time is now.',
      'author': 'Chinese Proverb'
    },
    {
      'quote': 'Your limitation—it\'s only your imagination.',
      'author': 'Anonymous'
    },
    {
      'quote': 'Push yourself, because no one else is going to do it for you.',
      'author': 'Anonymous'
    },
    {
      'quote': 'Sometimes later becomes never. Do it now.',
      'author': 'Anonymous'
    },
    {
      'quote': 'Don\'t stop when you\'re tired. Stop when you\'re done.',
      'author': 'Anonymous'
    },
    {
      'quote': 'Wake up with determination. Go to bed with satisfaction.',
      'author': 'Anonymous'
    },
    {
      'quote': 'Do something today that your future self will thank you for.',
      'author': 'Sean Patrick Flanery'
    },
    {'quote': 'Little things make big days.', 'author': 'Anonymous'},
    {
      'quote': 'It\'s going to be hard, but hard does not mean impossible.',
      'author': 'Anonymous'
    },
    {
      'quote': 'Don\'t be afraid to give up the good to go for the great.',
      'author': 'John D. Rockefeller'
    },
    {'quote': 'If you can dream it, you can do it.', 'author': 'Walt Disney'},
    {
      'quote':
          'Hardships often prepare ordinary people for an extraordinary destiny.',
      'author': 'C.S. Lewis'
    },
    {
      'quote':
          'Never give up on a dream just because of the time it will take to accomplish it.',
      'author': 'Anonymous'
    },
    {
      'quote': 'The distance between dreams and reality is called action.',
      'author': 'Anonymous'
    },
    {
      'quote': 'Fall seven times, stand up eight.',
      'author': 'Japanese Proverb'
    },
    {
      'quote': 'Every accomplishment starts with the decision to try.',
      'author': 'Anonymous'
    },
    {
      'quote': 'Your passion is waiting for your courage to catch up.',
      'author': 'Isabelle Lafleche'
    },
    {
      'quote': 'What you do today can improve all your tomorrows.',
      'author': 'Ralph Marston'
    },
    {
      'quote': 'The way to get started is to quit talking and begin doing.',
      'author': 'Walt Disney'
    },
    {
      'quote': 'A year from now you may wish you had started today.',
      'author': 'Karen Lamb'
    },
    {
      'quote':
          'You are never too old to set another goal or to dream a new dream.',
      'author': 'C.S. Lewis'
    },
    {
      'quote': 'The only impossible journey is the one you never begin.',
      'author': 'Tony Robbins'
    },
    {
      'quote': 'Don\'t let yesterday take up too much of today.',
      'author': 'Will Rogers'
    },
    {
      'quote':
          'Success is walking from failure to failure with no loss of enthusiasm.',
      'author': 'Winston Churchill'
    },
    {
      'quote': 'Act as if what you do makes a difference. It does.',
      'author': 'William James'
    },
    {
      'quote': 'The best revenge is massive success.',
      'author': 'Frank Sinatra'
    },
    {
      'quote': 'Opportunities don\'t happen. You create them.',
      'author': 'Chris Grosser'
    },
    {
      'quote': 'I never dreamed about success, I worked for it.',
      'author': 'Estée Lauder'
    },
    {
      'quote':
          'Try not to become a person of success, but rather try to become a person of value.',
      'author': 'Albert Einstein'
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchQuoteFromApi(); // Try to fetch from API first
    _startQuoteRotation();
    _loadUserData();
  }

  void _loadUserData() {
    final authState = context.read<AuthBloc>().state;
    if (authState.user != null) {
      final userId = authState.user!.id;
      context.read<HabitBloc>().add(LoadUserHabits(userId: userId));
      context.read<HabitBloc>().add(LoadHabitStreaks(userId: userId));
    }
  }

  void _startQuoteRotation() {
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) {
        _fetchQuoteFromApi(); // Fetch new quote from API
        _startQuoteRotation();
      }
    });
  }

  Future<void> _fetchQuoteFromApi() async {
    if (_isLoadingQuote) return;

    setState(() {
      _isLoadingQuote = true;
    });

    try {
      // Using ZenQuotes API - free, no auth required
      final response = await http
          .get(
            Uri.parse('https://zenquotes.io/api/random'),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200 && mounted) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final quoteData = data[0];
          setState(() {
            // Add API quote to the beginning of the list
            _motivationalQuotes.insert(0, {
              'quote': quoteData['q'] ?? '',
              'author': quoteData['a'] ?? 'Unknown',
            });
            // Keep list size manageable (max 100 quotes)
            if (_motivationalQuotes.length > 100) {
              _motivationalQuotes.removeLast();
            }
            _currentQuoteIndex = 0;
            _isLoadingQuote = false;
          });
          return;
        }
      }
    } catch (e) {
      // API failed, use local quotes
      debugPrint('Failed to fetch quote from API: $e');
    }

    // Fallback to rotating local quotes
    if (mounted) {
      setState(() {
        _currentQuoteIndex =
            (_currentQuoteIndex + 1) % _motivationalQuotes.length;
        _isLoadingQuote = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          Container(height: statusBarHeight),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const WelcomeHeader(),
                  const SizedBox(height: 28),
                  MotivationalQuoteCard(
                    quote: _motivationalQuotes[_currentQuoteIndex],
                  ),
                  const SizedBox(height: 32),
                  const NeumorphicSection(
                    title: 'Current Progress',
                    icon: Icons.analytics_rounded,
                    child: StatsOverviewCard(),
                  ),
                  const SizedBox(height: 32),
                  NeumorphicSection(
                    title: 'Today\'s Habits',
                    icon: Icons.today_rounded,
                    trailing: NeumorphicButton(
                      padding: const EdgeInsets.all(8),
                      borderRadius: BorderRadius.circular(10),
                      onPressed: () => context.push('/habits'),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                    ),
                    child: const TodaysHabitsList(),
                  ),
                  const SizedBox(height: 32),
                  const NeumorphicSection(
                    title: 'Quick Actions',
                    icon: Icons.bolt_rounded,
                    child: QuickActionsGrid(),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
