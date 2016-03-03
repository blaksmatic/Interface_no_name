require '../src/graph'
require '../src/view'
require_relative 'controller'

#This function gives out the title page when people use this system
#
def instruction
  @spliter = '-----------CSAIR-------------------------'
  puts @spliter
  puts 'Welcome to the CSair interface'
  puts 'You can use the following instruction to interact with the databse'
  puts 'Case is not sensitive in this interface'
  puts 'GetCity [CITY CODE] will return the information of the city'
  puts 'GetInfo will return the information of CSAIR'
  puts 'Browser will return the picture which has all the routes of CSAIR'
  puts 'GetAllCity will return a list of cities that CSAIR fly to.'
  puts 'EditCity will bring you to edit mode where you can edit a city'
  puts 'Editroute will bring you to the edit mode where you can edit a route.'
  puts 'Save will save the current graph onto the data file.'
  puts 'Load will reload the graph from the data file. Current progress will be lost.'
  puts 'Merge [file_path] will let you read and merge the file into our current graph'
  puts 'Checkroutes [metro1] [metro2]......[metro.n] will check the routes and give you some feekbacks'
  puts 'Shortest [City Code1] [city Code2] will return the path from city 1 to city 2.'
  puts 'Test and ExitTest will enter or exit the testing mode'
  puts 'Help will print this menu again.'
  puts @spliter
end

#This function is a main interface, cal this function and the interface will show up.

# @param [Graph] my_graph The input is the graph
def wait_for_input(my_graph)
  while true
    input = gets
    words = input.split
    if (words.length == 0)
      next
    end
    command = words[0].upcase
    case command
      when 'EXIT'
        break
      when 'BROWSER'
        open_browser(my_graph)
      when 'GETINFO'
        my_graph.analysis_data
      when 'GETALLCITY'
        list_city(my_graph)
      when 'GETCITY'
        if (words.length >= 2)
          get_city_info(words[1].upcase, my_graph)
        else
          puts 'You need to give me the city!'
        end
      when 'EDITCITY'
        edit_city(my_graph)
      when 'EDITROUTE'
        edit_route(my_graph)
      when 'HELP'
        instruction
      when 'SAVE'
        save_file(my_graph)
      when 'LOAD'
        my_graph = load_file(my_graph)
      when 'MERGE'
        merge_file(my_graph, words[1])
      when 'CHECKROUTES'
        words.shift
        check_routes(my_graph, words)
      when 'TEST'
        my_graph = Graph.new('../data/test.json')
        puts 'Into Test mode'
      when 'EXITTEST'
        my_graph = Graph.new('../data/map_data.json')
        puts 'Exit test mode'
      when 'SHORTEST'
        if words.length >=3
          if words[1]==words[2]
            puts 'I know without even thinking about it. It is 0'
          else
            calculate_shortest(my_graph, words[1].upcase, words[2].upcase)
          end
        else
          puts 'The number of cities you provide is not enough.'
        end
      else
        puts 'Commends not recognisable.'
    end
  end
end
