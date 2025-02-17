.PHONY: *

init:
	python -m venv .venv
	source .venv/bin/activate
	pip install west
	west init -l config/
	west zephyr-export
	west update --fetch-opt=--filter=blob:none

update:
	west update --fetch-opt=--filter=blob:none

build:
	west build -s zmk/app \
		-d build/left \ # all build files end up here
		-b nice_nano_v2 \
		-- -DSHIELD=corne_left \
		-DZEPHYR_TOOLCHAIN_VARIANT=gnuarmemb \
		-DGNUARMEMB_TOOLCHAIN_PATH=/nix/store/i3m8xrhhnb7l83cpwdd9rlkcglpnxkw8-gcc-arm-embedded-12.3.rel1 \
		-DZMK_CONFIG=./config
	
	mkdir -p out/
	cp build/left/zephyr/zmk.{bin,uf2} 

clean:
	rm -rf firmware .west zmk
