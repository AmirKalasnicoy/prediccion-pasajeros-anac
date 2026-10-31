# Predicción de pasajeros en vuelos regulares de cabotaje en Argentina

## Descripción del proyecto

Este proyecto busca desarrollar un modelo de Aprendizaje Automático que permita predecir la cantidad de pasajeros de una operación correspondiente a un vuelo regular de cabotaje en Argentina.

Para trabajar el problema se utilizan datos públicos de movimientos aéreos registrados por la Administración Nacional de Aviación Civil (ANAC) durante el año 2025.

La idea es analizar si características como el aeropuerto de salida, el destino y la aerolínea pueden aportar información útil para estimar la cantidad de pasajeros transportados.

La predicción se plantea para realizarse antes de la salida del vuelo, por lo que solamente se deberían utilizar como predictoras aquellas variables cuya información esté disponible en ese momento.

## Objetivo

Desarrollar un modelo de Aprendizaje Automático capaz de predecir la cantidad de pasajeros de una operación de vuelo regular de cabotaje en Argentina a partir de características disponibles sobre dicha operación.

Una estimación de este tipo podría servir como apoyo para la planificación de recursos aeroportuarios, por ejemplo personal, controles, equipaje o infraestructura necesaria para atender una operación.

## Tipo de problema

El proyecto corresponde a un problema de **Aprendizaje Supervisado de Regresión**, ya que la variable que se quiere predecir es numérica.

La variable objetivo es:

`Pasajeros`

Esta variable representa la cantidad de pasajeros registrada para una operación aérea.

## Dataset

El dataset utilizado es **“Aterrizajes y despegues procesados por la Administración Nacional de Aviación Civil”**, correspondiente al año 2025.

Los datos fueron publicados por la Administración Nacional de Aviación Civil (ANAC) a través del portal de Datos Abiertos de la Secretaría de Transporte de la Nación.

El archivo original contiene:

- **597.784 registros**
- **12 columnas**

Para el proyecto se seleccionaron solamente las operaciones correspondientes a vuelos regulares de cabotaje.

## Qué representa una observación

En el dataset original cada fila representa un movimiento aéreo, que puede corresponder a un despegue o a un aterrizaje.

Como para los vuelos de cabotaje se registran ambos movimientos, mantener los dos tipos podía hacer que una misma operación quedara representada más de una vez.

Por este motivo, para este proyecto se decidió trabajar solamente con los registros correspondientes a `Despegue`.

De esta forma:

- `Aeropuerto` representa el aeropuerto de salida.
- `Origen / Destino` representa el aeropuerto de destino.

Una observación del conjunto preparado representa entonces un registro de despegue correspondiente a una operación regular de cabotaje publicada por ANAC.

## Preparación de los datos

Durante la preparación se realizaron los siguientes pasos:

- Revisión de columnas y tipos de datos.
- Revisión de valores faltantes.
- Revisión de registros duplicados.
- Selección de vuelos cuya clase es `Regular`.
- Selección de vuelos cuya clasificación es `Doméstico`.
- Revisión de los registros de despegue y aterrizaje.
- Selección de los registros correspondientes a `Despegue`.
- Eliminación de duplicados exactos dentro del conjunto filtrado.
- Revisión de la variable `PAX` para detectar posibles casos de fuga de información.
- Revisión de `Aeronave`, `Fecha UTC` y `Hora UTC`.
- Eliminación de variables que quedaron constantes después de aplicar los filtros.

Después de seleccionar los vuelos regulares domésticos quedaron **265.624 registros**.

Al utilizar solamente los despegues quedaron **132.846 registros**.

Finalmente, después de eliminar 8 registros duplicados exactos, el dataset preparado quedó formado por:

- **132.838 registros**
- **7 columnas**

## Variables del dataset preparado

| Variable | Tipo de dato |
|---|---|
| `Fecha UTC` | `str` |
| `Hora UTC` | `str` |
| `Aeropuerto` | `str` |
| `Origen / Destino` | `str` |
| `Aerolinea Nombre` | `str` |
| `Aeronave` | `str` |
| `Pasajeros` | `float64` |

### Variables consideradas como posibles predictoras

Por el momento, las variables que se consideran más claras para usar como predictoras son:

- `Aeropuerto`
- `Origen / Destino`
- `Aerolinea Nombre`

### Variables que todavía necesitan revisión

`Fecha UTC` y `Hora UTC` se mantienen en el dataset, pero todavía no se consideran confirmadas como predictoras porque la fuente no aclara si corresponden al horario programado o al momento efectivo en que ocurrió la operación.

`Aeronave` también se mantiene en el conjunto preparado, aunque todavía falta confirmar si esta información estaría disponible antes de la salida del vuelo.

### Variable descartada por fuga de información

Durante la preparación se comprobó que, para los 132.838 registros analizados:

`PAX = Pasajeros / 2`

Por este motivo, `PAX` fue eliminada del conjunto preparado. Usarla como predictora permitiría conocer de manera indirecta la variable objetivo y generaría fuga de información.

También se eliminaron las siguientes columnas después de los filtros:

- `Clase de Vuelo (todos los vuelos)`
- `Clasificación Vuelo`
- `Tipo de Movimiento`
- `Calidad dato`

Estas variables quedaron con un único valor y dejaron de aportar información para una futura predicción.

## Modelos considerados

Como modelo inicial se plantea utilizar **Regresión Lineal Múltiple**.

También se podrá comparar su desempeño con otro modelo de regresión, como un **Árbol de Decisión para Regresión**, para ver si existen relaciones que no puedan representarse bien con un modelo lineal.

La elección definitiva del modelo se realizará más adelante, en la etapa de modelado y evaluación.

## Estructura del repositorio

```text
prediccion-pasajeros-anac/
│
├── data/
│   ├── external/            <- Datos externos, si fueran necesarios
│   ├── interim/             <- Datos intermedios del procesamiento
│   ├── processed/
│   │   └── vuelos_regulares_cabotaje_2025_procesado.csv
│   └── raw/
│       └── informe-ministerio-actualizado-dic-final.csv
│
├── docs/
│   └── descripcion_dataset.md
│
├── models/                  <- Modelos entrenados en etapas posteriores
├── notebooks/
│   └── preparacion_datos_anac_2025.ipynb
├── prediccion_pasajeros_anac/
│   └── __init__.py
├── references/              <- Material de referencia del proyecto
├── reports/
│   └── figures/             <- Gráficos y figuras generadas
│
├── .gitignore
├── Makefile
├── pyproject.toml
├── requirements.txt
└── README.md
```

La estructura del repositorio sigue la organización de **Cookiecutter Data Science**. Algunas carpetas, como `external`, `interim`, `models`, `references` y `reports/figures`, quedan preparadas para usarse cuando el proyecto las necesite.

## Archivos principales

- **Dataset original:** `data/raw/informe-ministerio-actualizado-dic-final.csv`
- **Dataset procesado:** `data/processed/vuelos_regulares_cabotaje_2025_procesado.csv`
- **Notebook de preparación:** `notebooks/preparacion_datos_anac_2025.ipynb`
- **Descripción del dataset:** `docs/descripcion_dataset.md`
- **Dependencias del proyecto:** `requirements.txt`
- **Configuración del proyecto:** `pyproject.toml`

## Fuente de los datos

Los datos provienen del portal de Datos Abiertos de la Secretaría de Transporte de la Nación y fueron publicados por la Administración Nacional de Aviación Civil (ANAC).

Dataset utilizado: **Aterrizajes y despegues procesados por la Administración Nacional de Aviación Civil**.

Período utilizado: **2025**.

Enlace oficial al dataset:

https://datos.transporte.gob.ar/dataset/aterrizajes-y-despegues-procesados-por-la-administracion-nacional-de-aviacion-civil-anac/archivo/0706775f-bed9-46e7-aac5-726d7e72e429
