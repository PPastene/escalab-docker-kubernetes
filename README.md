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
    * `cp env/conduit.prod.env Conduit_NodeJS/.env`
    * `cp env/vue.prod.env vue3-realworld-example-app/.env`
    * `cp nginx/docker-compose-nginx vue3-realworld-example-app/nginx.conf`
3. Ejecutar `docker-compose up --build` para levantar los contenedores incluyendo la base de datos local
4. Ingrese al frontend con http://localhost:3000
5. Para detener los contenedores presione la commbinación de teclas Ctrl+C (Cmd+C en Mac). Para ademas eliminar los volumenes y redes creadas ejecute `docker-compose down -v` en consola
## Ejecución en local con kubectl
1. Si usa Docker Desktop, habilite Kubernetes en el menú de opciones, en Linux instalar Minikube. Escriba `kubectl version` en consola para ver si está instalado
2. Copiar y renombrar los siguientes archivos:
    * `cp nginx/kubernetes-nginx vue3-realworld-example-app/nginx.conf`
3. Construir las imagenes:
    * `docker build -t realworld-backend ./Conduit_NodeJS`
    * `docker build --target production-stage -t realworld-frontend ./vue3-realworld-example-app`
4. Aplique los siguientes archivos de Kubernetes:
    * `kubectl apply -f kubernetes/namespace.yaml`
    * `kubectl apply -f kubernetes/mariadb-deployment.yaml`
    * `kubectl apply -f kubernetes/backend-secret.yaml`
    * `kubectl apply -f kubernetes/backend-deployment.yaml`
    * `kubectl apply -f kubernetes/frontend-deployment.yaml`
5. Verifique que los archivos se hayan aplicado correctamente con `kubectl get all -n realworld`
6. Ingrese al frontend con http://localhost:3000
7. Para eliminar todo el deployment local de Kubernetes ejecute el siguiente comando:
    * `kubectl delete namespace realworld`
## Deployment a Google Cloud Platform
### Creación de Cluster y push de imagenes
1. Asegurarse de tener Google Cloud SDK CLI instalado, verificar con `gcloud version`
2. Copiar y renombrar los siguientes archivos:
    * `cp nginx/kubernetes-nginx vue3-realworld-example-app/nginx.conf`
3. Cree un nuevo proyecto en Google Cloud y habilite las siguientes funcionalidades:
    * Kubernetes Engine
    * Container Registry
    * SQL
    * API y Servicios
4. En terminal escriba `gcloud init`, inicie sesión con su cuenta de Google e inicialize el ambiente seleccionando el proyecto anteriormente creado
5. En Kuberntes Engine cree un nuevo cluster y espere a su finalización, luego seleccione la opcion 'Conectar', copie el comando que se le muestra y ejecutelo en consola para conectarse al cluster. Para verificar si está conectado al cluster escriba en consola `kubectl cluster-info`
6. Asegurese de estar bajo el contexto de Kubernetes de Google Cloud, para aquello escriba `kubectl config get-contexts` y deberá retornar los contextos disponibles y el seleccionado. Si necesita cambiar de contexto escriba `kubectl config use-context <nombre-contexto>`
7. En consola ejecute `gcloud auth configure-docker` para configurar las credenciales de Google Cloud en Docker
8. Para los siguientes pasos puede ejecutar el archivo `gcp-cr.sh [ID_DEL_PROYECTO]` o `gcp-cr.bat [ID_DEL_PROYECTO]` para construir y pushear las imagenes al Container Registry, en caso de no poder ejecutar ambos archivos ejecute los siguientes comandos en consola (reemplazar `[ID_DEL_PROYECTO]` por el identificador del proyecto en Google Cloud):
    * `docker build -t gcr.io/[ID_DEL_PROYECTO]/realworld-backend ./Conduit_NodeJS`
    * `docker push gcr.io/[ID_DEL_PROYECTO]/realworld-backend`
    * `docker build --target production-stage -t gcr.io/[ID_DEL_PROYECTO]/realworld-frontend ./vue3-realworld-example-app`
    * `docker push gcr.io/[id_del_proyecto]/realworld-frontend`
### Creación de instancia SQL y configuración de Proxy SQL
1. En SQL crear una instancia de SQL de tipo MySQL version 5.7 u 8.0, al momento de crearla se le pedirá una contraseña del cual le será asignado al usuario root. Una vez creada la instancia, cree una base de datos de nombre `realworld_db`.
2. En  API y Servicios cree una nueva credencial de tipo 'Cuenta de Servicio'. En el paso 1 asignale un nombre y descripción (ej, Cloud SQL) y en el siguiente paso seleccione la función 'Cliente de Cloud SQL' (puede usar el cuadro de busqueda), luego cree la cuenta de servicio.
3. Una vez creada, seleccione la cuenta, en el detalle vaya a la opcion de 'Claves' y luego seleccione 'Agregar Clave', escoja de tipo JSON y una vez creada se descargará automaticamente. Ese archivo es unico y contiene el acceso al Proxy SQL, no lo comparta con nadie.
4. En SQL copie el nombre de la conexion con la instancia, y reemplazelo en el valor `[INSTANCIA_CONEXION_MYSQL]` del archivo `gcp/backend-gcp-deployment.yaml` en la linea 36

Nota: Si tiene problemas para conectar el backend con el Proxy SQL, siga la [documentación de Google](https://cloud.google.com/sql/docs/mysql/connect-kubernetes-engine?hl=es) para habilitar alguna API que no está a simple vista
### Modificar y aplicar archivos de Kubernetes
1. Crear el namespace para el proyecto:
    * `kubectl create namespace realworld`
2. Crear el secreto para el Proxy SQL indicando la ruta del archivo JSON que descargó `kubectl create secret generic cloudsql-instance-credentials --from-file=credentials.json=[RUTA_ARCHIVO_JSON] -n realworld`    
3. Modificar los siguientes archivos:
    * En `gcp/backend-gcp-deployment.yaml` cambiar el valor de `[ID_DEL_PROYECTO]` en la linea 43 por el identificador del proyecto
    * En `gcp/frontend-gcp-deployment.yaml` cambiar el valor de `[ID_DEL_PROYECTO]` en la linea 30 por el identificador del proyecto
    * En `gcp/backend-gcp-secret.yaml` cambiar el valor de `[PASSWORD_USUARIO]` en la linea 10 por la contraseña seteada al usuario root en SQL
4. Aplicar los siguientes archivos de Kubernetes:
    * `kubectl apply -f gcp/backend-gcp-secret.yaml`
    * `kubectl apply -f gcp/backend-gcp-deployment.yaml`
    * `kubectl apply -f gcp/frontend-gcp-deployment.yaml`
5. Ingresar a la IP asignada al cluster de Kubernetes para ingresar al sitio
