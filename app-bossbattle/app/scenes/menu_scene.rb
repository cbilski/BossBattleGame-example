class MenuScene
  attr_reader :id

  def initialize(id, gom)
    @id = id
    @gom = gom
    @pipeline = []
    @chime_played = false
    @font_name = "/fonts/Pixel Font Pack/Centurion Bold 8x16 Monospaced.ttf"

    @background_color = { r: 225, g: 115, b: 58 }
    @button_color = { r: 239, g: 163, b: 70 }

    @menu_items = [
      { index: 0, x: 640, y: 418, w: -1, h: -1, text: "FIGHT!", selected: true, selectable: true, outline: nil },
      { index: 1, x: 640, y: 320, w: -1, h: -1, text: "HOWTO", selected: false, selectable: true, outline: nil },
      { index: 2, x: 640, y: 226, w: -1, h: -1, text: "OPTIONS", selected: false, selectable: false, outline: nil },
      { index: 3, x: 640, y: 114, w: -1, h: -1, text: "QUIT", selected: false, selectable: true, outline: nil },
    ]

    @selected_index = 0
    @selected = @menu_items[@selected_index]

    @start_countdown = 0

    @alpha_fade_in_at = 0
    @alpha_fade_out_at = 0
    @alpha_duration = 50

    @last_input_at = 0
  end

  def scene_activate(args)
    @gom.app.scenes[:battle_scene_i] = BattleScene1.new(:battle_scene_i, @gom) unless args.nil?

    @alpha_fade_in_at = args.nil? ? 0 : args.tick_count
    @alpha_fade_out_at = 0
    @alpha_duration = 50

    @chime_played = false
    @selected_index = 0
    @selected = @menu_items[@selected_index]
    @start_countdown = 0
    @transition_to = :no_scene

    @menu_items = [
      { index: 0, x: 640, y: 418, w: -1, h: -1, text: "FIGHT!", selected: true, selectable: true, outline: nil },
      { index: 1, x: 640, y: 320, w: -1, h: -1, text: "HOWTO", selected: false, selectable: true, outline: nil },
      { index: 2, x: 640, y: 226, w: -1, h: -1, text: "OPTIONS", selected: false, selectable: true, outline: nil },
      { index: 3, x: 640, y: 114, w: -1, h: -1, text: "QUIT", selected: false, selectable: true, outline: nil },
    ]

    if $gtk.platform.start_with?("Emscript")
      @menu_items[3].selectable = false
    end

    if args != nil && args.sfx.looping_now? != :music_menu_1
      args.sfx.loop(:music_menu_1)
    end
  end

  def scene_deactivate(args)
    if args != nil && @transition_to != :howto && @transition_to != :options
      args.sfx.stop!(:music_menu_1)
    end
  end

  def render_background(args, alpha)
    # background color
    @background_color = { r: 68, g: 66, b: 65 }
    @background_color = { r: 113, g: 105, b: 89 }
    @background_color = { r: 0, g: 0, b: 0 }
    @pipeline << [0, 0, 1280, 720, @background_color[:r], @background_color[:g], @background_color[:b]].solid # background color
    #@pipeline << [0, 0, 1280, 720, 225, 115, 58].solid # background color

    # background image
    zoom = 2.0
    @pipeline << {
      x: -720 * zoom, y: -768 * zoom, w: 2048 * zoom, h: 1152 * zoom, a: alpha,
      path: "/sprites/free-game-assets.itch.io-battle-arena-backgrounds-pack/layers/back_decor-pixelmash.png", #2048x1152
    }.sprite!

    # torch 1
    @torch1_frame ||= 0
    @torch1_frame = (@torch1_frame + 1) % 4 if args.tick_count % 8 == 0
    @pipeline << {
      x: 174, y: 24, w: 176, h: 384, a: alpha,
      tile_x: 0 * 16, tile_y: @torch1_frame * 20, tile_w: 16, tile_h: 20,
      path: "/sprites/finalbossblues.itch.io-fantasyrpgtilesetpack/torch.png",
    }.sprite!

    # torch 2
    @torch2_frame ||= 0
    @torch2_frame = (@torch2_frame + 1) % 4 if args.tick_count % 8 == 0
    @pipeline << {
      x: 844, y: 24, w: 176, h: 384, a: alpha + 64,
      tile_x: 0 * 16, tile_y: @torch2_frame * 20, tile_w: 16, tile_h: 20,
      path: "/sprites/finalbossblues.itch.io-fantasyrpgtilesetpack/torch.png",
    }.sprite!
  end

  def render_menu(args, alpha)

    # BOSS BATTLE Shadow
    # [[1, 1], [1, -1], [-1, 1], [-1, -1]].each do |off|
    #   zoom = 2
    #   xoff = off[0] * zoom
    #   yoff = off[1] * zoom
    #
    #   @pipeline << {
    #     x: (1280 / 2) + xoff,
    #     y: (720 - 16) + yoff,
    #     text: "BOSS BATTLE",
    #     size_enum: 60,
    #     alignment_enum: 1,
    #     r: 0,
    #     g: 0,
    #     b: 0,
    #     a: 255,
    #     font: @font_name,
    #   }.label!
    # end

    # BOSS BATTLE
    @pipeline << {
      x: 1280 / 2,
      y: 720 + 16,
      text: "DECAF DUNGEON",
      size_enum: 60,
      alignment_enum: 1,
      #r: 208, g: 25, b: 70,
      r: 255, g: 0, b: 57,
      a: alpha,
      font: @font_name,
    }.label!

    @pipeline << {
      x: 1280 / 2,
      y: 592 + 20,
      text: "A Boss Battle",
      size_enum: 28,
      alignment_enum: 1,
      r: 0, g: 216, b: 168,
      a: alpha,
      font: @font_name,
    }.label!

    @menu_items.each do |item|
      @button_color = { r: 130, g: 113, b: 82 }
      text_color = { r: 224, g: 224, b: 224 }
      text_color = { r: 176, g: 176, b: 176 } if item[:selectable] == false

      y_offset = 0

      label = {
        x: item[:x],
        y: item[:y] - y_offset,
        text: item[:text],
        size_enum: 32,
        alignment_enum: 1,
        **text_color,
        a: alpha,
        font: @font_name,
      }.label!

      box = $gtk.calcstringbox(label[:text], label[:size_enum], label[:font]) # box has [w, h].
      box_width = box[0] + 64
      box_height = box[1] - 4

      outline = {
        x: item[:x] - (box_width / 2) - 12,
        y: item[:y] - box_height - 12 - y_offset,
        w: box_width + 16,
        h: box_height + 16,
        r: 0, g: 0, b: 0,
        a: alpha
      }.solid!

      item[:outline] = outline if item[:outline] == nil

      fill = {
        x: item[:x] - (box_width / 2) - 4,
        y: item[:y] - box_height - 4 - y_offset,
        w: box_width,
        h: box_height,
        **@button_color,
        a: alpha
      }.solid!

      if item[:selected] == true
        @pipeline << outline
        @pipeline << fill
      end

      @pipeline << label
    end
  end

  def render_version(args)
    font_color = { r: 0, g: 0, b: 0 }
    rect = args.layout.rect(row: 12, col: 23, w: 1, h: 1, dx: 0, dy: 0) # outer border

    @version ||= $wizards.itch.get_metadata[:version]
    @devtitle ||= $wizards.itch.get_metadata[:dev_title]

    @pipeline << {
      x1: rect.x + rect.w, x: 1280, y: rect.y + 4,
      text: "v#{@version.to_s} #{@devtitle}©2022", size_enum: 0,
      alignment_enum: 2, vertical_alignment_enum: 0,
      font: @font_name,
      **font_color,
    }.label!
  end

  def render_pipeline(args)
    args.outputs.primitives << @pipeline # args.outputs.sprites.concat args.state.lots_of_enemies
    @pipeline.clear
  end

  def tick(args)
    # process enter+alt keys
    menu_item_pressed = false

    if args.inputs.mouse.moved
      hover_items = @menu_items.select { |i| i[:outline] != nil && args.inputs.mouse.inside_rect?(i[:outline]) }
      if hover_items.length > 0
        hovered = hover_items[0]
        if hovered[:selectable] == true && hovered[:selected] == false

          @menu_items.select { |i| i[:selected] == true }.each do |menu_item|
            menu_item[:selected] = false
          end

          hovered[:selected] = true
          args.sfx.play :menu_item_changed
          @selected = hovered
          @selected_index = hovered[:index]
        end
      end
    end

    clicked_at = args.inputs.mouse.click
    if @selected != nil && clicked_at != nil && clicked_at.inside_rect?(@selected[:outline])
      menu_item_pressed = true
    end

    if args.inputs.keyboard.key_up.enter || args.inputs.keyboard.key_up.space || args.inputs.controller_one.key_down.a || args.inputs.controller_one.key_down.start || args.inputs.controller_one.key_down.r2 || args.inputs.controller_one.key_down.l2
      menu_item_pressed = true
      args.inputs.keyboard.key_down.clear
      args.inputs.keyboard.key_up.clear
      args.inputs.controller_one.key_down.clear
      args.inputs.controller_one.key_up.clear
    elsif (@last_input_at + 10 < args.tick_count) && ((args.inputs.down && args.tick_count.zmod?(15)) || args.inputs.keyboard.key_up.s || args.inputs.keyboard.key_up.down || args.inputs.controller_one.key_down.directional_down)
      @last_input_at = args.tick_count
      loop do
        # find next selectable item in list
        @menu_items.select { |i| i[:selected] == true }.each do |menu_item|
          menu_item[:selected] = false
        end
        @selected_index = (@selected_index + 1) % @menu_items.length
        @selected = @menu_items[@selected_index]
        @selected[:selected] = true
        break if @selected[:selectable] == true
      end
      args.sfx.play :menu_item_changed
    elsif (@last_input_at + 10 < args.tick_count) && (args.inputs.up && args.tick_count.zmod?(15)) || args.inputs.keyboard.key_up.w || args.inputs.keyboard.key_up.up || args.inputs.controller_one.key_down.directional_up
      @last_input_at = args.tick_count
      loop do
        # find next selectable item in list
        @menu_items.select { |i| i[:selected] == true }.each do |menu_item|
          menu_item[:selected] = false
        end
        @selected_index = (@selected_index - 1) % @menu_items.length
        @selected = @menu_items[@selected_index]
        @selected[:selected] = true
        break if @selected[:selectable] == true
      end
      args.sfx.play :menu_item_changed
    end

    # play sfx
    unless @chime_played
      @chime_played = true
      #args.sfx.play(:menu_transition)
    end

    alpha = 255
    if (@alpha_fade_in_at + @alpha_duration) > args.tick_count
      alpha = @alpha_fade_in_at.ease(@alpha_duration, [:flip, :quad, :flip]) # smoothest start?
      alpha *= 255
    elsif (@alpha_fade_out_at + @alpha_duration) > args.tick_count
      alpha = @alpha_fade_out_at.ease(@alpha_duration, [:flip, :quad, :flip]) # smoothest start?
      alpha = 255 - (255 * alpha)
    end

    render_background(args, alpha)
    render_menu(args, alpha)
    render_version(args)
    render_pipeline(args)

    # transition to game if animation has run and enter pressed
    if @start_countdown > 0
      @start_countdown -= 1
      if @start_countdown < 1
        @chime_played = false
        @start_countdown = 0
        @transition_to = :battle_scene_i
        @gom.app.transition_to(@transition_to, args)
      end
    elsif menu_item_pressed && @selected_index == 0
      args.sfx.play(:game_enter)
      @alpha_fade_out_at = args.tick_count
      @start_countdown = 40
    elsif menu_item_pressed && @selected_index == 1
      args.sfx.play(:game_enter)
      @transition_to = :howto
      @gom.app.transition_to(@transition_to, args)
    elsif menu_item_pressed && @selected_index == 2
      args.sfx.play(:game_enter)
      @transition_to = :options
      @gom.app.transition_to(@transition_to, args)
    elsif menu_item_pressed && @selected_index == 3
      $gtk.exit
    end
  end
end
