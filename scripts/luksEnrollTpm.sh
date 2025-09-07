#!/usr/bin/env bash

sudo systemd-cryptenroll --wipe-slot tpm2 --tpm2-device=auto --tpm2-pcrs=0+7 /dev/disk/by-partlabel/root
