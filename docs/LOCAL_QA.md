# Local QA Install

Use the installed app path for permission testing:

```sh
./scripts/install_local_app.sh
```

This builds the app, copies it to:

```text
~/Applications/Thock Studio.app
```

and launches that visible copy.

For a clean Input Monitoring test:

```sh
./scripts/reset_input_monitoring_for_qa.sh
./scripts/install_local_app.sh
```

Then open Thock Studio > Diagnostics > Open Input Monitoring.

If Thock Studio is missing from the Input Monitoring list, click `+` and choose:

```text
~/Applications/Thock Studio.app
```

After enabling it, return to Thock Studio and click Recheck.
