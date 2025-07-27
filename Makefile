APP = rsschool-devops-demo-app
VERSION ?= $(shell git describe --tags --always --dirty=-dev)
CHART_VERSION = "0.1.0-${VERSION}"
L_PORT = 8080
REGISTRY = ghcr.io/saaverdo
IMAGE = $(REGISTRY)/$(APP):latest
PROM_STACK = prom-stack
PROM_NS = prom

.PHONY: all docker helm run clean

all: docker helm

docker: docker-build docker-push

docker-build:
		docker build --build-arg VERSION=$(VERSION) -t $(IMAGE) .

docker-push:
		docker push $(IMAGE)

helm: helm-build helm-install

helm-build:
		helm package charts/demo-app --version $(CHART_VERSION) --app-version $(VERSION)
		helm push demo-app-$(CHART_VERSION).tgz oci://$(REGISTRY)

helm-install:
		helm upgrade --install $(APP) oci://$(REGISTRY)/demo-app --version $(CHART_VERSION) --namespace demo-app --create-namespace

prom-install:
		kubectl apply -f monitoring/grafana_secret.yaml --namespace $(PROM_NS)
		helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
		helm repo update
		helm upgrade --install $(PROM_STACK) prometheus-community/kube-prometheus-stack \
			--namespace $(PROM_NS) --create-namespace \
			-f monitoring/stack_values.yaml
prom-clean:
		helm uninstall $(PROM_STACK) --namespace $(PROM_NS) || true
		
		kubectl delete crd alertmanagerconfigs.monitoring.coreos.com
		kubectl delete crd alertmanagers.monitoring.coreos.com
		kubectl delete crd podmonitors.monitoring.coreos.com
		kubectl delete crd probes.monitoring.coreos.com
		kubectl delete crd prometheusagents.monitoring.coreos.com
		kubectl delete crd prometheuses.monitoring.coreos.com
		kubectl delete crd prometheusrules.monitoring.coreos.com
		kubectl delete crd scrapeconfigs.monitoring.coreos.com
		kubectl delete crd servicemonitors.monitoring.coreos.com
		kubectl delete crd thanosrulers.monitoring.coreos.com
# local run
run:
		docker run --rm -d -p $(L_PORT):8000 $(IMAGE)

clean:
		docker rmi -f $(IMAGE) || true
		 