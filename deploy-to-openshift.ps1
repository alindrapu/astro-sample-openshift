# PowerShell script to deploy the Astro application to OpenShift

# Variables
$AppName = "astro-sample"
$Namespace = $args[0]

if (-not $Namespace) {
    $Namespace = "astro-sample"
}

Write-Host "Deploying $AppName to OpenShift namespace: $Namespace"

# Check if logged in to OpenShift
try {
    $null = oc whoami
} catch {
    Write-Host "Error: Not logged in to OpenShift. Please run 'oc login' first." -ForegroundColor Red
    exit 1
}

# Create namespace if it doesn't exist
try {
    $null = oc get namespace $Namespace 2>&1
} catch {
    Write-Host "Creating namespace $Namespace..."
    oc new-project $Namespace
}

# Switch to the namespace
oc project $Namespace

# Create a new build if it doesn't exist
try {
    $null = oc get buildconfig $AppName 2>&1
} catch {
    Write-Host "Creating new build configuration..."
    oc new-build --name=$AppName --binary=$true
}

# Start the build
Write-Host "Starting build from local directory..."
oc start-build $AppName --from-dir=. --follow

# Apply the deployment configuration
Write-Host "Applying deployment configuration..."
oc apply -f openshift-deployment.yaml

# Wait for deployment to be ready
Write-Host "Waiting for deployment to be ready..."
oc rollout status deployment/$AppName

# Get the route URL
$RouteUrl = oc get route $AppName -o jsonpath='{.spec.host}'

Write-Host ""
Write-Host "Deployment complete!" -ForegroundColor Green
Write-Host "Your application is available at: http://$RouteUrl"