# Local QA Install

Use the installed app path for local QA:

```sh
./scripts/install_local_app.sh
```

This builds the app, copies it to:

```text
~/Applications/KeyThock.app
```

and launches that visible copy.

## QA Flow

1. Open the KeyThock menu bar popover.
2. Preview the current sound pack.
3. Open Diagnostics.
4. Type in another app such as TextEdit, Notes, or Codex.
5. Confirm `Last key event` and `Last playback decision` update.
6. Click `Restart Listener` and verify the keyboard listener returns to running.
7. Open Keys and assign a different sample to Space or Return.
8. Return to another app and confirm typing uses the updated sound.
