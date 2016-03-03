require 'json'
require '../src/metro'

#This graph class is the dictionary of our CSAIR system. it keeps all the information about the graph
class Graph
  #Make all the attributes visible to all other classes.
  attr_accessor :longest_dist, :shortest_dist, :avg_dist, :biggest_pop, :biggest_city, :avg_dist, :avg_pop

  ##
  #Initialize the graph. sets all the parameters.
  def initialize(filename)
    @data_source
    @metros = Hash.new
    if !File.file?(filename)
      puts "Files does not exit. check your path"
      exit
    end
    file = File.read(filename)
    dataset = JSON.parse(file)
    initialize_data_source(dataset['data sources'])
    initialize_metros(dataset['metros'])
    if (dataset.has_key?('single_route'))
      initialize_routes(dataset['routes'], 1)
    else
      initialize_routes(dataset['routes'], 0)
    end
  end

  ##
  #Initialize the data source
  def initialize_data_source(data)
    @data_source = data
  end

  ##
  #Initialize the metros, read data from files.
  # @param [Json data] data the JSON data that is imported
  def initialize_metros(data)
    data.each do |line|
      code = line['code']
      name = line['name']
      country = line['country']
      continent = line['continent']
      timezone = line['timezone']
      coordinates = line['coordinates']
      population = line['population']
      region = line['region']
      metro_node = Metro.new(code, name, country, continent, timezone, coordinates, population, region)

      #We refuse to overwrite a certain part of code
      if @metros.has_key?(code)
        puts 'We already have this city'
      else
        @metros[code] = metro_node
      end
    end
  end

  ##This function adds a city
  # @return [list] an array of attributes to add
  def manual_add_city()
    puts 'The code?'
    code = gets
    if @metros.has_key?(code)
      puts 'We already have this city. Goodbye'
      return
    end
    puts 'Name?'
    name = gets.split[0]
    puts 'Country?'
    country = gets.split[0]
    puts 'continent?'
    continent = gets.split[0]
    puts 'timezone?'
    timezone = gets.to_i
    puts 'coordinates?'
    coordinates = gets
    puts 'population?'
    population = gets.to_i
    if population <0
      puts 'You must be kidding me. Good bye'
      return false
    end
    puts 'region?'
    region = gets
    metro_node = Metro.new(code, name, country, continent, timezone, coordinates, population, region)
    #We refuse to overwrite a certain part of code
    @metros[code] = metro_node
    puts 'Done! now return'
  end

  ##
  #Read data routes from files. The routes information is also added into the metros.
  # @param [JSON data] data
  def initialize_routes(data, single)
    data.each do |line|
      @metros[line['ports'][0]].add_distination(line['ports'][1], line['distance'])
      if single == 0
        @metros[line['ports'][1]].add_distination(line['ports'][0], line['distance'])
      end
    end
  end

  #the getters
  def metro
    return @metros
  end

  def route
    return @routes
  end

  ##
  # This function merges the current graph with a new Json file.
  # @param [String] filename filename is a path
  # @return [true] if succeed
  def merge_file(filename)
    if !File.file?(filename)
      puts "Files does not exit. check your path"
      return false
    end
    file = File.read(filename)
    dataset = JSON.parse(file)
    @data_source = dataset['data sources']
    initialize_metros(dataset['metros'])
    if (dataset.has_key?('single_route'))
      initialize_routes(dataset['routes'], 1)
    else
      initialize_routes(dataset['routes'], 0)
    end
    return true
  end

  def clear_data()
    @data_source = nil
    @metros = nil
    @routes = nil
  end

  ##Take two cities' code in, and return the distance between two cities.
  # It will return -1 if there is no flight from city1 to city2.
  # @param [String] city_code1
  # @param [String] city_code2
  # @return [int] The distance between two cities or -1 if not acceessible.
  def get_distance(city_code1, city_code2)
    if @metros.has_key?(city_code1)
      dest = @metros[city_code1].destination
      if dest.has_key?(city_code2)
        return dest[city_code2]
      end
    end
    return -1
  end

  ##This functions deletes a city from this system.
  # @param [String] city_code
  # @return [null]
  def delete_city(city_code)
    if @metros.has_key?(city_code)
      dest = @metros[city_code].destination
      #Delete all the flight from other cities to this city
      dest.each do |code, distance|
        @metros[code].destination.delete(city_code)
      end
      #delete this line
      @metros.delete(city_code)
    end
  end

  #this function updates the information of a city.
  #The city code has already been verified that it exits in this hash table.
  # @param [String] city_code The code of the city we are editing
  # @param [String] attribute The attributes that we are going to edit
  # @param [multiple] new_value The new Values we are goint to give to the attributes.
  def update_city_info(city_code, attribute, new_value)
    case attribute
      when 'CODE'
        if attribute!=city_code
          @metros[city_code].code = new_value
          @metros[new_value] = @metros[city_code]
          @metros.delete(city_code)
        end
      when 'NAME'
        @metros[city_code].name = new_value
      when 'CONTINENT'
        @metros[city_code].continent = new_value
      when 'COORDINATE'
        @metros[city_code].coordinates = new_value
      when 'POPULATION'
        new_value = new_value.to_i
        if new_value < 0
          puts 'Population cannot be negative.'
          return
        end
        @metros[city_code].population = new_value
      when 'REGION'
        @metros[city_code].region = new_value
      when 'COUNTRY'
        @metros[city_code].country = new_value
      when 'TIMEZONE'
        @metros[city_code].timezone = new_value
      else
        puts 'there is no such attribute. Note that it is case sensitive.'
    end
  end

  ##
  # This is the Dijkstra algorith, used to find the closed cities
  # All distances are going to be positive. So there will be no loop.
  # @param [String] city1: the start city's citycode
  # @param [String] city2; the end city's citycode
  # @return [List] previous is the list of all the previous' nodes
  def dijkstra(city1, city2)
    #if city's distance is the same
    if city1==city2
      return 0
    end
    #set up dijkstra

    active = []
    distance = Hash.new
    previous = Hash.new

    @metros.each do |city_code, metro|
      distance[city_code] = Float::INFINITY
      previous[city_code] = nil
      active.push(city_code)
    end

    distance[city1] = 0
    until active.empty?
      #remove the min from dis
      min_city = active[0]
      min_dist = distance[min_city]
      active.each do |city|
        if distance[city]<min_dist
          min_dist = distance[min_city]
          min_city = city
        end
      end
      active.delete(min_city)
      this_city = min_city

      #for all the neighbor
      dest = @metros[this_city].destination
      dest.each do |next_city, dist|
        current_distance = get_distance(this_city, next_city)
        total_distance = distance[this_city]+current_distance
        if total_distance < distance[next_city]
          distance[next_city] = total_distance
          previous[next_city] = this_city
        end
      end
    end
    #return a list of prebious cities
    return previous, distance

  end

  ## Remove the route from both sides
  # @param [String] city_code1
  # @param [String] city_code2
  def remove_double_route(city_code1, city_code2)
    if @metros.has_key?(city_code1) && @metros.has_key?(city_code2)
      @metros[city_code1].destination.delete(city_code2)
      @metros[city_code2].destination.delete(city_code1)
    end
  end

  ##Remove the route from single side, from city1 to city2
  # @param [String] city_code1
  # @param [String] city_code2
  def remove_single_route(city_code1, city_code2)
    if @metros.has_key?(city_code1) && @metros.has_key?(city_code2)
      @metros[city_code1].destination.delete(city_code2)
    end
  end

  ##Add a route to the existing structure. Cannot add negative distance
  #The route is one side.
  # @param [String] city_code1
  # @param [String] city_code2
  # @param [int] distance The distance between two distance
  def add_route(city_code1, city_code2, distance)
    if distance <= 0
      puts 'The distance must be positive'
      return
    end
    if @metros.has_key?(city_code1) && @metros.has_key?(city_code2)
      @metros[city_code1].destination[city_code2] = distance
    end
  end

  ## check if there is a route between two cities. Firstly, there has to be two cities
  # @param [String] city_code1 from city
  # @param [String] city_code2 to city
  def has_route(city_code1, city_code2)
    if @metros.has_key?(city_code1)&&@metros.has_key?(city_code2)
      if @metros[city_code1].destination.has_key?(city_code2)
        return true
      end
    end
    false
  end


  ##
  # This function output the files to the disk. It will use the data from this graph
  #
  # @return [Boolean] true if succeed.
  def output_map
    map_towrite = Hash.new
    metro_towrite = []
    route_towrite = []

    #encode cuty
    @metros.each do |city_code, city|
      metro_towrite.push(city.output_json)
    end

    #encode route
    @metros.each do |city_code, city|
      dest = city.destination
      dest.each do |dest_city_code, distance|
        if dest_city_code == city_code
          puts "impossible #{dest_city_code}"
        end
        ports = []
        ports.push(city_code)
        ports.push(dest_city_code)
        one_route = Hash.new
        one_route['ports']=ports
        one_route['distance']=distance
        route_towrite.push(one_route)
      end
    end
    map_towrite['data source'] = @data_source
    map_towrite['metros']= metro_towrite
    map_towrite['routes']= route_towrite
    map_towrite['single_route'] = 1
    IO.write("../data/output_file.json", JSON.pretty_generate(map_towrite))
    #write to files
    return map_towrite.to_json
  end

  ##this function will print all the data that a person needs.
  #The data we are going to use is from the same class. So no params are going to be used.
  def analysis_data()
    first_destination = metro[metro.keys[0]].destination
    longest_distance = first_destination[first_destination.keys[0]]
    shortest_distance = first_destination[first_destination.keys[0]]
    avg_distance = 0
    total_number = 0
    longest_city_pair = "#{metro.keys[0]}-#{first_destination.keys[0]}"
    shortest_city_pair = "#{metro.keys[0]}-#{first_destination.keys[0]}"

    biggest_population = metro[metro.keys[0]].population
    smallest_population = metro[metro.keys[0]].population
    avg_population = 0
    biggest_city = metro.keys[0]
    smallest_city = metro.keys[0]

    continent = []
    hub_city = metro.keys[0]
    hub_size = first_destination.length

    #start the iteration for distance.
    @metros.each do |city_code, city|
      dest = city.destination
      dest.each do |dest, distance|
        if distance > longest_distance
          longest_distance = distance
          longest_city_pair = "#{city.code}-#{dest}"
        end
        if distance < shortest_distance
          shortest_distance = distance
          shortest_city_pair = "#{city.code}-#{dest}"
        end
        #calculate average
        avg_distance += distance
        total_number += 1
      end
    end

    #Search all values needed about continent, population and length.
    city_num = 0
    @metros.each do |city_code, city|
      if !continent.include?(city.continent)
        continent.push(city.continent)
      end

      if city.destination.length > hub_size
        hub_city = city_code
        hub_size = city.destination.length
      end
      if city.population > biggest_population
        biggest_population = city.population
        biggest_city = city_code
      end
      if city.population < smallest_population
        smallest_population = city.population
        smallest_city = city_code
      end
      avg_population += city.population
      city_num += 1
    end

    @longest_dist = longest_distance
    @shortest_dist = shortest_distance
    @avg_dist = avg_distance
    @biggest_pop = biggest_population
    @biggest_city = biggest_city
    @avg_pop = avg_population/city_num
    @hub_ct = hub_city
    #Here is the printing.
    puts "------------------CSAIR information---------------------"
    puts "The longest distance in CSAIR is #{longest_distance}, #{longest_city_pair}"
    puts "The shortest distance in CSAIR is #{shortest_distance}, #{shortest_city_pair}"
    puts "The average distance is #{avg_distance/total_number}"
    puts "The biggest city is #{biggest_city}, population #{biggest_population}"
    puts "The smallest city is #{smallest_city}, population #{smallest_population}"
    puts "The average population is #{avg_population/city_num}"
    puts "We fly to these continents and cities:"
    continent.each do |single_continent|
      print "#{single_continent}: "
      @metros.each do |city_code, attri|
        if attri.continent == single_continent
          print "#{city_code} "
        end
      end
      print "\n"
    end
    puts "Our hub city is #{hub_city}, it has #{hub_size} lines"
    puts "------------------CSAIR information---------------------"
    puts ""
  end
end


