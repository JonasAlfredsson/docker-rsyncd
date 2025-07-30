all: build

build:
	docker build --progress=plain -t jonasal/rsyncd:local .

run:
	docker run -it --rm \
	--network=host \
	-v '/etc/passwd:/etc/passwd:ro' \
	-v '/etc/group:/etc/group:ro' \
	-v $(PWD)/examples:/etc/rsyncd.d:ro \
	jonasal/rsyncd:local

dev:
	docker buildx build --platform linux/amd64,linux/386,linux/arm64,linux/arm/v7 --tag jonasal/rsyncd:dev .

push-dev:
	docker buildx build --platform linux/amd64,linux/arm64 --tag jonasal/rsyncd:dev --pull --no-cache --push .
