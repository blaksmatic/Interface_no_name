#This class defines each metropolitan. It has all the variables.

class Metro
  attr_accessor :code, :name, :continent, :timezone, :coordinates, :population, :destination, :region, :country
  #The destination is not required for initialization.
  def initialize(code, name, country, continent, timezone, coordinates, population, region)
    @code = code
    @name = name
    @country = country
    @continent = continent
    @timezone = timezone
    @coordinates = coordinates
    @population = population
    @region = region
    @destination = Hash.new
  end

  #The destination is a hashtable, input the city, output the distance.
  # @param [String] destinations The citycode of the destination city
  # @param [Int] distance The distance between two cities.
  def add_distination(destinations, distance)
    @destination[destinations] = distance
  end

  def output_json()
    output = Hash.new
    output['code']=@code
    output['name']=@name
    output['country']=@country
    output['continent']=@continent
    output['timezone']=@timezone
    output['coordinates'] = @coordinates
    output['population']=@population
    output['region']=@region
    output
  end
end
