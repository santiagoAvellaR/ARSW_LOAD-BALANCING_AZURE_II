### Escuela Colombiana de Ingeniería
### Arquitecturas de Software - ARSW

## Escalamiento en Azure con Maquinas Virtuales, Sacale Sets y Service Plans

### Dependencias
* Cree una cuenta gratuita dentro de Azure. Para hacerlo puede guiarse de esta [documentación](https://azure.microsoft.com/es-es/free/students/). Al hacerlo usted contará con $100 USD para gastar durante 12 meses.
Antes de iniciar con el laboratorio, revise la siguiente documentación sobre las [Azure Functions](https://www.c-sharpcorner.com/article/an-overview-of-azure-functions/)

### Parte 0 - Entendiendo el escenario de calidad

Adjunto a este laboratorio usted podrá encontrar una aplicación totalmente desarrollada que tiene como objetivo calcular el enésimo valor de la secuencia de Fibonnaci.

**Escalabilidad**
Cuando un conjunto de usuarios consulta un enésimo número (superior a 1000000) de la secuencia de Fibonacci de forma concurrente y el sistema se encuentra bajo condiciones normales de operación, todas las peticiones deben ser respondidas y el consumo de CPU del sistema no puede superar el 70%.

### Escalabilidad Serverless (Functions)

1. Cree una Function App tal cual como se muestra en las  imagenes.

![](images/part3/part3-function-config.png)

![](images/part3/part3-function-configii.png)

2. Instale la extensión de **Azure Functions** para Visual Studio Code.

![](images/part3/part3-install-extension.png)

3. Despliegue la Function de Fibonacci a Azure usando Visual Studio Code. La primera vez que lo haga se le va a pedir autenticarse, siga las instrucciones.

![](images/part3/part3-deploy-function-1.png)

![](images/part3/part3-deploy-function-2.png)

4. Dirijase al portal de Azure y pruebe la function.

![](images/part3/part3-test-function.png)

5. Modifique la coleción de POSTMAN con NEWMAN de tal forma que pueda enviar 10 peticiones concurrentes. Verifique los resultados y presente un informe.

6. Cree una nueva Function que resuleva el problema de Fibonacci pero esta vez utilice un enfoque recursivo con memoization. Pruebe la función varias veces, después no haga nada por al menos 5 minutos. Pruebe la función de nuevo con los valores anteriores. ¿Cuál es el comportamiento?.

**Preguntas**

* **¿Qué es un Azure Function?**  
  Es un servicio de computación serverless de Azure que permite ejecutar pequeñas piezas de código (funciones) en la nube, en respuesta a eventos o peticiones HTTP, sin necesidad de administrar servidores.

* **¿Qué es serverless?**  
  Es un modelo de computación en la nube donde el proveedor administra automáticamente la infraestructura. El usuario solo se enfoca en el código y paga únicamente por el tiempo de ejecución y los recursos consumidos.

* **¿Qué es el runtime y qué implica seleccionarlo al momento de crear el Function App?**  
  El runtime es el entorno de ejecución que interpreta y ejecuta el código de las funciones (por ejemplo, Node.js, .NET, Python). Seleccionarlo define el lenguaje soportado y las características disponibles para la Function App.

* **¿Por qué es necesario crear un Storage Account de la mano de un Function App?**  
  Azure Functions utiliza el Storage Account para almacenar archivos de configuración, logs, el código de las funciones y para gestionar el estado de ejecución (por ejemplo, colas y triggers).

* **¿Cuáles son los tipos de planes para un Function App?, ¿En qué se diferencian?, mencione ventajas y desventajas de cada uno de ellos.**  
  - **Consumption Plan:** Escala automáticamente, paga solo por el tiempo de ejecución. Ventaja: bajo costo para cargas variables. Desventaja: puede tener "cold start" y límites de recursos.
  - **Premium Plan:** Escala automáticamente, pero permite instancias pre-calentadas (sin cold start) y mayor capacidad. Ventaja: mejor rendimiento, sin cold start. Desventaja: mayor costo.
  - **Dedicated (App Service) Plan:** Usa recursos reservados (VMs dedicadas). Ventaja: integración con otras apps y control total de recursos. Desventaja: se paga aunque no haya ejecuciones.

* **¿Por qué la memorization falla o no funciona de forma correcta?**  
  Porque en Azure Functions el entorno puede reciclarse o escalar horizontalmente, perdiendo el estado en memoria (cache) entre ejecuciones o instancias. Además, el "cold start" reinicia el proceso y borra el cache.

* **¿Cómo funciona el sistema de facturación de las Function App?**  
  En el Consumption Plan, se factura por número de ejecuciones y tiempo de ejecución (GB-segundos). En Premium y Dedicated, se factura por el tiempo que las instancias están activas, independientemente del número de ejecuciones.

* Informe
## Informe de Escalabilidad y Optimización con Azure Functions

### Resumen de la experiencia

Durante el laboratorio se desplegó una función de Azure para calcular el enésimo número de Fibonacci. Inicialmente, la función utilizaba un enfoque recursivo puro, lo que resultaba en tiempos de respuesta elevados para valores grandes de `n` debido a la alta complejidad computacional.

#### Tiempos antes de la memorización

- Para valores altos de `n` (por ejemplo, 30,000 o más), los tiempos de respuesta podían superar los **varios segundos** o incluso provocar timeouts o errores por límite de recursos.
- Cada petición realizaba todos los cálculos desde cero, sin aprovechar resultados previos.

#### Tiempos después de implementar memorización

- Tras implementar memorización (cache en memoria), la **primera llamada** para un valor grande de `n` seguía siendo costosa, pero las siguientes llamadas para el mismo o menores valores eran **casi instantáneas** (menos de 100 ms).
- El tiempo de respuesta promedio mejoró drásticamente en las llamadas subsecuentes.

#### Porcentaje de mejora

- **Antes:** ~700 ms o más por petición (dependiendo de `n`).
- **Después:** ~100 ms o menos en llamadas repetidas.
- **Mejora estimada:**  

Porcentaje de mejora = ((tiempo antes - tiempo después) / tiempo antes) × 100

Porcentaje de mejora = ((700 - 100) / 700) × 100 ≈ 85.7% 
  (El porcentaje puede ser mayor para valores grandes de `n`).

### Cosas aprendidas

- **Serverless:** Permite ejecutar código sin preocuparse por la infraestructura, pagando solo por el uso real.
- **Azure Function:** Es una plataforma serverless de Azure que facilita la ejecución de funciones en la nube, escalando automáticamente según la demanda.
- **Memorización:** Es una técnica efectiva para optimizar funciones recursivas, pero su efectividad depende de la persistencia del entorno de ejecución.
- **Cache y cold start:** El cache en memoria solo es útil mientras la instancia de la función esté viva. Si Azure recicla la instancia (por escalado o inactividad), el cache se pierde (cold start), y la primera llamada vuelve a ser lenta.
- **Consideraciones:**  
  - No se debe depender del cache en memoria para datos críticos o persistentes.
  - El cold start puede afectar la experiencia del usuario en escenarios serverless.
  - Es importante entender el modelo de facturación y los límites de cada plan de Azure Functions.

### Conclusión

La memorización mejora significativamente el rendimiento de funciones recursivas en Azure Functions, pero su efectividad está limitada por la naturaleza efímera y escalable del entorno serverless. Es fundamental considerar estos aspectos al diseñar soluciones en la nube.
