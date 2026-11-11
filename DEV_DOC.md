# Developer documentation

## Setup from scratch

**Prerequisites:** a Linux VM with Docker Engine, the Docker Compose plugin, `make`, `openssl` and `sudo`.

```sh
git clone <repo> inception && cd inception
make secrets     # creates srcs/.env from .env.example and generates secrets/*.txt
```

- `srcs/.env`: domain, data paths, DB name/user, WordPress users, bonus settings. Check `WP_DATA_PATH` / `DB_DATA_PATH` match your login.
- `secrets/`: `db_password.txt`, `db_root_password.txt`, `ftp_password.txt` (one value each) and `credentials.txt`:
  ```
  WP_ADMIN_PASSWORD=...
  WP_USER_PASSWORD=...
  ```

## Build and launch

```sh
make           # = make up: create data dirs + secrets, then docker compose up -d --build
make build     # build images only
make host      # add DOMAIN_NAME to /etc/hosts
make re        # down + up
```

The Makefile calls `docker compose -f srcs/docker-compose.yml`. Each image is built from `srcs/requirements/<service>/Dockerfile`.

## Managing containers and volumes

```sh
make ps | status    # containers, volumes, networks
make logs           # follow logs
make stop / start / restart
make down           # remove containers
make clean          # remove containers and volumes
make fclean         # also remove images and host data (sudo)
make prune          # fclean + docker system prune

docker exec -it wordpress sh               # shell in a container
docker exec mariadb mariadb -u root -p     # SQL prompt
docker volume inspect wordpress mariadb
```

## Data and persistence

| Volume      | Mounted in               | Host path                         |
|-------------|--------------------------|-----------------------------------|
| `wordpress` | wordpress, nginx, ftp    | `/home/mtaheri/data/wordpress`    |
| `mariadb`   | mariadb                  | `/home/mtaheri/data/mariadb`      |

Both are named volumes whose data is stored at the host path above, so it survives `make down` and rebuilds. Only `make clean` (volumes) and `make fclean` (host directories) delete it. The database and WordPress are only initialised when these directories are empty.
