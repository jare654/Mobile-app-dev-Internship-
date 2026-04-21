// lib/features/profile/presentation/screens/profile_screen.dart

import 'package:flutter/material.dart';
import '../core/entities.dart';
import '../core/localization/app_strings.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    this.isLoggedIn = true,
    this.themeMode = ThemeMode.system,
    this.onThemeChange,
    this.onLogout,
    this.onLogin,
    this.onRegister,
    this.onToggleConnection,
    this.onLanguageChange,
    this.pendingActionsCount = 0,
    this.isOnline = true,
    this.appLanguage = AppLanguage.english,
    this.currentUser,
    this.actionErrorMessage,
  });

  final bool isLoggedIn;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode>? onThemeChange;
  final VoidCallback? onLogout;
  final VoidCallback? onLogin;
  final VoidCallback? onRegister;
  final VoidCallback? onToggleConnection;
  final ValueChanged<AppLanguage>? onLanguageChange;
  final int pendingActionsCount;
  final bool isOnline;
  final AppLanguage appLanguage;
  final User? currentUser;
  final String? actionErrorMessage;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ThemeMode _themeMode;
  late AppLanguage _language;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.themeMode;
    _language = widget.appLanguage;
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.themeMode != widget.themeMode) {
      _themeMode = widget.themeMode;
    }
    if (oldWidget.appLanguage != widget.appLanguage) {
      _language = widget.appLanguage;
    }
  }

  void _setTheme(ThemeMode mode) {
    setState(() => _themeMode = mode);
    widget.onThemeChange?.call(mode);
  }

  void _setLanguage(AppLanguage language) {
    setState(() => _language = language);
    widget.onLanguageChange?.call(language);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings(widget.appLanguage);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          snap: true,
          backgroundColor: theme.scaffoldBackgroundColor,
          surfaceTintColor: Colors.transparent,
          title: Text(
            strings.profile,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            child: Column(
              children: [
                // ── User card ──────────────────────────────────
                widget.isLoggedIn
                    ? _UserCard(
                        user: widget.currentUser ??
                            const User(
                              id: 'guest',
                              name: 'Abel Kebede',
                              email: 'abel.kebede@example.com',
                            ),
                        isOnline: widget.isOnline,
                        pendingActionsCount: widget.pendingActionsCount,
                      )
                    : _GuestCard(
                        onLogin: widget.onLogin,
                        onRegister: widget.onRegister,
                        strings: strings,
                      ),
                const SizedBox(height: 24),

                // ── Appearance ─────────────────────────────────
                _SectionHeader(strings.appearance),
                const SizedBox(height: 8),
                _SettingsCard(
                  children: [
                    _ThemeTile(
                      current: _themeMode,
                      onChanged: _setTheme,
                      strings: strings,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Preferences ────────────────────────────────
                _SectionHeader(strings.preferences),
                const SizedBox(height: 8),
                _SettingsCard(
                  children: [
                    if (widget.actionErrorMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Text(
                          widget.actionErrorMessage!,
                          style: TextStyle(
                            color: theme.colorScheme.error,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    SwitchListTile(
                      title: Text(strings.notifications),
                      subtitle: Text(strings.propertyAlerts),
                      secondary: const Icon(Icons.notifications_outlined),
                      value: _notificationsEnabled,
                      onChanged: (v) =>
                          setState(() => _notificationsEnabled = v),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.language_rounded),
                      title: Text(strings.languageLabel),
                      trailing: SegmentedButton<AppLanguage>(
                        segments: const [
                          ButtonSegment(
                            value: AppLanguage.english,
                            label: Text('EN'),
                          ),
                          ButtonSegment(
                            value: AppLanguage.amharic,
                            label: Text('አማ'),
                          ),
                        ],
                        selected: {_language},
                        onSelectionChanged: (selection) =>
                            _setLanguage(selection.first),
                        showSelectedIcon: false,
                      ),
                    ),
                    ListTile(
                      leading: Icon(
                        widget.isOnline
                            ? Icons.wifi_rounded
                            : Icons.wifi_off_rounded,
                      ),
                      title: Text(strings.connection),
                      subtitle: Text(
                        widget.isOnline ? strings.online : strings.offline,
                      ),
                      trailing: SizedBox(
                        width: 120,
                        child: FilledButton(
                          onPressed: widget.onToggleConnection,
                          child: Text(
                            widget.isOnline ? strings.offline : strings.online,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Sync info (logged-in only) ──────────────────
                if (widget.isLoggedIn) ...[
                  _SectionHeader(strings.syncStatus),
                  const SizedBox(height: 8),
                  _SyncStatusCard(
                    isOnline: widget.isOnline,
                    pendingCount: widget.pendingActionsCount,
                    strings: strings,
                  ),
                  const SizedBox(height: 20),
                ],

                // ── About ──────────────────────────────────────
                _SectionHeader(strings.about),
                const SizedBox(height: 8),
                _SettingsCard(
                  children: [
                    _NavTile(
                      icon: Icons.description_outlined,
                      label: strings.terms,
                      onTap: () {},
                    ),
                    _NavTile(
                      icon: Icons.privacy_tip_outlined,
                      label: strings.privacy,
                      onTap: () {},
                    ),
                    _NavTile(
                      icon: Icons.info_outline_rounded,
                      label: strings.appVersion,
                      trailing: Text(
                        'v1.0.0',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      onTap: null,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Logout ─────────────────────────────────────
                if (widget.isLoggedIn)
                  _LogoutButton(onLogout: widget.onLogout, strings: strings),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── User card ─────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.isOnline,
    required this.pendingActionsCount,
  });

  final User user;
  final bool isOnline;
  final int pendingActionsCount;
  
  String get _avatarInitial {
    final trimmed = user.name.trim();
    if (trimmed.isEmpty) {
      return '?';
    }
    return trimmed[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _avatarInitial,
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.75),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _StatusDot(isOnline: isOnline),
                    const SizedBox(width: 6),
                    Text(
                      isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary.withValues(alpha: 0.75),
                        fontSize: 12,
                      ),
                    ),
                    if (pendingActionsCount > 0) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$pendingActionsCount pending',
                          style: TextStyle(
                            color: theme.colorScheme.onTertiaryContainer,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.isOnline});
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: isOnline ? theme.colorScheme.primary : theme.colorScheme.outline,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _GuestCard extends StatelessWidget {
  const _GuestCard({this.onLogin, this.onRegister, required this.strings});
  final VoidCallback? onLogin;
  final VoidCallback? onRegister;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: theme.colorScheme.surfaceContainerHigh,
            child: Icon(
              Icons.person_rounded,
              size: 32,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.guest,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  strings.signInForFullFeatures,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              FilledButton(
                onPressed: onLogin,
                style: FilledButton.styleFrom(minimumSize: const Size(96, 38)),
                child: Text(strings.signIn),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: onRegister,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(96, 38),
                ),
                child: Text(strings.createAccount),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Sync status card ──────────────────────────────────────────────

class _SyncStatusCard extends StatelessWidget {
  const _SyncStatusCard({
    required this.isOnline,
    required this.pendingCount,
    required this.strings,
  });

  final bool isOnline;
  final int pendingCount;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _SyncRow(
            icon: isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
            iconColor: isOnline ? theme.colorScheme.primary : theme.colorScheme.error,
            label: strings.connection,
            value: isOnline ? strings.online : strings.offline,
            valueColor: isOnline ? theme.colorScheme.primary : theme.colorScheme.error,
          ),
          Divider(color: theme.dividerColor, height: 16),
          _SyncRow(
            icon: Icons.pending_actions_rounded,
            iconColor: pendingCount > 0
                ? theme.colorScheme.tertiary
                : theme.colorScheme.onSurfaceVariant,
            label: strings.pendingSync,
            value: pendingCount == 0
                ? strings.allSynced
                : '$pendingCount ${strings.queued}',
            valueColor: pendingCount > 0 
                ? theme.colorScheme.tertiary 
                : theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

class _SyncRow extends StatelessWidget {
  const _SyncRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 10),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ── Theme tile ────────────────────────────────────────────────────

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({
    required this.current,
    required this.onChanged,
    required this.strings,
  });

  final ThemeMode current;
  final ValueChanged<ThemeMode> onChanged;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Icon(switch (current) {
            ThemeMode.dark => Icons.dark_mode_rounded,
            ThemeMode.light => Icons.light_mode_rounded,
            ThemeMode.system => Icons.brightness_auto_rounded,
          }, color: theme.colorScheme.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Text(strings.appearance, style: theme.textTheme.bodyLarge),
          ),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.light,
                icon: Icon(Icons.light_mode_rounded, size: 16),
                tooltip: 'Light',
              ),
              ButtonSegment(
                value: ThemeMode.system,
                icon: Icon(Icons.brightness_auto_rounded, size: 16),
                tooltip: 'System',
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                icon: Icon(Icons.dark_mode_rounded, size: 16),
                tooltip: 'Dark',
              ),
            ],
            selected: {current},
            onSelectionChanged: (s) => onChanged(s.first),
            showSelectedIcon: false,
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable layout components ────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          letterSpacing: 1.2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(
                height: 1,
                indent: 56,
                color: Theme.of(context).dividerColor,
              ),
          ],
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.label,
    this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
      title: Text(label, style: theme.textTheme.bodyLarge),
      trailing: trailing ??
          Icon(
            Icons.chevron_right_rounded,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({this.onLogout, required this.strings});
  final VoidCallback? onLogout;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onLogout,
        icon: const Icon(Icons.logout_rounded),
        label: Text(strings.logout),
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.error,
          side: BorderSide(
            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5),
          ),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
