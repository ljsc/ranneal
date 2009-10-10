require 'test_helper'

require 'ranneal/examples/seating'

class SeatingTest < Test::Unit::TestCase
  context "a seating manager" do
    setup do
      data_file = File.join(RAnneal::BASEDIR, 'data', 'guests.txt')
      @manager = SeatingManager.new(data_file)
    end

    should "seat guests" do
      @manager.seat_guests
      assert_equal 15, @manager.guests.size
    end

    should "provide access to guest records" do
      @manager.seat_guests
      guest = @manager.guests[0]

      assert_match /\A\w+\z/,  guest.name
      assert_kind_of Integer, guest.age
      assert_match /\AB|G\z/,  guest.party
    end

    should "find guests on a certain edge" do
      stub(g1 = Object.new).seat { :s1 }
      stub(g2 = Object.new).seat { :s2 }
      stub(@manager).guests { [g1, g2] }
      
      guests = @manager.guests_on_edge([:s1, :s0])
      assert guests.include?(g1)
      assert !guests.include?(g2)
    end

    should "have pre defined edges" do
      assert @manager.edges.include?( [:T1S0, :T2S0] )
    end

    should "accept a solution" do
      assert_nothing_raised { @manager.accept }
    end

    should "encode a undirected graph" do
      assert_equal [:T1S0, :T2S0], @manager.canonical([:T2S0, :T1S0])
    end

    should "return the cost of the next solution" do
      @manager.seat_guests
      assert_kind_of Integer, @manager.next_solution
    end

    should "run until frozen" do
      assert !@manager.solution_acceptable?
    end
  end
end
