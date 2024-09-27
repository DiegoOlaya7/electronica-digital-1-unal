# electronica-digital-1-unal
Proyecto en verilog, implementando una FPGA de un simon dice\\

en el siguiente repositorio se encontrara los archvios necesarios para llevar a cabo un proyecto de simon dice con 4 pulsadores, 4 leds, un display 7 segmentos y una fpga ice40\\

RESUMEN\\

tambien se encontraran deficiones teoriacas y tecnicas de lo implementado y un analisis de lo evidenciado a la hora de realizar el proyecto.
Se planteo y construyó una implementación en FPGA del juego de memoria de patrones simon dice. El programa está diseñado para generar una secuencia aleatoria de colores (rojo, verde, azul y amarillo) para que el jugador intente recrear el pantron más tarde. Esta secuencia se almacena en un bloque de memoria interna y se reproduce para el usuario antes de esperar la entrada. La entrada del jugador llega al sistema a través de cuatro botones externos (uno para cada color). El jugador debe presionar los botones en el orden en que el sistema muestra los colores como una prueba de la memoria del jugador. La memoria interna es lo suficientemente grande como para almacenar una secuencia de colores de 32 "etapas" de longitud, por lo que si el usuario llega a ese punto, el juego declara una victoria y se encienden todas las luces de salida. Si en cualquier momento durante la entrada el usuario presiona una luz incorrecta, el juego se pierde se encederan todas las luces acompañados de un sonido. En todo momento, se mostrara la puntuación del usuario, que es igual al número de etapas en la secuencia actual. Para iniciar o reiniciar el juego, el usuario debe presionar un botón de reinicio, que borra la secuencia anterior y comienza el juego nuevamente.\\


CONFIGURACION PIN 7 SEGMENTOS\\
![](./pines%207%20segmentos.jpg)\\

DIAGRAMA DE FLUJO\\
La siguiente imagen muestra como es el diagrama de flujo de proyecto realizado:\\
![](./diagrama%20de%20flujo.jpeg)\\
CODIGO DE PRUEBA\\

SIMULACION\\

CODIGO FINAL\\

RTL\\

CONCLUSIONES\\

ANEXOS\\


REFERENCIAS\\


