class BossBattleGameApp
  attr_reader :scene
  attr_reader :scenes
  attr_reader :gom
  attr_reader :flags

  def initialize
    @gom = GameObjectModel.new(self)

    # setup scenes
    @scenes = {}
    @scenes[:splash] = SplashScene.new(:splash, @gom)
    @scenes[:menu] = MenuScene.new(:menu, @gom)
    @scenes[:howto] = HowtoScene.new(:howto, @gom)
    @scenes[:options] = OptionsScene.new(:options, @gom)
    @scenes[:battle_scene_i] = BattleScene1.new(:battle_scene_i, @gom)

    # process command line
    if $flags[:no_menu] == true
      transition_to(:battle_scene_i)
    elsif $flags[:no_splash] == true
      transition_to(:menu)
    else
      transition_to(:splash)
    end

    # result = $gtk.exec("cmd /c \"dir *.png /b app-bossbattle\\sprites \"")
    # log result

    $gtk.set_window_fullscreen(true) if $flags[:fullscreen]
  end

  def tick(args)
    @scene.tick(args)
  end

  def transition_to(scene_id, args = nil)
    @scene.scene_deactivate args if @scene != nil
    @scene = @scenes[scene_id]
    @scene.scene_activate args if @scene != nil
  end
end

module GTK
  class Runtime
    module Framerate
      def xx_check_framerate
        # suppress framerate message
      end
    end
  end
end

module GTK
  class Runtime
    module Framerate
      def xx_framerate_below_threshold?
        false
      end
    end
  end
end
