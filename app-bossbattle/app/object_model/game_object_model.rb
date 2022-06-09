class GameObjectModel
  attr_reader :app

  # this should store game/world level data: not level specific data
  attr_reader :hero # LENS
  attr_reader :boss # SHADES

  def initialize(app)
    @app = app
  end

  def tick(args)
    # world background processing
  end
end
