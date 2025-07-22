# Build stage
FROM registry.access.redhat.com/ubi8/nodejs-16:latest as build

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
FROM registry.access.redhat.com/ubi8/nginx-120:latest

# Copy built assets from the build stage
COPY --from=build /app/dist /usr/share/nginx/html

# Copy custom nginx config for OpenShift
COPY nginx.conf /etc/nginx/nginx.conf

# Set permissions for OpenShift
RUN chmod -R 777 /var/log/nginx /var/lib/nginx/ /usr/share/nginx/html

# Expose port 8080 (OpenShift expects non-root processes to use ports > 1024)
EXPOSE 8080

# Use the default nginx command from the base image
CMD ["nginx", "-g", "daemon off;"]