#!/bin/bash

# Descargar imagen ISO de Ubuntu 22.04.02 LTS
wget https://releases.ubuntu.com/22.04/ubuntu-22.04.2-live-server-amd64.iso

# Verificar el archivo de imagen ISO
sha256sum ubuntu-22.04.2-live-server-amd64.iso
