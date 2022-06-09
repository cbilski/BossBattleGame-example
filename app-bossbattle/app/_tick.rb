def tick(args)
  # https://discord.com/channels/608064116111966245/608064116984250379/913909072066150411
  #   ./dragonruby.exe mygame --onewithvalue 3 --otherflag
  #   $gtk.cli_arguments #=> {:dragonruby=>"mygame", :onewithvalue=>"3", :otherflag=>nil}
  #
  $flags = {}
  argv = $gtk.argv.split(" ")
  argv.each do |part|
    if part.start_with?("--")
      part = part[2..-1]
      $flags[part.to_sym] = true
    end
  end

  @app ||= BossBattleGameApp.new
  @version ||= $wizards.itch.get_metadata[:version]
  $app ||= @app

  args.sfx ||= Sfx.new(args)

  @app.tick(args)
  args.sfx.tick(args)
  #
  # $gtk.hide_cursor
  # mouse = args.inputs.mouse
  #
  if $gtk.production == false
    debug_label = [
      4,
      24,
      #"#{Time.now}; Ticks: #{args.state.tick_count}; Frames: #{$gtk.current_framerate.idiv(1)}; Platform: #{$gtk.platform}; DragonRuby: #{$gtk.version}; Version: #{@version}; Scene: #{@app.scene.id}; Mouse: #{args.inputs.mouse.position}",
      "#{Time.now}; Ticks: #{args.state.tick_count}; Frames: #{$gtk.current_framerate.idiv(1)}; Platform: #{$gtk.platform}; DragonRuby: #{$gtk.version}; Version: #{@version}; Scene: #{@app.scene.id}",
      -2,
      0,
      0,
      0,
      0,
      255,
    ].label

    args.outputs.primitives << debug_label
  end

  # help Palanir be helpful
  if args.tick_count.zmod?(10)
    # args.state[:gtk_sound] = args.audio
    # args.state[:sfx_music_watch] = args.sfx.loop_watcher
    # args.state[:sfx_queued] = args.sfx.queued
  end
end
