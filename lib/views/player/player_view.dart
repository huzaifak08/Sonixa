import 'package:flutter/material.dart';

class PlayerView extends StatelessWidget {
  const PlayerView({super.key});

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
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.sizeOf(context).height * 0.05,
            horizontal: MediaQuery.sizeOf(context).height * 0.01,
          ),
          child: Column(
            children: [
              // Top Bar:
              Row(
                children: [
                  // Back Icon:
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black12,
                    ),
                    onPressed: () {},
                    icon: Icon(Icons.arrow_back_ios_new, size: 18),
                  ),

                  SizedBox(width: 50),

                  // Title:
                  Column(
                    children: [
                      Text(
                        "PLAYING FROM PLAYLIST",
                        style: Theme.of(
                          context,
                        ).textTheme.titleSmall!.copyWith(color: Colors.white60),
                      ),
                      Text(
                        "Favorite",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Music Disk:
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 20,
                ),
                child: Image.network(
                  "https://www.pngplay.com/wp-content/uploads/4/Vinyl-Record-Free-PNG.png",
                ),
              ),

              SizedBox(height: 20),

              // Song Name:
              Text(
                "Blinding Lights",
                style: Theme.of(context).textTheme.headlineMedium,
              ),

              SizedBox(height: 10),

              // Song Subtitle:
              Text(
                "The Weekend",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge!.copyWith(color: Colors.white60),
              ),

              SizedBox(height: 20),

              // Song Progress Bar:
              LinearProgressIndicator(value: 0.5),

              SizedBox(height: 10),

              // Song Duration:
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "1:23",
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall!.copyWith(color: Colors.white60),
                  ),
                  Text(
                    "3:20",
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall!.copyWith(color: Colors.white60),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Media Controls:
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.repeat, size: 25),
                  SizedBox(width: 35),
                  Icon(Icons.skip_previous, color: Colors.white, size: 40),
                  SizedBox(width: 8),
                  Icon(Icons.play_arrow, color: Colors.white, size: 40),
                  SizedBox(width: 8),
                  Icon(Icons.skip_next, color: Colors.white, size: 40),
                  SizedBox(width: 35),
                  Icon(Icons.shuffle, size: 25),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
