# Descripción y preparación del dataset

## Dataset utilizado

Para este proyecto se utiliza el dataset **“Aterrizajes y despegues procesados por la Administración Nacional de Aviación Civil”**, correspondiente al año 2025.

Los datos provienen del portal de Datos Abiertos de la Secretaría de Transporte de la Nación y fueron publicados por la Administración Nacional de Aviación Civil (ANAC).

El dataset original contiene **597.784 registros y 12 columnas**.

La fecha exacta de descarga no quedó registrada por separado. El archivo original fue incorporado al repositorio el **28/10/2026**.

Enlace oficial al dataset:

https://datos.transporte.gob.ar/dataset/aterrizajes-y-despegues-procesados-por-la-administracion-nacional-de-aviacion-civil-anac/archivo/0706775f-bed9-46e7-aac5-726d7e72e429

## Variables originales

| Variable | Tipo de dato | Descripción |
|---|---|---|
| `Fecha UTC` | `str` | Fecha en la que se registró la operación aérea, expresada en horario UTC. |
| `Hora UTC` | `str` | Hora de la operación expresada en UTC. |
| `Clase de Vuelo (todos los vuelos)` | `str` | Categoría del vuelo, como Regular, No Regular, Vuelo Escuela, entre otras. |
| `Clasificación Vuelo` | `str` | Indica si el vuelo es doméstico o internacional. |
| `Tipo de Movimiento` | `str` | Indica si el registro corresponde a un despegue o un aterrizaje. |
| `Aeropuerto` | `str` | Código del aeropuerto donde se registra la operación. |
| `Origen / Destino` | `str` | Código del aeropuerto relacionado con el origen o destino de la operación. |
| `Aerolinea Nombre` | `str` | Nombre de la aerolínea que realiza la operación. |
| `Aeronave` | `str` | Código utilizado para identificar el fabricante y modelo de la aeronave. |
| `Pasajeros` | `float64` | Cantidad de pasajeros correspondiente a una operación aérea. |
| `PAX` | `float64` | Variable relacionada con la cantidad de pasajeros de cabotaje. |
| `Calidad dato` | `str` | Indica la condición o calidad del registro publicado. |

## Variable objetivo

La variable objetivo del proyecto es `Pasajeros`, porque queremos estimar cuántos pasajeros transporta una operación de vuelo regular de cabotaje.

La predicción se plantea **24 horas antes de la salida del vuelo**. Tomar ese momento es una decisión del proyecto y no significa que la fuente confirme que todas las variables originales estén disponibles 24 horas antes.

## Preparación de los datos

Como el proyecto trabaja con vuelos regulares de cabotaje, se seleccionaron solo los registros cuya clase de vuelo es `Regular` y cuya clasificación es `Doméstico`.

Después de este filtro quedaron **265.624 registros**.

También se revisó cómo ANAC registra los movimientos. En los vuelos de cabotaje aparecen registros de despegue y aterrizaje, por lo que mantener ambos podría hacer que una misma operación aparezca dos veces.

Por eso se decidió trabajar solamente con los registros de `Despegue`. Así, `Aeropuerto` representa el aeropuerto de salida y `Origen / Destino` el aeropuerto de destino.

Luego de seleccionar los despegues quedaron **132.846 registros**.

## Registros duplicados

Después de aplicar los filtros se encontraron **8 registros duplicados**.

Al revisarlos, se vio que las filas tenían exactamente los mismos valores en todas las columnas.

Como el dataset no tiene un identificador único para cada vuelo, no se puede comprobar cada caso por separado. De todas formas, al ser registros completamente iguales dentro del conjunto ya filtrado, se decidió eliminar una de las copias.

Después de eliminar estos duplicados quedaron **132.838 registros**.

## Revisión de PAX

Se revisó la relación entre `PAX` y `Pasajeros`.

En los 132.838 registros del conjunto preparado se comprobó que:

`PAX = Pasajeros / 2`

Como `Pasajeros` es la variable que queremos predecir, usar `PAX` como entrada generaría fuga de información porque contiene un valor calculado directamente a partir de ella.

Por eso se eliminó `PAX` del conjunto preparado.

## Revisión de Aeronave

La variable `Aeronave` contiene códigos correspondientes al fabricante y modelo de avión utilizado en la operación.

También se encontraron registros con el valor `0`, pero la documentación no deja claro qué significa ese valor.

Además, no se pudo confirmar si la aeronave registrada es información disponible antes de la salida del vuelo. Por eso la variable se mantiene en el dataset, pero no se usa como predictora.

## Revisión de Fecha UTC y Hora UTC

Las variables `Fecha UTC` y `Hora UTC` indican la fecha y hora de la operación en horario UTC.

La fuente no aclara si corresponden al horario programado o al horario real en que ocurrió el movimiento.

Como la predicción se hace antes de la salida, esa diferencia es importante. Por eso ambas variables se mantienen en el dataset, pero no se usan como predictoras.

## Variables eliminadas después de los filtros

Después de aplicar los filtros, algunas columnas quedaron con un único valor:

- `Clase de Vuelo (todos los vuelos)`: Regular.
- `Clasificación Vuelo`: Doméstico.
- `Tipo de Movimiento`: Despegue.
- `Calidad dato`: DEFINITIVO.

Como estas variables tienen el mismo valor en todos los registros, ya no aportan información útil para el modelo y se eliminaron del dataset preparado.


## Análisis de la variable objetivo

En el conjunto final, `Pasajeros` tiene los siguientes valores:

| Medida | Valor |
|---|---:|
| Mínimo | 0 |
| Percentil 1 | 0 |
| Percentil 5 | 69 |
| Percentil 25 | 91 |
| Media | 129,79 |
| Mediana | 140 |
| Percentil 75 | 162 |
| Percentil 95 | 186 |
| Percentil 99 | 231 |
| Máximo | 284 |

Se encontraron **1.824 operaciones con 0 pasajeros (1,37 %)**. No aparecen valores negativos ni fraccionarios.

Como la fuente no indica que el valor 0 represente un dato faltante, estos casos se conservaron. Además, aparecen en distintas aerolíneas y rutas, por lo que no había una razón clara para eliminarlos.

También se revisaron los valores extremos. Con el criterio de 1,5 veces el rango intercuartílico aparecen solo **3 registros** por encima del límite superior de 268,5 pasajeros: 269, 271 y 284. Se dejaron en el dataset porque no había evidencia suficiente para considerarlos errores.

## Análisis de los predictores

El modelo utiliza `Aeropuerto`, `Origen / Destino` y `Aerolinea Nombre` como variables predictoras.

| Elemento | Cantidad |
|---|---:|
| Aeropuertos de salida | 42 |
| Destinos | 66 |
| Aerolíneas | 41 |
| Rutas origen-destino | 420 |

También hay categorías poco frecuentes:

- 3 aeropuertos de salida tienen menos de 10 registros.
- 24 destinos tienen menos de 10 registros.
- 32 aerolíneas tienen menos de 10 registros.
- 183 rutas tienen menos de 10 operaciones y 99 aparecen una sola vez.

No se encontraron espacios sobrantes ni diferencias que fueran solamente de mayúsculas y minúsculas en los tres predictores. Tampoco se agruparon categorías solo porque sus nombres fueran parecidos.

Las tres aerolíneas con más operaciones son `AEROLINEAS ARGENTINAS SA`, `JETSMART AIRLINES S.A.` y `FB LÍNEAS AÉREAS - FLYBONDI`, que juntas concentran aproximadamente el 98,54 % de los registros. La notebook incluye además la comparación de pasajeros entre las aerolíneas y rutas con más operaciones.

## Selección de variables y momento de predicción

El momento de predicción se define como **24 horas antes de la salida del vuelo**. Es un supuesto del proyecto que sirve para decidir qué información puede usarse como predictora.

Las variables utilizadas por el modelo son:

- `Aeropuerto`.
- `Origen / Destino`.
- `Aerolinea Nombre`.

`Fecha UTC` se usa para ordenar los registros y organizar la evaluación temporal, pero no entra al modelo como predictora. `Hora UTC` y `Aeronave` tampoco se usan porque no se pudo confirmar que estén disponibles 24 horas antes de la salida.

## Preparación de categorías y evaluación temporal

Dentro de las notebooks, `Fecha UTC` se convierte a tipo temporal y se revisa que los datos cubran desde el **01/01/2025** hasta el **31/12/2025**.

Como el objetivo es estimar pasajeros de operaciones futuras, la evaluación se organiza respetando el orden temporal:

- **Entrenamiento:** enero a agosto de 2025.
- **Validación:** septiembre y octubre de 2025.
- **Prueba final:** noviembre y diciembre de 2025, con 22.884 registros.

Las variables categóricas se preparan con `OneHotEncoder(handle_unknown="ignore")`. Durante la comparación de modelos, el codificador se ajusta solamente con entrenamiento y después se aplica a validación. El conjunto de prueba se deja aparte hasta la evaluación final.

Después de elegir el modelo y su profundidad, se juntan los datos de enero a octubre, con **109.954 registros**. El codificador se vuelve a ajustar con ese período completo y después se aplica a noviembre y diciembre. Así, la preparación del test no usa información del propio conjunto de prueba.

En la preparación final, tanto desarrollo como prueba quedan representados con **139 columnas** después de la codificación.

## Reproducibilidad

Las dependencias están listadas en `requirements.txt`.

Para reproducir el proyecto:

1. Desde la raíz del repositorio, ejecutar `python -m pip install -r requirements.txt`.
2. Entrar a la carpeta `notebooks`.
3. Ejecutar primero `jupyter notebook preparacion_datos_anac_2025.ipynb`.
4. Luego ejecutar `jupyter notebook modelado_anac_2025.ipynb`.

Las rutas de lectura y escritura son relativas a la carpeta `notebooks`.

## Resultado final

El dataset preparado quedó formado por **132.838 registros y 7 columnas**:

| Variable | Tipo de dato |
|---|---|
| `Fecha UTC` | `str` |
| `Hora UTC` | `str` |
| `Aeropuerto` | `str` |
| `Origen / Destino` | `str` |
| `Aerolinea Nombre` | `str` |
| `Aeronave` | `str` |
| `Pasajeros` | `float64` |

Cada observación del conjunto preparado representa un despegue de una operación regular de cabotaje publicada por ANAC, después de aplicar los filtros y eliminar los duplicados exactos.

Este conjunto preparado es el que se usa en la notebook de modelado. Ahí se comparan los modelos, se elige la profundidad del Árbol de Decisión y se hace la evaluación final con los datos de noviembre y diciembre.

## Archivos relacionados

- Dataset original: `data/raw/informe-ministerio-actualizado-dic-final.csv`
- Dataset procesado: `data/processed/vuelos_regulares_cabotaje_2025_procesado.csv`
- Notebook de preparación: `notebooks/preparacion_datos_anac_2025.ipynb`
- Notebook de modelado y evaluación: `notebooks/modelado_anac_2025.ipynb`
