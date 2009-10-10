require 'ranneal'
require 'enumerator'
require 'set'

class SeatingManager
  Guest = Struct.new(:name, :age, :party, :seat)

  attr_writer :guests
  attr_reader :solution

  def initialize(datafile)
    @data_file = datafile
  end
 
  def accept
    self.guests = @candidate
  end

  def adjacent_edges(e)
    edges = Set.new
    g1, g2 = guests_on_edge(e)
    es1 = neighbors[g1.seat].collect {|n| canonical([g1.seat, n])}
    es2 = neighbors[g2.seat].collect {|n| canonical([g2.seat, n])}
    edges.merge(es1).merge(es2).delete(e)
  end

  def canonical(e)
    e.map{|e| [e.to_s, e]}.sort.map{|e| e[1]}
  end

  def cost(*args)
    edges.inject(0) do |i,e|
      g1, g2 = guests_on_edge(e)
      i + (g1.age - g2.age).abs + (g1.party != g2.party ? 15 : 0)
    end
  end

  def deep_copy
    guests.collect {|g| g.dup }
  end

  def delta
    @potential - @current_cost
  end

  def edges
    edges = []

    neighbors.each_key do |node|
      neighbors[node].each do |neighbor|
        if node.to_s < neighbor.to_s
          edges << [node, neighbor]
        end
      end
    end

    edges
  end

  def guests
    @guests ||=
      begin
        File.readlines(@data_file).collect do |line|
          name, age, party, seat = *line.strip.split(',')
          Guest.new(name, age.to_i, party, seat)
        end
      end
  end

  def guests_on_edge(e)
    guests.select {|g| e.include? g.seat}
  end

  def neighbors
    { :T1S0 => [:T1S1, :T1S4, :T2S0, :T3S0],
      :T1S1 => [:T1S2, :T1S0], :T1S2 => [:T1S3, :T1S1], :T1S3 => [:T1S4, :T1S2], :T1S4 => [:T1S0, :T1S3],
  
      :T2S0 => [:T2S1, :T2S4, :T1S0, :T3S0],
      :T2S1 => [:T2S2, :T2S0], :T2S2 => [:T2S3, :T2S1], :T2S3 => [:T2S4, :T2S2], :T2S4 => [:T2S0, :T2S3],
  
      :T3S0 => [:T3S1, :T3S4, :T1S0, :T2S0],
      :T3S1 => [:T3S2, :T3S0], :T3S2 => [:T3S3, :T3S1], :T3S3 => [:T3S4, :T3S2], :T3S4 => [:T3S0, :T3S3]
    }
  end

  def next_solution
    @solution = deep_copy
    e = edges[rand(edges.size)]

    @current_cost = cost
    swap_guests(e)
    @potential = cost

    @candidate = deep_copy
    self.guests = @solution
    @potential - @current_cost
  end

  def seat_guests
    available_seats = neighbors.keys.sort_by{rand}

    guests.each do |guest|
      guest.seat = available_seats.shift
    end
  end

  def solution_acceptable?
    false
  end

  def swap_guests(e)
    g1, g2 = guests_on_edge(e)
    saved_seat = g1.seat
    g1.seat = g2.seat
    g2.seat = saved_seat
  end

  def chart_to_tex
    require 'erb'
    template = File.join(::RAnneal::BASEDIR, 'data', 'figure.tex.erb')
    erb = ERB.new(File.read(template))
    guests = self.guests

    data = Object.new
    meta(data).module_eval do
      guests.each do |g|
        define_method(g.seat.to_s.downcase) { g }
      end
      public :binding
    end
    
    erb.result(data.binding)
  end

  def meta(foo)
    class << foo; self end
  end
end

