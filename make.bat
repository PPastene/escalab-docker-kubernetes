@echo off


IF /I "%1"=="deps" GOTO deps
IF /I "%1"=="init-dev" GOTO init-dev
IF /I "%1"=="init-prod" GOTO init-prod
IF /I "%1"=="docker-compose-nginx" GOTO docker-compose-nginx
IF /I "%1"=="install-dev-docker" GOTO install-dev-docker
IF /I "%1"=="install-prod-docker" GOTO install-prod-docker
IF /I "%1"=="docker-compose-dev" GOTO docker-compose-dev
IF /I "%1"=="docker-compose-prod" GOTO docker-compose-prod
IF /I "%1"=="stop-docker" GOTO stop-docker
IF /I "%1"=="kubernetes-nginx" GOTO kubernetes-nginx
IF /I "%1"=="build-postgres" GOTO build-postgres
IF /I "%1"=="build-backend" GOTO build-backend
IF /I "%1"=="build-frontend" GOTO build-frontend
IF /I "%1"=="install-kubernetes" GOTO install-kubernetes
IF /I "%1"=="run-kubernetes" GOTO run-kubernetes
IF /I "%1"=="kubernetes" GOTO kubernetes
IF /I "%1"=="to-windows" GOTO to-windows
GOTO error

:deps
	git submodule init
	git submodule update
	GOTO :EOF

:init-dev
	XCOPY /Y env/postgres.dev.env .env 
	XCOPY /Y env/conduit.dev.env Conduit_NodeJS/.env 
	XCOPY /Y env/vue.dev.env vue3-realworld-example-app/.env 
	XCOPY /Y docker-compose/docker-compose.dev.yml docker-compose.yml 
	GOTO :EOF

:init-prod
	XCOPY /Y env/postgres.prod.env .env 
	XCOPY /Y env/conduit.prod.env Conduit_NodeJS/.env 
	XCOPY /Y env/vue.prod.env vue3-realworld-example-app/.env 
	XCOPY /Y docker-compose/docker-compose.prod.yml docker-compose.yml 
	GOTO :EOF

:docker-compose-nginx
	XCOPY /Y nginx/docker-compose-nginx.conf vue3-realworld-example-app/nginx.conf 
	GOTO :EOF

:install-dev-docker
	make deps
	make init-dev
	make docker-compose-nginx
	GOTO :EOF

:install-prod-docker
	make deps
	make init-prod
	make docker-compose-nginx
	GOTO :EOF

:docker-compose-dev
	make install-dev-docker
	docker-compose up --build
	GOTO :EOF

:docker-compose-prod
	make install-prod-docker
	docker-compose up --build
	GOTO :EOF

:stop-docker
	docker-compose down -v
	GOTO :EOF

:kubernetes-nginx
	XCOPY /Y nginx/kubernetes-nginx.conf vue3-realworld-example-app/nginx.conf 
	GOTO :EOF

:build-postgres
	docker run --rm --name postgres_kubernetes -p 5432:5432 --env-file .env -d postgres:13-alpine
	GOTO :EOF

:build-backend
	docker build -t realworld-backend ./Conduit_NodeJS
	GOTO :EOF

:build-frontend
	docker build --target production-stage -t realworld-frontend ./vue3-realworld-example-app
	GOTO :EOF

:install-kubernetes
	make deps
	make init-prod
	make kubernetes-nginx
	make build-postgres
	make build-backend
	make build-frontend
	GOTO :EOF

:run-kubernetes
	kubectl apply -f kubernetes/namespace.yaml
	kubectl apply -f kubernetes/backend-secret.yaml
	kubectl apply -f kubernetes/backend-deployment.yaml
	kubectl apply -f kubernetes/frontend-deployment.yaml
	GOTO :EOF

:kubernetes
	make install-kubernetes
	make run-kubernetes
	GOTO :EOF

:to-windows
	GOTO :EOF

:error
    IF "%1"=="" (
        ECHO make: *** No targets specified and no makefile found.  Stop.
    ) ELSE (
        ECHO make: *** No rule to make target '%1%'. Stop.
    )
    GOTO :EOF
