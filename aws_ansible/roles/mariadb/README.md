Role Name
=========

Installs MariaDB package and its requirements and secures the installation

Requirements
------------

Nothing special.

Role Variables
--------------

* `mariadb_priv_user_passwd` - the root user password to pass


Dependencies
------------

None

Example Playbook
----------------

    - hosts: servers
      roles:
         - { role: mariadb,  mariadb_priv_user_passwd: p@ssw0rd }

License
-------

BSD

