### DOCKER

- **Mongo**

```bash
docker compose up -d
docker volume create mongo-data
docker compose up -d
# conecction
mongodb://root:crow@<ip_del_contenedor>/contracdb?authSource=admin
```

- Nota:admin-admin

- **Redis**

```bash
docker compose up -d
# test
docker exec -it redis_db redis-cli -a admin
#PING devuelve PONG
# conecction
redis://:admin@172.21.0.2:6379
```

- **Postgres**

```bash
docker compose up -d
docker volume create postgres-db
docker compose up -d
# conecction
postgres://postgres:mailito@172.18.0.2/dashboardApp
```
