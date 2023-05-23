# Documento RFP

<div style="text-align: justify!important">

En este documento se recogen la conclusiones y decisiones tomadas a lo largo de los RFIs anteriores.
Además, aparecen dos nuevos puntos a tratar: el despliegue total del sistema en AWS y el coste de la solución teniendo en cuenta todos los factores.
</div>
    
## Tabla de contenidos

<!-- TOC -->
* [Introducción](#introducción)
* [Despliegue en AWS](#despliegue-en-aws)
* [Métricas/logs](#métricaslogs)
* [Coste de la solución](#coste-de-la-solución)
* [Trabajo futuro o desarrollos pendientes](#trabajo-futuro-o-desarrollos-pendientes)
* [Análisis final de las preguntas](#análisis-final-de-las-preguntas)
<!-- TOC -->

# Introducción

<div style="text-align: justify">

En este documento se plasma el resultado de los RFIs anteriores que derivarán en aspectos como el despliegue en AWS, las métricas/logs y el coste de la solución, todos ellos explicados en los siguientes apartados.
Además, se deja abierto a futuros desarrollos una serie de puntos especificados en el apartado [Trabajo futuro o desarrollos pendientes](#trabajo-futuro-o-desarrollos-pendientes).

# Despliegue en AWS
<div style="text-align: justify">
    
TODO
</div>

→ ***[Ver ADR correspondiente](../ADRs/Infrastructure/Deployment.md)***

# Métricas/logs
<div style="text-align: justify">
  
En cuanto a las métricas también se nos han presentado varias opciones. No obstante, y debido principalmente a los plazos, se ha optado por emplear el sistema de monitorización integrado de AWS: CloudWatch.
Con esta herramienta podremos crear los dashboards que necesitemos para monitorizar el sistema, así como crear alarmas que nos avisen en caso de que se produzca algún error o se sobrepase algún umbral.

Otras opciones a las que se podría haber recurrido son:
- Prometheus: sistema de monitorización de código abierto que permite la monitorización de métricas y logs.
- Grafana: herramienta de visualización de datos que permite crear dashboards para monitorizar el sistema.
- ELK: conjunto de herramientas que permite la monitorización de logs.
- Datadog: herramienta de monitorización de logs y métricas.
- New Relic: herramienta de monitorización de logs y métricas.

Como se ha mencionado, CloudWatch será la herramienta a utilizar. A continuación se puede observar un ejemplo de visualización obtenido a partir de CloudWatch:

TODO INSERTAR CAPTURA DE ALGO DE MONITORIZACION DE CLOUDWATCH
</div>

# Coste de la solución
<div style="text-align: justify">

A modo de resumen, se presenta la siguiente tabla de presupuestos:

![Presupuesto solución](../img/presupuesto.jpg)

Como se puede observar, se han planteado tres entornos a desplegar: desarrollo, preproducción y producción. Cada uno de ellos tiene un coste asociado, que se detalla en la tabla anterior. Además, se han añadido costes generales asociados a recursos humanos, licencias o infraestructuras.

Con ello, se obtiene un coste total de 1.784,90\$ para el primer año de los entornos y un total de 9.139,06\$ totales para los cinco primeros años.

Por otro lado, los costes generales ascienden a 140.400,00\$ para el primer año y 702.432,00\$ para los cinco primeros años.

De esta forma, el presupuesto presentado total, en el que se incluyen costes desde la aplicación hasta la infraestructura necesaria para el equipo, sería de:
* 142.184,90\$ para el primer año
* 711.571,06\$ para los cinco primeros años

→ ***[Ver ADR correspondiente](../ADRs/Infrastructure/Deployment.md#presupuesto)***
</div>

# Trabajo futuro o desarrollos pendientes
<div style="text-align: justify">
  
TODO
</div>

# Análisis final de las preguntas
- Todas las preguntas anunciadas en los RFI anteriores.
Ver [RFI I](RFI%20I.md)
Ver [RFI II](RFI%20II.md)
Ver [RFI III](RFI%20III.md)
- ¿Cómo se despliega el sistema en AWS?
Ver [Despliegue en AWS](#despliegue-en-aws)
- ¿Cuáles son las métricas/logs para evaluar el funcionamiento del sistema?
Ver [Métricas/logs](#métricaslogs)
- ¿Cuál es la arquitectura del sistema de métricas/logs?
Ver [Métricas/logs](#métricaslogs)
- ¿Cómo se visualizan esas métricas/logs?
Ver [Métricas/logs](#métricaslogs)
- Trabajo futuro o Desarrollos pendientes
Ver [Trabajo futuro o desarrollos pendientes](#trabajo-futuro-o-desarrollos-pendientes)
