# Using Docker image based on Alpine Linux, because it's a lightweight version
# 14, 14.15, 14.15.1 – 109 MB (npm 6.14.8, yarn 1.22.10)
# 12, 12.19, 12.19.1 – 81.2 MB (npm 6.14.8, yarn 1.22.10)
# (using Node 12 to reduce size of image)
# Specify also minor version for compatibility and new features (except patches)
FROM node:12.19-alpine AS base

# Create app directory
WORKDIR /app

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
COPY package*.json ./

# Install all dependencies (both dependencies and devDependencies) for build
RUN npm install

# Bundle app source. All files that we do not need during the build were excluded
# from build context via .dockerignore file
COPY . .

# Run the production build
RUN npm run build

# Use multi-stage build to optimize Docker image (copy only necessary files from base image)
FROM node:12-alpine AS service

# Copy package.json and package-lock,json
COPY --from=base /app/package*.json ./

# Install npm modules for production image (npm ci)
RUN npm ci --only=production
COPY --from=base /app/dist ./dist

USER node
ENV PORT=4000
EXPOSE 4000

CMD [ "node", "dist/main"]

