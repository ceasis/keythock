# KeyThock Sound Pack Format

A `.thockpack` is a folder or zipped folder with this structure:

```text
MyPack.thockpack
├── manifest.json
├── artwork.png
├── preview.wav
└── samples
    ├── alpha
    │   ├── press_01.wav
    │   └── release_01.wav
    ├── space
    ├── enter
    ├── backspace
    ├── tab
    ├── escape
    ├── arrow
    ├── modifier
    └── function
```

Minimum valid manifest:

```json
{
  "schemaVersion": 1,
  "packId": "com.example.pack.deep",
  "name": "Example Deep",
  "version": "1.0.0",
  "author": "Example",
  "category": "linear",
  "tone": "deep",
  "loudness": "medium",
  "description": "Warm mechanical keyboard samples.",
  "isPremium": false,
  "supportsPress": true,
  "supportsRelease": true,
  "recommendedVolume": 0.55,
  "pitchVariationDefault": 0.02,
  "sampleVariationDefault": true,
  "artwork": "artwork.png",
  "preview": "preview.wav",
  "samples": {
    "alpha": {
      "press": ["samples/alpha/press_01.wav"],
      "release": ["samples/alpha/release_01.wav"]
    }
  }
}
```

Validation rules:

- `manifest.json` must exist.
- `schemaVersion`, `packId`, `name`, `version`, `category`, `tone`, `loudness`, and `samples` are required.
- `version` must be semantic version text like `1.0.0`.
- At least one `alpha.press` sample must be present.
- Sample paths must stay inside the pack folder.
- Supported audio formats are WAV, AIFF, CAF, and M4A when AVFoundation can decode them.
- Imported packs are copied into `~/Library/Application Support/KeyThock/ImportedPacks/`.
