---
name: managing-plist-agents
description: Manages launchd plist files in the project's plists/ directory and applies them to ~/Library/LaunchAgents/ via symbolic links. Use when creating, editing, linking, unlinking, or listing managed launchd agents.
---

# Managing Plist Agents

Manage launchd agent plist files under version control in `plists/` and symlink them to `~/Library/LaunchAgents/`.

## Directory Convention

```
plists/
  com.playground.open-calculator.plist
  com.playground.backup-notes.plist
  ...
```

Target: `~/Library/LaunchAgents/{filename}` -> `{project_root}/plists/{filename}`

## Instructions

### Creating a new agent

1. Write plist XML to `plists/{label}.plist`
2. Validate with `plutil -lint plists/{label}.plist`
3. Create symlink: `ln -s "$(pwd)/plists/{label}.plist" ~/Library/LaunchAgents/{label}.plist`
4. Load: `launchctl load ~/Library/LaunchAgents/{label}.plist`
5. Verify: `launchctl list | grep {label}`

### Editing an existing agent

1. Edit `plists/{label}.plist` directly (the symlink points here)
2. Validate with `plutil -lint plists/{label}.plist`
3. Reload: `launchctl unload ~/Library/LaunchAgents/{label}.plist && launchctl load ~/Library/LaunchAgents/{label}.plist`
4. Verify: `launchctl list | grep {label}`

### Unlinking / removing an agent

1. Unload: `launchctl unload ~/Library/LaunchAgents/{label}.plist`
2. Remove symlink: `rm ~/Library/LaunchAgents/{label}.plist`
3. Optionally delete `plists/{label}.plist` if no longer needed

### Listing managed agents

```bash
ls -la ~/Library/LaunchAgents/ | grep "$(pwd)/plists/"
```

### Syncing all plists (link all, load all)

```bash
for f in plists/*.plist; do
  name=$(basename "$f")
  target=~/Library/LaunchAgents/"$name"
  if [ ! -L "$target" ]; then
    ln -s "$(pwd)/$f" "$target"
    launchctl load "$target"
  fi
done
```

## Plist Template

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>{label}</string>
	<key>Program</key>
	<string>{program_path}</string>
	<key>ProgramArguments</key>
	<array>
		<string>{program_path}</string>
		<string>{arg1}</string>
	</array>
	<key>StartInterval</key>
	<integer>{seconds}</integer>
	<key>StandardOutPath</key>
	<string>/Users/{username}/Library/Logs/launchd-ui/{label}.stdout.log</string>
	<key>StandardErrorPath</key>
	<string>/Users/{username}/Library/Logs/launchd-ui/{label}.stderr.log</string>
</dict>
</plist>
```

## Best Practices

- Label convention: `com.playground.{descriptive-name}`
- Always validate with `plutil -lint` before loading
- Always unload before relinking or deleting
- Log directory: `$HOME/Library/Logs/launchd-ui/` (plist内では絶対パスが必須、`~` は展開されない)

## Anti-Patterns

- Do not copy plist files to LaunchAgents (use symlinks)
- Do not edit files directly in ~/Library/LaunchAgents/
- Do not use `launchctl load` without validating first
