require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'rr'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'ranneal'

class Test::Unit::TestCase
  include RR::Adapters::TestUnit

  def assert_greater_than(limit, actual, message = nil)
    message = build_message(message, "expected <?> to be greater than <?>.", actual, limit)
    assert_block message do
      actual > limit
    end
  end

  def assert_less_than(limit, actual, message = nil)
    message = build_message(message, "expected <?> to be less than <?>.", actual, limit)
    assert_block message do
      actual < limit
    end
  end
end
