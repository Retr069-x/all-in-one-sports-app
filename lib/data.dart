import 'package:flutter/material.dart';

class Lesson {
  const Lesson(this.id, this.title, this.body);

  final String id;
  final String title;
  final String body;
}

class Quiz {
  const Quiz(this.question, this.options, this.answer, this.explanation);

  final String question;
  final List<String> options;
  final int answer;
  final String explanation;
}

class Sport {
  const Sport({
    required this.id,
    required this.name,
    required this.format,
    required this.icon,
    required this.tint,
    required this.lessons,
    required this.quiz,
  });

  final String id;
  final String name;
  final String format;
  final IconData icon;
  final Color tint;
  final List<Lesson> lessons;
  final Quiz quiz;
}

const sports = [
  Sport(
    id: 'football',
    name: 'Football',
    format: 'Association football (soccer)',
    icon: Icons.sports_soccer,
    tint: Color(0xFFDCF2B9),
    lessons: [
      Lesson(
        'aim',
        'Aim of the game',
        'Move the ball as a team and score by getting it into the other team’s goal. For a goal, all of the ball has to enter the goal past the line, with no offence by the scoring team. The team with more goals wins.',
      ),
      Lesson(
        'equipment',
        'Get equipped',
        'Bring a football, suitable footwear and water. Use cones for a casual practice area. Wear shin guards for a match and follow the venue’s footwear rules.',
      ),
      Lesson(
        'passing',
        'Passing and control',
        'Plant one foot beside the ball and pass with the inside of the other foot. When receiving, soften your first touch so the ball stays within your reach.',
      ),
      Lesson(
        'short-pass',
        'Practise a short pass',
        'Put two cones a step apart. With a partner, stand a few metres away and take turns passing through the gap. Start close, then increase the distance once the pass feels controlled.',
      ),
      Lesson(
        'first-game',
        'Play your first game',
        'Agree the pitch, team sizes and restart rules. Start with a small-sided game and look for space to receive a pass. In a standard match, when the ball goes out over a touchline, the team that did not touch it last takes a throw-in.',
      ),
    ],
    quiz: Quiz(
      'Which part of the foot is useful for a controlled short pass?',
      ['The heel', 'The inside', 'The toe'],
      1,
      'The inside of the foot gives you a broad surface to guide the ball.',
    ),
  ),
  Sport(
    id: 'cricket',
    name: 'Cricket',
    format: 'Beginner batting and fielding',
    icon: Icons.sports_cricket,
    tint: Color(0xFFF9E7B2),
    lessons: [
      Lesson(
        'aim',
        'Aim of the game',
        'The batting side tries to score runs while the fielding side tries to limit runs and take wickets. Match length and some playing conditions depend on the format.',
      ),
      Lesson(
        'equipment',
        'Get equipped',
        'Use a bat, a soft training ball and a set of stumps for your first practice. Use the appropriate protective equipment when playing with a hard cricket ball.',
      ),
      Lesson(
        'runs-wickets',
        'Runs and wickets',
        'Batters can score by running between the wickets. A ball hit by the batter that reaches the boundary after bouncing usually scores four. A fair catch before the ball touches the ground can dismiss the batter.',
      ),
      Lesson(
        'straight-hit',
        'Practise a straight hit',
        'Have a partner roll or gently feed a soft ball. Keep your eyes on the ball and swing the bat straight towards a wide target. Swap roles after a few attempts.',
      ),
      Lesson(
        'first-game',
        'Play your first game',
        'Agree a short format and the rules with your group. Choose an opening pair, a bowler and fielders. Practise calling clearly before attempting a run with your batting partner.',
      ),
    ],
    quiz: Quiz(
      'A batter hits the ball and it rolls over the boundary. What does the boundary usually score?',
      ['Two runs', 'Four runs', 'Six runs'],
      1,
      'A boundary four usually occurs when the ball reaches the boundary after touching the ground inside the field.',
    ),
  ),
  Sport(
    id: 'badminton',
    name: 'Badminton',
    format: 'Beginner singles',
    icon: Icons.sports_tennis,
    tint: Color(0xFFE9DEF9),
    lessons: [
      Lesson(
        'aim',
        'Aim of the game',
        'Hit the shuttle over the net so that it lands inside the opponent’s court or forces an error. A rally ends when the shuttle lands or a fault is called.',
      ),
      Lesson(
        'equipment',
        'Get equipped',
        'Bring a badminton racket, shuttle and court shoes. Use the inner side lines for singles. Check the court markings before playing.',
      ),
      Lesson(
        'serve-score',
        'Serve and score',
        'Aim your serve diagonally across the net into the other service box. At the start of a singles game, serve from the right. A rally win earns a point.',
      ),
      Lesson(
        'short-rally',
        'Practise a short rally',
        'Stand opposite a partner near the net and gently tap the shuttle back and forth. Aim for five controlled shots in a row before moving farther apart.',
      ),
      Lesson(
        'first-game',
        'Play your first game',
        'Agree the format and decide who serves first. Call the score before serving. Between rallies, return to a balanced ready position and keep your racket up.',
      ),
    ],
    quiz: Quiz(
      'Where should a singles serve go?',
      [
        'Into the opposite diagonal service court',
        'Straight down the same side',
        'Anywhere behind the opponent',
      ],
      0,
      'A serve goes into the service court diagonally opposite the server.',
    ),
  ),
];

class Region {
  const Region(this.code, this.country, this.city, this.ranking);

  final String code;
  final String country;
  final String city;
  final List<String> ranking;
}

const regions = [
  Region('PK', 'Pakistan', 'Karachi', ['cricket', 'football', 'badminton']),
  Region('US', 'United States', 'New York', [
    'football',
    'badminton',
    'cricket',
  ]),
  Region('CA', 'Canada', 'Toronto', ['badminton', 'football', 'cricket']),
  Region('AU', 'Australia', 'Sydney', ['cricket', 'badminton', 'football']),
  Region('GB', 'United Kingdom', 'London', [
    'football',
    'cricket',
    'badminton',
  ]),
  Region('SA', 'Saudi Arabia', 'Riyadh', ['football', 'badminton', 'cricket']),
  Region('AE', 'United Arab Emirates', 'Dubai', [
    'cricket',
    'football',
    'badminton',
  ]),
  Region('FR', 'France', 'Paris', ['football', 'badminton', 'cricket']),
  Region('IN', 'India', 'Mumbai', ['cricket', 'badminton', 'football']),
  Region('ES', 'Spain', 'Madrid', ['football', 'badminton', 'cricket']),
  Region('AR', 'Argentina', 'Buenos Aires', [
    'football',
    'badminton',
    'cricket',
  ]),
];

class DemoCentre {
  const DemoCentre(this.name, this.distanceKm, this.sessions, this.coach);

  final String name;
  final double distanceKm;
  final String sessions;
  final String coach;
}

List<DemoCentre> centresFor(Sport sport, Region region) => [
  DemoCentre(
    '${region.city} Community Sports Centre',
    1.4,
    'Group introductions and beginner practice',
    'Coach Alex · ${sport.name} fundamentals',
  ),
  DemoCentre(
    '${region.city} Sports Academy',
    3.2,
    'Small groups and individual sessions',
    'Coach Sam · First-game preparation',
  ),
];
