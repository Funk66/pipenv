#!/usr/bin/env bash

# NOTE: set TEST_SUITE to be markers you want to run.

set -e

PYPI_VENDOR_DIR="$(pwd)/tests/pypi/"
export PYPI_VENDOR_DIR


if [[ ! -z "$TEST_SUITE" ]]; then
	TEST_SUITE=""
fi

if [[ ! -z "$CI" ]]; then
	echo "Using RAM disk…"

	RAM_DISK="/opt/ramdisk"
	export RAM_DISK

	echo "Installing Pipenv…"

	pip install -e . --upgrade --upgrade-strategy=only-if-needed
	pipenv install --deploy --system --dev

else
	echo "Using RAM disk (assuming MacOS)…"
	if [[ ! -d "/Volumes/RamDisk" ]]; then
		diskutil erasevolume HFS+ 'RAMDisk' $(hdiutil attach -nomount ram://8388608)
	fi


	RAM_DISK="/Volumes/RAMDisk"
	export RAM_DISK

	pipenv install --dev
fi

pipenv run time pytest -v -n auto tests -m "$TEST_SUITE" --tap-stream | tee report.tap