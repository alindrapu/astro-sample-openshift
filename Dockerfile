# Build stage
FROM ubi8/nodejs-18-minimal AS build

WORKDIR /app

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy package.json and package-lock.json/yarn.lock/bun.lock
COPY package.json bun.lock* ./

RUN npm ci --only=production

COPY . .

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