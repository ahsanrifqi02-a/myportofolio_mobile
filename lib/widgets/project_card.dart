import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

/// Widget kartu tombol interaktif yang menampilkan ikon, label, warna unik,
/// memunculkan SnackBar, serta menavigasi ke halaman terkait ketika ditekan.
class ItemCard extends StatelessWidget {
  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final messenger = ScaffoldMessenger.of(context);
          final navigator = Navigator.of(context);

          if (item.name == 'Logout') {
            final authState = context.read<AuthState>();
            if (!authState.isLoggedIn) {
              messenger
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(content: Text('You are not logged in.')),
                );
              return;
            }
            await authState.logout();
            messenger
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(content: Text('Logged out successfully.')),
              );
            return;
          }

          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text('Kamu telah menekan tombol ${item.name}!'),
              ),
            );

          if (item.name == 'Lihat Proyek') {
            navigator.push(
              MaterialPageRoute(builder: (_) => const ProjectListScreen()),
            );
          } else if (item.name == 'Tambah Proyek') {
            final ok = await ensureLoggedIn(context);
            if (!ok) return;
            navigator.push(
              MaterialPageRoute(builder: (_) => const ProjectFormPage()),
            );
          } else if (item.name == 'Tambah Experience') {
            navigator.push(
              MaterialPageRoute(builder: (_) => const ExperienceFormPage()),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(6),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, color: Colors.white, size: 26.0),
                const SizedBox(height: 4.0),
                Flexible(
                  child: Text(
                    item.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 12.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
