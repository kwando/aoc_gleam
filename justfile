today:=`date +"%d"`
current_year:=`date +"%Y"`

run:
    @echo {{current_year}}
    @gleam run run --timed=true {{today}} #--example

fetch_input YEAR DAY:
    curl --cookie "session=$AOC_COOKIE" https://adventofcode.com/{{YEAR}}/day/{{DAY}}/input > input/{{YEAR}}/{{DAY}}.input.txt
