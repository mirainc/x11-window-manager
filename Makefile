dev:
	docker-compose build
	docker-compose run -e DISPLAY=host.docker.internal:0 -e UDEV=0 main
