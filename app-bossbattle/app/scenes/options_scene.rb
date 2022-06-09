class OptionsScene
  attr_reader :id

  def initialize(id, gom)
    @id = id
    @gom = gom
    @pipeline = []
    @font_name = "/fonts/Pixel Font Pack/Centurion Bold 8x16 Monospaced.ttf"
    @alpha_fade_in_at = 0
    @alpha_duration = 50
    @buttons = []

    reset
  end

  def scene_activate(args)
    if args != nil
      @alpha_fade_in_at = args.tick_count
    end
  end

  def scene_deactivate(args)
    if args != nil

    end
  end

  def reset
    @back_color_values = { r: 0, g: 0, b: 0 }
    @commands = {
      :sfx_up => { selected: false },
      :sfx_down => { selected: false },
      :music_up => { selected: false },
      :music_down => { selected: false },
    }
  end

  def render_background(args)
    # background color
    @background_color ||= { r: 0, g: 0, b: 0 }
    @pipeline << [0, 0, 1280, 720, @background_color[:r], @background_color[:g], @background_color[:b]].solid # background color

    alpha = @alpha_fade_in_at.ease(@alpha_duration, [:flip, :quad, :flip]) # smoothest start?
    alpha *= 255

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

  def render_label_button(args, text, text_size, font_name, x, y, id)
    color_not_selected = {r: 0, g: 0, b: 0}
    color_selected = {r: 130, g: 113, b: 82}

    button_state = @commands[id]
    color = button_state.selected ?  color_selected : color_not_selected
    outline_color = button_state.selected ?  0 : 255

    text_box = args.gtk.calcstringbox(text, text_size, font_name)
    text_box[0] += 0
    text_box[1] += 0
    button = { x: x - 8, y: y - text_box[1] + text_size.half, w: text_box[0], h: text_box[1].half - 8, **color, id: id }.solid!
    @pipeline << { x: button.x - 4, y: button.y - 4, w: button.w + 8, h: button.h + 8, r: outline_color, g: outline_color, b: outline_color }.solid!
    @pipeline << button
    button
  end

  def render_pipeline(args)
    args.outputs.primitives << @pipeline
    @pipeline.clear
  end

  def tick(args)
    if args.inputs.keyboard.key_up.escape || args.inputs.controller_one.key_up.b
      reset
      args.sfx.play :menu_item_changed
      @gom.app.transition_to(:menu, args)
      return
    end

    # black background
    @pipeline << [0, 0, 1280, 720, @back_color_values[:r], @back_color_values[:g], @back_color_values[:b]].solid

    # normal background
    render_background(args)

    red = { r: 255, g: 0, b: 57 }
    white = { r: 255, g: 255, b: 255 }
    bluish = { r: 0, g: 216, b: 168 }

    sfx_mast = (args.sfx.sfx_mast * 10).to_i
    music_mast = (args.sfx.music_mast * 10).to_i

    # Text
    @pipeline << { x: 1280.half, y: 720 - 16, text: "OPTIONS", size_enum: 32, alignment_enum: 1, **red, a: 255, font: @font_name }.label!
    @pipeline << { x: 1280.half, y: 720.half + 144, text: "VOLUME", size_enum: 24, alignment_enum: 1, **bluish, a: 255, font: @font_name }.label!
    @pipeline << { x: 1280.half, y: 720.half + 72, text: "SOUND: ", size_enum: 24, alignment_enum: 2, **white, a: 255, font: @font_name }.label!
    @pipeline << { x: 1280.half, y: 720.half + 72, text: "#{sfx_mast}", size_enum: 24, alignment_enum: 3, **white, a: 255, font: @font_name }.label!
    @pipeline << { x: 1280.half, y: 720.half + 00, text: "MUSIC: ", size_enum: 24, alignment_enum: 2, **white, a: 255, font: @font_name }.label!
    @pipeline << { x: 1280.half, y: 720.half + 00, text: "#{music_mast}", size_enum: 24, alignment_enum: 3, **white, a: 255, font: @font_name }.label!

    @buttons.clear

    #SFX UP
    button1 = { x: 1280.half + 64, y: 720.half + 72 + 32, text: "+", size_enum: 48, alignment_enum: 0, **white, a: 255, font: @font_name, id: :sfx_up }.label!
    button2 = render_label_button(args, button1.text, button1.size_enum, button1.font, button1.x, button1.y, button1.id)
    @pipeline << button1
    @buttons << button1.merge({ x: button2.x, y: button2.y, w: button2.w, h: button2.h })

    #SFX DOWN
    button1 = { x: 1280.half + 144, y: 720.half + 72 + 32, text: "-", size_enum: 48, alignment_enum: 0, **white, a: 255, font: @font_name, id: :sfx_down }.label!
    button2 = render_label_button(args, button1.text, button1.size_enum, button1.font, button1.x, button1.y, button1.id)
    @pipeline << button1
    @buttons << button1.merge({ x: button2.x, y: button2.y, w: button2.w, h: button2.h })

    #MUSIC UP
    button1 = { x: 1280.half + 64, y: 720.half + 0 + 32, text: "+", size_enum: 48, alignment_enum: 0, **white, a: 255, font: @font_name, id: :music_up }.label!
    button2 = render_label_button(args, button1.text, button1.size_enum, button1.font, button1.x, button1.y, button1.id)
    @pipeline << button1
    @buttons << button1.merge({ x: button2.x, y: button2.y, w: button2.w, h: button2.h })

    #MUSIC DOWN
    button1 = { x: 1280.half + 144, y: 720.half + 0 + 32, text: "-", size_enum: 48, alignment_enum: 0, **white, a: 255, font: @font_name, id: :music_down }.label!
    button2 = render_label_button(args, button1.text, button1.size_enum, button1.font, button1.x, button1.y, button1.id)
    @pipeline << button1
    @buttons << button1.merge({ x: button2.x, y: button2.y, w: button2.w, h: button2.h })

    @buttons.each do |button|
      @commands[button.id].button = button
    end

    render_pipeline(args)

    # process user input
    handle_input(args)

    if $gtk.production == false
      args.state.options.buttons = @buttons if args.tick_count.zmod?(10)
      args.state.options.commands = @commands if args.tick_count.zmod?(10)
      args.state.options.mouse = args.inputs.mouse if args.tick_count.zmod?(10)
      args.state.options.selected = @selected if args.tick_count.zmod?(10)
    end
  end

  def handle_input(args)
    @selected ||= nil

    menu_item_pressed = false

    # Mouseover
    if args.inputs.mouse.moved
      buttons = @buttons.select { |i| args.inputs.mouse.inside_rect?([i.x, i.y, i.w, i.h]) }
      if buttons.length > 0
        hovered = @commands[buttons[0].id]
        if hovered[:selected] == false

          @commands.select { |key,value| value.selected == true }.each do |key,value|
            value[:selected] = false
          end

          hovered[:selected] = true
          @selected = buttons[0]
        end
      end
    end

    # Mouseclick
    clicked_at = args.inputs.mouse.click
    if @selected != nil && clicked_at != nil && clicked_at.inside_rect?(@selected)
      menu_item_pressed = true
    end

    input_map = {
      :sfx_up     => { right: :sfx_down, down: :music_up},
      :sfx_down   => {  left: :sfx_up,   down: :music_down },
      :music_up   => { right: :music_down, up: :sfx_up },
      :music_down => {  left: :music_up,   up: :sfx_down }
    }

    # @commands has state + button graphic (hash)
    # @buttons has button information (array)
    # @selected is a button (selected is the hovered button)

    is_down = args.inputs.down #args.inputs.controller_one.key_down.directional_down
    is_up = args.inputs.up #args.inputs.controller_one.key_down.directional_up
    is_left = args.inputs.left #args.inputs.controller_one.key_down.directional_left
    is_right = args.inputs.right #args.inputs.controller_one.key_down.directional_right

    # keyboard/controller
    if @selected.nil? && (is_down || is_up || is_left || is_right)
      #select something (e.g. first button)
      @commands[:sfx_up].selected = true
      @selected = @commands[:sfx_up].button
    elsif !@selected.nil? && (is_down || is_up || is_left || is_right)

      input = input_map[@selected.id]
      if is_up && input.key?(:up)
        @commands.select { |key,value| value.selected == true }.each do |key,value|
          value[:selected] = false
        end
        @selected = @commands[input.up].button
        @commands[input.up].selected = true
        #args.state.options.is_up_at = args.tick_count
      elsif is_down && input.key?(:down)
        @commands.select { |key,value| value.selected == true }.each do |key,value|
          value[:selected] = false
        end
        @selected = @commands[input.down].button
        @commands[input.down].selected = true
        #args.state.options.is_down_at = args.tick_count
      elsif is_left && input.key?(:left)
        @commands.select { |key,value| value.selected == true }.each do |key,value|
          value[:selected] = false
        end
        @selected = @commands[input.left].button
        @commands[input.left].selected = true
        #args.state.options.is_left_at = args.tick_count
      elsif is_right && input.key?(:right)
        @commands.select { |key,value| value.selected == true }.each do |key,value|
          value[:selected] = false
        end
        @selected = @commands[input.right].button
        @commands[input.right].selected = true
        #args.state.options.is_right_at = args.tick_count
      end
    end
    # WASD
    #
    non_directional_input = args.inputs.controller_one.key_up.a || args.inputs.keyboard.key_up.space || args.inputs.keyboard.key_up.enter
    if !@selected.nil? && non_directional_input
      menu_item_pressed = true
    end

    if menu_item_pressed
      args.sfx.play :player_attack_1
      min_vol = 0.0
      max_vol = 0.9
      case @selected.id
      when :sfx_up
        args.sfx.sfx_mast = (args.sfx.sfx_mast + 0.1).clamp(min_vol, max_vol)
      when :sfx_down
        args.sfx.sfx_mast = (args.sfx.sfx_mast - 0.1).clamp(min_vol, max_vol)
      when :music_up
        args.sfx.music_mast = (args.sfx.music_mast + 0.1).clamp(min_vol, max_vol)
      when :music_down
        args.sfx.music_mast = (args.sfx.music_mast - 0.1).clamp(min_vol, max_vol)
      else
        raise "Unknown options command #{@selected.id}!"
      end
    end
  end
end
