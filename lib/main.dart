import 'dart:ui_web' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:dev_icons/dev_icons.dart';

// Conditional import for web-only features
import 'dart:html' if (dart.library.io) 'dart:io' as html;
import 'package:flutter/foundation.dart' show kIsWeb;

// --- STATE MANAGEMENT for Interactive Highlighting ---
// A ValueNotifier to hold the currently hovered skill.
// Widgets can listen to this and update their appearance.
final hoveredSkillNotifier = ValueNotifier<String?>(null);

void main() {
  runApp(const PortfolioApp());
}

// --- App Theme and Configuration ---
const Color kPrimaryColor = Color(0xFF0D1117);
const Color kCardColor = Color(0x99161B22);
const Color kBorderColor = Color(0x8030363D);
const Color kTextColor = Color(0xFFC9D1D9);
const Color kHeadingColor = Color(0xFFFFFFFF);
const Color kAccentColor = Color(0xFF58A6FF);
const Color kSubtleTextColor = Color(0xFF8B949E);
const Color kHighlightColor = Color(0x3358A6FF); // For the interactive glow

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aryan Jumani - Portfolio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: kPrimaryColor,
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(
            context,
          ).textTheme.apply(bodyColor: kTextColor, displayColor: kHeadingColor),
        ),
      ),
      home: const PortfolioHomePage(),
    );
  }
}

// --- Main Home Page Widget ---
class PortfolioHomePage extends StatefulWidget {
  const PortfolioHomePage({super.key});

  @override
  State<PortfolioHomePage> createState() => _PortfolioHomePageState();
}

class _PortfolioHomePageState extends State<PortfolioHomePage> {
  Offset _mousePosition = Offset.zero;
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  int _currentSectionIndex = 0;

  // --- ADDED New Sections ---
  final List<String> sectionTitles = [
    "About Me",
    "Experience",
    "Projects",
    "Game Development",
    "Skills",
    "Certifications",
    "Education",
  ];

  final Map<String, Widget> sections = {
    "About Me": const AboutMeSection(),
    "Experience": const ExperienceSection(),
    "Projects": const ProjectSection(),
    "Game Development": const GameDevelopmentSection(),
    "Skills": const SkillsSection(),
    "Certifications": const CertificationsSection(),
    "Education": const EducationSection(),
    // The "Contact" section will be a static footer, not part of the scrollable list.
  };

  @override
  void initState() {
    super.initState();
    itemPositionsListener.itemPositions.addListener(() {
      final positions = itemPositionsListener.itemPositions.value;
      if (positions.isEmpty) return;
      final topVisibleItem = positions.reduce(
        (min, current) =>
            (min.itemLeadingEdge).abs() < (current.itemLeadingEdge).abs()
                ? min
                : current,
      );
      if (_currentSectionIndex != topVisibleItem.index) {
        setState(() {
          _currentSectionIndex = topVisibleItem.index;
        });
      }
    });
  }

  void _scrollToIndex(int index) {
    itemScrollController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sectionWidgets = sections.values.toList();
    return Scaffold(
      body: MouseRegion(
        onHover: (event) {
          setState(() {
            _mousePosition = event.position;
          });
        },
        // --- CHANGE: Added SelectionArea to make all text selectable ---
        child: SelectionArea(
          child: Stack(
            children: [
              DynamicGridBackground(mousePosition: _mousePosition),
              Container(
                color: kPrimaryColor,
                margin: const EdgeInsets.symmetric(horizontal: 200),
              ),
              ScrollablePositionedList.builder(
                itemCount:
                    sectionWidgets.length + 1, // +1 for the contact footer
                itemScrollController: itemScrollController,
                itemPositionsListener: itemPositionsListener,
                itemBuilder: (context, index) {
                  // --- ADDED Contact Section at the end of the list ---
                  if (index == sectionWidgets.length) {
                    return const ContactSection();
                  }

                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 950),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (index == 0) ...[
                              const SizedBox(height: 120),
                              const HeaderSection(),
                              const SizedBox(height: 48),
                            ],
                            SectionWidget(
                              title: sectionTitles[index],
                              children: [sectionWidgets[index]],
                            ),
                            const SizedBox(height: 48),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: TopNavigationBar(
                  sections: sectionTitles,
                  currentIndex: _currentSectionIndex,
                  onTap: _scrollToIndex,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- WIDGETS (New and Modified) ---

class TopNavigationBar extends StatelessWidget {
  final List<String> sections;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const TopNavigationBar({
    super.key,
    required this.sections,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      isNavBar: true,
      child: Center(
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(sections.length, (index) {
              final bool isSelected = currentIndex == index;
              return GestureDetector(
                onTap: () => onTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? kAccentColor.withOpacity(0.15)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    sections[index],
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? kAccentColor : kSubtleTextColor,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class DynamicGridBackground extends StatefulWidget {
  final Offset mousePosition;
  const DynamicGridBackground({super.key, required this.mousePosition});

  @override
  State<DynamicGridBackground> createState() => _DynamicGridBackgroundState();
}

class _DynamicGridBackgroundState extends State<DynamicGridBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
      setState(() {});
    });
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _DynamicGridPainter(widget.mousePosition, _controller.value),
    );
  }
}

class _DynamicGridPainter extends CustomPainter {
  final Offset mousePosition;
  final double animationValue;
  _DynamicGridPainter(this.mousePosition, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    const double spacing = 35.0;
    final paint = Paint();

    for (double i = 0; i < size.width; i += spacing) {
      for (double j = 0; j < size.height; j += spacing) {
        final pos = Offset(i, j);
        final distance = (pos - mousePosition).distance;

        final double wave = math.sin(
          (i / 100) + (j / 100) + (animationValue * 2 * math.pi),
        );

        final double influence = math.exp(-(distance * distance) / (200 * 200));

        final double radius = 0.5 + influence * 3.5 + wave * 0.5;
        final double opacity = 0.1 + influence * 0.6 + wave * 0.05;

        paint.color = kSubtleTextColor.withOpacity(opacity.clamp(0.0, 1.0));
        canvas.drawCircle(pos, radius.clamp(0.0, 5.0), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DynamicGridPainter oldDelegate) =>
      oldDelegate.mousePosition != mousePosition ||
      oldDelegate.animationValue != animationValue;
}

class GameDevelopmentSection extends StatefulWidget {
  const GameDevelopmentSection({super.key});
  @override
  State<GameDevelopmentSection> createState() => _GameDevelopmentSectionState();
}

class _GameDevelopmentSectionState extends State<GameDevelopmentSection> {
  String? _selectedGameUrl;

  final Map<String, String> games = {
    'Throw!':
        '<iframe frameborder="0" src="https://itch.io/embed-upload/4149772?color=e6dfdf" allowfullscreen="" width="1500" height="1200"></iframe>',
    'Orb of Time':
        '<iframe frameborder="0" src="https://itch.io/embed-upload/3640002?color=333333" allowfullscreen="" width="1280" height="740"></iframe>',
    'A Trail Of Blood':
        '<iframe frameborder="0" src="https://itch.io/embed-upload/2480215?color=333333" allowfullscreen="" width="1300" height="808"></iframe>',
    'The Joker':
        '<iframe frameborder="0" src="https://itch.io/embed-upload/2269905?color=ff16e7" allowfullscreen="" width="980" height="688"></iframe>',
    'Earth 2.1':
        '<iframe frameborder="0" src="https://itch.io/embed-upload/2183280?color=333333" allowfullscreen="" width="980" height="688"></iframe>',
  };

  void _selectGame(String gameUrl) {
    setState(() {
      _selectedGameUrl = gameUrl;
    });
  }

  void _closeGame() {
    setState(() {
      _selectedGameUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_selectedGameUrl == null)
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children:
                games.entries.map((entry) {
                  return ElevatedButton(
                    onPressed: () => _selectGame(entry.value),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kCardColor,
                      side: const BorderSide(color: kBorderColor),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      entry.key,
                      style: const TextStyle(color: kAccentColor),
                    ),
                  );
                }).toList(),
          ),
        const SizedBox(height: 32),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child:
              _selectedGameUrl != null
                  ? Column(
                    children: [
                      GameCard(
                        key: ValueKey(_selectedGameUrl),
                        iframeHtml: _selectedGameUrl!,
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        icon: const Icon(Icons.close, color: kSubtleTextColor),
                        label: const Text(
                          "Close Game",
                          style: TextStyle(color: kSubtleTextColor),
                        ),
                        onPressed: _closeGame,
                      ),
                    ],
                  )
                  : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class GameCard extends StatefulWidget {
  final String iframeHtml;
  const GameCard({super.key, required this.iframeHtml});

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  static final Set<String> _registeredViewIds = {};
  late final String _viewId;
  double _aspectRatio = 16 / 9;

  @override
  void initState() {
    super.initState();
    _viewId = 'iframe-${DateTime.now().microsecondsSinceEpoch}';

    final double? width = _extractDimension('width');
    final double? height = _extractDimension('height');
    if (width != null && height != null && height > 0) {
      _aspectRatio = width / height;
    }

    if (kIsWeb) {
      if (!_registeredViewIds.contains(_viewId)) {
        final iframe =
            html.IFrameElement()
              ..src = _extractSrc(widget.iframeHtml)
              ..style.border = 'none'
              ..style.width = '100%'
              ..style.height = '100%'
              ..allow = "fullscreen";
        ui.platformViewRegistry.registerViewFactory(
          _viewId,
          (int viewId) => iframe,
        );
        _registeredViewIds.add(_viewId);
      }
    }
  }

  String _extractSrc(String html) {
    final regex = RegExp('src="([^"]*)"');
    return regex.firstMatch(html)?.group(1) ?? '';
  }

  double? _extractDimension(String dimension) {
    final regex = RegExp('$dimension="([^"]*)"');
    final match = regex.firstMatch(widget.iframeHtml);
    if (match != null) {
      final value = match.group(1);
      if (value != null) {
        return double.tryParse(value);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: AspectRatio(
        aspectRatio: _aspectRatio,
        child:
            kIsWeb
                ? HtmlElementView(viewType: _viewId)
                : const Center(
                  child: Text("Games are only playable on the web version."),
                ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final bool isNavBar;
  const GlassCard({super.key, required this.child, this.isNavBar = false});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius:
          isNavBar
              ? const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              )
              : BorderRadius.circular(12.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          padding: !isNavBar ? const EdgeInsets.all(24.0) : EdgeInsets.zero,
          decoration: BoxDecoration(
            color: kCardColor,
            border: Border.all(color: kBorderColor, width: 1.5),
          ),
          child: child,
        ),
      ),
    );
  }
}

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  void _downloadResume() {
    // Make sure you have your resume file in assets/resume.pdf
    if (kIsWeb) {
      html.AnchorElement anchorElement = html.AnchorElement(
        href: 'assets/resume.pdf',
      );
      anchorElement.download = 'AryanJumani_Resume.pdf';
      anchorElement.click();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Aryan Jumani",
          style: GoogleFonts.inter(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: kHeadingColor,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "Aspiring Software & Data Engineer with a passion for building innovative solutions, from quantum computing models to augmented reality experiences.",
          style: TextStyle(fontSize: 16, color: kSubtleTextColor),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            SocialIcon(
              icon: FontAwesomeIcons.linkedin,
              url: 'https://linkedin.com/in/aryanjumani',
            ),
            const SizedBox(width: 16),
            SocialIcon(
              icon: FontAwesomeIcons.github,
              url: 'https://github.com/aryanjumani',
            ),
            const SizedBox(width: 16),
            SocialIcon(
              icon: FontAwesomeIcons.envelope,
              url: 'mailto:aryanjumani10@gmail.com',
            ),
            const Spacer(),
            // --- NEW: Download Resume Button ---
            ElevatedButton.icon(
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text("Download Resume"),
              onPressed: _downloadResume,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                backgroundColor: kAccentColor,
                foregroundColor: kPrimaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SectionWidget extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SectionWidget({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: kHeadingColor,
          ),
        ),
        const SizedBox(height: 24),
        ...children,
      ],
    );
  }
}

// --- MODIFIED: About Me Section to prevent overflow ---
class AboutMeSection extends StatelessWidget {
  const AboutMeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            // <-- FIX: Changed Expanded to Flexible
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Driven by curiosity and a passion for technology, I am a Computer Science student at Purdue University specializing in Data Science and Entrepreneurship. My journey has taken me from building scalable data frameworks at Tredence and mobile apps at Svaguna to exploring the frontiers of augmented reality at IIT-Delhi. I thrive on solving complex problems, whether it's optimizing a quantum computing model or designing an intuitive game. I believe in leveraging technology to create meaningful and innovative user experiences.",
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/profile_photo.jpeg',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExperienceSection extends StatelessWidget {
  const ExperienceSection({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExperienceCard(
          role: "Data Engineering Intern",
          company: "Tredence Inc.",
          period: "Jun 2025 - Aug 2025",
          location: "Chicago, IL (Onsite)",
          logo: Image.asset('assets/tredence_logo.png', width: 40),
          associatedSkills: const ['Snowflake', 'Python', 'JavaScript'],
          details: const [
            "Shadowed a mentor consulting for a global hotel chain, attending client meetings to gain exposure and insight into the hospitality sector and their operations.",
            "Built a self-heal framework in Snowflake using Javascript and SnowSQL to refresh upstream Airflow processes and detect 13+ recurring data anomalies to reduce manual oversight for 2 business-critical dashboards.",
            "Performed Exploratory Data Analysis (EDA) and developed 5+ predictive models using Python (pandas, sklearn, keras, pycaret) across various datasets and projects.",
          ],
        ),
        ExperienceCard(
          role: "Augmented Reality Intern",
          company: "Divine Labs, IIT-Delhi",
          period: "Jun 2024 - Aug 2024",
          location: "Remote",
          logo: Image.asset('assets/divine_lab_logo.jpeg', width: 40),
          associatedSkills: const ['Unity', 'C#', 'Blender'],
          details: const [
            "Designed an educational toolkit comprising of 6 applets in Unity 3D, integrating Augmented Reality for IIT-D's Department of Design.",
            "Supported a Government of India initiative to educate children aged 3 to 6 in rural areas being deployed in 1500+ schools nationwide, benefiting over one million children.",
            "Using Blender for 3D modeling, Vuforia for AR Detection, along with Unity3D for prototyping, and C# for programming.",
          ],
        ),
        ExperienceCard(
          role: "Software Engineering Intern",
          company: "Svaguna",
          period: "Jun 2023 - Jul 2023",
          location: "Mumbai, India (Onsite)",
          logo: Image.asset('assets/svaguna_logo.png', width: 40),
          associatedSkills: const ['Flutter'],
          details: const [
            "Assisted in coding and debugging a mobile application for an e-commerce food app using robust and easily maintainable code.",
            "Integrated Flutter for frontend and Firebase for backend services, implementing authentication and real-time database capabilities; supported over 200,000 concurrent users with 24/7 uptime.",
          ],
        ),
      ],
    );
  }
}

class ProjectSection extends StatelessWidget {
  const ProjectSection({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        ProjectCard(
          title: "Quantum Computing Predictor Model",
          description:
              "Designed a basketball match predictor using a quantum server with 32 qubits to make use of a predictor model having previous match data to determine player performance for accurate results with 4% more accuracy than models available on the net. Presented at the Fall Undergraduate Research Symposium 2023 at Purdue.",
          tags: ["Python", "DWave"],
          associatedSkills: ['Python'],
        ),
        SizedBox(height: 16),
        ProjectCard(
          title: "PythonPedia",
          description:
              "Launched a free online learning platform enabling individuals to master Python through interactive, editable examples and instructional videos. Had an active community of 500+ learners.",
          tags: ["Python", "HTML/CSS", "JavaScript", "PHP"],
          associatedSkills: ['Python', 'HTML5', 'CSS3', 'JavaScript'],
        ),
      ],
    );
  }
}

class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key});
  @override
  Widget build(BuildContext context) {
    return const SkillsCard();
  }
}

// --- MODIFIED: Certifications Section with new layout ---
class CertificationsSection extends StatelessWidget {
  const CertificationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          const Icon(FontAwesomeIcons.snowflake, color: Colors.white, size: 40),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "SnowPro Core Certification",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kAccentColor,
                  ),
                ),
                SizedBox(height: 4),
                Text("Snowflake", style: TextStyle(color: kHeadingColor)),
                SizedBox(height: 8),
                Text(
                  "Aug 2025 - Aug 2027",
                  style: TextStyle(color: kSubtleTextColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed:
                () => _launchURL(
                  'https://achieve.snowflake.com/b584a85f-1ae4-4932-9284-112c096a03e5',
                ),
            child: const Text("Show Credential"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              backgroundColor: kCardColor,
              foregroundColor: kAccentColor,
              side: const BorderSide(color: kBorderColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EducationSection extends StatelessWidget {
  const EducationSection({super.key});
  @override
  Widget build(BuildContext context) {
    return const EducationCard();
  }
}

class ExperienceCard extends StatelessWidget {
  final String role, company, period, location;
  final List<String> details;
  final Widget logo;
  final List<String> associatedSkills;

  const ExperienceCard({
    super.key,
    required this.role,
    required this.company,
    required this.period,
    required this.details,
    required this.logo,
    required this.location,
    required this.associatedSkills,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: hoveredSkillNotifier,
      builder: (context, hoveredSkill, child) {
        final bool isHighlighted =
            hoveredSkill != null && associatedSkills.contains(hoveredSkill);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow:
                isHighlighted
                    ? [
                      BoxShadow(
                        color: kHighlightColor,
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                    : [],
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: GlassCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 50, child: logo),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    role,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: kAccentColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    company,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: kHeadingColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    location,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: kSubtleTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              period,
                              style: const TextStyle(
                                fontSize: 14,
                                color: kSubtleTextColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...details
                            .map(
                              (detail) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "• ",
                                      style: TextStyle(color: kSubtleTextColor),
                                    ),
                                    Expanded(
                                      child: Text(
                                        detail,
                                        style: const TextStyle(
                                          color: kTextColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ProjectCard extends StatelessWidget {
  final String title, description;
  final List<String> tags;
  final List<String> associatedSkills;

  const ProjectCard({
    super.key,
    required this.title,
    required this.description,
    required this.tags,
    required this.associatedSkills,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: hoveredSkillNotifier,
      builder: (context, hoveredSkill, child) {
        final isHighlighted =
            hoveredSkill != null && associatedSkills.contains(hoveredSkill);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow:
                isHighlighted
                    ? [
                      BoxShadow(
                        color: kHighlightColor,
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                    : [],
          ),
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kAccentColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(color: kTextColor),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tags.map((tag) => SkillTag(name: tag)).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SkillsCard extends StatelessWidget {
  const SkillsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SkillCategory(
            title: "Languages",
            icons: [
              SkillLogo(icon: DevIcons.pythonPlain, name: "Python"),
              SkillLogo(icon: DevIcons.javaPlain, name: "Java"),
              SkillLogo(icon: DevIcons.mysqlPlain, name: "SQL"),
              SkillLogo(icon: DevIcons.dartPlain, name: "Dart"),
              SkillLogo(icon: DevIcons.cplusplusPlain, name: "C++"),
              SkillLogo(icon: DevIcons.csharpPlain, name: "C#"),
              SkillLogo(icon: DevIcons.javascriptPlain, name: "JavaScript"),
              SkillLogo(icon: DevIcons.typescriptPlain, name: "TypeScript"),
              SkillLogo(icon: DevIcons.html5Plain, name: "HTML5"),
              SkillLogo(icon: DevIcons.css3Plain, name: "CSS3"),
              SkillLogo(icon: DevIcons.kotlinPlain, name: "Kotlin"),
            ],
          ),
          SizedBox(height: 24),
          SkillCategory(
            title: "Frameworks & Libraries",
            icons: [
              SkillLogo(icon: DevIcons.flutterPlain, name: "Flutter"),
              SkillLogo(icon: DevIcons.reactOriginal, name: "React"),
              SkillLogo(icon: DevIcons.nodejsPlain, name: "Node.js"),
              SkillLogo(icon: DevIcons.flaskOriginal, name: "Flask"),
            ],
          ),
          SizedBox(height: 24),
          SkillCategory(
            title: "Developer Tools",
            icons: [
              SkillLogo(icon: FontAwesomeIcons.unity, name: "Unity"),
              SkillLogo(icon: FontAwesomeIcons.blender, name: "Blender"),
              SkillLogo(icon: FontAwesomeIcons.snowflake, name: "Snowflake"),
              SkillLogo(
                icon: DevIcons.amazonwebservicesPlainWordmark,
                name: "AWS",
              ),
              SkillLogo(icon: DevIcons.googlecloudPlain, name: "GCP"),
              SkillLogo(icon: DevIcons.gitPlain, name: "Git"),
              SkillLogo(icon: DevIcons.dockerPlain, name: "Docker"),
              SkillLogo(icon: DevIcons.kubernetesPlain, name: "Kubernetes"),
            ],
          ),
        ],
      ),
    );
  }
}

class SkillCategory extends StatelessWidget {
  final String title;
  final List<Widget> icons;
  const SkillCategory({super.key, required this.title, required this.icons});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: kHeadingColor,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(spacing: 24, runSpacing: 16, children: icons),
      ],
    );
  }
}

class SkillLogo extends StatelessWidget {
  final IconData icon;
  final String name;
  const SkillLogo({super.key, required this.icon, required this.name});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        hoveredSkillNotifier.value = name;
      },
      onExit: (_) {
        hoveredSkillNotifier.value = null;
      },
      child: SizedBox(
        width: 60,
        child: Column(
          children: [
            Icon(icon, size: 36, color: kTextColor),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(color: kSubtleTextColor, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class EducationCard extends StatefulWidget {
  const EducationCard({super.key});

  @override
  State<EducationCard> createState() => _EducationCardState();
}

class _EducationCardState extends State<EducationCard> {
  bool _showCourses = false;

  final List<String> courses = [
    "Object Oriented Programming",
    "Discrete Math",
    "Statistics",
    "Data Structures & Algorithms",
    "Computer Architecture",
    "Systems Programming",
    "Software Engineering",
    "Database Management Systems",
    "Cryptography",
    "Artificial Intelligence",
    "Operating Systems",
  ];

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Purdue University",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kAccentColor,
                ),
              ),
              const Text(
                "Aug 2023 - May 2027",
                style: TextStyle(color: kSubtleTextColor),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            "Bachelor of Science in Computer Science",
            style: TextStyle(fontSize: 16, color: kHeadingColor),
          ),
          const SizedBox(height: 8),
          const Text(
            "GPA: 3.6/4.0 | Dean's List Student + Semester Honors",
            style: TextStyle(color: kSubtleTextColor),
          ),
          const SizedBox(height: 16),
          const Divider(color: kBorderColor),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () {
                setState(() {
                  _showCourses = !_showCourses;
                });
              },
              child: Text(
                _showCourses
                    ? "Hide Relevant Coursework"
                    : "Show Relevant Coursework",
                style: const TextStyle(color: kAccentColor),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child:
                _showCourses
                    ? Column(
                      children:
                          courses
                              .map(
                                (course) => ListTile(
                                  leading: const Icon(
                                    Icons.code,
                                    color: kSubtleTextColor,
                                  ),
                                  title: Text(
                                    course,
                                    style: TextStyle(color: kAccentColor),
                                  ),
                                ),
                              )
                              .toList(),
                    )
                    : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 950),
          child: Column(
            children: [
              Text(
                "Get In Touch",
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: kHeadingColor,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "I'm always open to discussing new projects, creative ideas, or opportunities to be part of an ambitious vision. Feel free to reach out!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: kSubtleTextColor),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => _launchURL('mailto:aryanjumani10@gmail.com'),
                child: const Text("Say Hello"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  backgroundColor: kAccentColor,
                  foregroundColor: kPrimaryColor,
                ),
              ),
              const SizedBox(height: 48),
              Text(
                "Built with Flutter by Aryan Jumani",
                style: TextStyle(color: kSubtleTextColor.withOpacity(0.5)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Utility Widgets & Functions ---
class SkillTag extends StatelessWidget {
  final String name;
  const SkillTag({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0x2958A6FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x6658A6FF)),
      ),
      child: Text(
        name,
        style: const TextStyle(
          color: kAccentColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class SocialIcon extends StatelessWidget {
  final IconData icon;
  final String url;
  const SocialIcon({super.key, required this.icon, required this.url});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: FaIcon(icon, color: kSubtleTextColor),
      onPressed: () => _launchURL(url),
      hoverColor: kCardColor,
    );
  }
}

void _launchURL(String url) async {
  if (!await launchUrl(Uri.parse(url))) {
    throw 'Could not launch $url';
  }
}
