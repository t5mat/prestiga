# Prestiga

![Prestiga 1.0.0](https://github.com/user-attachments/assets/213afbe2-6879-42f1-8ca8-38332581e096)

This is my monospace font, built from [Iosevka](https://github.com/be5invis/Iosevka).

- Curly Style (`ss20`) with further character variant customizations
- Custom metrics; wider, less curvy
- Fixed spacing
- No ligatures

## Usage

[Download](https://github.com/t5mat/prestiga/releases/) and install the latest *SuperTTC*.

To use with [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts), I recommend installing **Symbols Nerd Font** and using it as a fallback font in your editor/terminal.

## Development

To build the font archived in all formats into `./build`:

```docker build . -o ./build --progress=plain```

- Building with all the weights/slopes can take a while. Use `filter_weights`, `filter_slopes` to filter to specific weights/slopes (`select Regular`, `select Upright Italic`).

- Disable `export_glyph_names` to generate smaller font files.

- The build process is very heavy on RAM & CPU usage. Use `max_concurrent_jobs` to limit the number of concurrent jobs.

When testing metrics in smaller font sizes, you'd might want to try the unhinted version, in which glyphs don't snap to grid.

#### Iosevka & custom builds
- [Building Iosevka from Source](https://github.com/be5invis/Iosevka/blob/main/doc/custom-build.md)
- [Iosevka Customizer](https://typeof.net/Iosevka/customizer)
- [Iosevka Specimen](https://typeof.net/Iosevka/specimen)

#### Font testing
- [FontDrop!](https://fontdrop.info/)
- [Font Testing Websites](https://github.com/Jolg42/awesome-typography#font-testing-websites)
