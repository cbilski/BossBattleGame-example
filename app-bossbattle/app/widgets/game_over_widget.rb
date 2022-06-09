class GameOverWidget
  def initialize(args, win_or_lose)
    @win_or_lose = win_or_lose
    @font_name = "/fonts/Pixel Font Pack/Centurion Bold 8x16 Monospaced.ttf"
    @finished = false
  end

  def finished?
    @finished
  end

  def handle_input(args)
    if args.inputs.keyboard.key_up.enter || args.inputs.keyboard.key_up.escape || args.inputs.controller_one.key_up.b
      args.inputs.keyboard.key_down.clear
      args.inputs.keyboard.key_up.clear
      args.inputs.controller_one.key_down.clear
      args.inputs.controller_one.key_up.clear
      @finished = true
      :menu
    else
      :no_input
    end
  end

  def modal?
    true
  end

  def render(args, pipeline)

    # BOSS BATTLE
    pipeline << {
      x: 1280 / 2,
      y: 720 + 4,
      text: @win_or_lose == :win ? "YOU WON!" : "YOU DIED.",
      size_enum: 60,
      alignment_enum: 1,
      #r: 208, g: 25, b: 70,
      r: 255, g: 0, b: 57,
      a: 255,
      font: @font_name,
    }.label!

    args.outputs.primitives << pipeline

    # @menu_items.each do |item|
    #   @button_color = { r: 130, g: 113, b: 82 }
    #   text_color = { r: 224, g: 224, b: 224 }
    #   text_color = { r: 176, g: 176, b: 176 } if item[:selectable] == false
    #
    #   y_offset = 0
    #
    #   label = {
    #     x: item[:x],
    #     y: item[:y] - y_offset,
    #     text: item[:text],
    #     size_enum: 32,
    #     alignment_enum: 1,
    #     **text_color,
    #     a: 255,
    #     font: @font_name,
    #   }.label!
    #
    #   box = $gtk.calcstringbox(label[:text], label[:size_enum], label[:font]) # box has [w, h].
    #   box_width = box[0] + 64
    #   box_height = box[1] - 4
    #
    #   outline = {
    #     x: item[:x] - (box_width / 2) - 12,
    #     y: item[:y] - box_height - 12 - y_offset,
    #     w: box_width + 16,
    #     h: box_height + 16,
    #     r: 0, g: 0, b: 0,
    #   }.solid!
    #
    #   item[:outline] = outline if item[:outline] == nil
    #
    #   fill = {
    #     x: item[:x] - (box_width / 2) - 4,
    #     y: item[:y] - box_height - 4 - y_offset,
    #     w: box_width,
    #     h: box_height,
    #     **@button_color,
    #   }.solid!
    #
    #   if item[:selected] == true
    #     pipeline << outline
    #     pipeline << fill
    #   end
    #
    #   pipeline << label
    # end
  end

  def track(args)

  end
end