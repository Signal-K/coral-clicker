FROM node:20-alpine

WORKDIR /workspace/web

RUN apk add --no-cache bash

EXPOSE 3000

CMD ["sh", "-c", "npm install && npm run dev"]
