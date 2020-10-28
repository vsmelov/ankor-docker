# ankor-docker
Тестовое задание для компании Анкор
Создает докер с samtools и biobambam2

## Build

```bash
git clone https://github.com/vsmelov/ankor-docker
cd ankor-docker
docker build -t ankor .
```

## Run

Для запуска нужно примонтировать локальную директорию с данными для работы внутрь докера.
Предположим, что данные хранятся в /my/local/data

Тогда для запуска интерактивного bash:

```bash
docker run -ti -v /my/local/data:/data ankor bash
```

Для запуска конкретной команды:

```bash
docker run -v /my/local/data:/data ankor bamsort --help
```
