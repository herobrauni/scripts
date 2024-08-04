#!/bin/bash

paru -S --needed --noconfirm libfido2 ansible proxzima-plymouth-git
sudo plymouth-set-default-theme -R proxzima

