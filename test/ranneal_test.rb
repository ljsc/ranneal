require 'test_helper'

class TestSolutionManager
  attr_accessor :solutions_asked_for, :accepted

  def initialize(*solutions)
    @solutions_asked_for = 0
    @solutions = solutions
    @rounds    = solutions.size
    @accepted  = []
  end

  def next_solution
    self.solutions_asked_for += 1
    @current = @solutions.shift
  end

  def solution_acceptable?
    solutions_asked_for >= @rounds
  end

  def accept
    @accepted << @current
  end
end

class RannealTest < Test::Unit::TestCase
  context "An example annealer" do
    setup do
      @manager      = TestSolutionManager.new(5,-5,3)
      @initial_temp = 10
      @annealer     = RAnneal.new(@manager,
                                  :initial_temp => @initial_temp,
                                  :rand => lambda { 0.5 })
    end

    should "use the manager to find solutions" do
      @annealer.run
      assert_greater_than 0, @manager.solutions_asked_for
    end

    should "start at the initial temperature" do
      assert_equal @initial_temp, @annealer.temperature
    end

    should "reduce the temperature of the system" do
      @annealer.run
      assert_less_than @initial_temp, @annealer.temperature
    end

    should "calculate probability of a move" do
      assert_in_delta 0.60, @annealer.P(5), 0.01
    end

    should "accept a bad choice at high temperatures" do
      @annealer.run
      assert @manager.accepted.any?{|x| x == 5}
    end
  end

  context "An annealer" do
    setup { @annealer = RAnneal.new(TestSolutionManager.new, :p_func => lambda { 0 })}
    should "be ablet to simulate the greedy method" do
      [-15,-5,-1].each {|x| assert_equal 1 , @annealer.P(x) }
      [1,5,15].each {|x| assert_equal 0 , @annealer.P(x) }
    end
  end
end
