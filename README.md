# Predicción de pasajeros en vuelos regulares de cabotaje en Argentina

## Descripción del proyecto

Este proyecto busca predecir la cantidad de pasajeros de una operación correspondiente a un vuelo regular de cabotaje en Argentina.

Se utilizan datos públicos de movimientos aéreos registrados por la Administración Nacional de Aviación Civil (ANAC) durante 2025. La predicción se plantea **24 horas antes de la salida del vuelo** y se utilizan como variables de entrada el aeropuerto de salida, el destino y la aerolínea.

La idea es evaluar cuánto pueden aportar estas características para estimar la cantidad de pasajeros transportados antes de que ocurra la operación.

## Pregunta del proyecto

¿Es posible predecir la cantidad de pasajeros de una operación correspondiente a un vuelo regular de cabotaje en Argentina a partir del aeropuerto de salida, el destino y la aerolínea, utilizando información disponible 24 horas antes de la salida?

## Objetivo general

Desarrollar un modelo de Aprendizaje Automático capaz de predecir la cantidad de pasajeros de una operación de vuelo regular de cabotaje en Argentina a partir de características disponibles sobre dicha operación.

Una estimación así podría ayudar a planificar recursos aeroportuarios, por ejemplo personal, controles, equipaje o infraestructura necesaria para atender una operación.

## Tipo de problema

Se trata de un problema de **Aprendizaje Supervisado de Regresión**, porque la variable que se quiere predecir es numérica.

La variable objetivo es `Pasajeros`.

## Definición del problema

| Pregunta | Respuesta |
|---|---|
| ¿Qué representa cada fila? | Un registro de despegue correspondiente a una operación regular de cabotaje |
| ¿Qué se predice? | La cantidad de pasajeros transportados |
| ¿Cuándo se hace la predicción? | 24 horas antes de la salida, como supuesto de alcance del proyecto |
| ¿Con qué información? | Aeropuerto de salida, destino y aerolínea |
| ¿Para qué puede servir? | Como apoyo para planificar recursos asociados a la operación |
| ¿Cómo produce la predicción el modelo final? | El Árbol de Decisión sigue una serie de divisiones hasta llegar a una hoja y devuelve una estimación de pasajeros |

## Dataset

El dataset utilizado es **“Aterrizajes y despegues procesados por la Administración Nacional de Aviación Civil”**, publicado por ANAC a través del portal de Datos Abiertos de la Secretaría de Transporte de la Nación.

El archivo original contiene **597.784 registros y 12 columnas**.

Para el proyecto se seleccionaron únicamente vuelos regulares de cabotaje y se trabajó solo con registros de `Despegue`. Después de eliminar 8 duplicados exactos, el conjunto preparado quedó formado por **132.838 registros y 7 columnas**.

### Variables del conjunto preparado

| Variable | Uso |
|---|---|
| `Fecha UTC` | Ordenamiento y separación temporal |
| `Hora UTC` | No se utiliza como predictora |
| `Aeropuerto` | Predictora. Representa el aeropuerto de salida |
| `Origen / Destino` | Predictora. Representa el destino |
| `Aerolinea Nombre` | Predictora |
| `Aeronave` | No se utiliza como predictora |
| `Pasajeros` | Variable objetivo |

### Variable descartada por fuga de información

Durante la preparación se comprobó que, en el conjunto utilizado:

`PAX = Pasajeros / 2`

Por este motivo, `PAX` fue eliminada. Utilizarla como entrada permitiría conocer de forma indirecta la variable objetivo y generaría fuga de información.

## Análisis exploratorio

La variable `Pasajeros` presenta una media de **129,79** pasajeros y una mediana de **140**. Los valores van desde **0 hasta 284 pasajeros**.

También se encontraron **1.824 operaciones con 0 pasajeros**, que representan aproximadamente el **1,37 %** del conjunto. Estos registros se mantuvieron porque no hay evidencia suficiente para considerarlos errores.

En las variables predictoras se encontraron:

- **42** aeropuertos de salida
- **66** destinos
- **41** aerolíneas
- **420** rutas diferentes

El análisis exploratorio completo, junto con la preparación de los datos, se encuentra en la notebook [`preparacion_datos_anac_2025.ipynb`](notebooks/preparacion_datos_anac_2025.ipynb).

## Estrategia de evaluación

Como se trabaja con registros históricos y el objetivo es estimar operaciones futuras, la división se realizó respetando el orden temporal.

- **Entrenamiento:** enero a agosto de 2025
- **Validación:** septiembre y octubre de 2025
- **Prueba final:** noviembre y diciembre de 2025

El conjunto de validación se utilizó para comparar modelos y elegir la profundidad del Árbol de Decisión. El conjunto de prueba se mantuvo apartado hasta la evaluación final.

Las variables categóricas se transformaron con **One-Hot Encoding**. El codificador se ajustó solamente con los datos de entrenamiento y después se reutilizó sobre los períodos posteriores.

## Modelos comparados

Se utilizó primero un baseline que siempre predice la cantidad promedio de pasajeros observada en entrenamiento. Después se compararon dos modelos de regresión:

- Regresión Lineal Múltiple
- Árbol de Decisión para Regresión

Los resultados sobre el conjunto de validación fueron:

| Modelo | MAE | MSE | R² |
|---|---:|---:|---:|
| Baseline | 35,48 | 1872,23 | -0,0008 |
| Regresión Lineal | 24,49 | 1021,75 | 0,4538 |
| Árbol de Decisión | **21,73** | **867,74** | **0,5362** |

El Árbol de Decisión obtuvo los mejores resultados y se eligió como modelo final.

## Ajuste de la profundidad

Para elegir `max_depth` se probaron distintas profundidades utilizando únicamente entrenamiento y validación.

Las mejoras fueron haciéndose cada vez más pequeñas a partir de una profundidad cercana a 35. Entre `max_depth=40` y valores más altos, el MAE de validación mejoró solo unas centésimas.

Por este motivo se eligió **`max_depth=40`**, ya que mantiene un buen resultado sin aumentar innecesariamente la complejidad del árbol.

## Resultados finales

Una vez elegido el modelo, se volvió a entrenar utilizando juntos los datos de enero a octubre y se evaluó una única vez sobre noviembre y diciembre.

Los resultados finales fueron:

| Métrica | Resultado |
|---|---:|
| MAE | **23,77 pasajeros** |
| MSE | **1021,02** |
| R² | **0,5408** |

El MAE indica que las predicciones se alejan, en promedio, alrededor de **24 pasajeros** del valor real de cada operación.

El R² muestra que el modelo logra captar parte de la variabilidad en la cantidad de pasajeros, aunque todavía quedan factores que no están representados por las variables utilizadas.

El análisis de los residuos mostró una media de **6,76 pasajeros**, por lo que el modelo tiende a quedarse un poco corto en algunas estimaciones. También aparecen operaciones con errores considerablemente mayores.

## Ejemplo de uso

Para mostrar cómo se realiza una predicción con un caso nuevo, en la notebook se utiliza como ejemplo una operación desde **CBA** hacia **AER** operada por **Aerolíneas Argentinas**.

Con esas características, el modelo estima aproximadamente **115 pasajeros**.

Este ejemplo muestra cómo utilizar `.predict()` con una nueva operación. No se utiliza para medir el desempeño del modelo.

## Conclusiones

Los resultados muestran que el aeropuerto de salida, el destino y la aerolínea contienen información útil para estimar la cantidad de pasajeros de una operación.

Entre los modelos comparados, el Árbol de Decisión obtuvo el mejor desempeño en validación y mantuvo resultados similares al evaluarse con datos posteriores.

Aun así, el modelo no explica toda la variación observada y existen operaciones en las que la diferencia entre el valor real y el predicho es considerable.

## Limitaciones y posibles mejoras

- El proyecto utiliza únicamente datos correspondientes a **2025**.
- La predicción 24 horas antes de la salida se toma como un supuesto del proyecto. La fuente no confirma de forma explícita que todas las variables originales estén disponibles con esa anticipación.
- `Hora UTC` y `Aeronave` no se utilizan como predictoras porque no se pudo confirmar su disponibilidad 24 horas antes.
- La variable objetivo representa **pasajeros transportados por operación**, no la demanda total de personas interesadas en viajar.
- El dataset no incluye un identificador único de vuelo.
- El modelo utiliza solamente tres variables predictoras, por lo que distintas operaciones con las mismas características pueden recibir estimaciones parecidas.

Como trabajo futuro se podrían incorporar nuevas variables que estén realmente disponibles antes de la salida y evaluar el modelo sobre otros períodos o años.

## Documentación y orden de lectura

| Orden | Archivo | Contenido |
|---|---|---|
| 1 | [`docs/descripcion_dataset.md`](docs/descripcion_dataset.md) | Origen, descripción y decisiones sobre las variables |
| 2 | [`notebooks/preparacion_datos_anac_2025.ipynb`](notebooks/preparacion_datos_anac_2025.ipynb) | Preparación de datos y análisis exploratorio |
| 3 | [`notebooks/modelado_anac_2025.ipynb`](notebooks/modelado_anac_2025.ipynb) | División temporal, modelos, ajuste de profundidad, evaluación, residuos y ejemplo de predicción |

## Estructura del repositorio

```text
prediccion-pasajeros-anac/
│
├── data/
│   ├── external/
│   ├── interim/
│   ├── processed/
│   │   └── vuelos_regulares_cabotaje_2025_procesado.csv
│   └── raw/
│       └── informe-ministerio-actualizado-dic-final.csv
│
├── docs/
│   └── descripcion_dataset.md
│
├── models/
├── notebooks/
│   ├── preparacion_datos_anac_2025.ipynb
│   └── modelado_anac_2025.ipynb
├── prediccion_pasajeros_anac/
├── references/
├── reports/
│   └── figures/
│
├── .gitignore
├── Makefile
├── pyproject.toml
├── requirements.txt
└── README.md
```

## Cómo ejecutar el proyecto

Desde la raíz del repositorio, instalar las dependencias:

```bash
python -m pip install -r requirements.txt
```

Después entrar a la carpeta `notebooks`:

```bash
cd notebooks
```

Primero ejecutar la preparación de datos:

```bash
jupyter notebook preparacion_datos_anac_2025.ipynb
```

Luego ejecutar el modelado:

```bash
jupyter notebook modelado_anac_2025.ipynb
```

Las rutas utilizadas en las notebooks son relativas a la carpeta `notebooks`.

## Fuente de los datos

Los datos fueron publicados por la Administración Nacional de Aviación Civil (ANAC) a través del portal de Datos Abiertos de la Secretaría de Transporte de la Nación.

Dataset utilizado: **Aterrizajes y despegues procesados por la Administración Nacional de Aviación Civil**.

Período utilizado: **2025**.

La fecha exacta de descarga no quedó registrada por separado. El archivo original fue incorporado al repositorio el **28/10/2026**.

Enlace oficial al dataset:

https://datos.transporte.gob.ar/dataset/aterrizajes-y-despegues-procesados-por-la-administracion-nacional-de-aviacion-civil-anac/archivo/0706775f-bed9-46e7-aac5-726d7e72e429
