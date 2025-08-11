# Generate documentation for all charts
.PHONY: docs
docs:
	@for chart in */; do \
		if [ -f "$$chart/Chart.yaml" ]; then \
			echo "Generating docs for $$chart using common ci/README.md.gotmpl"; \
			helm-docs --chart-search-root "$$chart" --template-files="ci/README.md.gotmpl" --sort-values-order file --log-level info; \
		fi \
	done
