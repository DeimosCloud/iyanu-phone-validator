# FROM node:alpine3.12
# WORKDIR /validator-frontend
# COPY package.json .
# COPY package-lock.json .
# RUN npm install
# COPY . .
# RUN npm run build
# EXPOSE 8081

# CMD ["npm", "run", "start"]


FROM node:16.3.0-alpine AS build

WORKDIR /validator-frontend
COPY . .

RUN npm install 
RUN npm run build

FROM nginx:1.23

COPY --from=build /validator-frontend/build  /usr/share/nginx/html


EXPOSE 8081

CMD ["nginx", "-g", "daemon off;"]