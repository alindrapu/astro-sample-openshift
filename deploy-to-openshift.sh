#!/bin/bash

# Script to deploy the Astro application to OpenShift
# This script deploys an Astro.js application using Red Hat UBI images for OpenShift 4.19 compatibility

# Exit on error
set -e

# Variables
APP_NAME="astro-sample"
NAMESPACE="${1:-astro-sample}"

echo "Deploying $APP_NAME to OpenShift namespace: $NAMESPACE"

# Check if logged in to OpenShift
if ! oc whoami &>/dev/null; then
  echo "Error: Not logged in to OpenShift. Please run 'oc login' first."
  exit 1
fi

# Create namespace if it doesn't exist
if ! oc get namespace $NAMESPACE &>/dev/null; then
  echo "Creating namespace $NAMESPACE..."
  oc new-project $NAMESPACE
fi

# Switch to the namespace
oc project $NAMESPACE

# Create a new build if it doesn't exist
if ! oc get buildconfig $APP_NAME &>/dev/null; then
  echo "Creating new build configuration..."
  oc new-build --name=$APP_NAME --binary=true --strategy=docker
fi

# Start the build
echo "Starting build from local directory..."
oc start-build $APP_NAME --from-dir=. --follow

# Apply the deployment configuration
echo "Applying deployment configuration..."
oc apply -f openshift-deployment.yaml

# Wait for deployment to be ready
echo "Waiting for deployment to be ready..."
oc rollout status deployment/$APP_NAME

# Get the route URL
ROUTE_URL=$(oc get route $APP_NAME -o jsonpath='{.spec.host}')

echo ""
echo "Deployment complete!"
echo "Your application is available at: http://$ROUTE_URL"

echo ""
echo "Note: This deployment uses Red Hat UBI images which are optimized for OpenShift."
echo "If you encounter any issues, please check the pod logs with:"
echo "  oc logs -f deployment/$APP_NAME"