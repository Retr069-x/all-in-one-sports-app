part of 'data.dart';

const additionalSports = <Sport>[
  Sport(
    id: 'basketball',
    name: 'Basketball',
    format: 'Half-court fundamentals',
    icon: Symbols.sports_basketball,
    tint: Color(0xFFE8E7FC),
    lessons: [
      Lesson(
        'aim',
        'Aim of the game',
        'Score by putting the ball through the other team’s hoop. In a half-court practice game, agree the scoring and possession rules first.',
      ),
      Lesson('equipment', 'Get equipped', 'Basketball, hoop, and court shoes.'),
      Lesson(
        'rules',
        'Rules and scoring',
        'Dribble with one hand. Once you stop your dribble, look to pass or shoot instead of starting another dribble.',
      ),
      Lesson(
        'basics',
        'Learn the basics',
        'Use a balanced stance and push the ball toward the floor with your fingertips. Look up between bounces.',
      ),
      Lesson(
        'practice',
        'Try a beginner drill',
        'Dribble around three markers, then make a close shot. Repeat on each side at a pace you can control.',
      ),
    ],
    quiz: Quiz(
      'What can you do after stopping your dribble?',
      ['Pass or shoot', 'Start a second dribble', 'Run while holding the ball'],
      0,
      'Pass or shoot.',
    ),
  ),
  Sport(
    id: 'tennis',
    name: 'Tennis',
    format: 'Beginner singles',
    icon: Symbols.sports_tennis,
    tint: Color(0xFFE8E7FC),
    lessons: [
      Lesson(
        'aim',
        'Aim of the game',
        'Win a point when the other player cannot return the ball into the court. For a first practice game, agree a simple points format.',
      ),
      Lesson(
        'equipment',
        'Get equipped',
        'Tennis racket, practice balls and suitable court shoes.',
      ),
      Lesson(
        'rules',
        'Rules and scoring',
        'Serve diagonally into the opposite service box. During a rally, return the ball before it bounces a second time.',
      ),
      Lesson(
        'basics',
        'Learn the basics',
        'Start in a balanced stance with the racket in front. Use a short backswing for gentle rallies.',
      ),
      Lesson(
        'practice',
        'Try a beginner drill',
        'Stand inside the service lines with a partner and try ten gentle cross-net shots. Move back when the rally is steady.',
      ),
    ],
    quiz: Quiz(
      'Where should the serve land?',
      [
        'The diagonal service box',
        'Behind the opposite baseline',
        'On your own side',
      ],
      0,
      'The diagonal service box.',
    ),
  ),
  Sport(
    id: 'volleyball',
    name: 'Volleyball',
    format: 'Indoor team basics',
    icon: Symbols.sports_volleyball,
    tint: Color(0xFFE8E7FC),
    lessons: [
      Lesson(
        'aim',
        'Aim of the game',
        'Send the ball over the net and land it inside the other team’s court. A point is awarded when a rally ends.',
      ),
      Lesson(
        'equipment',
        'Get equipped',
        'Volleyball, court shoes and a net or marked line.',
      ),
      Lesson(
        'rules',
        'Rules and scoring',
        'The team usually has up to three contacts to return the ball. Call for the ball so teammates know who will take it.',
      ),
      Lesson(
        'basics',
        'Learn the basics',
        'Join your hands to make a level forearm platform. Angle the platform toward the player you are passing to.',
      ),
      Lesson(
        'practice',
        'Try a beginner drill',
        'In pairs, toss and forearm-pass gently. Aim for a repeatable height before adding movement.',
      ),
    ],
    quiz: Quiz(
      'How many contacts does a team usually have to return the ball?',
      ['Up to three', 'Up to five', 'Only one'],
      0,
      'Up to three.',
    ),
  ),
  Sport(
    id: 'table-tennis',
    name: 'Table tennis',
    format: 'Singles rally practice',
    icon: Symbols.sports_tennis,
    tint: Color(0xFFE8E7FC),
    lessons: [
      Lesson(
        'aim',
        'Aim of the game',
        'Return the ball to the opponent’s side after it bounces on your side. A missed legal return ends the point.',
      ),
      Lesson(
        'equipment',
        'Get equipped',
        'Table tennis bat, ball and a table with a net.',
      ),
      Lesson(
        'rules',
        'Rules and scoring',
        'A serve bounces first on your side and then on the receiver’s side. Keep the serve visible so the receiver can read it.',
      ),
      Lesson(
        'basics',
        'Learn the basics',
        'Hold the bat lightly and use a short controlled stroke. Reset in a balanced stance after each return.',
      ),
      Lesson(
        'practice',
        'Try a beginner drill',
        'Rally diagonally at low speed. Try to land five shots in the same half of the table.',
      ),
    ],
    quiz: Quiz(
      'Where does a serve bounce first?',
      ['On your side', 'On the receiver’s side', 'On the floor'],
      0,
      'On your side.',
    ),
  ),
  Sport(
    id: 'swimming',
    name: 'Swimming',
    format: 'Supervised pool fundamentals',
    icon: Symbols.pool,
    tint: Color(0xFFE8E7FC),
    lessons: [
      Lesson(
        'aim',
        'Aim of the game',
        'For a first session, focus on moving comfortably and breathing steadily in water you can stand in.',
      ),
      Lesson(
        'equipment',
        'Get equipped',
        'A supervised pool, swimwear and goggles if comfortable.',
      ),
      Lesson(
        'rules',
        'Rules and scoring',
        'Follow the pool’s lane and safety rules. Work with a qualified instructor if you are new to swimming.',
      ),
      Lesson(
        'basics',
        'Learn the basics',
        'Practise breathing out gently into the water at the pool edge. Pause and stand up whenever you need to.',
      ),
      Lesson(
        'practice',
        'Try a beginner drill',
        'With an instructor or supervisor, practise a short push-and-glide in shallow water. Stop when you can no longer stand comfortably.',
      ),
    ],
    quiz: Quiz(
      'Where should a beginner first practise?',
      [
        'In a supervised pool in suitable shallow water',
        'Alone in open water',
        'In the deepest lane without support',
      ],
      0,
      'In a supervised pool in suitable shallow water.',
    ),
  ),
  Sport(
    id: 'squash',
    name: 'Squash',
    format: 'Singles court basics',
    icon: Symbols.sports_tennis,
    tint: Color(0xFFE8E7FC),
    lessons: [
      Lesson(
        'aim',
        'Aim of the game',
        'Players alternate hitting the ball to the front wall. Keep the ball within the court markings.',
      ),
      Lesson(
        'equipment',
        'Get equipped',
        'Squash racket, a suitable ball and non-marking shoes.',
      ),
      Lesson(
        'rules',
        'Rules and scoring',
        'Return the ball before its second bounce. Give the other player room to move and stop a point if swinging would be unsafe.',
      ),
      Lesson(
        'basics',
        'Learn the basics',
        'After a controlled shot, recover toward the centre of the court while leaving your partner space.',
      ),
      Lesson(
        'practice',
        'Try a beginner drill',
        'Practise gentle straight drives alone. Add a partner only after agreeing movement and safe spacing.',
      ),
    ],
    quiz: Quiz(
      'What should you do if you cannot swing safely?',
      [
        'Stop the point',
        'Swing through anyway',
        'Block your partner’s movement',
      ],
      0,
      'Stop the point.',
    ),
  ),
  Sport(
    id: 'baseball',
    name: 'Baseball',
    format: 'Batting and fielding basics',
    icon: Symbols.sports_baseball,
    tint: Color(0xFFE8E7FC),
    lessons: [
      Lesson(
        'aim',
        'Aim of the game',
        'Hit the ball and travel through the bases to score a run. The fielding side tries to record outs.',
      ),
      Lesson(
        'equipment',
        'Get equipped',
        'A glove, soft practice ball, batting tee and suitable protective equipment.',
      ),
      Lesson(
        'rules',
        'Rules and scoring',
        'Run the bases in order. For a casual drill, agree what counts as an out and when players rotate.',
      ),
      Lesson(
        'basics',
        'Learn the basics',
        'On a ground ball, get your glove low and move behind the ball. Keep throws gentle when partners are close.',
      ),
      Lesson(
        'practice',
        'Try a beginner drill',
        'Hit a soft ball off a tee toward an empty target area. Rotate between hitting and fielding with a clear signal.',
      ),
    ],
    quiz: Quiz(
      'What order should a runner use?',
      [
        'The bases in order',
        'Any base that is free',
        'Home first, then second',
      ],
      0,
      'The bases in order.',
    ),
  ),
  Sport(
    id: 'rugby-union',
    name: 'Rugby union',
    format: 'Non-contact starter practice',
    icon: Symbols.sports_rugby,
    tint: Color(0xFFE8E7FC),
    lessons: [
      Lesson(
        'aim',
        'Aim of the game',
        'Move the ball toward the opposing try line. Grounding the ball legally in the in-goal area scores a try.',
      ),
      Lesson(
        'equipment',
        'Get equipped',
        'A rugby ball, suitable footwear and markers for a non-contact practice area.',
      ),
      Lesson(
        'rules',
        'Rules and scoring',
        'Pass sideways or backwards. Use touch rules for first sessions and learn contact skills separately with a qualified coach.',
      ),
      Lesson(
        'basics',
        'Learn the basics',
        'Hold the ball in two hands and pass toward a teammate’s chest while moving at a controlled pace.',
      ),
      Lesson(
        'practice',
        'Try a beginner drill',
        'In groups of three, move through a marked channel and pass backwards. Use a touch marker instead of tackling.',
      ),
    ],
    quiz: Quiz(
      'Which direction can you pass by hand?',
      ['Sideways or backwards', 'Only forwards', 'Any direction'],
      0,
      'Sideways or backwards.',
    ),
  ),
  Sport(
    id: 'ice-hockey',
    name: 'Ice hockey',
    format: 'Supervised skating and puck basics',
    icon: Symbols.sports_hockey,
    tint: Color(0xFFE8E7FC),
    lessons: [
      Lesson(
        'aim',
        'Aim of the game',
        'Move the puck as a team and score in the opposing goal. Practise at a supervised beginner session.',
      ),
      Lesson(
        'equipment',
        'Get equipped',
        'Skates, helmet, gloves and other rink-required protective equipment.',
      ),
      Lesson(
        'rules',
        'Rules and scoring',
        'Follow the rink’s safety rules and the instructor’s restart signals. Begin with non-contact play.',
      ),
      Lesson(
        'basics',
        'Learn the basics',
        'Bend your knees slightly and keep your stick blade near the ice. Learn controlled stops before adding speed.',
      ),
      Lesson(
        'practice',
        'Try a beginner drill',
        'On a quiet supervised practice lane, guide the puck around wide markers at walking pace.',
      ),
    ],
    quiz: Quiz(
      'What should you learn before adding speed?',
      ['Controlled stops', 'Body checking', 'Full-power shots'],
      0,
      'Controlled stops.',
    ),
  ),
];
