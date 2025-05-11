.ONESHELL: # allows us to use west without combining all calls into a single command

.PHONY: *

default: build # flash

init-python:
	python -m venv .venv
	. .venv/bin/activate
	pip install west

init:
	. .venv/bin/activate
	west init -l config/
	west update --fetch-opt=--filter=blob:none
	west zephyr-export

update:
	. .venv/bin/activate
	west update --fetch-opt=--filter=blob:none

build:
	. .venv/bin/activate

	echo -e "\nBuilding left...\n"
	west build -s zmk/app \
		-d build/left \
		-b nice_nano_v2 \
		-p auto \
		-- -DSHIELD=corne_left \
		-DZEPHYR_TOOLCHAIN_VARIANT=gnuarmemb \
		-DGNUARMEMB_TOOLCHAIN_PATH=/nix/store/i3m8xrhhnb7l83cpwdd9rlkcglpnxkw8-gcc-arm-embedded-12.3.rel1 \
		-DZMK_CONFIG=$(realpath ./config)

	echo -e "\nBuilding right...\n"
	west build -s zmk/app \
		-d build/right \
		-b nice_nano_v2 \
		-p auto \
		-- -DSHIELD=corne_right \
		-DZEPHYR_TOOLCHAIN_VARIANT=gnuarmemb \
		-DGNUARMEMB_TOOLCHAIN_PATH=/nix/store/i3m8xrhhnb7l83cpwdd9rlkcglpnxkw8-gcc-arm-embedded-12.3.rel1 \
		-DZMK_CONFIG=$(realpath ./config)
	
	mkdir -p out/
	cp build/left/zephyr/zmk.bin out/corne_left.bin
	cp build/left/zephyr/zmk.uf2 out/corne_left.uf2
	cp build/right/zephyr/zmk.bin out/corne_right.bin
	cp build/right/zephyr/zmk.uf2 out/corne_right.uf2

flash-left:
	cp out/corne_left.bin /dev/ttyACM0
flash-right:
	cp out/corne_right.bin /dev/ttyACM0

clean:
	rm -rf out/*

clean-all:
	rm -rf firmware .west zmk build
