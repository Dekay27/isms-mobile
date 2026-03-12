# Codemagic -> AltStore (Unsigned IPA)

This project includes a Codemagic workflow in `/codemagic.yaml`:

- workflow id: `ios_unsigned_altstore`
- output artifact: `Runner-unsigned-altstore.ipa`

## Codemagic setup

1. Connect this repository in Codemagic.
2. Use **Configuration as code** and select `codemagic.yaml` from repo root.
3. Start build with workflow: `ios_unsigned_altstore`.

## Download and install

1. After build success, download artifact:
   - `Runner-unsigned-altstore.ipa`
2. On iPhone, open AltStore -> `My Apps` -> `+`.
3. Select the downloaded IPA and install.

## Notes

- This IPA is unsigned from Flutter build; AltStore handles signing/install using your Apple ID.
- Free Apple ID requires periodic refresh in AltStore.
- If AltStore reports install/sign issues, confirm:
  - Developer Mode enabled on iPhone
  - trust established for your Apple ID profile
  - AltServer running on your computer
