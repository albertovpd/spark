LOCAL = local-v3 local-v2
KUBERNETES = kubernetes-general kubernetes-v3 kubernetes-v2
GIT = git
.PHONY: all info $(LOCAL) $(KUBERNETES) $(GIT)

all: info

info:
	@echo "LOCAL: $(LOCAL)"
	@echo "KUBERNETES: $(KUBERNETES)"
	@echo "GIT: $(GIT)"

# LOCAL
local-v3:
	@bash ./scripts/local/v3/spark.sh
local-v2:
	@bash ./scripts/local/v2/spark.sh

# KUBERNETES
kubernetes-general:
	@bash ./scripts/kubernetes/kubernetes.sh
kubernetes-v3:
	@bash ./scripts/kubernetes/v3/spark.sh
kubernetes-v2:
	@bash ./scripts/kubernetes/v2/spark.sh

# GIT
git:
	@bash ./scripts/git.sh
	