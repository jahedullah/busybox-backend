echo "Deploying MySQL database..."
kubectl apply -f db-deployment.yaml

echo "Waiting for MySQL pod to be running..."
kubectl wait --for=condition=ready pod -l app=mysql --timeout=300s

# Deploy backend
echo "Deploying backend..."
kubectl apply -f busybox-backend-deployment.yaml

# Wait for backend pod to be running
echo "Waiting for backend pod to be running..."
kubectl wait --for=condition=ready pod -l app=busybox-backend --timeout=300s

# Deploy frontend
echo "Deploying frontend..."
kubectl apply -f busybox-frontend-deployment.yaml

# Wait for frontend pod to be running
echo "Waiting for frontend pod to be running..."
kubectl wait --for=condition=ready pod -l app=busybox-frontend --timeout=300s

echo "Application deployed successfully! go to the url -> http://192.168.64.2:3100"