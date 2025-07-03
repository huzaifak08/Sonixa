import 'package:flutter/material.dart';
import 'package:sonixa/views/player/player_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2C1F6A), Color(0xFF11968D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // All Widgets:
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.sizeOf(context).height * 0.05,
                horizontal: MediaQuery.sizeOf(context).height * 0.01,
              ),
              child: Column(
                children: [
                  // Top Bar:
                  Row(
                    children: [
                      // Todo: App Logo here
                      Text(
                        "Sonixa",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Spacer(),
                      // Todo: Functionality
                      Icon(Icons.search),
                      SizedBox(width: 12),
                      // Todo: Functionality
                      Icon(Icons.more_vert_outlined),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Total Data:
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Total Songs",
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  color: Colors.white60,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            "247",
                            style: Theme.of(context).textTheme.headlineSmall!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),

                      Spacer(),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Playing Time",
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  color: Colors.white60,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            "16h 42m",
                            style: Theme.of(context).textTheme.headlineSmall!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Horizontal Filter Buttons:
                  SegmentedButton<String>(
                    showSelectedIcon: false,

                    style: SegmentedButton.styleFrom(
                      backgroundColor: Color(0xff374151),
                      foregroundColor: Colors.white,
                      selectedBackgroundColor: Color(0xff9333EA),
                      selectedForegroundColor: Colors.white,
                    ),
                    segments: [
                      ButtonSegment(value: "All", label: Text("All")),
                      ButtonSegment(value: "Recent", label: Text("Recent")),
                      ButtonSegment(
                        value: "Favourite",
                        label: Text("Favourite"),
                      ),
                    ],
                    selected: {"All"},
                    onSelectionChanged: (Set<String> newSelection) {
                      // Handle selection change
                    },
                  ),

                  SizedBox(height: 20),

                  // Songs List:
                  ...List.generate(5, (index) {
                    return ListTile(
                      leading: Image.network(
                        "https://cdn3d.iconscout.com/3d/premium/thumb/headphone-3d-icon-download-in-png-blend-fbx-gltf-file-formats--headphones-headset-earphones-virtual-reality-pack-science-technology-icons-3342612.png",
                        height: 45,
                        width: 45,
                      ),
                      title: Text("Index: $index"),
                      subtitle: Text("Harry Styles"),
                      trailing: Text("2:54"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PlayerView()),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),

            // Bottom Current Song Playing Widget:
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                width: double.infinity,
                height: MediaQuery.sizeOf(context).height * 0.15,
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.sizeOf(context).width * 0.02,
                  vertical: MediaQuery.sizeOf(context).height * 0.01,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF667DE9), Color(0xFF764CA3)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    // Song Info:
                    ListTile(
                      leading: Image.network(
                        "https://cdn3d.iconscout.com/3d/premium/thumb/headphone-3d-icon-download-in-png-blend-fbx-gltf-file-formats--headphones-headset-earphones-virtual-reality-pack-science-technology-icons-3342612.png",
                        height: 45,
                        width: 45,
                      ),
                      title: Text("Index: "),
                      subtitle: Text("Harry Styles"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.skip_previous, color: Colors.white),
                          SizedBox(width: 8),
                          Icon(Icons.play_arrow, color: Colors.white),
                          SizedBox(width: 8),
                          Icon(Icons.skip_next, color: Colors.white),
                        ],
                      ),
                    ),

                    // Song Duration:
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "1:23",
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        Text(
                          "3:20",
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                    SizedBox(height: 5),

                    LinearProgressIndicator(value: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
