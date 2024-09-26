
v=./proyecto.v
top=proyecto
tb=./simon_dice_tb.v
MACRO_SIM=-DPOS=5

sim:
	# 1. Crear el archivo .vvp ejecutable desde iverilog
	iverilog $(MACRO_SIM) -o $(tb).vvp $(tb)
	# 2. Ejecuta el archivo .vvp para mostrar resultados
	vvp $(tb).vvp -dumpfile=$(top)_tb.vcd

wave:
	gtkwave $(top)_tb.vcd $(top).gtkw

rtl:
	# 1. Síntesis del diseño, si la sintaxis es correcta, se genera un archivo json que representa el diseño
	yosys $(MACRO_SIM) -p 'read_verilog $v; prep -top $(top); hierarchy -check; proc; write_json $(top).json'
	# 2. Comando para generación del RTL en formato SVG (vectorial)
	netlistsvg $(top).json -o $(top).svg
	# 3. Visualizar el RTL con el visor de imagenes eog
	eog $(top).svg

clean:
	rm -f *.vvp *.json *.vcd *.json *.pnr *.bin

syn:
	yosys -p "synth_ice40 -top $(top) -json $(top).json" $(top).v 
pnr:
	nextpnr-ice40 --hx4k --package tq144 --json $(top).json --pcf $(top).pcf --asc $(top).pnr 
	icepack wokwi.pnr wokwi.bin 
	
pack:
	icepack $(top).pnr $(top).bin 
	
config:
	stty -F /dev/ttyACM0 raw
	cat $(top).bin > /dev/ttyACM0
