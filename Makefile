all: build

build:
	docker build --progress=plain -t jonasal/rsync:local .

run:
	docker run -it --rm \
	--network=host \
	-v $(PWD)/examples:/etc/rsyncd.d:ro \
	jonasal/rsync:local

dev:
	docker buildx build --platform linux/amd64,linux/386,linux/arm64,linux/arm/v7 --tag jonasal/rsync:dev .

push-dev:
	docker buildx build --platform linux/amd64,linux/arm64 --tag jonasal/rsync:dev --pull --no-cache --push .
