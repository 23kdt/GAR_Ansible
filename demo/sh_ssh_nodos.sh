#!/bin/bash

# Variables
ssh_key_file="/home/kdt23/.ssh/ansible.pub"
inventory_file="inventario"

# Iterar sobre las direcciones IP del archivo inventario
grep -Eo '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' $inventory_file | while read ip_address; do
  # Ejecutar ssh-copy-id
  output=$(sshpass -f /home/kdt23/.password.txt ssh-copy-id -i $ssh_key_file $ip_address 2>&1) # Redireccionar stderr a stdout
  if echo "$output" | grep -q "WARNING: All keys were skipped"; then
    echo "La clave ya existe en $ip_address, se omite"
  else
    echo "La clave se ha añadido correctamente en $ip_address"
  fi
done

