##
#This function prings the information about a city
# @param [String] city_code The code of the city we are going to get the information from
# @param [Graph] my_graph The graph we are editing.
def get_city_info(city_code, my_graph)
  metro = my_graph.metro
  if metro.has_key?(city_code)
    city = metro[city_code]
    puts "#{@spliter}"
    puts "City Code: #{city.code}"
    puts "City Name: #{city.name}"
    puts "Country: #{city.country}"
    puts "Continent: #{city.continent}"
    puts "Timezone: #{city.timezone}"
    coord = city.coordinates
    puts "Latitude: #{coord.keys[0]}: #{coord[coord.keys[0]]}"
    puts "Longitude: #{coord.keys[1]}: #{coord[coord.keys[1]]}"
    puts "Population: #{city.population}"
    puts "Region: #{city.region}"
    puts "You can fly to:"
    dest = city.destination
    dest.each do |city_code, distance|
      puts "City Name: #{metro[city_code].name}, City Code: #{city_code}, Distance: #{distance}"
    end
    puts "#{@spliter}"
  else
    puts "We don't have this city"
    'noCity'
  end
end

#This function opens the browser and shows people the webpage of CSAIR
# @param [graph] my_graph The Graph obeject that needs to be read in
# @return [null]
def open_browser(my_graph)
  routes = Array.new
  metros = my_graph.metro
  metros.each do |cityCode, city|
    destination = city.destination
    destination.each do |destCity, distance|
      if !routes.include?("#{destCity}-#{cityCode}")
        routes.push("#{cityCode}-#{destCity}")
      end
    end
  end
  url = 'http://www.gcmap.com/map?P='
  routes.each do |flight|
    url = url + flight + ','
  end
  url = url[0...-1]
  system("open", url)
end

##
# This function lists all the cities we have in this system, in real time
# @param [Graph] my_graph : A graph objet
# @return [null] doesn't return anything
def list_city(my_graph)
  puts 'We fly to these cities: '
  my_graph.metro.each do |cityCode, city|
    puts "#{cityCode} : #{city.name}"
  end
end


##
#This function is the interface of editing a city. You can exit the function anytime.
# @param [Graph] my_graph, a Graph object
# @return [null] doesn't return anything, but will print out if somehitng happens.
def edit_city(my_graph)
  metro = my_graph.metro
  while true
    #you can only change once attribute of a city for one time
    puts 'Input the city code of the city you want to edit.'
    puts 'If you want to add the city, use ADD '
    input = gets
    words = input.split
    if (words.length == 0)
      next
    end

    command = words[0].upcase

    if command == 'ADD'
      words.shift
      my_graph.manual_add_city()
      next
    end

    if command=='EXIT'
      puts 'You are now in Main menu.'
      return
    end
    if metro.has_key?(command)
      get_city_info(command, my_graph)
      puts 'Please use the following structure to edit the information:(attribute_to_edit new_value).'
      puts 'If you want to remove this city, simply input Remove'
      input = gets
      words = input.split
      if (words.length == 0)
        next
      end
      attri = words[0].upcase
      #if removing a city, the program returns to its previous level
      if attri == 'REMOVE'
        puts 'City removed! return to main menu!'
        my_graph.delete_city(command)
        return
      end

      value = words[1]
      if value != nil
        my_graph.update_city_info(command, attri.upcase, value)
        puts 'Updated! you can keep editing or input exit and return to the previous menu.'
      end
    else
      puts 'We do not have this city yet. Please add this city first.'
    end
  end
end

#
# @param [graph] my_graph a graph objects.
# @return [null] doesn't return anything.
def edit_route(my_graph)
  puts 'Now you can edit the routes information'
  puts 'Please use the following structure to add: (add from_city_code dest_city_code distance)'
  puts 'Please use the following structure to delete: (delete from_city_code dest_city_code)'
  puts 'If it is delete, then distance can be ignored'
  puts 'Input Exit will bring you to the previous menu'
  while true
    input = gets
    words = input.split
    if (words.length == 0)
      next
    end
    command = words[0].upcase
    if command=='EXIT'
      puts 'You are now in Main menu.'
      return
    end
    if command == 'ADD'
      if my_graph.metro.has_key?(words[1].upcase) && my_graph.metro.has_key?(words[2].upcase)
        my_graph.add_route(words[1].upcase, words[2].upcase, words[3])
      else
        puts "City doesn't exit. Please make sure."
      end
    elsif command == 'DELETE'
      my_graph.remove_single_route(words[1], words[2])
    else
      puts 'Your input format is not correct.'
    end
  end
end

##
#This function saves the graph onto a file in data
# @param [Grpah] my_graph the graph object
def save_file(my_graph)
  my_graph.output_map
  puts 'We have successfully saved the city'
end

##
#This function loads a file from the dataset. The name is predetermined.
#It will overwrite the current my_graph
# @return [return the my_graph]
def load_file(my_graph)
  my_graph = Graph.new("../data/output_file.json")
  puts 'We have successfully loaded the city'
  my_graph
end

##
# This function will calculate the shortest path from A to B
# We should be sure that city 1 can go to city 2, or this will not output anything.
# @param [Graph] my_graph
# @param [Source City_code] city1
# @param [Source City_code] city2
# @return [true if there is a shortest path]
def calculate_shortest(my_graph, city1, city2)
  if !(my_graph.metro.has_key?(city1)&&my_graph.metro.has_key?(city2))
    puts "We don't have the city!"
    return
  end

  #Use my dijkastra
  previous, distance = my_graph.dijkstra(city1, city2)
  s = []
  u = city2
  while previous[u] != nil
    s.push(u)
    u = previous[u]
  end
  s.push(u)
  s = s.reverse
  check_routes(my_graph, s)
  puts 'The cities that we are going to pass by are'
  s.each do |city|
    puts "#{city}"
  end
  return s
end

##
#This fuction merges the file with the current graph.
#return true if it suceed
# @param [Stirng] file file path
# @param [Graph] my_graph
def merge_file(my_graph, file)
  my_graph.merge_file(file)
  puts 'Successfully Merged!'
  return true
end


##
# This checks if it is a valid route.
# @return [Boolean] true if the route is valid
# @param [graph] my_graph the graph
# @param [list] list the list of cities that to be checked
def check_routes(my_graph, list)
  if list.length < 2
    puts 'Not valid routes'
    return
  end
  total_distance = 0
  total_money = 0.0
  total_time = 0.0
  previous = list[0].upcase

  # Now check one by one
  for index in 1..list.length-1
    next_city =list[index].upcase
    if !my_graph.has_route(previous, next_city)
      puts 'Route is invalid.'
      return false
    end
    current_distance = my_graph.get_distance(previous, next_city)
    total_distance += current_distance
    current_rate = 0.4 - index*0.05
    if current_rate < 0
      current_rate = 0
    end
    total_money+=current_rate * current_distance
    total_time+=get_time_part1(current_distance)
    if index!=1
      total_time+=get_time_part2(previous, my_graph)
    end
    previous = next_city
  end

  puts "The total distance is #{total_distance} kilometer"
  puts "The total money is #{total_money} dollars"
  puts "The total time is #{total_time} hours"
  return total_distance, total_money, total_time
end

##
# This return the flying time
# @param [Int] distance between two cities
def get_time_part1(distance)
  if distance > 400
    time = (distance - 400) / 750 + 2* (400/750)**0.5
  else
    time = 2* (distance/750)**0.5
  end
  time
end

##
# Calculate the layover time. The layover will happen if stops > 3, or else people will not wait at all.
#
# @param [String] metro the code of the city
# @param [Graph] my_graph
# @return [int] the hours of time
def get_time_part2(metro, my_graph)
  time = 2.0 + 1.0/6.0 - (1.0/6.0)*my_graph.metro[metro].destination.length
  if time <0
    time = 0
  end
  time
end
