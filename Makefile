.PHONY: deps init-dev init-prod docker-compose kubernetes

deps:
	git submodule init
	git submodule update

init-dev:
	cp env/postgres.dev.env .env
	cp env/conduit.dev.env Conduit_NodeJS/.env
	cp env/vue.dev.env vue3-realworld-example-app/.env
	cp docker-compose/docker-compose.dev.yml docker-compose.yml

init-prod:
	cp env/postgres.prod.env .env
	cp env/conduit.prod.env Conduit_NodeJS/.env
	cp env/vue.prod.env vue3-realworld-example-app/.env
	cp docker-compose/docker-compose.prod.yml docker-compose.yml

docker-compose-nginx:
	cp nginx/docker-compose-nginx.conf vue3-realworld-example-app/nginx.conf

install-dev-docker:
	make init-dev
	make docker-compose-nginx

install-prod-docker:
	make init-prod
	make docker-compose-nginx

docker-compose-dev:
	make install-dev-docker
	docker-compose up --build

docker-compose-prod:
	make install-prod-docker
	docker-compose up --build

stop-docker:
	docker-compose down -v

kubernetes-nginx:
	cp nginx/kubernetes-nginx.conf vue3-realworld-example-app/nginx.conf

build-postgres:
	docker run --rm --name postgres_kubernetes -p 5432:5432 --env-file .env -d postgres:13-alpine

build-backend:
	docker build -t realworld-backend ./Conduit_NodeJS

build-frontend:
	docker build --target production-stage -t realworld-frontend ./vue3-realworld-example-app

install-kubernetes:
	make init-prod
	make kubernetes-nginx
	make build-postgres
	make build-backend
	make build-frontend

run-kubernetes:
	kubectl apply -f kubernetes/namespace.yaml
	kubectl apply -f kubernetes/backend-secret.yaml
	kubectl apply -f kubernetes/backend-deployment.yaml
	kubectl apply -f kubernetes/frontend-deployment.yaml

kubernetes:
	make install-kubernetes
	make run-kubernetes

clean:
	kubectl delete --all deployment -n realworld
	kubectl delete --all svc -n realworld
	kubectl delete --all secret -n realworld
	kubectl delete namespace realworld
	docker stop postgres_kubernetes

to-windows:
#https://github.com/espositoandrea/Make-to-Batch
	make-to-batch -i Makefile -o make.bat