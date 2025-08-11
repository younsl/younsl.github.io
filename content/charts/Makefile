# Generate documentation for all charts
.PHONY: docs
docs:
	@for chart in */; do \
		if [ -f "$$chart/ci/README.md.gotmpl" ]; then \
			echo "Generating docs for $$chart using ci/README.md.gotmpl"; \
			helm-docs --chart-search-root "$$chart" --template-files="$$chart/ci/README.md.gotmpl" --log-level info; \
		fi \
	done
