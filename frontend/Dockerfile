
# ==========================================
# STAGE 1 - BUILD REACT APPLICATION
# ==========================================

FROM node:22-alpine AS build

WORKDIR /app

COPY package*.json ./

RUN npm ci

COPY . .

ENV CI=true
ENV REACT_APP_API_BASE_URL=""

RUN npm run build


# ==========================================
# STAGE 2 - PRODUCTION NGINX SERVER
# ==========================================

FROM nginx:alpine

COPY --from=build /app/build /usr/share/nginx/html

COPY nginx.aws.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
