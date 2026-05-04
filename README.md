# ABO YUMA WordPress Docker Bitnami

<img src="assets/container-preview.png" width="650"/>  

**A simple Docker-based WordPress environment for local development using the Bitnami stack.**  
The purpose of this project is to simulate a local development environment closer to the AWS Lightsail WordPress Bitnami stack.

> 📝 NOTE: This project is provided as a reference setup.  
> Please rename the project, container names, database name, and environment variables as needed to match your own setup.

Reference: https://hub.docker.com/r/bitnami/wordpress

## 🧩 Project Structure

Example project structure:

```
aboyuma/                                 # Project workspace
├── aboyuma-wordpress/                   # WordPress development workspace
│   ├── aboyuma-wp-docker-bitnami/       # Infrastructure (this project)
│   ├── wordpress/                       # WordPress content (bind-mounted)
│   └── migration/                       # WordPress files / database backup
└── aboyuma-content/                     # WordPress content workspace
```

ℹ️ Bitnami stores only `wp-content` and `wp-config.php` in the mounted volume;  
the WordPress core remains inside the container.

## 🧑‍💻 Plugin & Theme Development

You can develop themes and plugins inside the bind-mounted WordPress directory:
```yaml
- ../wordpress:/bitnami/wordpress
```
Clone your plugin or theme repositories into:

```
wordpress/wp-content/themes
wordpress/wp-content/plugins
```
Because the WordPress content is bind-mounted, any changes made to plugin or theme files are persisted on the host machine.  
The files will remain intact even after running `docker compose down`.

## 🚀 Run Containers

```bash
docker compose up
```

## 🌐 Access

- WordPress Site:
  [http://localhost:8080](http://localhost:8080)

- WordPress Admin Dashboard:
  [http://localhost:8080/wp-admin](http://localhost:8080/wp-admin)

- phpMyAdmin:
  [http://localhost:8081](http://localhost:8081)

## 🔐 Default Credentials

### Database User
- Username: db_user
- Password: db_pass

### Database Root (phpMyAdmin / full access)
- Username: root (default MariaDB superuser)
- Password: root123

## 🗄️ Database Setup
This project uses a database dump for initialization.  

MariaDB data is stored using a Docker volume:

```yaml
volumes:
  - mariadb_data:/bitnami/mariadb
````

The database is initialized on first startup when the volume is empty.  
After initialization, all data is stored inside the Docker volume and will persist across container restarts.

To completely reset the database, the volume must be removed:

```bash
docker compose down -v
docker compose up
```
This deletes the existing database volume and initializes a fresh database.

## Migration note
Reference:  
https://developer.wordpress.org/advanced-administration/security/backup
