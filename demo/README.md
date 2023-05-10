# Ansible
Repositorio trabajo teórico Gestión y Administración de Red

## Archivos de configuración y listado de hosts

- **ansible.cfg** : indica el inventario y claves ssh a usar por defecto, para evitar introducir ambos continuamente por línea de comandos

- **inventario**: listado de nodos o host asociados


# SEGUNDA ENTREGA

Para este trabajo haré uso de los siguientes archivos:

- **nodos.yaml**: manifiesto en el que definimos los nuevos nodos a añadir en el inventario, definiendo su IP, MAC y el node_role que queremos que se les aplique. En esta ocasión, el node_role y el host group será el mismo con el fin de simplificar la tarea, a la vez de ser lo más parecido a las prácticas en entornos reales.
 
- **sh_ssh_nodos.sh**: script encargado de leer las IPs del archivo de inventario y ejecutar el ssh-copy-id para pasar las claves públicas a los distintos nodos remotos. Hago uso también de sshpass, que con el parámetro -f <fichero>, pasa directamente la clave para evitar que nos pida la clave de root de dichos nodos remotos. Esto funciona ya que ambos nodos tienen la misma clave. Si se desea probar, se debería cambiar la ruta del archivo password.txt. 

- **cambiar_inventario.yaml**: playbook que se encarga de sobreescribir el archivo de inventario con los nuevos nodos definidos en el archivo nodos.yaml. No lo he utilizado durante la demostración, pero puede ser útil si queremos crear un inventario desde 0 o borrar todos los nodos anteriores.

- **add_nodos.yaml**: es el playbook encargado de añadir los nuevos nodos al archivo de inventario a partir de un manifiesto yaml que indique los nodos que queremos añadir. Añade y no reescribe, por lo que puede ser útil para entornos reales dónde se tenga que añadir nuevos nodos sin eliminar los anteriores y evitar hacerlo uno por uno o directamente en el inventario, pudiendo evitar así posibles errores. A su vez, también se encarga de ejecutar el script sh_ssh_nodos.sh que pasa los certificados ssh a los nodos remotos. Crea también un host_group llamado nuevos, con los que trabajaremos para pasar las notificaciones.
  
- **notify.yaml** playbook que se encarga de simular las instalaciones propias de cada rol, así como de pasar el comando curl que deben ejecutar los nodos remotos para crear la notificación de Telegram.

---
  
# PRIMERA ENTREGA

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
