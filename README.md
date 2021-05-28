# Escalab Docker y Kubernetes
## Requisitos
* Sistema operativo con posibilidad de correr contenedores Docker
* Docker y Docker Compose
* Kubernetes (kubectl o minikube)
* Git
## Preparación del ambiente
1. Asegurese de tener git instalado, para comprobar escriba git version en consola
2. Clonar repositorio con `git clone https://github.com/PPastene/escalab-docker-kubernetes --recursive`
3. En la raíz del proyecto copiar el archivo .env.example y renombrarlo a .env, luego setear las variables de entorno de la base de datos
4. En Conduit_NodeJS copiar el archivo `.env.example` y renombrarlo a `.env`, luego setear las variables de conexion a la base de datos (para su ejecución en local tienen que coincidir con las variables seteadas en la raiz del proyecto)
    * DB_HOST debe apuntar al nombre del servicio de la DB indicado en docker-compose.yml
    * DB_PORT debe apuntar al puerto indicado dentro del servicio de la DB en docker-compose.yml
    * DB_USER, DB_PASS y DB_NAME deben coindidir con las variables POSTGRES_USER, POSTGRES_PASSWORD y POSTGRES_DB respectivamente ubicadas en la raiz del proyecto.
5. En vue3-realworld-example-app abrir el archivo nginx.conf escribir el valor en proxy_pass dependiendo del caso de uso:
    * Si se ejecutará en Docker Compose escribir http://server:8080;
    * Si se ejecutará en Kubernetes en local escribir http://backend-service.realworld.svc.cluster.local:8080;
        - Además descomente la linea 8 con el resolver de DNS de Kubernetes (o comentar linea si se usará Docker compose)
## Ejecución en local con docker-compose.yml
1. Asegurese de tener Docker y Docker Compose instalado, para verificar escriba `docker version` y `docker-compose version` en consola
2. En la raíz del proyecto abrir el archivo docker-compose.yml, asegurarse que la propiedad target dentro de build en client esté definida como production-stage para construir la imagen en produccion
    - Para ejecutar el proyecto en desarrollo, cambie el valor de target a development-stage, dentro de vue3-realworld-example-app copie el archivo .env.example y nombrelo a .env, y cambie el valor de VITE_API_HOST a http://localhost:8080 (el archivo .env no se usará en produccion)
3. Ejecute `docker-compose.yml up --build` para construir las imagenes, descargar la imagen de postgresql y levantar los contenedores. Esto tomará un par de minutos dependiendo de la potencia de su PC (puede agregar la opcion -d para levantar los contenedores en modo detached)
4. Una vez construida las imagenes, ingrese al frontend desde http://localhost
5. Para detener la ejecución en Docker Compose ejecute `docker-compose down` (puede agregar la opcion -v para ademas eliminar el network y volumes creados)
## Ejecución en local con kubectl
1. En Windows o Mac si se usa Docker Desktop habilite Kubernetes en el menú de opciones, en Linux se recomienda usar minikube para levantar un nodo de prueba en kubernetes. Para verificar que Kubernetes esté funcionando ejecute `kubectl version` en consola
2. En la raíz del proyecto copie el archivo `.env.example` y renombrelo a `.env` si es que no está creado, luego ejecute `docker run --rm --name postgres_example -p 5432:5432 --env-file .env -d postgres:13-alpine` para correr un contenedor de PostgreSQL
3. Dentro de vue3-realworld-example-app abra nginx.conf y edite lo siguiente
    * Descomentar linea 8 con el resolver de DNS de kubernetes
    * En proxy_pass setear el siguiente valor http://backend-service.realworld.svc.cluster.local:8080;
4. Construya las imagenes con `docker build -t realworld-backend ./Conduit_NodeJS` y `docker build --target production-stage -t realworld-frontend ./vue3-realworld-example-app`
5. En Windows escriba `ipconfig` o en Mac/Linux escriba `ifconfig` en consola y anote la IP local del equipo
6. En al raiz del proyecto copie el archivo `backend-secret.yaml.example` y nombrelo `backend-secret.yaml`, luego setee las variables de entorno
    - En DB_HOST escriba la IP del equipo local
    - En DB_USER, DB_PASS y DB_NAME escriba los valores que aparecen en las variables de entorno de la base de datos ubicadas en .env
7. Ejecute los siguientes comandos de Kubernetes:
    * kubectl apply -f namespace.yaml
    * kubectl apply -f backend-secret.yaml
    * kubectl apply -f backend-deployment.yaml
    * kubectl apply -f frontend-deployment.yaml
9. Una vez ejecutado lo anterior, verifique si los servicios pods se han levanmtado con `kubectl get all -n realworld`, luego ingrese al frontend desde http://localhost