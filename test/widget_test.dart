
import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/main.dart';

void main() {
  testWidgets('Music Player app loads correctly',
      (WidgetTester tester) async {

    // Build the Music Player app.
    await tester.pumpWidget(
      const MusicPlayerApp(),
    );

    // Verify that the app title appears.
    expect(find.text('Music Player'), findsOneWidget);

    // Verify that the playlist songs appear.
    expect(find.text('back to friends'), findsOneWidget);
    expect(find.text('Earrings'), findsOneWidget);
    expect(find.text('Innocence'), findsOneWidget);
    expect(find.text('No. 1 Party Anthem'), findsOneWidget);
    expect(find.text('Sailor Song'), findsOneWidget);

    // Verify that the playlist header appears.
    expect(find.text('Your Playlist'), findsOneWidget);

    // Verify that the number of songs is displayed.
    expect(find.text('5 Songs'), findsOneWidget);
  });
}