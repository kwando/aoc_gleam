today:=`date +"%d"`
run:
    @gleam run run --timed=true {{today}} #--example
