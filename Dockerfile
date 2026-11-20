# Stage 1 - build: compile the Angular app (discarded after the build)
FROM node:24-slim AS build
WORKDIR /app
# Dependencies first: this layer stays cached while the lockfile is unchanged
COPY package.json package-lock.json ./
RUN npm ci
# Source code last: it changes often
COPY . .
RUN npm run build

# Stage 2 - runtime: Nginx serves only the compiled files
FROM nginx:1.30-alpine
# Provided configuration (root /app, SPA fallback), used as is
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY --from=build /app/dist/olympic-games-starter/browser/ /app/
EXPOSE 80
