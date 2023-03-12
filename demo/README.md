# Ansible
Repositorio trabajo teórico Gestión y Administración de Red

## Archivos de configuración y listado de hosts

- **ansible.cfg** : indica el inventario y claves ssh a usar por defecto, para evitar introducir ambos continuamente por línea de comandos

- **inventario**: listado de nodos o host asociados

## Ejemplos de archivos YAML

- **install_kubernetes.yml / uninstall_kubernetes.yml** : ejemplos de playbook para mostrar la sincronización de los nodos con el maestro y el uso de apt 

## Ejemplos de creación de nodos con perfiles

- **playbook_defecto.yaml**: archivo dónde muestro como crear un nodo asignandole un rol por defecto.

- **asignar_roles.yaml**: archivo dónde muestro cómo asignar un rol por defecto a un grupo de host y otro rol alternativo a otro grupo de hosts

- **asignar_roles_condicional.yaml**: archivo dónde muestro cómo asignar un rol por defecto a todos los hosts y un rol alternativo en función de la IP (realmente en función del grupo al que pertenece el host)

## Ejemplo de lo que podría ser un playbook con el uso de roles, realizando distintas tareas o instalaciones en función del grupo al que pertenezca el host. 

- **ejemplo_avanzado.yaml**: ejemplo de un playbook "real", distinguiendo tareas en función del grupo de hosts. 

## EJEMPLOS EXTRA
Distintos archivos yaml para mostrar algunas utilidades básicas de Ansible por si me diese tiempo a exponerlo en clase. Estas utilidades son el uso del parámetro state y el uso de la shell del host remoto.

- **crear_usuario.yaml**: muestra cómo crear un usuario en un host remoto.

- **borrar_usuario.yaml**: borra el usuario creado y su directorio propio de /home

- **ejecucion_remota.yaml**: muestra el uso de la shell del host remoto.

## Carpeta /roles
Carpeta donde almaceno los ficheros respectivos de los roles "default" y "alternativo".
