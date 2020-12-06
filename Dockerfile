FROM node:12-alpine AS base

# Create app directory
WORKDIR /app

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
COPY package*.json ./
RUN npm install

# Bundle app source
COPY . .
RUN npm run build

FROM node:12-alpine AS service
COPY --from=base /app/package*.json ./
# RUN npm install
# If you are building your code for production
RUN npm ci --only=production
COPY --from=base /app/dist ./dist

USER node
ENV PORT=4000
EXPOSE 4000

CMD [ "node", "dist/main"]

