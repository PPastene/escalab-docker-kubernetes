docker build -t gcr.io/$1/realworld-backend ./Conduit_NodeJS
docker push gcr.io/$1/realworld-backend
docker build --target production-stage -t gcr.io/$1/realworld-frontend ./vue3-realworld-example-app
docker push gcr.io/$1/realworld-frontend