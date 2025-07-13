APP = rsschool-devops-demo-app
VERSION ?= $(shell git describe --tags --always --dirty=-dev)
CHART_VERSION = "0.1.0-${VERSION}"
L_PORT = 8080
REGISTRY = ghcr.io/saaverdo
IMAGE = $(REGISTRY)/$(APP)

# .PHONY: all build test run clean
.PHONY: all docker helm run clean

all: docker helm

docker: docker-build docker-push

docker-build:
		docker build --build-arg VERSION=$(VERSION) -t $(IMAGE):latest .

docker-push:
		docker push $(IMAGE):latest

helm: helm-build helm-install

helm-build:
		helm package charts/demo-app --version $(CHART_VERSION) --app-version $(VERSION)
		helm push demo-app-$(CHART_VERSION).tgz oci://$(REGISTRY)

helm-install:
		helm upgrade --install $(APP) oci://$(REGISTRY)/demo-app --version $(CHART_VERSION) --namespace demo-app --create-namespace

# local run
run:
		docker run --rm -d -p $(L_PORT):8000 $(IMAGE):latest

clean:
        docker rmi -f $(IMAGE):latest || true
		 