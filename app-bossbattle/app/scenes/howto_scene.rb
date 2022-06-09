class HowtoScene
  attr_reader :id

  def initialize(id, gom)
    @id = id
    @gom = gom
    @pipeline = []
    @font_name = "/fonts/Pixel Font Pack/Centurion Bold 8x16 Monospaced.ttf"
    @alpha_fade_in_at = 0
    @alpha_duration = 50
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
  end

  def render_background(args)
    # background color
    @background_color ||= { r: 0, g: 0, b: 0 }
    @pipeline << [0, 0, 1280, 720, @background_color[:r], @background_color[:g], @background_color[:b]].solid # background color
    #@pipeline << [0, 0, 1280, 720, 225, 115, 58].solid # background color

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

  def render_label_background(args, text, text_size, font_name, x, y)
    text_box = args.gtk.calcstringbox(text, text_size, font_name)
    text_box[0] += 16
    text_box[1] += 4
    @pipeline << { x: x - text_box[0].half, y: y - text_box[1], w: text_box[0], h: text_box[1], r: 0, g: 0, b: 0 }.solid!
  end

  def render_pipeline(args)
    args.outputs.primitives << @pipeline
    @pipeline.clear
  end

  def tick(args)
    if args.inputs.keyboard.key_up.escape || args.inputs.keyboard.key_up.enter || args.inputs.keyboard.key_up.space || args.inputs.controller_one.key_down.a || args.inputs.controller_one.key_down.b || args.inputs.controller_one.key_down.start || args.inputs.controller_one.key_down.r2 || args.inputs.controller_one.key_down.l2
      reset
      args.sfx.play :menu_item_changed
      @gom.app.transition_to(:menu, args)
      return
    end

    # do actual scene stuff

    # black background
    @pipeline << [0, 0, 1280, 720, @back_color_values[:r], @back_color_values[:g], @back_color_values[:b]].solid

    # normal background
    render_background(args)

    red = { r: 255, g: 0, b: 57 }
    # Title
    @pipeline << {
      x: 1280 / 2,
      y: 720 - 16,
      text: "CONTROLS",
      size_enum: 32,
      alignment_enum: 1,
      **red,
      a: 255,
      font: @font_name,
    }.label!

    # controller outline, background, keys
    #base_x = 640 - 524 / 2
    base_x = 64
    base_y = 208
    @pipeline << {
      # x: 70 - 4,
      # y: 120 - 4,
      x: base_x - 4,
      y: base_y - 4,
      w: 524 + 8,
      h: 240 + 8,
      r: 0, g: 0, b: 0,
    }.solid!

    @pipeline << {
      # x: 70,
      # y: 120,
      x: base_x,
      y: base_y,
      w: 524,
      h: 240,
      r: 66, g: 76, b: 110,
    }.solid!

    @pipeline << {
      x: base_x + 46, y: base_y - 44, w: 113 * 4, h: 78 * 4,
      path: "/sprites/help/retrocademedia.itch.io-buttonprompts4/help-1.png",
      a: 255, r: 255, g: 255, b: 255,
      tile_x: 27,
      tile_y: 83,
      tile_w: 113,
      tile_h: 78,
    }.sprite!

    # keyboard backround, background, keys
    base_x = 720 - 64
    base_y = 208
    @pipeline << {
      # x: 704 - 4,
      # y: 120 - 4,
      x: base_x - 4,
      y: base_y - 4,
      w: 524 + 8,
      h: 240 + 8,
      r: 0, g: 0, b: 0,
    }.solid!

    @pipeline << {
      # x: 704,
      # y: 120,
      x: base_x,
      y: base_y,
      w: 524,
      h: 240,
      r: 66, g: 76, b: 110,
    }.solid!

    @pipeline << {
      x: base_x + 16, y: base_y + 8, w: 122 * 4, h: 57 * 4,
      path: "/sprites/help/retrocademedia.itch.io-buttonprompts4/help-1.png",
      a: 255, r: 255, g: 255, b: 255,
      tile_x: 180,
      tile_y: 92,
      tile_w: 122,
      tile_h: 57,
    }.sprite!

    # Commands (Left)
    base_x = 326
    base_y = 612
    spacing = 48
    text_color = { r: 255, g: 255, b: 255 }
    text_size = 8
    render_label_background(args, "MOVE PLAYER", text_size, @font_name, base_x, base_y - (spacing * 1))
    @pipeline << { x: base_x, y: base_y - (spacing * 1), text: "MOVE PLAYER", size_enum: text_size, alignment_enum: 1, **text_color, a: 255, font: @font_name }.label!
    base_y = 160
    render_label_background(args, "SHOOT BOW", text_size, @font_name, base_x, base_y - (spacing * 0))
    @pipeline << { x: base_x, y: base_y - (spacing * 0), text: "SHOOT BOW", size_enum: text_size, alignment_enum: 1, **text_color, a: 255, font: @font_name }.label!
    render_label_background(args, "ADVANCE DIALOG", text_size, @font_name, base_x, base_y - (spacing * 1))
    @pipeline << { x: base_x, y: base_y - (spacing * 1), text: "ADVANCE DIALOG", size_enum: text_size, alignment_enum: 1, **text_color, a: 255, font: @font_name }.label!

    # Commands (Right)
    base_x = 919
    base_y = 612
    render_label_background(args, "MOVE PLAYER", text_size, @font_name, base_x, base_y - (spacing * 1))
    @pipeline << { x: base_x, y: base_y - (spacing * 1), text: "MOVE PLAYER", size_enum: text_size, alignment_enum: 1, **text_color, a: 255, font: @font_name }.label!
    base_y = 160
    render_label_background(args, "SHOOT BOW", text_size, @font_name, base_x, base_y - (spacing * 0))
    @pipeline << { x: base_x, y: base_y - (spacing * 0), text: "SHOOT BOW", size_enum: text_size, alignment_enum: 1, **text_color, a: 255, font: @font_name }.label!
    render_label_background(args, "ADVANCE DIALOG", text_size, @font_name, base_x, base_y - (spacing * 1))
    @pipeline << { x: base_x, y: base_y - (spacing * 1), text: "ADVANCE DIALOG", size_enum: text_size, alignment_enum: 1, **text_color, a: 255, font: @font_name }.label!

    # draw lines
    lines = [
      [[201, 538], [90, 538], [90, 359], [105, 359]], # MOVE PLAYER L
      [[201, 550], [80, 550], [80, 278], [169, 278]], # MOVE PLAYER DPAD
      [[430, 140], [560, 140], [560, 312], [522, 312]], # SHOOT BOW A
      [[470, 90],  [580, 90],  [580, 360], [564, 360]], # ADVANCE DIALOG B
      [[801, 544], [774, 544], [774, 333], [804, 333], [804, 322]], # MOVE PLAYER A
      [[801, 544], [774, 544], [774, 333], [869, 333], [869, 345]], # MOVE PLAYER W
      [[801, 544], [774, 544], [774, 333], [869, 333], [869, 322]], # MOVE PLAYER S
      [[801, 544], [774, 544], [774, 333], [932, 333], [932, 322]], # MOVE PLAYER D
      [[820, 142], [785, 142], [785, 239], [812, 239]], # SHOOT BOW SPACE
      [[1058, 88], [1160, 88], [1160, 300], [1130, 300]], # SHOOT BOW SPACE
    ]

    lines.each do |line|
      log_once line.to_s
      line.each_cons(2) do |p1, p2|
        @pipeline << { x: p1.x, y: p1.y, x2: p2.x, y2: p2.y, r: 255, g: 255, b: 255, a: 255 }.line!
        @pipeline << { x: p1.x + 1, y: p1.y + 1, x2: p2.x + 1, y2: p2.y + 1, r: 255, g: 255, b: 255, a: 255 }.line!
        @pipeline << { x: p1.x + 2, y: p1.y + 2, x2: p2.x + 2, y2: p2.y + 2, r: 255, g: 255, b: 255, a: 255 }.line!
      end
    end

    render_pipeline(args)
  end
end
