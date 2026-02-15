import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../bloc/navigation_bloc.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../study/presentation/pages/study_page.dart';
import '../../../vault/presentation/pages/vault_page.dart';

class MainNavigationPage extends StatelessWidget {
  const MainNavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return Scaffold(
          body: IndexedStack(
            index: state.index,
            children: const [DashboardPage(), StudyPage(), VaultPage()],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: state.index,
              onTap: (index) {
                context.read<NavigationBloc>().add(NavigationTabChanged(index));
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_rounded),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(FontAwesomeIcons.bookOpen),
                  label: 'Study',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.folder_copy_rounded),
                  label: 'Vault',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
