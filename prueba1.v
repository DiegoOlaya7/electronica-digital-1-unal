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
