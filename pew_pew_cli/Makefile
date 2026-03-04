.PHONY: help build clean test format analyze fix watch get

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Run build_runner to generate code
	dart run build_runner build --delete-conflicting-outputs

watch: ## Run build_runner in watch mode
	dart run build_runner watch --delete-conflicting-outputs

clean: ## Clean build artifacts
	dart pub get
	dart run build_runner clean

test: ## Run tests with coverage
	@dart test --coverage=coverage
	@dart run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib
	@echo "\n📊 Coverage Summary:"
	@cat coverage/lcov.info | awk '/^SF:/{gsub(/.*\/lib\//, "lib/", $$0); f=$$0}/^LF:/{lf=substr($$0,4)}/^LH:/{lh=substr($$0,4); if(f !~ /\.g\.dart$$/) {pct=(lf>0)?lh/lf*100:0; printf "  %-60s %5.1f%% (%d/%d)\n", f, pct, lh, lf; total_lh+=lh; total_lf+=lf}}END{pct=(total_lf>0)?total_lh/total_lf*100:0; printf "\n  %-60s %5.1f%% (%d/%d)\n", "TOTAL", pct, total_lh, total_lf}'
	@rm -rf coverage/

format: ## Format code
	dart format .

fix: ## Apply Dart fixes
	dart fix --apply

analyze: ## Run static analysis
	dart analyze

get: ## Get dependencies
	dart pub get
