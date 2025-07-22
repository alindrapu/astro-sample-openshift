# Astro Sample for OpenShift

This is a sample Astro.js application configured for deployment on OpenShift 4.19.

## Project Structure

- `src/` - Contains the Astro application source code
- `public/` - Static assets that will be served directly
- `Dockerfile` - Instructions for building the container image
- `nginx.conf` - Nginx configuration for serving the built application
- `openshift-deployment.yaml` - OpenShift deployment configuration

## Local Development

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

## Deploying to OpenShift

### Method 1: Using the OpenShift CLI (oc)

1. Log in to your OpenShift cluster:

```bash
oc login --token=<your-token> --server=<your-server>
```

2. Create a new project (or use an existing one):

```bash
oc new-project astro-sample
```

3. Build and push the container image:

```bash
# Build the image using the OpenShift build system
oc new-build --name=astro-sample --binary=true
oc start-build astro-sample --from-dir=. --follow
```

4. Deploy the application using the provided YAML:

```bash
oc apply -f openshift-deployment.yaml
```

5. Get the route URL:

```bash
oc get route astro-sample
```

### Method 2: Using the OpenShift Web Console

1. Log in to the OpenShift Web Console
2. Create a new project or select an existing one
3. Go to +Add > Import from Git
4. Enter your Git repository URL
5. Select "Dockerfile" as the build strategy
6. Configure the application name as "astro-sample"
7. Click Create

## Configuration

The application is configured to run on port 8080 as required by OpenShift for non-root users. The Nginx configuration in `nginx.conf` handles serving the static files built by Astro.

## Resources

- [Astro Documentation](https://docs.astro.build)
- [OpenShift Documentation](https://docs.openshift.com)
- [Nginx Documentation](https://nginx.org/en/docs/)
