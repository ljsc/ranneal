require 'ranneal'

# A silly example of anealing

class FooManager
  attr_reader :solution

  def initialize
    @solution = (1..10).sort_by{ rand() }
  end

  def next_solution
    pos  = rand(9)
    pos2 = pos+1
    @candidate = @solution.dup
    temp = @candidate[pos]
    @candidate[pos] = @candidate[pos2]
    @candidate[pos2] = temp

    delta
  end

  def accept
    @solution = @candidate
  end

  def solution_acceptable?
    cost(@solution) <= 20
  end

  def cost(configuration)
    cost = 0

    0.upto(9) do |j|
      n = configuration[j]
      if n % 2 == 0
        cost += j
      else
        cost += (9-j)
      end

      cost += 5 if n == 9 && j == 5
    end

    cost
  end

  def delta
    cost(@candidate) - cost(@solution)
  end
end

if __FILE__ == $0
  manager = FooManager.new
  annealer = RAnneal.new(manager, :initial_temp => 10)
  annealer.debug = true
  annealer.run#(100)

  p manager.solution
end
