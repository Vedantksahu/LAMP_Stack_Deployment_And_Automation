# Task 1 — LAMP Stack in Docker

## Files
- `Dockerfile` — Nginx + PHP-FPM image
- `nginx.conf` — Nginx site config, proxies `.php` to PHP-FPM
- `start.sh` — starts php-fpm then nginx inside the container
- `index.php` — connects to MySQL and prints a success/failure message
- `docker-compose.yml` — wires the web container to a MySQL container

## Run it (recommended: docker-compose)
```bash
cd task1-docker
docker compose up --build
```
Visit http://localhost:80 — you should see "Hello, World! Your MySQL connection is successful."

## Run it manually (without compose, to prove you understand the pieces)
```bash
# 1. Create a network so the containers can resolve each other by name
docker network create lampnet

# 2. Start MySQL
docker run -d --name mysql --network lampnet \
  -e MYSQL_ROOT_PASSWORD=rootpassword \
  -e MYSQL_DATABASE=lampdb \
  mysql:8.0

# 3. Build the web image
docker build -t lamp-web .

# 4. Run the web container, pointing DB_HOST at the mysql container's name
docker run -d --name web --network lampnet -p 80:80 \
  -e DB_HOST=mysql -e DB_USER=root -e DB_PASSWORD=rootpassword -e DB_NAME=lampdb \
  lamp-web
```

## Teardown
```bash
docker compose down -v
```
