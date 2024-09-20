# Nerd Fonts Ubuntu Installer script in Ruby

This Ruby script automates the installation of Nerd Fonts from links stored in a `fonts.json` file. It allows the user to select which fonts to install, downloads/unzips the files directly into the system font directory (`~/.fonts`), and handles URL redirects. After installation, the script also updates the system's font cache.

## Features

- Allows users to select fonts by number or range (e.g., `1,4,5` or `5-12,14`).
- Supports both individual font selection and ranges of fonts.
- Automatically follows HTTP redirects to ensure successful downloads.
- Extracts downloaded zip files and installs fonts into the system font directory.
- Updates the system font cache after installation.
- Default version is set to `3.2.1`, but the user can specify another version using command-line options.

## Getting Started

first of all, you need to install a Ruby version described in `.tool-versions` file. If you use [asdf-vm](https://asdf-vm.com/) as a package manager, you just download a Ruby version, according with this file.


## Dependencies

To install the required gems, run:

```bash
bundle install
```

## Usage

### Command-line Options

- `-v` or `--version`: Allows the user to specify the font version to download. If not specified, the default version `3.2.1` is used.

Example usage:

```bash
ruby install.rb -v 3.0.0
```

### Font Selection

After running the script, you will be prompted to select which fonts to install. You can either:
- Specify individual font numbers (e.g., `1,4,5`).
- Specify ranges of fonts (e.g., `5-12,14`).
- A combination of individual numbers and ranges.

**Note:** Option `0` to select all fonts is displayed.

## Code Structure

### 1. `load_fonts_json(file_path)`

Loads the `fonts.json` file and parses the font data.

### 2. `follow_redirects(uri, limit = 10)`

Handles HTTP redirects, following up to 10 redirects to ensure the correct URL is reached.

### 3. `download_and_extract(url, install_dir)`

Downloads the font zip file from the provided URL, extracts it, and installs the font into the specified directory.

- Downloads are saved in the user's `~/.fonts` directory.
- If the download results in a file with zero size, the script will abort that specific download.

### 4. `process_font_selection(selection, fonts)`

Processes user input for font selection, supporting both ranges and individual numbers.

### 5. `OptionParser`

Handles the command-line argument for specifying the version of the fonts.

### 6. Font Installation Loop

Iterates through the user-selected fonts, downloads, and installs them into the system.

### 7. Font Cache Update

After installation, the script runs the `fc-cache -f` command to refresh the system font cache, ensuring the new fonts are available.

## Example

1. Run the script:

   ```bash
   ruby install.rb -v 3.2.1
   ```

2. The script will display a list of fonts:

   ```plaintext
   Select the fonts you want to install (e.g., 1-5,7,10-12):
   0. ALL FONTS
   1. 0xProto
   2. 3270
   3. Agave
   ...
   ```

3. Enter your selection, for example:

   ```plaintext
   1-3,5,7
   ```

4. The script will download, extract, and install the selected fonts, then update the font cache.

## Notes

- The option `0` for selecting all fonts is displayed but **not yet implemented**.

## License

This script is open-source and available under the MIT license.