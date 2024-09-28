#!/usr/bin/env python3

"""
Script: sign_and_install_deb.py
Date: 2023-05-25
Author: Claude Dev
Reason: To automate the process of signing Debian packages and installing them in a repository,
        improving efficiency and reducing manual errors in the package management workflow.

This script signs a Debian package and installs it in a repository.

Example usage:
    python3 sign_and_install_deb.py /path/to/package.deb /path/to/repository /path/to/private_key.gpg

Make sure you have the necessary permissions to sign packages and modify the repository.
"""

import argparse
import subprocess
import os
import sys

def sign_and_install_deb(deb_file, repo_path, key_file):
    # Check if files exist
    if not os.path.isfile(deb_file):
        raise FileNotFoundError(f"Debian package file not found: {deb_file}")
    if not os.path.isdir(repo_path):
        raise NotADirectoryError(f"Repository directory not found: {repo_path}")
    if not os.path.isfile(key_file):
        raise FileNotFoundError(f"Private key file not found: {key_file}")

    # Sign the Debian package
    try:
        subprocess.run(['dpkg-sig', '--sign', 'builder', '-k', key_file, deb_file], check=True)
        print(f"Successfully signed {deb_file}")
    except subprocess.CalledProcessError as e:
        print(f"Error signing the Debian package: {e}", file=sys.stderr)
        sys.exit(1)

    # Install the signed package in the repository
    try:
        subprocess.run(['reprepro', '-b', repo_path, 'includedeb', 'stable', deb_file], check=True)
        print(f"Successfully installed {deb_file} in the repository at {repo_path}")
    except subprocess.CalledProcessError as e:
        print(f"Error installing the Debian package in the repository: {e}", file=sys.stderr)
        sys.exit(1)

def main():
    parser = argparse.ArgumentParser(description="Sign a Debian package and install it in a repository.")
    parser.add_argument("deb_file", help="Path to the .deb file")
    parser.add_argument("repo_path", help="Path to the repository")
    parser.add_argument("key_file", help="Path to the private key file")
    
    args = parser.parse_args()

    try:
        sign_and_install_deb(args.deb_file, args.repo_path, args.key_file)
    except Exception as e:
        print(f"An error occurred: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()