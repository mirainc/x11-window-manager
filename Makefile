dev:
	docker-compose build
	docker-compose run -e DISPLAY=host.docker.internal:0 -e UDEV=0 main

push-balena:
	git push $(remote) $$(git rev-parse --abbrev-ref HEAD):master -f
