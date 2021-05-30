# Escalab Docker y Kubernetes
## Requisitos
* Sistema operativo con posibilidad de correr contenedores Docker
* Docker y Docker Compose
* Kubernetes (kubectl o minikube)
* Git
* Google Cloud SDK CLI
## Preparación del ambiente
1. Clonar repositorio con `git clone https://github.com/PPastene/escalab-docker-kubernetes --recursive`
## Ejecución en local con docker-compose.yml
1. Asegurese de tener Docker y Docker Compose instalado, verificar con `docker version` y `docker-compose version` en consola
2. Copiar y renombrar los siguientes archivos: 
    * `cp docker-compose/docker-compose-prod.yml docker-compose.yml`
    * `cp env/mariadb.prod.env .env`
    * `cp env/conduit.prod.env Conduit_NodeJS/.env`
    * `cp env/vue.prod.env vue3-realworld-example-app/.env`
    * `cp nginx/docker-compose-nginx vue3-realworld-example-app/nginx.conf`
3. Ejecutar `docker-compose up --build` para levantar los contenedores incluyendo la base de datos local
4. Ingrese al frontend con http://localhost:3000
5. Para detener los contenedores presione la commbinación de teclas Ctrl+C (Cmd+C en Mac). Para ademas eliminar los volumenes y redes creadas ejecute `docker-compose down -v` en consola
## Ejecución en local con kubectl
1. Si usa Docker Desktop, habilite Kubernetes en el menú de opciones, en Linux instalar Minikube. Escriba `kubectl version` en consola para ver si está instalado
2. Copiar y renombrar los siguientes archivos:
    * `cp env/mariadb.prod.env .env`
    * `cp env/conduit.prod.env Conduit_NodeJS/.env`
    * `cp nginx/kubernetes-nginx vue3-realworld-example-app/nginx.conf`
3. Construir las imagenes:
    * `docker run --rm --name mariadb_kubernetes -p 3306:3306 --env-file .env -d mariadb:10.6.1`
    * `docker build -t realworld-backend ./Conduit_NodeJS`
    * `docker build --target production-stage -t realworld-frontend ./vue3-realworld-example-app`
4. Tenga a mano la IP del equipo, en Windows escriba `ipconfig` en consola mientras que en Mac/Linux escriba `ifconfig` en terminal
5. En el archivo `kubernetes/backend-secret.yaml` cambiar el valor de la variable `DB_HOST` por la IP obtenida en el paso anterior
6. Aplique los siguientes archivos de Kubernetes:
    * `kubectl apply -f namespace.yaml`
    * `kubectl apply -f backend-secret.yaml`
    * `kubectl apply -f backend-deployment.yaml`
    * `kubectl apply -f frontend-deployment.yaml`
7. Verifique que los archivos se hayan aplicado correctamente con `kubectl get all -n realworld`
8. Ingrese al frontend con http://localhost
9. Para eliminar el deployment local de Kubernetes ejecute los siguientes comandos:
    * `kubectl delete namespace realworld`
## Deployment a Google Cloud Platform