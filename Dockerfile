# Build stage
FROM ubi8/nodejs-18-minimal AS build

WORKDIR /app

# Copy package.json and package-lock.json/yarn.lock/bun.lock
COPY package.json bun.lock* ./

# Create node_modules directory with proper permissions and install dependencies
RUN mkdir -p /app/node_modules && \
    chown -R 1001:0 /app && \
    chmod -R g+rwX /app && \
    npm install

# Copy the rest of the application
COPY . .

# Build the application
RUN npm run build

# Production stage
FROM registry.access.redhat.com/ubi8/nginx-120

# Copy built assets from the build stage
COPY --from=build /app/dist /opt/app-root/src

# Copy custom nginx config for OpenShift
COPY nginx.conf /etc/nginx/nginx.conf

# Set permissions for OpenShift
RUN chmod -R g+rwX /opt/app-root/src

# Expose port 8080 (OpenShift expects non-root processes to use ports > 1024)
EXPOSE 8080

# Use the UBI nginx startup command
CMD ["nginx", "-g", "daemon off;"]