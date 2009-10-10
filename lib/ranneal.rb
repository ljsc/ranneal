
class RAnneal
  BASEDIR = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  attr_reader :temperature, :step_number
  attr_accessor :debug

  DEFAULT_P_FUNCTION = lambda {|d,t| Math.exp(-d/t)}

  def initialize(solution_manager, opts={})
    @manager = solution_manager
    @temperature = opts.delete(:initial_temp) || 20
    @p_func      = opts.delete(:p_func)       || DEFAULT_P_FUNCTION
    @rand        = opts.delete(:rand)         || Kernel.method(:rand)
    @step_number = 0
    @debug       = false
  end

  def run(steps=nil)
    n_times(steps) do |step|
      break if completed? or @temperature <= 1.0e-4
      candidate = @manager.next_solution
      chance    = @rand.call()
      probability = P(candidate)

      printf("Step(%d): T=%0.2f, Prob=%0.2f, Rand=%0.2f, Cost=%0.2f, Delta=%0.2f %s\n",
             step, @temperature, probability, chance, @manager.cost(@manager.solution),
             @manager.delta, chance <= probability ? '*' : '') if @debug
      @manager.accept if chance <= probability
      @temperature = @temperature * 0.999
    end
  end

  def completed?
    @manager.solution_acceptable?
  end

  def P(delta)
    delta = delta.to_f
    delta < 0.0 ? 1.0 : @p_func.call(delta, @temperature)
  end

  protected

  def n_times(steps=nil, &blk)
    raise "n_times needs a block" unless block_given?
    if steps
      steps.times {|i| blk.call(i)}
    else
      loop { @step_number += 1; blk.call(@step_number) }
    end
  end
end
