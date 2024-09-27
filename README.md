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

SIMULACION\\
```verilog
// filename: simon_dice_tb.v
`include "./simon_dice.v"
module simon_dice_tb;
// STIMULUS
reg sclk = 0;
reg rst = 0;
reg [3:0] button = 0;
wire [3:0] led;

localparam integer TICKS = 1;
always #(TICKS) sclk = !sclk;

initial begin
// Pasado 32 estímuslos finaliza la simulación
#(1000 * TICKS) $finish();  // [stop(), $finish()]
end

  // RESET STIMULUS
initial begin
#0 rst = 0;
#(1 * TICKS) button = 4'b0100;
#(1 * TICKS) button = 4'b0000;
end

// DEVICE/DESIGN UNDER TEST
simon_dice dut (.clk(sclk), .rst(reset), .button(button), .led(led));
// MONITOR
/*
initial
begin
	$monitor("Time: %t, b = %d, a = %d => c = %d, s = %d",
	$time, b, a, c, s);
end
*/

initial begin
$dumpvars(0, simon_dice_tb);
end

endmodule
```

CODIGO DE PRUEBA\\
```verilog
module simon_dice(
    input clk,              // Reloj de la FPGA
    input rst,              // Botón de reset
    input [3:0] button,     // Entrada de los 4 pulsadores
    output reg [3:0] led    // Salida de los 4 LEDs
);

    // Definición de estados
    parameter START = 3'b000;
    parameter SHOW_SEQ = 3'b001;
    parameter WAIT_INPUT = 3'b010;
    parameter CHECK_SEQ = 3'b011;
    parameter WIN = 3'b100;
    parameter LOSE = 3'b101;

    reg [2:0] state, next_state;
    reg [3:0] seq;         // Secuencia de LEDs (simplificada a 4 bits)
    reg [3:0] input_seq;   // Secuencia ingresada por el jugador
    reg [1:0] seq_index;   // Índice de la secuencia
    reg [1:0] player_index; // Índice de la entrada del jugador

    // Reloj para controlar la velocidad del juego
    reg [25:0] counter;
    wire slow_clk = counter[25];  // Divisor de frecuencia

    // Contador de reloj para ralentizar la secuencia
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
        end else begin
            counter <= counter + 1;
        end
    end

    // Actualización del estado secuencialmente (sin bucles combinacionales)
    always @(posedge slow_clk or posedge rst) begin
        if (rst) begin
            state <= START;
            seq_index <= 0;
            player_index <= 0;
            seq <= 4'b1010;  // Secuencia predefinida para simplificación
            input_seq <= 0;
        end else begin
            state <= next_state;

            // Solo actualizar el índice de la secuencia en el estado SHOW_SEQ
            if (state == SHOW_SEQ) begin
                seq_index <= seq_index + 1;
            end

            // Solo actualizar el índice de la secuencia del jugador en WAIT_INPUT
            if (state == WAIT_INPUT && button != 4'b0000) begin
                input_seq[player_index] <= button;
                player_index <= player_index + 1;
            end

            // Resetear índices al comenzar una nueva ronda
            if (state == START) begin
                seq_index <= 0;
                player_index <= 0;
            end
        end
    end

    // Máquina de estados sin lógica combinacional directa
    always @(*) begin
        next_state = state; // Por defecto, mantener el estado actual
        led = 4'b0000;      // Por defecto, mantener los LEDs apagados

        case (state)
            START: begin
                next_state = SHOW_SEQ;  // Cambiar al estado SHOW_SEQ
            end
            
            SHOW_SEQ: begin
                if (seq_index < 4) begin
                    led = (1 << seq_index);  // Mostrar LEDs uno por uno
                    next_state = SHOW_SEQ;
                end else begin
                    next_state = WAIT_INPUT;
                end
            end
            
            WAIT_INPUT: begin
                if (button != 4'b0000) begin
                    if (player_index == 4) begin
                        next_state = CHECK_SEQ;
                    end else begin
                        next_state = WAIT_INPUT;
                    end
                end
            end
            
            CHECK_SEQ: begin
                if (input_seq == seq) begin
                    next_state = WIN;
                end else begin
                    next_state = LOSE;
                end
            end
            
            WIN: begin
                led = 4'b1111;  // Indicar victoria
                next_state = START;
            end
            
            LOSE: begin
                led = 4'b0000;  // Indicar derrota
                next_state = START;
            end
            
            default: next_state = START;
        endcase
    end
endmodule
```

CODIGO FINAL\\
```verilog
`default_nettype none

module proyecto (//se establecen los input y los output, inicializar variables y configurar el sistema.

    input  CLK, //clock
    input  RST, //reset
    input  BTN0, //botones
    input  BTN1,
    input  BTN2,
    input  BTN3,
    output LED0,//leds
    output LED1,
    output LED2,
    output LED3,
    output SND,//sonido
    output SEG_A,//segmentos del display
    output SEG_B,
    output SEG_C,
    output SEG_D,
    output SEG_E,
    output SEG_F,
    output SEG_G,
    output DIG1,
    output DIG2
);

  simon simon1 (
      .clk      (CLK),
      .rst      (RST),
      .ticks_per_milli (16'd50),
      .btn      ({BTN3, BTN2, BTN1, BTN0}),
      .led      ({LED3, LED2, LED1, LED0}),
      .segments_invert(1'b1), // For common anode 7-segment display
      .segments({SEG_G, SEG_F, SEG_E, SEG_D, SEG_C, SEG_B, SEG_A}),
      .segment_digits({DIG2, DIG1}),
      .sound    (SND)
  );

endmodule

//modulo de score//Estado: Power On:
        // Encender los LEDs.
        //Esperar a que el usuario presione un botón.
       // Si se presiona un botón, ir a Estado: Init.

module score (
    input wire clk,
    input wire rst,
    input wire ena,
    input wire invert,
    input wire inc,
    output reg [6:0] segments,
    output reg [1:0] digits
);
  reg active_digit;
  reg [3:0] ones;
  reg [3:0] tens;
  wire [3:0] digit_value = active_digit ? tens : ones;

  always @(posedge clk) begin
    active_digit <= ~active_digit;

    if (rst) begin
      ones <= 0;
      tens <= 0;
    end else if (inc) begin
      ones <= ones + 1;
      if (ones == 9) begin
        ones <= 0;
        tens <= tens + 1;
        if (tens == 9) begin
          tens <= 0;
        end
      end
    end

    case(active_digit)// Estado: Init:
        //Inicializar secuencia (secuencia de longitud 1).
       // Esperar un breve tiempo (milisegundos).
        //Ir a Estado: Play.

      1'b0: digits <= invert ? 2'b10 : 2'b01;
      1'b1: digits <= invert ? 2'b01 : 2'b10;
    endcase

    case (ena ? digit_value : 4'd15)
      4'd0: segments <= invert ? 7'b1000000 : 7'b0111111;
      4'd1: segments <= invert ? 7'b1111001 : 7'b0000110;
      4'd2: segments <= invert ? 7'b0100100 : 7'b1011011;
      4'd3: segments <= invert ? 7'b0110000 : 7'b1001111;
      4'd4: segments <= invert ? 7'b0011001 : 7'b1100110;
      4'd5: segments <= invert ? 7'b0010010 : 7'b1101101;
      4'd6: segments <= invert ? 7'b0000010 : 7'b1111101;
      4'd7: segments <= invert ? 7'b1111000 : 7'b0000111;
      4'd8: segments <= invert ? 7'b0000000 : 7'b1111111;
      4'd9: segments <= invert ? 7'b0010000 : 7'b1101111;
      default: segments <= invert ? 7'b1111111 : 7'b0000000;
    endcase
  end
  
endmodule


module play ( //modo de juego   //Estado: Play:
        //Encender el LED correspondiente a la secuencia actual.
        //Generar el sonido correspondiente.
        //Esperar un tiempo (milisegundos).
        //Ir a Estado: Play Wait.

    input wire clk,
    input wire rst,
    input wire [15:0] ticks_per_milli,
    input wire [9:0] freq,
    output reg sound
);
  reg [31:0] tick_counter;
  wire [31:0] ticks_per_second = ticks_per_milli * 1000;
  wire [31:0] freq32 = {22'b0, freq};

  always @(posedge clk) begin
    if (rst) begin
      tick_counter <= 0;
      sound <= 0;
    end else if (freq == 0) begin
      sound <= 0;
    end else begin
      tick_counter <= tick_counter + freq32;
      if (tick_counter >= (ticks_per_second >> 1)) begin
        sound <= !sound;
        tick_counter <= tick_counter + freq32 - (ticks_per_second >> 1);
      end
    end
  end

endmodule

module simon ( //modulo de simon dice
    input wire clk,
    input wire rst,
    input wire [15:0] ticks_per_milli,
    input wire [3:0] btn,
    input wire segments_invert,
    output reg [3:0] led,
    output wire sound,
    output wire [6:0] segments,
    output wire [1:0] segment_digits
);

  localparam MAX_GAME_LEN = 32;

  wire [9:0] GAME_TONES[3:0];
  assign GAME_TONES[0] = 196;  // G3
  assign GAME_TONES[1] = 262;  // C4
  assign GAME_TONES[2] = 330;  // E4
  assign GAME_TONES[3] = 784;  // G5

  wire [9:0] SUCCESS_TONES[6:0];
  assign SUCCESS_TONES[0] = 330;  // E4
  assign SUCCESS_TONES[1] = 392;  // G4
  assign SUCCESS_TONES[2] = 659;  // E5
  assign SUCCESS_TONES[3] = 523;  // C5
  assign SUCCESS_TONES[4] = 587;  // D5
  assign SUCCESS_TONES[5] = 784;  // G5
  assign SUCCESS_TONES[6] = 0;  // silence

  wire [9:0] GAMEOVER_TONES[3:0];
  assign GAMEOVER_TONES[0] = 622;  // D#5 
  assign GAMEOVER_TONES[1] = 587;  // D5
  assign GAMEOVER_TONES[2] = 554;  // C#5
  assign GAMEOVER_TONES[3] = 523;  // C5

  localparam StatePowerOn = 0;
  localparam StateInit = 1;
  localparam StatePlay = 2;
  localparam StatePlayWait = 3;
  localparam StateUserWait = 4;
  localparam StateUserInput = 5;
  localparam StateNextLevel = 6;
  localparam StateGameOver = 7;

  reg [4:0] seq_counter;
  reg [4:0] seq_length;
  reg [1:0] seq[MAX_GAME_LEN-1:0];
  reg [2:0] state;

  reg [15:0] tick_counter;
  reg [9:0] millis_counter;
  reg [2:0] tone_sequence_counter;
  reg [9:0] sound_freq;

  reg [1:0] next_random;
  reg [1:0] user_input;
  reg score_inc;
  reg score_rst;
  reg score_ena;

  play play1 (
      .clk(clk),
      .rst(rst),
      .ticks_per_milli(ticks_per_milli),
      .freq(sound_freq),
      .sound(sound)
  );

  score score1 (
      .clk(clk),
      .rst(rst | score_rst),
      .ena(score_ena),
      .inc(score_inc),
      .invert(segments_invert),
      .segments(segments),
      .digits(segment_digits)
  );

  always @(posedge clk) begin
    if (rst) begin
      seq_length <= 0;
      seq_counter <= 0;
      tick_counter <= 0;
      millis_counter <= 0;
      sound_freq <= 0;
      next_random <= 0;
      state <= StatePowerOn;
      seq[0] <= 0;
      led <= 4'b0000;
      score_inc <= 0;
      score_rst <= 0;
      score_ena <= 0;
    end else begin
      tick_counter <= tick_counter + 1;
      next_random  <= next_random + 1;
      score_inc <= 0;
      score_rst <= 0;

      if (tick_counter == ticks_per_milli - 1) begin
        tick_counter   <= 0;
        millis_counter <= millis_counter + 1;
      end

      case (state) //   Estado: Play Wait:
        //Apagar LED y sonido.
        //Comprobar si se ha mostrado toda la secuencia:
            //Sí: Ir a Estado: User Wait.
            //No: Regresar a Estado: Play.

        StatePowerOn: begin
          led <= 4'b1111;
          led[millis_counter[9:8]] <= 1'b0;
          //esto espera hasta qu el jugador presione algun boton para empezar la secuencia random
          if (btn != 0) begin
            state <= StateInit;
            led <= 4'b0000;
            millis_counter <= 0;
            score_ena <= 1;
            seq[0] <= next_random;
          end
        end
        StateInit: begin
          seq_length <= 1;
          seq_counter <= 0;
          tone_sequence_counter <= 0;
          if (millis_counter == 500) begin
            score_rst <= 1;
            state <= StatePlay;
          end
        end
        StatePlay: begin
          led <= 0;
          led[seq[seq_counter]] <= 1'b1;
          sound_freq <= GAME_TONES[seq[seq_counter]];
          millis_counter <= 0;
          state <= StatePlayWait;
        end
        StatePlayWait: begin
          if (millis_counter == 300) begin
            led <= 0;
            sound_freq <= 0;
          end
          if (millis_counter == 400) begin
            if (seq_counter + 1 == seq_length) begin
              state <= StateUserWait; // Estado: User Wait:
       // Esperar a que el usuario presione un botón.
       // Al recibir entrada, ir a Estado: User Input.

              millis_counter <= 0;
              seq_counter <= 0;
            end else begin
              seq_counter <= seq_counter + 1;
              state <= StatePlay;
            end
          end
        end
        StateUserWait: begin
          led <= 0;
          millis_counter <= 0;
          if (btn != 0) begin
            state <= StateUserInput;     //Estado: User Input:
        //Encender el LED correspondiente al botón presionado.
        //Generar el sonido correspondiente.
        //Esperar un tiempo (milisegundos).
        //Comparar la entrada del usuario con la secuencia:
            //Correcto:
                //Si es la última entrada: Ir a Estado: Next Level.
                //Si no: Regresar a Estado: User Wait.
            //Incorrecto: Ir a Estado: Game Over.

            seq[seq_length] <= next_random;
            case (btn)
              4'b0001: user_input <= 0;
              4'b0010: user_input <= 1;
              4'b0100: user_input <= 2;
              4'b1000: user_input <= 3;
              default: state <= StateUserWait;
            endcase
          end
        end
        StateUserInput: begin
          led <= 0;
          led[user_input] <= 1'b1;
          sound_freq <= GAME_TONES[user_input];
          if (millis_counter == 300) begin
            sound_freq <= 0;
            if (user_input == seq[seq_counter]) begin
              if (seq_counter + 1 == seq_length) begin
                millis_counter <= 0;
                seq_length <= seq_length + 1;
                state <= StateNextLevel;  //    Estado: Next Level:
        //Incrementar la longitud de la secuencia.
        //Reproducir sonido de éxito.
        //Esperar tiempo.
        //Ir a Estado: Play.

                score_inc <= 1;
              end else begin
                seq_counter <= seq_counter + 1;
                state <= StateUserWait;
              end
            end else begin
              millis_counter <= 0;
              state <= StateGameOver;
            end
          end
        end
        StateNextLevel: begin
          led <= 0;
          if (millis_counter == 150) begin
            if (tone_sequence_counter < 7) begin
              sound_freq <= SUCCESS_TONES[tone_sequence_counter];
            end else begin
              sound_freq <= 0;
              tone_sequence_counter <= 0;
              seq_counter <= 0;
              state <= StatePlay;
            end
            tone_sequence_counter <= tone_sequence_counter + 1;
            millis_counter <= 0;
          end
        end
        StateGameOver: begin     //Estado: Game Over:
        //Encender LEDs de manera intermitente.
        //Reproducir tonos de Game Over.
        //Esperar a que el usuario presione un botón para reiniciar.
        //Ir a Estado: Init.

          led <= millis_counter[7] ? 4'b1111 : 4'b0000;

          if (tone_sequence_counter == 4) begin
            // sonidos
            sound_freq <= GAMEOVER_TONES[3] - 16 + {5'b0, millis_counter[4:0]};
            if (millis_counter == 1000) begin
              tone_sequence_counter <= 7;
              sound_freq <= 0;
            end
          end else if (millis_counter == 300) begin
            if (tone_sequence_counter < 4) begin
              sound_freq <= GAMEOVER_TONES[tone_sequence_counter[1:0]];
              tone_sequence_counter <= tone_sequence_counter + 1;
            end
            millis_counter <= 0;
          end

          if (btn != 0) begin
            led <= 4'b0000;
            sound_freq <= 0;
            millis_counter <= 0;
            seq[0] <= next_random;
            state <= StateInit;
          end
        end
      endcase
    end
  end

endmodule
  //    Fin:
        //Terminar o reiniciar el juego.
        // En cada estado, puedes incluir detalles sobre la configuración de las variables y las acciones específicas que se realizan.
```

RTL\\

A continuacion se presentaran los RTL de cada uno de los modulos, emepezando por el modulo score:

![](./modulo%20score.jpeg)

A continuacion se presenta el modulo de play:

![](./modulo%20play.jpeg)
CONCLUSIONES\\

A traves de este proyecto se pudo evidenciar como se interactua entre los diferentes tipos de logicas dentro de un diseño con fpga y prohgramando con verilog.

se entendio todas las fases preeliminares de programacion, como el test bench, makefile, pcf. json, pnr para poder ejecutar un codigo en la vida real

se enetiendo la logica detras de los pulsadores y actuadores y el tipo de proyectos que se pueden realizar para ayuda de la sociedad.

ANEXOS\\


REFERENCIAS\\




[def]: ./simon_dice_tb.v