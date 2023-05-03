# Documento RFI II

<div style="text-align: justify!important">

En este documento se recoge la información relativa a las decisiones tomadas en torno a la arquitectura de la aplicación y los microservicios empleados. Se analizan aspectos en cuanto a ventajas/desventajas y se explica la funcionalidad y el método de instalación y uso en local.
</div>
    
## Tabla de contenidos

<!-- TOC -->
- [Introducción](#introducción)
- [Arquitectura](#arquitectura)
- [Microservicios](#microservicios)
  - [Base de datos](#base-de-datos)
  - [Backend](#backend)
  - [API Gateway](#api-gateway)
- [Análisis final de las preguntas](#análisis-final-de-las-preguntas)
<!-- TOC -->

# Introducción

Se ha implementado una arquitectura basada en microservicios que, en nuestro caso, serán los siguientes tres: base de datos, backend y API Gateway.

# Arquitectura
<div style="text-align: justify">
    
Existe una gran variedad de arquitecturas posibles para el sistema. Algunas de estas son:
- Arquitectura basada en microservicios
- Arquitectura de 3 capas
- Arquitectura de 2 capas

La arquitectura del sistema elegida ha sido la basada en microservicios debido, no solo a su requerimiento por parte del cliente (requisito de la asignatura), sino también a sus grandes ventajas que proporcionará tanto en esta release (RFI II), como en la próxima en la que se hará un despliegue en Cloud. Algunas de estas ventajas son la modularidad, la escalabilidad y un mayor desacoplamiento.

También se ha tenido en cuenta el listado de microservicios necesarios que se implementarán para el funcionamiento de la aplicación, ya que de ellos también dependerá la arquitectura del sistema.

→ ***[Ver ADR correspondiente](../ADRs/Infrastructure/Architecture.md)***
</div>

# Microservicios
<div style="text-align: justify">
  
En relación a la arquitectura se definen también los microservicios:
</div>

## Base de datos
<div style="text-align: justify">

En este caso, se encargará de almacenar los datos referentes a las encuestas: votos, opciones, ajustes, etc.
Para persistir sus datos se hará uso de un volumen y, de esta forma, no se perderán los datos al cerrar el contenedor.
En concreto, se empleará PostgreSQL debido a motivos ya explicados previamente en el [RFI I](RFI%20I.md).
</div>

## Backend
<div style="text-align: justify">

La funcionalidad de este servicio es servir como API para obtener y escribir los datos necesarios para su funcionamiento. Ésto se realizará a traves de los distintos endpoints definidos, cada uno con su función correspondiente.
Cabe destacar que desde el frontend solo estarán disponibles ciertos endpoints por lo que algunas funcionalidades más relacionadas con el usuario administrador estarán restringidas y se podrá acceder a ellas mediante peticiones HTTP (curl, Postman, etc)
</div>

## API Gateway
<div style="text-align: justify">
</div>

Debido a requisitos del cliente, se ha hecho uso de Kong para el desarrollo del API Gateway. Se encargará de la correcta redirección según el tipo de petición y el endpoint al que se vaya a acceder, además de otras funcionalidades como los *logging* para auditoría.
</div>

→ ***[Ver ADR correspondiente](../ADRs/Infrastructure/Microservices.md)***

# Análisis final de las preguntas
- ¿Cuáles son los microservicios de los que consiste el sistema votación?
Ver [Microservicios](#microservicios)
- ¿Cuál es la funcionalidad de cada uno de los microservicios?
Ver [Microservicios](#microservicios)
- ¿Cuál es la arquitectura de la solución?
Ver [Arquitectura](#arquitectura)
- ¿Cómo es la comunicación entre microservicios?
Ver [ADR Microservicios](../ADRs/Infrastructure/Microservices.md)
- ¿Cómo se despliega el sistema en un entorno de test local?
Ver [README](../../README.md)
- ¿Cómo se prueba la funcionalidad del sistema en un entorno de test local?
 Lanzar aplicación / usar Postman (Ver [ADR Microservicios](../ADRs/Infrastructure/Microservices.md))
- ¿Cómo se lleva a cabo la autenticación, autorización y auditoria del sistema?
Ver [ADR Microservicios](../ADRs/Infrastructure/Microservices.md)
- ¿Por qué es escalable y elástica la solución?
Ver [Arquitectura](#arquitectura) y [Microservicios](#microservicios)

