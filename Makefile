.PHONY: help install install-dev clean lint format test build upload docs

# Default target
help:
	@echo "Available targets:"
	@echo "  install     - Install the package"
	@echo "  install-dev - Install development dependencies"
	@echo "  clean       - Clean build artifacts"
	@echo "  lint        - Run code linting"
	@echo "  format      - Format code with black"
	@echo "  test        - Run tests"
	@echo "  build       - Build distribution packages"
	@echo "  upload      - Upload to PyPI (requires credentials)"
	@echo "  docs        - Build documentation"

# Installation
install:
	pip install .

install-dev:
	pip install -e ".[dev]"

# Cleanup
clean:
	rm -rf build/
	rm -rf dist/
	rm -rf *.egg-info/
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete

# Code quality
lint:
	flake8 WoeUSB/
	mypy WoeUSB/ --ignore-missing-imports

format:
	black WoeUSB/

# Testing
test:
	pytest -v

# Build and distribution
build: clean
	python -m build

upload: build
	twine upload dist/*

# Documentation
docs:
	cd doc && make html

# Development setup
dev-setup: clean
	pip install -e ".[dev]"
	@echo "Development environment ready!"
