# FROM node:alpine3.12
# WORKDIR /validator-frontend
# COPY package.json .
# COPY package-lock.json .
# RUN npm install
# COPY . .
# RUN npm run build
# EXPOSE 8081

# CMD ["npm", "run", "start"]

FROM node:17-alpine

WORKDIR /validator-frontend

 COPY package.json .

 RUN npm install

 COPY . .

 EXPOSE 8081

 CMD ["npm", "start"]
