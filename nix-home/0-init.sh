#!/bin/bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

git clone git@github.com:herobrauni/nixos.git ~/.config/home-manager

#paru -S --needed --noconfirm ansible
