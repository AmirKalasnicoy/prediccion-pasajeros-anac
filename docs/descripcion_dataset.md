# Descripción y preparación del dataset

## Dataset utilizado

Para este proyecto se utiliza el dataset **“Aterrizajes y despegues procesados por la Administración Nacional de Aviación Civil”**, correspondiente al año 2025.

Los datos provienen del portal de Datos Abiertos de la Secretaría de Transporte de la Nación y fueron publicados por la Administración Nacional de Aviación Civil (ANAC).

El dataset original contiene **597.784 registros y 12 columnas**.

Enlace oficial al dataset:

https://datos.transporte.gob.ar/dataset/aterrizajes-y-despegues-procesados-por-la-administracion-nacional-de-aviacion-civil-anac/archivo/0706775f-bed9-46e7-aac5-726d7e72e429

## Variables originales

| Variable | Tipo de dato | Descripción |
|---|---|---|
| `Fecha UTC` | `object` | Fecha en la que se registró la operación aérea, expresada en horario UTC. |
| `Hora UTC` | `object` | Hora de la operación expresada en UTC. |
| `Clase de Vuelo (todos los vuelos)` | `object` | Categoría del vuelo, como Regular, No Regular, Vuelo Escuela, entre otras. |
| `Clasificación Vuelo` | `object` | Indica si el vuelo es doméstico o internacional. |
| `Tipo de Movimiento` | `object` | Indica si el registro corresponde a un despegue o un aterrizaje. |
| `Aeropuerto` | `object` | Código del aeropuerto donde se registra la operación. |
| `Origen / Destino` | `object` | Código del aeropuerto relacionado con el origen o destino de la operación. |
| `Aerolinea Nombre` | `object` | Nombre de la aerolínea que realiza la operación. |
| `Aeronave` | `object` | Código utilizado para identificar el fabricante y modelo de la aeronave. |
| `Pasajeros` | `float64` | Cantidad de pasajeros correspondiente a una operación aérea. |
| `PAX` | `float64` | Variable relacionada con la cantidad de pasajeros de cabotaje. |
| `Calidad dato` | `object` | Indica la condición o calidad del registro publicado. |

## Variable objetivo

La variable objetivo del proyecto es `Pasajeros`, ya que se busca estimar la cantidad de pasajeros transportados en una operación correspondiente a un vuelo regular de cabotaje.

La predicción se plantea para realizarse antes de la salida del vuelo, por lo que solamente deberían utilizarse como predictoras aquellas variables cuya información esté disponible en ese momento.

## Preparación de los datos

Como el proyecto está enfocado en vuelos regulares de cabotaje, se seleccionaron únicamente los registros cuya clase de vuelo es `Regular` y cuya clasificación es `Doméstico`.

Después de este filtro quedaron **256.624 registros**.

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

## Resultado final

El dataset preparado quedó formado por **132.838 registros y 7 columnas**:

| Variable | Tipo de dato |
|---|---|
| `Fecha UTC` | `object` |
| `Hora UTC` | `object` |
| `Aeropuerto` | `object` |
| `Origen / Destino` | `object` |
| `Aerolinea Nombre` | `object` |
| `Aeronave` | `object` |
| `Pasajeros` | `float64` |

Una observación del conjunto preparado representa un registro de despegue correspondiente a una operación regular de cabotaje publicada por ANAC, luego de aplicar los filtros y eliminar duplicados exactos.

El dataset queda preparado para continuar con la selección definitiva de variables y la posterior generación del modelo de Aprendizaje Automático.

## Archivos relacionados

- Dataset original: `data/raw/informe-ministerio-actualizado-dic-final.csv`
- Dataset procesado: `data/processed/vuelos_regulares_cabotaje_2025_procesado.csv`
- Notebook de preparación: `notebooks/preparacion_datos_anac_2025.ipynb`
