FROM node:20-alpine

WORKDIR /workspace

RUN apk add --no-cache bash

EXPOSE 8787

CMD ["sh", "-c", "node bridge/server.js"]
