require '../src/graph'
require '../src/view'
require '../src/metro'

#The main function the CSAIR, will call graph once start
#starts from here
class CSAir
  class Main
    my_graph = Graph.new('../data/map_data.json')
    instruction
    wait_for_input(my_graph)
  end
end