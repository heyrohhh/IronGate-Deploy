FROM node:18-alpine AS BUILD
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build 
FROM nginx:stable-alpine
COPY --from=BUILD /app/dist /usr/share/ngnix/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]