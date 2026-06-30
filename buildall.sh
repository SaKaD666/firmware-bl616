#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(cd "$SCRIPT_DIR/.." && pwd)

export PATH="$PATH:$ROOT_DIR/toolchain_gcc_t-head_macos/bin"

DEFAULT_BL_SDK_BASE="$ROOT_DIR/bouffalo_sdk"
if [ -n "${BL_SDK_BASE-}" ] && [ -d "$BL_SDK_BASE" ]; then
    echo "Using BL_SDK_BASE from environment"
elif [ -d "$DEFAULT_BL_SDK_BASE" ]; then
    BL_SDK_BASE="$DEFAULT_BL_SDK_BASE"
else
    echo "Error: SDK path not found at $DEFAULT_BL_SDK_BASE" >&2
    exit 1
fi
export BL_SDK_BASE

MAKE=make
if command -v gmake >/dev/null 2>&1; then
    MAKE=gmake
fi

echo "Using make command: $MAKE"

 boards="console60k console138k"
# boards="console60k console138k mega60k mega138k primer25k"
# boards="console138k"

mkdir -p buildall
rm -f buildall/* 2>/dev/null || true

for b in $boards; do
  echo Building for board: $b

  $MAKE clean

  export TANG_BOARD="$b"
  $MAKE

  if [ $? -eq 0 ]; then
    echo Build successful for $b

    cp -f build/build_out/tangcore_bl616.bin buildall/tangcore_${b}.bin

    if [ "$b" = "console60k" ]; then
      cp -f bl616_fpga_partner_Console.bin buildall/bl616_fpga_partner_${b}.bin
    elif [ "$b" = "console138k" ]; then
      cp -f bl616_fpga_partner_Console.bin buildall/bl616_fpga_partner_${b}.bin
    elif [ "$b" = "mega60k" ]; then
      cp -f bl616_fpga_partner_138k60kNeoDock.bin buildall/bl616_fpga_partner_${b}.bin
    elif [ "$b" = "mega138k" ]; then
      cp -f bl616_fpga_partner_138k60kNeoDock.bin buildall/bl616_fpga_partner_${b}.bin
    elif [ "$b" = "primer25k" ]; then
      cp -f bl616_fpga_partner_25kDock.bin buildall/bl616_fpga_partner_${b}.bin
    elif [ "$b" = "nano20k" ]; then
      cp -f bl616_fpga_partner_20kNano.bin buildall/bl616_fpga_partner_${b}.bin
    fi

    sed -e "s/bl616_fpga_partner\.bin/bl616_fpga_partner_${b}.bin/g" -e "s/tangcore\.bin/tangcore_${b}.bin/g" flash.ini > buildall/flash_${b}.ini
  else
    echo Build failed for $b
  fi

  echo
done

echo
echo Contents of buildall directory:
ls -1 buildall || true
