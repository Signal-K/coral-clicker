FROM node:20-alpine

WORKDIR /workspace

RUN apk add --no-cache bash

EXPOSE 8081

CMD ["sh", "-c", "yarn install && yarn start"]
