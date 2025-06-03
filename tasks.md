Como empresa de desarrollo de *software,* FinTech Solutions S. A. sabe que, para desarrollar un código de calidad, es muy importante automatizar las pruebas. En esta actividad se completará una batería de pruebas que se ofrece como ejemplo.

El código del repositorio unir-test (https://github.com/jafraileni/unir-test), que se utilizó en el caso práctico, contiene una batería de pruebas insuficiente y, además, no ha implementado todas las funcionalidades. Por lo tanto, debes completar las funcionalidades que faltan y añadir más pruebas para cubrir el mayor número de funciones posibles.

Asimismo, debes modificar los ficheros api.py y calc.py para que incluyan las funciones de suma, resta, multiplicación, división, potenciación, raíz cuadrada y logaritmo en base 10. Algunas de las funciones necesarias ya están implementadas. 

Las funciones de la clase Calculator deben comprobar que los parámetros tengan valores aceptables. Por ejemplo, la división ya implementada eleva una excepción si el divisor es 0. Se puede usar TypeError para todas las excepciones de esta clase.

Asimismo, hay que añadir pruebas unitarias en unit/calc_test.py y rest/api_test.py. Si has definido funciones auxiliares, añade las pruebas en unit/util_test.py. Las pruebas deben cubrir los casos de éxito y los casos de fallo. Por ejemplo, una llamada GET /calc/divide/1/0 debe comprobar que la API devuelve un código HTTP 400 Bad Request. Asimismo, las pruebas de la clase Calculator deben cubrir métodos estáticos, si se definen algunos. 

Es importante aprovechar el módulo math para las funciones matemáticas avanzadas. Si lo necesitas, refactoriza la clase Calculator para reutilizar código.