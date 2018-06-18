timestamp = $(shell date +%s)
image = jupyterhub:$(timestamp) 
build:
	docker build --tag crcsi/$(image) .

push: build
	docker push crcsi/$(image)
