# Build stage
FROM node:20-alpine as build

WORKDIR /app

# Copy package.json and package-lock.json/yarn.lock/bun.lock
COPY package.json bun.lock* ./

# Install dependencies
RUN npm install

# Copy the rest of the application
COPY . .

# Build the application
RUN npm run build

# Production stage
FROM nginx:alpine

# Copy built assets from the build stage
COPY --from=build /app/dist /usr/share/nginx/html

# Copy custom nginx config for OpenShift
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 8080 (OpenShift expects non-root processes to use ports > 1024)
EXPOSE 8080

# Run nginx in foreground
CMD ["nginx", "-g", "daemon off;"]