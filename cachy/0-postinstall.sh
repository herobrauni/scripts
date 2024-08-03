#!/bin/bash

paru -S --needed --noconfirm libfido2 ansible

eval "$(ssh-agent -s)"
ssh-add -K
mkdir ~/.ssh
cd ~/.ssh
ssh-keygen -K

mv id_ed25519_sk_rk id_ed25519_sk
mv id_ed25519_sk_rk.pub id_ed25519_sk.pub


