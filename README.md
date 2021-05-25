# Escalab Docker y Kubernetes
## Requisitos
* Sistema operativo con posibilidad de correr contenedores Docker
* Docker y Docker Compose
* Kubernetes (kubectl o minikube)
* Git
## Instrucciones de instalación
1. Asegurese de tener git instalado, para comprobar escriba git version en consola
2. Clonar repositorio con git clone https://github.com/PPastene/escalab-docker-kubernetes --recursive
3. En la raíz del proyecto copiar el archivo .env.example y renombrarlo a .env, luego setear las variables de entorno de la base de datos (usuario, contraseña y nombre de base de datos)
4. En Conduit_NodeJS copiar el archivo .env.example y renombrarlo a .env, luego setear las variables de conexion a la base de datos (para su ejecución en local tienen que coincidir con las variables seteadas en la raiz del proyecto)
5. En vue3-realworld-example-app copiar el archivo .env.example a .env, luego cambiar el valor de VITE_API_HOST a http://localhost:8080
## Ejecución en local con docker-compose.yml
1. Asegurese de tener Docker y Docker Compose instalado, para verificar escriba docker version y docker-compose version en consola
2. En la raíz del proyecto abrir el archivo docker-compose.yml, asegurarse que la propiedad target dentro de build en client esté definida como production-stage para construir la imagen en produccion
    - Para ejecutar el proyecto en desarrollo, cambie el valor de target a development-stage
3. Ejecute docker-compose.yml up --build para construir las imagenes, descargar la imagen de postgresql y levantar los contenedores, esto tomará un par de minutos dependiendo de la potencia de su PC (puede añadir opcion -d para levantar los contenedores en modo detached)
4. Una vez construida las imagenes, ingrese al frontend desde http://localhost
## Ejecución en local con kubectl o minikube
Por agregar