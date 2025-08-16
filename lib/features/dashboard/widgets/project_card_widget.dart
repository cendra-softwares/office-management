import 'package:flutter/material.dart';

class ProjectCardWidget extends StatelessWidget {
  const ProjectCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[100],
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(child: Text('A')),
                  const SizedBox(width: 8.0),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Peedika',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      Text('yakakara', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Center(
                  child: Icon(Icons.image, size: 40.0, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Saleem',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Text('+91 657456521', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8.0),
              const Text('Description'),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      elevation: 0,
                    ),
                    child: const Text('View Details'),
                  ),
                  TextButton(onPressed: () {}, child: const Text('Edit')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
