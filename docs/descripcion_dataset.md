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

La variable objetivo del proyecto es `Pasajeros`, ya que se busca estimar la cantidad de pasajeros transportados en una operación correspondiente a un vuelo regular de cabotaje.

Para esta primera versión se toma como referencia una predicción **24 horas antes de la salida del vuelo**. Esta anticipación es una decisión de alcance del proyecto y no implica que la fuente confirme la disponibilidad de todas las variables originales en ese momento.

## Preparación de los datos

Como el proyecto está enfocado en vuelos regulares de cabotaje, se seleccionaron únicamente los registros cuya clase de vuelo es `Regular` y cuya clasificación es `Doméstico`.

Después de este filtro quedaron **265.624 registros**.

También se revisó la forma en la que ANAC registra los movimientos. Para los vuelos de cabotaje aparecen registros de despegue y aterrizaje, por lo que mantener ambos podría representar dos veces una misma operación.

Por este motivo, se decidió trabajar únicamente con los registros correspondientes a `Despegue`. De esta forma, `Aeropuerto` puede interpretarse como el aeropuerto de salida y `Origen / Destino` como el aeropuerto de destino.

Luego de seleccionar los despegues quedaron **132.846 registros**.

## Registros duplicados

Sobre el conjunto ya filtrado se detectaron 8 registros duplicados.

Después de revisar estos casos se observó que las filas aparecían repetidas con exactamente los mismos valores en todas las columnas disponibles.

Como el dataset no cuenta con un identificador único de vuelo, no es posible verificar cada caso de forma independiente. Sin embargo, al tratarse de registros completamente iguales dentro del conjunto ya filtrado, se eliminó una de las copias de cada caso.

Luego de este tratamiento quedaron **132.838 registros**.

## Revisión de PAX

Se revisó la relación entre `PAX` y `Pasajeros`.

En los 132.838 registros del conjunto preparado se comprobó que:

`PAX = Pasajeros / 2`

Como `Pasajeros` es la variable objetivo, utilizar `PAX` como entrada del modelo generaría fuga de información, ya que contiene un valor calculado directamente a partir de la variable que se busca predecir.

Por este motivo, `PAX` fue eliminada del conjunto preparado.

## Revisión de Aeronave

La variable `Aeronave` contiene códigos correspondientes al fabricante y modelo de avión utilizado en la operación.

También se encontraron registros con el valor `0`. La documentación consultada no permite determinar con precisión qué representa ese valor.

Además, todavía no se pudo confirmar si la aeronave registrada corresponde a información disponible antes de la salida del vuelo. Por este motivo, la variable se mantiene en el dataset, pero no se considera confirmada como predictora.

## Revisión de Fecha UTC y Hora UTC

Las variables `Fecha UTC` y `Hora UTC` indican la fecha y hora de la operación en horario UTC.

Sin embargo, la fuente no aclara si corresponden al horario programado o al momento efectivo en que ocurrió el movimiento.

Como la predicción se plantea antes de la salida del vuelo, esta diferencia es importante. Por este motivo, ambas variables se mantienen en el dataset, aunque todavía no se consideran confirmadas como predictoras.

## Variables eliminadas después de los filtros

Después de aplicar los filtros, algunas columnas quedaron con un único valor:

- `Clase de Vuelo (todos los vuelos)`: Regular.
- `Clasificación Vuelo`: Doméstico.
- `Tipo de Movimiento`: Despegue.
- `Calidad dato`: DEFINITIVO.

Como estas variables ya no presentan variación y no aportarían información para una futura predicción, fueron eliminadas del dataset preparado.


## Análisis de la variable objetivo

En el conjunto final, `Pasajeros` presenta los siguientes valores:

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

Se encontraron **1.824 operaciones con 0 pasajeros (1,37 %)**. No hay valores negativos ni fraccionarios.

La fuente oficial define `Pasajeros` como la cantidad de pasajeros de una operación individual y no indica que 0 sea un código de dato faltante. Los ceros aparecen además en distintas aerolíneas y rutas. Por este motivo se conservan y no se eliminan automáticamente.

Con el criterio de 1,5 veces el rango intercuartílico, el límite superior es 268,5 pasajeros y aparecen **3 registros** por encima de ese valor: 269, 271 y 284 pasajeros. Se mantienen identificados para revisión, pero no se eliminan solamente por ser valores extremos.

## Análisis de los predictores iniciales

La primera versión del proyecto utiliza `Aeropuerto`, `Origen / Destino` y `Aerolinea Nombre`.

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

No se encontraron espacios al inicio o al final ni variantes que se diferencien únicamente por mayúsculas y minúsculas en los tres predictores iniciales. Por ahora no se agrupan categorías solamente porque sus nombres sean parecidos.

Las tres aerolíneas con más operaciones son `AEROLINEAS ARGENTINAS SA`, `JETSMART AIRLINES S.A.` y `FB LÍNEAS AÉREAS - FLYBONDI`, que juntas concentran aproximadamente el 98,54 % de los registros. La notebook incluye además la comparación de pasajeros entre las aerolíneas y rutas con más operaciones.

## Selección inicial de variables y momento de predicción

Para esta primera versión, el momento de predicción se define como **24 horas antes de la salida del vuelo**. Se trata de un supuesto operativo del proyecto para poder delimitar qué información sería válida como predictor.

El conjunto inicial de predictores queda formado por:

- `Aeropuerto`.
- `Origen / Destino`.
- `Aerolinea Nombre`.

`Fecha UTC` se usa para ordenar los registros y organizar la evaluación temporal, pero no se incorpora como predictor. `Hora UTC` y `Aeronave` quedan fuera de esta primera versión hasta poder confirmar mejor su disponibilidad con la anticipación definida.

## Preparación de categorías y evaluación temporal

Dentro de la notebook, `Fecha UTC` se convierte a tipo temporal y se comprobó que el conjunto cubre desde el **01/01/2025** hasta el **31/12/2025**.

Como se busca estimar pasajeros de vuelos futuros, se define una separación temporal:

- **Desarrollo:** enero a octubre de 2025, con 109.954 registros.
- **Prueba final:** noviembre y diciembre de 2025, con 22.884 registros.

Los tres predictores iniciales se preparan con `OneHotEncoder(handle_unknown="ignore")`. El codificador se ajusta únicamente con el conjunto de desarrollo y luego se aplica al período de prueba. De esta forma, las categorías nuevas no obligan a volver a ajustar el preprocesamiento con información del test.

Después de la codificación, el conjunto de desarrollo tiene 139 columnas. En el período de prueba aparecen 7 destinos y 3 aerolíneas que no estaban en el período de desarrollo, lo que confirma la utilidad de contemplar categorías desconocidas.

No se entrena ningún modelo en esta etapa.

## Reproducibilidad

Las dependencias están listadas en `requirements.txt`.

Para reproducir la preparación:

1. Desde la raíz del repositorio, ejecutar `python -m pip install -r requirements.txt`.
2. Entrar a la carpeta `notebooks`.
3. Ejecutar `jupyter notebook preparacion_datos_anac_2025.ipynb`.

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

Una observación del conjunto preparado representa un registro de despegue correspondiente a una operación regular de cabotaje publicada por ANAC, luego de aplicar los filtros y eliminar duplicados exactos.

Con esta preparación queda definida una primera versión de los predictores y una estrategia temporal de evaluación. El modelado y la evaluación de resultados se realizarán en la etapa posterior.

## Archivos relacionados

- Dataset original: `data/raw/informe-ministerio-actualizado-dic-final.csv`
- Dataset procesado: `data/processed/vuelos_regulares_cabotaje_2025_procesado.csv`
- Notebook de preparación: `notebooks/preparacion_datos_anac_2025.ipynb`
