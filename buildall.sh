#!/usr/bin/env bash

boards="console60k console138k"
# boards="console60k console138k mega60k mega138k primer25k"
# boards="console138k"

mkdir -p buildall
rm -f buildall/* 2>/dev/null || true

for b in $boards; do
  echo Building for board: $b

  make clean

  export TANG_BOARD="$b"
  make

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
