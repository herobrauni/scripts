#!/bin/bash
#paru -S --needed --noconfirm ansible
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
