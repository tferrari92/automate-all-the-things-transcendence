#!/usr/bin/bash
read -p "Enter the new image tag: " IMAGE_TAG

yarn install --frozen-lockfile

# tsc outputs type definitions to dist-types/ in the repo root, which are then consumed by the build
yarn tsc

# Build the backend, which bundles it all up into the packages/backend/dist folder.
# The configuration files here should match the one you use inside the Dockerfile below.
yarn build:backend --config ../../app-config.production.yaml

docker image build . -f packages/backend/Dockerfile --tag AATT_DOCKERHUB_USERNAME/backstage:$IMAGE_TAG
docker push AATT_DOCKERHUB_USERNAME/backstage:$IMAGE_TAG