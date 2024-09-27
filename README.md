# Mergdev APT Repository Manager

This project provides tools for creating, managing, and using an APT Repository on Raspberry Pi OS (PiOS). It includes a script to set up, remove, or check the status of the mergdev apt repository.

## mergdev-archive.sh

The `mergdev-archive.sh` script is a comprehensive tool for managing the mergdev apt repository on Raspbian systems. It allows you to install, remove, or check the status of the repository.

### Prerequisites

- Raspberry Pi running Raspberry Pi OS (PiOS)
- Sudo privileges

### Usage

```
sudo ./scripts/mergdev-archive.sh [-h] [-R <raspbian-release>] [-i | -r | -s]
```

### Options

- `-h`: Display help information
- `-R <raspbian-release>`: Specify the Raspbian release (default: current system release)
- `-i`: Install the repository
- `-r`: Remove the repository
- `-s`: Check the status of the repository

### Examples

1. Install the repository:
   ```
   sudo ./scripts/mergdev-archive.sh -i
   ```

2. Remove the repository:
   ```
   sudo ./scripts/mergdev-archive.sh -r
   ```

3. Check the status of the repository:
   ```
   sudo ./scripts/mergdev-archive.sh -s
   ```

4. Install the repository for a specific Raspbian release:
   ```
   sudo ./scripts/mergdev-archive.sh -R bookworm -i
   ```

## Features

- Automatic detection of the current Raspbian release
- Support for multiple Raspbian releases (including future releases)
- Comprehensive status check of the repository
- Clear error messages and user feedback

## Note

This script must be run with sudo privileges as it modifies system files and uses apt-get.

## Contributing

If you'd like to contribute to this project, please feel free to submit pull requests or open issues for bugs and feature requests.

## License

This project is licensed under the GNU General Public License v3.0 (GPLv3). See the [LICENSE](LICENSE) file for details.

The GPLv3 is a copyleft license that requires anyone who distributes this code or a derivative work to make the source available under the same terms. It is designed to ensure that the software remains free and open source.

Key points of the GPLv3:
- You are free to use, modify, and distribute this software.
- If you distribute modified versions, you must also distribute the source code.
- Any modifications or larger works must also be licensed under the GPLv3.

For more information about the GPLv3, visit [https://www.gnu.org/licenses/gpl-3.0.en.html](https://www.gnu.org/licenses/gpl-3.0.en.html).

---

This README serves as an aide-memoir for creating and managing an APT Repository on PiOS. For more detailed information about APT repositories, please refer to the official Debian documentation.
