FROM node:20-alpine

WORKDIR /workspace

RUN apk add --no-cache bash git

CMD ["sh", "-c", "echo 'Coral base image ready. Use docker-compose services for runtime targets.' && sleep infinity"]
