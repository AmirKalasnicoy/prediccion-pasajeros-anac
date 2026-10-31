PROJECT_NAME = prediccion-pasajeros-anac
PYTHON = python

.PHONY: requirements clean help

requirements:
	$(PYTHON) -m pip install -U pip
	$(PYTHON) -m pip install -r requirements.txt

clean:
	find . -type f -name "*.py[co]" -delete
	find . -type d -name "__pycache__" -delete

help:
	@echo "Comandos disponibles:"
	@echo "  make requirements  Instala las dependencias del proyecto"
	@echo "  make clean         Limpia archivos temporales de Python"
