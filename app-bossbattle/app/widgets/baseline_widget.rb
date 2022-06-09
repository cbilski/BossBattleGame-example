class BaselineWidget
  def initialize(args)

  end

  def finished?
    # return true if this widget is done doing things (and parent should clean up)
    false
  end

  def handle_input(args)
    # input logic goes here
  end

  def modal?
    # return true if this should pause game
    true
  end

  def render(args, pipeline)
    # drawing code goes here
  end

  def track(args)
    # update logic goes here
  end
end