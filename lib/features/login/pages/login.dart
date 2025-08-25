import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

const frameworks = {
  'next': 'Next.js',
  'react': 'React',
  'astro': 'Astro',
  'nuxt': 'Nuxt.js',
};

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: ShadCard(
          width: 350,
          title: Text('Create project', style: theme.textTheme.titleLarge),
          description: const Text('Deploy your new project in one-click.'),
          footer: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShadButton.outline(
                child: const Text('Cancel'),
                onPressed: () {},
              ),
              ShadButton(
                child: const Text('Deploy'),
                onPressed: () {},
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Name'),
                const SizedBox(height: 6),
                const ShadInput(placeholder: Text('Name of your project')),
                const SizedBox(height: 16),
                const Text('Framework'),
                const SizedBox(height: 6),
                ShadSelect<String>(
                  placeholder: const Text('Select'),
                  options: frameworks.entries
                      .map(
                          (e) => ShadOption(value: e.key, child: Text(e.value)))
                      .toList(),
                  selectedOptionBuilder: (context, value) {
                    return Text(frameworks[value]!);
                  },
                  onChanged: (value) {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
