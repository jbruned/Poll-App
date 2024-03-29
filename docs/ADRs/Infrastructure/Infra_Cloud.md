# ADR Despliegue

* Estado: aceptada
* Responsables:
    * Unai Biurrun Villacorta
    * Jorge Bruned Alamán
    * Iñaki Velasco Rodríguez
* Fecha: 01-05-2023

# Introducción

<div style="text-align: justify!important">

En este documento se recoge la información relativa a las decisiones iniciales en cuanto a la arquitectura en la nube del sistema.
Para cada decisión, se listan las opciones consideradas junto a una breve descripción, ventajas y contras, así como la decisión final tomada.

El formato a seguir será una sección para cada uno de los microservicios que componen el sistema, así como una sección para la integración de los mismos.

Además, se parte de la base de que el despliegue se hará en la nube, concretamente en AWS, por requisito del cliente.
Por tanto, no se considerarán otras opciones como despliegue *on-premise* o en otras plataformas como Azure o Google Cloud.

</div>

## Tabla de contenidos

<!-- TOC -->
* [Introducción](#introducción)
    * [Tabla de contenidos](#tabla-de-contenidos)
    * [Factores en la decisión](#factores-en-la-decisión)
* [Servidor web](#servidor-web)
    * [API + Frontend en el mismo servicio](#api--frontend-en-el-mismo-servicio)
    * [API y Frontend en servicios separados](#api-y-frontend-en-servicios-separados)
    * [Decisión](#decisión)
* [Base de datos](#base-de-datos)
    * [Base de datos en el mismo servicio](#base-de-datos-en-el-mismo-servicio)
    * [Base de datos PostgreSQL en servicio independiente](#base-de-datos-postgresql-en-servicio-independiente)
    * [Base de datos nativa de AWS (RDS)](#base-de-datos-nativa-de-aws-rds)
    * [Decisión](#decisión-1)
* [API Gateway](#api-gateway)
    * [Uso de API Gateway (Kong)](#uso-de-api-gateway-kong)
    * [Redirección directa al servidor web](#redirección-directa-al-servidor-web)
    * [Uso del API Gateway de AWS](#uso-del-api-gateway-de-aws)
    * [Decisión](#decisión-2)
* [Arquitectura resultante](#arquitectura-resultante)
    * [Despliegue en AWS](#despliegue-en-aws)
    * [Presupuesto](#presupuesto)
<!-- TOC -->

## Factores en la decisión

<div style="text-align: justify!important">

Para tomar la decisión se han priorizado los siguientes factores:

* Sencillez de configuración
* Precio
* Escalabilidad
* Posibilidad de automatización

</div>

# Servidor web

<div style="text-align: justify!important">

Este servicio es totalmente imprescindible. En nuestro caso, se han contemplado dos opciones, que se describen a continuación.

</div>

## API + Frontend en el mismo servicio

<div style="text-align: justify!important">

En esta opción, el servidor web contendría tanto la API como el frontend. Esto es, el servidor web se encargaría de servir los archivos estáticos del frontend en la raíz `/`, así como de redirigir las peticiones a la API en la ruta `/api`.

- Ventajas:
    - Sencillez de configuración
    - Despliegue simultáneo mediante una única imagen de *Docker*
    - Precio (solo se necesita un servicio)
- Desventajas:
    - No se puede escalar de forma independiente el frontend y la API
    - Si el API se cae o se reinicia, se cae también el frontend
    - No se puede reemplazar de forma independiente el frontend y la API

</div>

## API y Frontend en servicios separados

<div style="text-align: justify!important">

En esta opción, existiría un servicio para el frontend y otro para la API, cada uno con su propio servidor web.
En este caso, sería imprescindible contar con un API gateway o un balanceador de carga que redirija las peticiones
a cada uno de los servicios.

- Ventajas:
    - Se puede escalar de forma independiente cada uno de los servicios
    - Podemos actualizar la versión del API sin afectar al frontend
    - Mientras el API se reinicia, el frontend sigue funcionando y muestra un mensaje al usuario
    - Se puede reemplazar de forma independiente el frontend y la API
    - Posibilidad de usar un servidor estático o un CDN para el frontend, lo que reduce el coste y optimiza el rendimiento
- Desventajas:
    - Configuración más compleja
    - Necesidad de un API gateway o balanceador de carga
    - Necesidad de dos procesos de despliegue
    - Precio (se necesitan dos servicios)

</div>

## Decisión

<div style="text-align: justify!important">

Se ha optado por la primera opción, ya que es más sencilla de configurar y desplegar, y además es más barata.
Además, se ajusta más a la arquitectura actual desplegada en local y no se considera necesario escalar de forma independiente el frontend y la API a corto plazo. Sería relativamente sencillo cambiar a la segunda opción en el futuro si fuera necesario.

</div>

# Base de datos

<div style="text-align: justify!important">

La base de datos es el segundo de los servicios desplegados en local. Sin embargo, existe la opción de desplegarla en el mismo servicio que el API o en un servicio separado. También se ha considerado la posibilidad de usar la base de datos de AWS. A continuación, se presentan y describen las opciones consideradas.

</div>

## Base de datos en el mismo servicio

<div style="text-align: justify!important">

En esta opción, la base de datos se desplegaría en el mismo servicio que el API. Esto es fácilmente realizable ya que disponemos de una variable de entorno `USE_POSTGRES`, que en caso de ser `False` utiliza una base de datos de SQLite por defecto dentro del propio servicio. En caso de ser `True`, se utiliza una base de datos de PostgreSQL.

- Ventajas:
    - Sencillez de configuración
    - Prescindimos de un servicio
- Desventajas:
    - No se puede escalar de forma independiente el servidor web y la base de datos
    - De hecho, imposibilita crear más de una instancia del servidor web (puesto que cada instancia tendría su propia base de datos) 
    - Fuerte acoplamiento entre el API y la base de datos
    - No se puede reemplazar ni reiniciar a base de datos sin afectar al API
    - Si la base de datos se cae o se reinicia, se cae también el API (¡y el frontend si están en el mismo servicio!)

</div>

## Base de datos PostgreSQL en servicio independiente

<div style="text-align: justify!important">

En esta opción, la base de datos se desplegaría en un servicio independiente, tal y como se hace en local. Esto es,
se desplegaría un servicio de PostgreSQL y se configuraría el API para que se conecte a él. Esto es fácilmente realizable
gracias a las variables de entorno, que creamos en su día con la mirada puesta en el despliegue en la nube.

- Ventajas:
    - Se puede escalar de forma independiente el servidor web y la base de datos
    - Se puede crear más de una instancia del servidor web
    - Se puede reemplazar o reiniciar la base de datos sin afectar al API
    - La arquitectura local ya está desplegada de esta forma
    - Conocimiento de la herramienta
- Desventajas:
    - Configuración más compleja
    - Necesidad de un servicio adicional

</div>

## Base de datos nativa de AWS (RDS)

<div style="text-align: justify!important">

En esta opción, la base de datos se desplegaría en un servicio de AWS, concretamente en RDS.

- Ventajas:
    - Prescindimos de un servicio
    - Escalabilidad
    - BD gestionada por AWS
    - Precio (en principio es más barato que desplegar un servicio de *PostgreSQL*)
- Desventajas:
    - Desconocimiento de la herramienta
    - Necesidad de configuración adicional
    - Mayor dependencia de AWS, lo que dificulta la migración a otro proveedor

</div>

## Decisión

<div style="text-align: justify!important">

Se ha optado por la segunda opción, ya que es más sencilla de configurar y desplegar, además de que ya está desplegada en local. Además, se ajusta más a la arquitectura actual desplegada en local y no se considera necesario utilizar RDS en las circunstancias actuales. Sin embargo, a fecha de hoy (entrega del RFI III), se ha desplegado la base de datos junto al API (primera opción), ya que se ha considerado que es más importante tener el servicio desplegado cuanto antes y en las próximas semanas se realizará el cambio a la segunda opción, que  implemente requiere crear el servicio de PostgreSQL y configurar las variables de entorno mencionadas anteriormente. Así mismo, no nos cerramos a la posibilidad de utilizar RDS en el futuro, si se considera necesario.

</div>

# API Gateway

<div style="text-align: justify!important">

El API Gateway es el tercer servicio desplegado en local. Sin embargo, es un servicio prescindible, ya que se pueden dirigir las peticiones al servidor web directamente. También podríamos utilizar el API Gateway de AWS. A continuación,
se presentan y describen las opciones consideradas.

</div>

## Uso de API Gateway (Kong)

<div style="text-align: justify!important">

En esta opción, se desplegaría un servicio de API Gateway que redirigiría las peticiones al servidor web. Esto es,
replicaríamos la arquitectura actual desplegada en local.

- Ventajas:
    - Captura de logs
    - Escalabilidad
    - Posibilidad de redirigir las peticiones a distintos servicios (si, por ejemplo, el API y el frontend estuvieran en servicios distintos)
    - Posibilidad de proteger ciertos endpoints con autenticación (por ejemplo, mediante tokens)
    - La arquitectura local ya está desplegada de esta forma
    - Conocimiento de la herramienta
- Desventajas:
    - Configuración más compleja
    - Necesidad de un servicio adicional
    - Precio (por el mismo motivo)
    - Punto de fallo adicional
    - Posible cuello de botella si no se escala debidamente

</div>

## Redirección directa al servidor web

<div style="text-align: justify!important">

En esta opción, se redirigirían las peticiones al servidor web directamente, sin pasar por un API Gateway.

- Ventaas:
    - Sencillez de configuración
    - Prescindimos de un servicio
    - Menor latencia (potencialmente)
    - Menor precio al no necesitar un servicio adicional
- Desventajas:
    - Perdemos las ventajas del API Gateway: no se capturan logs, proteger ciertos endpoints, etc.

</div>

## Uso del API Gateway de AWS

<div style="text-align: justify!important">

En esta opción, se utilizaría el API Gateway de AWS, que es un servicio que ofrece AWS de forma nativa.

- Ventajas:
    - Prescindimos de un servicio
    - Precio (en principio es más barato que desplegar un servicio de *API Gateway*)
- Desventajas:
    - Desconocimiento de la herramienta
    - Necesidad de configuración adicional
    - Mayor dependencia de AWS, lo que dificulta la migración a otro proveedor

</div>

## Decisión

<div style="text-align: justify!important">

Al igual que en el caso de la base de datos, hemos decidido mantener por el momento la arquitectura actual desplegada en local, es decir, replicaríamos la arquitectura actual desplegada en local. Sin embargo, a fecha de hoy (entrega del RFI III), no se ha desplegado el API Gateway, ya que se ha considerado que es más importante tener el servicio desplegado cuanto antes y en las próximas semanas se realizará el cambio a la primera opción, que simplemente requiere crear el servicio de API Gateway y configurar las rutas. Así mismo, no nos cerramos a la posibilidad de utilizar el API Gateway de AWS en el futuro, si se considera necesario.

</div>

# Arquitectura resultante

A continuación, se presenta la arquitectura resultante, recogida en el siguiente diagrama:

<div style="text-align: center!important">

![Arquitectura en la nube](../../img/cloud_arch.png)

</div>

<div style="text-align: justify!important">

Cabe destacar que, actualmente, solo se ha desplegado el servidor web con el API y el frontend, y la base de datos
está integrada en el mismo. En las próximas semanas se desplegará la base de datos en un servicio independiente y
se configurará el API gateway.

</div>

## Despliegue en AWS

<div style="text-align: justify!important">

Para automatizar el despliegue de la arquitectura en AWS, se utilizará *Terraform*, por ser la herramienta más extendida y, al mismo tiempo, un requisito del cliente. Además, se utilizarán imágenes de *Docker* para desplegar los servicios; concretamente, para el servicio con el API y el frontend se utilizará la imagen de *Docker* que ya se ha creado en anteriores iteraciones del desarrollo. Para el servicio de base de datos, se utilizará la imagen oficial de *PostgreSQL* y para el servicio de API Gateway, se utilizará la imagen oficial de *Kong*.

La automatización del despliegue se incorporará a la versión final del proyecto, y se incluirá en el pipeline de CI/CD.
En este RFI, se ha realizado el despliegue manualmente, para comprobar que la arquitectura funciona correctamente. La única parte que ya se ha automatizado es la publicación de la imagen de *Docker* del servidor web en *ECR* desde la pipeline de CI/CD de *Github Actions*.

</div>

## Presupuesto

<div style="text-align: justify!important">

A continuación se detallan los costes para la solución propuesta de manera desglosada. Se han hecho estimaciones incluyendo varios aspectos y considerando tanto el primer año como los 5 primeros. Esto se debe a que el coste del primer año podría ser reducido gracias al nivel gratuito de AWS, pero en los años siguientes se tendría que pagar el coste completo.

Habrá dos aspectos principales a tener en cuenta: los entornos a desplegar, con todo lo que ello requiere, y otros aspectos generales como podrían ser el coste de los salarios de los desarrolladores, el coste de la infraestructura, etc.

### Entornos
Se han considerado tres entornos: desarrollo, preproducción y producción.

El entorno de desarrollo se utilizará por el equipo de desarrollo para probar los cambios realizados en el código, realizar nuevas implementaciones, etc, y no se espera que tenga un uso intensivo. Además que un fallo en este entorno no supondría un gran problema, ya que no se vería afectado el servicio en producción.

De manera similar, el entorno de preproducción tendrá la misma capacidad que el de desarrollo y será en el que se realicen las pruebas de aceptación por parte del cliente.
Ambos entornos dispondrán de una capacidad menor que el de producción. 

Finalmente, el entorno de producción contendrá la aplicación funcional y todo lo necesario para que funcione correctamente. Este entorno tendrá una capacidad mayor que los anteriores.

Para todos ellos habrá que tener en cuenta los siguientes puntos a la hora de calcular el coste:
* Servicio aplicación
* Servicio API Gateway
* RDS
* Load Balancer
* Almacenamiento en ECR
* Dominio (en el caso del entorno de producción)

Cada uno de los puntos previos se facturará en función de las características correspondientes: CPU, memoria, almacenamiento, etc. Además, se tendrá en cuenta el tiempo de uso de cada uno de ellos que, en el caso de esta propuesta, está contemplado como un servicio disponible 24/7 durante todo el año.

### Costes generales

Para esta propuesta se han considerado los siguientes costes generales:
* Coste humano: 3 desarrolladores a un coste medio de 3500$ mensuales para la empresa.
* Coste de licencias: tan solo se requerirá de GitHub Pro.
* Coste de infraestructura: se ha optado por el alquiler de una oficina de trabajo suficiente para todo el equipo

### Extras

A pesar de que no supongan ningun coste para esta propuesta, en el desarrollo de un proyecto similar también habría que tener en cuenta los siguientes aspectos:
* Bastion host: se emplea durante el despliegue y se destuye una vez finalizado por lo que se ha considerado un coste despreciable.
* CloudWatch: se emplea para monitorizar los servicios y, en nuestro caso, está cubierto completamente por el nivel gratuito de AWS.

### Presupuesto final

En la siguiente tabla se detalla el coste desglosado en base a lo comentado anteriormente:

![Presupuesto solución](../../img/presupuesto.jpg)

Como se puede observar, la mayor parte corresponde al pago de los desarrolladores.

Dejando de lado los costes generales y centrándonos en los entornos, el coste del balanceador de carga destaca por encima del resto, pero se considera un elemento imprescindible y con dificil remplazo. Por otro lado, el coste más bajo correspondería al almacenamiento de imágenes propias en ECR, con un total de 1,20\$ anuales.

Finalmente, el coste total de los entornos para el primer año sería de 1.784,90\$ y de 9.139,06\$ totales para los cinco primeros años.
Los costes generales (recursos humanos, licencias e infraestructura) supondrían un total de 140.400,00\$ para el primer año y 702.432,00\$ para los cinco primeros años.

Con ello, el presupuesto presentado total sería de:
* 142.184,90\$ para el primer año
* 711.571,06\$ para los cinco primeros años
</div>
