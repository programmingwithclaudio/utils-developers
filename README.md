## BASES DE DATOS CON `DOCKER-COMPOSE`

[![Tema de Colores](https://img.shields.io/badge/theme-gruvbox%20dark-brightgreen)](https://github.com/morhetz/gruvbox)
[![Estado](https://img.shields.io/badge/estado-stand%20by-yellowgreen)](https://github.com/programmingwithclaudio/dotfiles)
[![Licencia](https://img.shields.io/badge/licencia-MIT-blue)](https://opensource.org/licenses/MIT)

- **Mongo**
- Contiene el servicio mongo y interfaz mongo-express en el puerto `http://localhost:8080/`

```bash
docker compose up -d
docker volume create mongo-data
docker compose up -d
docker start <id_container_mongo:6.0>
# example docker start 3c4, solamante 3 digitos
# conecction
mongodb://root:crow@<ip_del_contenedor>/contracdb?authSource=admin
```

- Nota Login `http://localhost:8080/`: user:admin- password:admin
- Independientemente de automatizar por completo el Compose, lo mantengo así por motivos de practicar el flujo de los contenedores y su implementación a producción.
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
