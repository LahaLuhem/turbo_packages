.PHONY: help analyze fix format test build watch clean get pub-check pub-publish pub-publish-dry-run all

.DEFAULT_GOAL := help

## help: Show this help message
help:
	@echo "Usage: make [target] [package=<package-name>]"
	@echo ""
	@echo "Targets:"
	@grep -E '^## [a-zA-Z_-]+:.*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ": "}; {printf "  %-20s %s\n", $$1, $$2}'
	@echo ""
	@echo "Examples:"
	@echo "  make test                    # Run tests on all packages"
	@echo "  make test package=turbo_response  # Run tests on specific package"
	@echo "  make build package=turbo_mvvm    # Build specific package"

## analyze: Run static analysis across all packages
analyze:
	@if [ -n "$(package)" ]; then \
		cd $(package) && dart analyze --fatal-infos .; \
	else \
		dart run melos exec --fail-fast --concurrency=1 -- "dart analyze --fatal-infos"; \
	fi

## format: Format all packages
format:
	@if [ -n "$(package)" ]; then \
		cd $(package) && dart format .; \
	else \
		dart run melos exec --fail-fast --concurrency=1 -- "dart format ."; \
	fi

## fix: Apply Dart fixes across packages
fix:
	@if [ -n "$(package)" ]; then \
		cd $(package) && dart fix --apply; \
	else \
		dart run melos exec --fail-fast --concurrency=1 -- "dart fix --apply"; \
	fi

## test: Run tests with coverage across all packages
test:
	@if [ -n "$(package)" ]; then \
		cd $(package) && make test; \
	else \
		dart run melos exec --fail-fast --concurrency=1 --dir-exists="test" -- "bash \"$(CURDIR)/tool/test_with_coverage.sh\""; \
	fi

## build: Run build_runner to generate code
build:
	@if [ -n "$(package)" ]; then \
		cd $(package) && make build; \
	else \
		dart run melos exec --fail-fast --concurrency=1 --depends-on="build_runner" -- "dart run build_runner build --delete-conflicting-outputs"; \
	fi

## watch: Run build_runner in watch mode
watch:
	@if [ -n "$(package)" ]; then \
		cd $(package) && make watch; \
	else \
		dart run melos exec --fail-fast --concurrency=1 --depends-on="build_runner" -- "\
			if [ -f pubspec.yaml ]; then \
				if grep -q '^flutter:' pubspec.yaml; then \
					flutter pub run build_runner watch --delete-conflicting-outputs; \
				else \
					dart run build_runner watch --delete-conflicting-outputs; \
				fi; \
			fi"; \
	fi

## clean: Clean build artifacts
clean:
	@if [ -n "$(package)" ]; then \
		cd $(package) && flutter clean && flutter pub get && dart run build_runner clean; \
	else \
		dart run melos exec --fail-fast --concurrency=1 -- "\
			if [ -f pubspec.yaml ]; then \
				if grep -q '^flutter:' pubspec.yaml; then \
					flutter clean && flutter pub get; \
				else \
					dart pub get; \
				fi; \
				if grep -q '^[[:space:]]*build_runner:' pubspec.yaml; then \
					dart run build_runner clean; \
				fi; \
			fi"; \
	fi

## get: Get dependencies
get:
	@if [ -n "$(package)" ]; then \
		cd $(package) && flutter pub get; \
	else \
		dart run melos bootstrap; \
	fi

## pub-check: Validate all packages meet 160/160 pub.dev points
pub-check:
	@if [ -n "$(package)" ]; then \
		MELOS_PACKAGE_PATH="$(package)" bash "$(CURDIR)/tool/pub_check.sh"; \
	else \
		dart run melos exec --fail-fast --concurrency=1 -- "bash \"$(CURDIR)/tool/pub_check.sh\""; \
	fi

## pub-publish-dry-run: Validate packages for publishing without actually publishing
pub-publish-dry-run:
	@dart run melos pub-publish-dry-run

## pub-publish: Publish packages to pub.dev (requires confirmation)
pub-publish:
	@dart run melos pub-publish

## all: Run full CI pipeline (format, analyze, test)
all: clean get build fix format analyze test pub-check pub-publish-dry-run

## all-from-clean: Run full CI pipeline (clean, get, build, fix, format, analyze, test, pub-check, pub-publish-dry-run) starting from clean
all-from-clean: clean get build fix format analyze test pub-check pub-publish-dry-run

## all-from-build: Run full CI pipeline (format, analyze, test) starting from build_runner
all-from-build: build fix format analyze test pub-check pub-publish-dry-run

## all-from-fix: Run full CI pipeline (fix, format, analyze, test) starting from fix
all-from-fix: fix format analyze test pub-check pub-publish-dry-run

## all-from-format: Run full CI pipeline (format, analyze, test) starting from format
all-from-format: format analyze test pub-check pub-publish-dry-run

## all-from-analyze: Run full CI pipeline (analyze, test) starting from analyze
all-from-analyze: analyze test pub-check pub-publish-dry-run

## all-from-test: Run full CI pipeline (test) starting from test
all-from-test: test pub-check pub-publish-dry-run

## all-from-pub-check: Run full CI pipeline (pub-check) starting from pub-check
all-from-pub-check: pub-check pub-publish-dry-run