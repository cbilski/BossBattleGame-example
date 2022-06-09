module GTK
  # monkey-patch Args to add game-specific attributes
  class Args
    # sfx manager
    attr_accessor :sfx
  end
end
