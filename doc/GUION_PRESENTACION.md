# GUIÓN DE LA PRESENTACIÓN


## PREPARACIÓN DE LA CONEXIÓN SSH

- Generamos par de claves ssh con:
``ssh-keygen -t ed25519 -C "ansible"``

- Añadimos la clave pública en el cliente:
```ssh-copy-id -i ~/.ssh/ansible.pub <ip_host>```

El cliente debe tener el servicio ssh inicializado. 

- Después de esto, podremos hacer el siguiente comando sin indicar la clave
`` ssh <ip_host>``

* Después, desde el servicio ejecutar el siguiente comando para comprobar la conectividad con todos los hosts
``ansible all -m ping -KK``

***

## CÓMO CONSTRUIR DOS PERFILES: UNO POR DEFECTO Y OTRO ALTERNATIVO

Podemos definir los roles como una estructura de ficheros y directorios organizados de manera que permiten implementar una lógica más avanzada y ordenada, de las que podemos realizar en un playbook. Nos permitirá reutilizar nuestras tareas más fácilmente, ya que puede ser reutilizado por otros playbook. 

Ansible comenzará la ejecución del rol por el fichero tasks/main.yml.

Un rol es indivisible de un playbook, de forma que un rol no puede ser llamado fuera del contexto de un playbook. 

Ansible permite crear un rol mediante:

`` ansible-galaxy init <rol_a_crear>``

De forma, que para crear un rol por defecto y otro alternativo, deberemos crear un directorio /roles para almacenarlos y, dentro de este, realizar los siguientes comandos:

``ansible-galaxy init default``

``ansible-galaxy init alternativo``

El comando anterior nos crea un subdirectorio con las siguientes carpetas y archivos predefinidos:

* **defaults**: contiene el fichero de variables por defecto del rol
* **files**: ficheros estáticos a desplegar por el rol (ej. licencias)
* **handlers**: controladores de eventos
* **meta**: contiene metadatos que pueden ser usados
* **tasks**: ficheros para las tareas a realizar por el rol
* **templates**: plantillas a desplegar por el rol
* **vars**: contiene ficheros con otras variables a utilizar

La estructura sería la siguiente:

alternativo/  
├── defaults  
│   └── main.yml  
├── handlers  
│   └── main.yml  
├── meta  
│   └── main.yml  
├── README.md  
├── tasks  
│   └── main.yml  
├── tests  
│   ├── inventory  
│   └── test.yml  
└── vars  
    └── main.yml  


La lógica que queremos ejecutar en el rol debe definirse en el archivo **/task/main.yaml**. Por ejemplo, en mi role alternativo es algo así:

```
#Código /roles/alternativo/tasks/main.yaml
---
# tasks file for alternativo
- name: Mostrar mensaje por pantalla
  debug:
    msg: "Se ha aplicado un rol alternativo"

- name: Instalar MariaDB
  become: true
  apt:
    name: mariadb-server
    state: present
```


Dos conceptos también importantes, aunque no los utilizaré en la demostración, son los siguientes:

- **handlers**, que sirve para añadir una notificación después de una tarea, de forma que reiniciará el servicio si una configuración ha cambiado (en caso contrario continuará)
- **templates** Jinja2 (python), que nos permitirá añadir una lógica algo más avanzada

***

## CONSTRUIR NODO CON PERFIL POR DEFECTO 

```
#Código playbook_defecto.yaml
---
- name: Aplicar role por defecto a un nodo
  hosts: all
  become: true
  roles:
    - default
```



***

## CÓMO ESTABLECER QUÉ PERFIL DEBE APLICARSE A UN NODO

Esto se logra mediante la etiqueta "roles" dentro del playbook de ejecución. En este caso, indicamos que queremos utilizar el rol por defecto a todos los hosts del inventario. 

```
#Código playbook_defecto.yaml
---
- name: Aplicar roles a los hosts
  hosts: all
  become: true
  roles:
    - default
```


***

## CONSTRUIR NODO CON PERFIL ALTERNATIVO SEGÚN MAC/IP

A continuación voy a mostrar distintas opciones, bastante similares entre sí, de realizar esta tarea. 

#### Role por defecto para todos y alternativo para un subgrupo de hosts

Esta tarea no es exactamente lo que se pide en el caso de uso, pero se utiliza con mucha frecuencia en niveles mayores. 
En el siguiente ejemplo se aplica el role default a todos los hosts, mientras que a los hosts del grupo "subred1" se les aplica también el role alternativo.

```
#Código asignar_roles.yaml
---
- name: Aplicar roles a los hosts
  hosts: all
  become: true
  roles:
    - default

- name: Aplicar roles a los hosts de subred1
  hosts: subred1
  become: true
  roles:
    - alternativo
```



Aplicar una serie de tareas a todos los hosts, como actualizaciones o comprobaciones de estados previas, se realiza en todos los procesos de automatización. Estas tareas se conocen como "pre-tasks". Un ejemplo sencillo para mostrar esto puede ser el siguiente (ejemplo_avanzado.yaml):

```
#Código ejemplo_avanzado.yaml
---

- hosts: all
  become: true
  pre_tasks:

  - name: install updates (Ubuntu)
    apt:
      update_cache: yes
    when: ansible_distribution == "Ubuntu"


- hosts: subred1
  become: true
  tasks:

  - name: install kubernetes y docker
    apt:
      name:
        - kubernetes
        - docker
      state: latest
    when: ansible_distribution == "Ubuntu"


- hosts: subred2
  tasks:
   - name: hacer ping
     ping:

```


#### Asignar role por defecto para todas las máquinas excepto para un grupo de hosts, que tendrán role alternativo

El siguiente ejemplo muestra cómo asignar un role por defecto para todas las máquinas y un role alternativo para aquellos hosts que determine el operador, que en este caso son aquellos hosts que pertenecen al grupo "subred1". Esto se consigue mediante el uso del condicional **when**, que en este caso asigna el role default a aquellos grupos del inventario que sean distintos de "subred1".  En los hosts de "subred1", al realizar la tarea "Asignar rol por defecto", nos mostrará "skipping", lo que indica que esta tarea se salta en dichos hosts.

```
#Código asignar_roles_condicional.yaml
---
- name: Asignar rol por defecto a todos los hosts                          
  hosts: all
  tasks:
    - name: Aplicar rol por defecto
      include_role:
        name: default
      when: "'subred1' not in group_names"

- name: Aplicar rol alternativo a subgrupo
  hosts: subred1
  roles:
    - alternativo

```


#### Asignar role por defecto para todas las máquinas excepto para un grupo de hosts, que tendrán role alternativo en función de su MAC

El siguiente código muestra cómo asignar un role alternativo a un nodo en función de su dirección MAC. En este caso, se restringe a un único host y no al grupo completo. 

Para ello, debemos añadir una variable a todos los hosts en el archivo inventario, indicando su dirección MAC, en mi caso utilizando la variable "ansible_mac_address" a la que haremos referencia posteriormente en el playbook:

```
#Código inventario

[subred1]
192.168.6.168 ansible_mac_address=00:0c:29:94:b7:28


[subred2]
192.168.6.50 ansible_mac_address=00:0c:29:50:68:45


```


El código del playbook será el siguiente, que utilizará condicionales para seleccionar a qué hosts se aplica el role (al igual que en el ejemplo anterior):
```
#Código asignar_roles_MAC.yaml
---
- name: Asignar rol por defecto a todos los hosts                          
  hosts: all
  tasks:
    - name: Aplicar rol por defecto
      include_role:
        name: default
      when: "'00:0c:29:94:b7:28' not in hostvars[inventory_hostname]['ansible_mac_address']"

- name: Aplicar rol alternativo a subgrupo
  hosts: subred2
  roles:
    - alternativo

```



***
***
***


## EJECUCIÓN REMOTA DESDE EL NODO DE CONTROL (Extra)

Una funcionalidad que seguramente tengamos que explotar en las prácticas será la ejecución de código remota desde el nodo de control, ya sea para realizar algún tipo de comprobación o para inicializar algún software. Para ello muestro el siguiente código, que ejecuta un cómando en la shell del nodo remoto y lo muestra por pantalla, ejecutando ls -l sobre el directorio /home para mostrar los usuarios existentes en la máquina.

```
---
- name: Ejecutar comando Bash en el host remoto
  hosts: subred1
  become: true
  gather_facts: false
  tasks:
    - name: Ejecutar comando Bash
      shell: ls -l /home
      register: output

    - name: Imprimir salida
      debug:
        var: output.stdout_lines
```


***


## USO DE ESTADOS PARA BORRAR CONFIGURACIONES (Extra)

Una de las formas que nos facilita Ansible para borrar, crear o actualizar aplicaciones, usuarios o configuraciones es mediante el uso del parámetro "state", y sus diferentes valores. 

Por ejemplo, hemos visto cómo instalar software en los nodos remotos, pero veremos ahora cómo borrar alguna configuración o instalación que hayamos hecho por error o que simplemente haya que eliminar. 

El siguiente código muestra cómo instalar kubernetes en todos los hosts del inventario:

```
---

- hosts: all
  become: true
  tasks:

  - name: install kubernetes package
    apt:
      name:
        - kubernetes
      state: latest
      update_cache: yes

```

Prestar especial atención al parámetro state. Algunos de los valores que puede tener este parámetro son los siguientes (los que he usado yo):

-   present: nos indica que un recurso debe estar presente. Ansible es idempotente, por lo que si este recurso ya existe no hará nada. Pero en caso contrario, lo instalará. 

-   absent: nos indica que un recurso no debe estar presente. Ansible es idempotente, por lo que si este recurso no existe no hará nada. Pero en caso contrario, lo borrará.

-  latest: se utiliza  para asegurar que el paquete de software especificado esté actualizado.

El siguiente código nos muestra cómo desinstalar kubernetes de todos los hosts: 

```
---
- hosts: all
  become: true
  tasks:

  - name: uninstall kubernetes package
    apt:
      name: kubernetes
      state: absent
```


De igual forma, podemos añadir y quitar usuarios de los host remotos, algo que proporciona un gran grado de automatización para el trabajo de los operadores que vayan a manipular los nodos. 
El siguiente código muestra cómo crear el usuario "Diego" en los hosts de la subred1:

```
---
- name: Crear usuario Diego
  hosts: subred1
  become: true
  tasks:
    - name: Crear usuario Diego
      user:
        name: Diego
        comment: "Diego Dorado"
        password: "{{ 'prueba' | password_hash('sha512') }}"
        state: present

```

Y a continuación muestro cómo eliminar este usuario y su directorio propio en /home: 

```
---
- name: Borrar usuario Diego
  hosts: subred1
  become: true
  tasks:
    - name: Borrar usuario Diego
      user:
        name: Diego
        state: absent

    - name: Borrar directorio del usuario Diego
      file:
        path: "/home/Diego"
        state: absent
        force: yes
```

Esto puede ser muy útil cuando se haya añadido previamente un usuario con permisos y que posteriormente no trabaje en el equipo/empresa. Una medida importante de seguridad será eliminar sus permisos para que no pueda manipular el proyecto. 

