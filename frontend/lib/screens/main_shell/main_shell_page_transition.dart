part of '../main_shell.dart';

class _ShellPageTransition extends StatefulWidget {
  const _ShellPageTransition({
    required this.selectedIndex,
    required this.children,
  });

  final int selectedIndex;
  final List<Widget> children;

  @override
  State<_ShellPageTransition> createState() => _ShellPageTransitionState();
}
