.PHONY: help build-images up down logs docker-build docker-clean \
        k8s-deploy k8s-delete k8s-status k8s-logs kubectl-port-forward

help:
	@echo "TodoList Application - Development Commands"
	@echo "==========================================="
	@echo ""
	@echo "DOCKER COMMANDS:"
	@echo "  make build-images     - Build Docker images for backend and frontend"
	@echo "  make up              - Start all services with Docker Compose"
	@echo "  make down            - Stop all services"
	@echo "  make logs            - View logs from all services"
	@echo "  make docker-clean    - Remove containers, images, and volumes"
	@echo ""
	@echo "KUBERNETES COMMANDS:"
	@echo "  make k8s-deploy      - Deploy application to Kubernetes"
	@echo "  make k8s-delete      - Delete Kubernetes deployment"
	@echo "  make k8s-status      - Check deployment status"
	@echo "  make k8s-logs        - View logs (usage: make k8s-logs SERVICE=backend)"
	@echo "  make k8s-port        - Port forward to frontend (3000:3000)"
	@echo ""
	@echo "UTILITY COMMANDS:"
	@echo "  make clean           - Full cleanup"
	@echo ""

# ============= DOCKER COMMANDS =============

build-images:
	@echo "Building Docker images..."
	docker build -t todolist-backend:latest ./server
	docker build -t todolist-frontend:latest ./client
	@echo "✓ Images built successfully!"

up:
	@echo "Starting Docker Compose..."
	docker-compose up -d
	@echo "✓ Services started!"
	@echo "Frontend: http://localhost:3000"
	@echo "Backend: http://localhost:8080"

down:
	@echo "Stopping Docker Compose..."
	docker-compose down
	@echo "✓ Services stopped!"

logs:
	docker-compose logs -f

docker-clean: down
	@echo "Cleaning up Docker resources..."
	docker-compose down -v
	docker rmi todolist-backend:latest todolist-frontend:latest
	@echo "✓ Cleanup completed!"

# ============= KUBERNETES COMMANDS =============

k8s-deploy:
	@echo "Deploying to Kubernetes..."
	@chmod +x deploy-k8s.sh
	./deploy-k8s.sh
	@echo "Waiting for deployments to be ready..."
	kubectl wait --for=condition=available --timeout=300s deployment/backend -n todolist || true
	kubectl wait --for=condition=available --timeout=300s deployment/frontend -n todolist || true
	@echo "✓ Deployment completed!"
	@echo ""
	@echo "Current status:"
	@make k8s-status

k8s-delete:
	@echo "Deleting Kubernetes deployment..."
	kubectl delete namespace todolist
	@echo "✓ Kubernetes deployment deleted!"

k8s-status:
	@echo "=== Kubernetes Resources Status ==="
	@echo ""
	@echo "Pods:"
	@kubectl get pods -n todolist --no-headers || echo "No resources found"
	@echo ""
	@echo "Services:"
	@kubectl get svc -n todolist --no-headers || echo "No resources found"
	@echo ""
	@echo "PVC:"
	@kubectl get pvc -n todolist --no-headers || echo "No resources found"
	@echo ""
	@echo "HPA:"
	@kubectl get hpa -n todolist --no-headers || echo "No resources found"

k8s-logs:
	@if [ -z "$(SERVICE)" ]; then \
		echo "Error: SERVICE not specified"; \
		echo "Usage: make k8s-logs SERVICE=backend|frontend|mysql"; \
		exit 1; \
	fi
	kubectl logs -f deployment/$(SERVICE) -n todolist

k8s-port:
	@echo "Port forwarding to frontend service..."
	@echo "Access: http://localhost:3000"
	kubectl port-forward svc/frontend-service 3000:3000 -n todolist

# ============= UTILITY COMMANDS =============

setup-env:
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "✓ .env file created from .env.example"; \
		echo "  Please update .env with your configuration"; \
	else \
		echo ".env file already exists"; \
	fi

clean: docker-clean k8s-delete
	@echo "Full cleanup completed!"
	@echo "Run 'make setup-env' to prepare for new deployment"
