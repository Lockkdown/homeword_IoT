# Stage 1: Build Flutter web app
# Build context = lab311/ root (có lib/, web/, pubspec.yaml)
FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app

# Copy Flutter project files
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY lib ./lib
COPY web ./web

# Build Flutter web (release mode)
RUN flutter build web --release

# Stage 2: Serve với nginx
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html

# nginx config: proxy /api/ → backend:8080, SPA fallback
RUN printf 'server {\n\
    listen 80;\n\
    root /usr/share/nginx/html;\n\
    index index.html;\n\
    location /api/ {\n\
        proxy_pass http://backend:8080/;\n\
        proxy_set_header Host $host;\n\
        proxy_set_header X-Real-IP $remote_addr;\n\
    }\n\
    location / {\n\
        try_files $uri $uri/ /index.html;\n\
    }\n\
}\n' > /etc/nginx/conf.d/default.conf

EXPOSE 80
