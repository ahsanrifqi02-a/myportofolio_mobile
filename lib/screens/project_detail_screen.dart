import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';

/// Displays full details of a selected [Project].
class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({required this.project, super.key});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final String imageUrl = project.projectImageUrl.trim();

    return Scaffold(
      appBar: AppBar(
        title: Text(project.title),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: double.infinity,
                    height: 160,
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.broken_image_outlined, size: 40),
                        SizedBox(height: 8),
                        Text('Failed to load project image'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              project.title,
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Tech Stack',
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(color: primaryColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(project.techStack),
            const SizedBox(height: 16),
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(color: primaryColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(project.description),
            const SizedBox(height: 16),
            Text(
              'Project URL',
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(color: primaryColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            SelectableText(
              project.projectUrl,
              style: TextStyle(color: primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
