#noinspection RubyTooManyInstanceVariablesInspection
class BattleScene1

  CAMERA_TRAUMA_DECAY = 0.018 #0.003

  attr_reader :id
  attr_reader :player
  attr_reader :camera
  attr_reader :context

  def initialize(id, gom)
    @id = id
    @gom = gom
    @pipeline = []
    @torches = {}

    @context = {
      background_fade_in: 0,
      player_fade_in: 0,
      ui_fade_in: 0,
      npc_fade_in: 0,
      trauma: 0.0,
    } # scene context

    @world = { w: 2048, h: 1152 }
    @camera = {
      x: 640, y: 384,
      scale: 1.0,
      show_empty_space: :no
    }

    @player = Player.create_player
    @npc = Npc.create_npc
    @boss = Boss.create_boss
    @game_phases = GamePhases.create_phases
    @pickups = [] # things in this collection can be picked up by the player
    @projectiles = [] # things in this collection can hit other things in the world
    @thrown = [] # things in this collection are trying to get from one location to another
    @alive_alpha = 255

    @widgets = []
    load_arena_boundary
  end

  def scene_activate(args)
    if args != nil

    end
  end

  def scene_deactivate(args)
    if args != nil

    end
  end

  def calc_viewport(args)
    result = { x: @camera.x - (@player.x * @camera.scale),
               y: @camera.y - (@player.y * @camera.scale),
               w: @world.w * @camera.scale,
               h: @world.h * @camera.scale,
               scale: @camera.scale }

    return result if @camera.show_empty_space == :yes

    padding = 0

    # if result.w < args.grid.w
    #   result.merge!(x: (args.grid.w - result.w).half)
    # elsif (@player.x * result.scale) < args.grid.w.half
    #   result.merge!(x: padding)
    # elsif (result.x + result.w) < args.grid.w
    #   result.merge!(x: - result.w + (args.grid.w - padding))
    # end

    if result.h < args.grid.h
      result.merge!(y: (args.grid.h - result.h).half)
    elsif (result.y) > padding
      result.merge!(y: padding)
    elsif (result.y + result.h) < args.grid.h
      result.merge!(y: -result.h + (args.grid.h - padding))
    end

    result
  end

  def calc_arena_tile_index(x, y)
    tile_size = 8

    arena_tile_index = ((((@world.h - y) / tile_size).floor * (@world.w / tile_size))).to_i # y portion of index
    arena_tile_index += (((x) / tile_size).floor).to_i # x portion of index

    arena_tile_index
  end

  def calc_arena_upper_bounds(x)
    tile_size = 8

    arena_tiles_h = (@world.h / tile_size).to_i
    arena_tiles_w = (@world.w / tile_size).to_i
    arena_tile_x_index = (((x) / tile_size).floor).to_i
    arena_tile_y_index = arena_tiles_h - 1

    index_val = 1
    while index_val == 1
      arena_tile_index = arena_tiles_w * arena_tile_y_index # y portion of index
      arena_tile_index += arena_tile_x_index # x portion of index

      index_val = @arena_path_data[arena_tile_index]
      #log "Index for (#{arena_tile_x_index}, #{arena_tile_y_index}) in (#{arena_tiles_w}, #{arena_tiles_h}) is #{index_val}"
      if index_val > 0
        arena_tile_y_index -= 1
      end
    end

    #log "Index for (#{arena_tile_x_index}, #{arena_tile_y_index}) in (#{arena_tiles_w}, #{arena_tiles_h})"
    (arena_tiles_h - arena_tile_y_index) * tile_size
  end

  def spawn_coffee_thrown(args, start_x, start_y, thrown_x, thrown_y, duration)
    @thrown << {
      x: start_x,
      y: start_y,
      w: 32,
      h: 32,
      facing: rand(2) == 0 ? :left : :right,
      state: :full,
      frame: 0,
      num_frames: 1,
      thrown_at: args.tick_count,
      thrown_until: args.tick_count + duration,
      thrown_source_xy: { x: start_x, y: start_y },
      thrown_target_xy: { x: thrown_x, y: thrown_y },
      thrown_duration: duration,
      object_type: :coffee,
    }
  end

  def spawn_coffee_pickup(args, x, y)
    @pickups << {
      x: x,
      y: y,
      w: 32,
      h: 32,
      state: :full,
      frame: 0,
      num_frames: 1,
      object_type: :coffee,
    }
  end

  def spawn_boss_cube(args, id)
    size = 64
    offset_y = (id - 1) * size
    offset_x = 0
    source = @boss

    if source.facing == :left
      offset_x = -180
      offset_y += -128
    elsif source.facing == :right
      offset_x = 104
      offset_y += -128
    elsif source.facing == :up
      offset_y += 0
    else
      offset_y += 0
    end

    cube = {
      x: source.x + source[:size].half + offset_x,
      y: source.y + source[:size].half + offset_y,
      w: 64,
      h: 64,
      frame: 0,
      num_frames: 1,
      speed_x: 0,
      speed_y: 0,
      facing: source.facing,
      source_id: :boss,
      object_type: :cube,
      damage: Boss::BOSS_DAMAGE_CUBE,
      collision: :false,
    }

    @projectiles << cube

    cube
  end

  def spawn_player_arrow(args)
    base_speed = 20
    offset_x = 0
    speed_x = 0
    speed_y = 0

    if @player.facing == :left
      speed_x = base_speed * -1
      offset_y = -16
      offset_x = -8
    elsif @player.facing == :right
      speed_x = base_speed
      offset_x = 8
      offset_y = -16
    elsif @player.facing == :up
      speed_y = base_speed
      offset_y = 32
    else
      speed_y = base_speed * -1
      offset_y = -40
    end

    @projectiles << {
      x: @player.x + @player[:size].half + offset_x,
      y: @player.y + @player[:size].half + offset_y,
      w: 8,
      h: 8,
      frame: 0,
      num_frames: 1,
      speed_x: speed_x,
      speed_y: speed_y,
      facing: @player.facing,
      source_id: :player,
      object_type: :arrow,
      damage: Player::PLAYER_ARROW_DAMAGE,
      collision: :false,
    }

    args.sfx.play :player_attack_1
  end

  def spawn_spikes(args, facing = nil)
    source = @boss
    base_speed = 5
    offset_x = 0
    speed_x = 0
    speed_y = 0

    if facing.nil?
      facing = source.facing
    end

    if facing == :left
      speed_x = base_speed * -1
      offset_y = -96
      offset_x = -112
    elsif facing == :right
      speed_x = base_speed
      offset_y = -96
      offset_x = 32
    elsif facing == :up
      speed_y = base_speed
      offset_y = 48
      offset_x = -48
    else
      speed_y = base_speed * -1
      offset_y = -120
      offset_x = -48
    end

    @projectiles << {
      x: source.x + source[:size].half + offset_x,
      y: source.y + source[:size].half + offset_y,
      w: 96,
      h: 96,
      frame: 0,
      num_frames: 10,
      track_speed: 5,
      speed_x: speed_x,
      speed_y: speed_y,
      facing: source.facing,
      source_id: :boss,
      object_type: :spike,
      damage: Boss::BOSS_DAMAGE_SPIKE, #TBD
      collision: :false,
    }
  end

  def handle_player_input(args, is_paused)

    # debug info
    # if args.tick_count.zmod?(10)
    #   args.state.directional_angle = args.inputs.directional_angle
    #
    #   if args.inputs.directional_angle
    #     args.state.directional_angle_x = args.inputs.directional_angle.vector_x
    #     args.state.directional_angle_y = args.inputs.directional_angle.vector_y
    #   end
    # end
    #

    last_state = @player.state
    is_alive = @player.state != :dying && @player.state != :dead
    keep_shooting = false

    # direction handling
    if is_alive && !is_paused
      unless @player.state_shoot_interrupt
        if args.inputs.directional_angle
          vec_x = args.inputs.directional_angle.vector_x
          vec_y = args.inputs.directional_angle.vector_y
          @player.state = :run
        elsif @player.state != :attack
          # not moving
          @player.state = :idle
        end
      end

      # shoot
      if args.inputs.keyboard.key_down.space || args.inputs.controller_one.key_down.a
        @player.state_shoot_interrupt = true if @player.state == :run
        @player.state = :attack # always start shooting?
      end

      # keep shooting, if space held
      if @player.state == :attack && (args.inputs.keyboard.key_held.space || args.inputs.controller_one.key_held.a)
        keep_shooting = true
      end

      if args.inputs.keyboard.key_up.space || args.inputs.controller_one.key_up.a
        @player.state_shoot_interrupt = false
      end

      # process movement, if running (maybe this is update code we should do later)
      if @player.state == :run
        # moving
        new_x = (@player.x + (vec_x * @player.stride)).clamp(0, @world.w - @player[:size])
        new_y = (@player.y + (vec_y * @player.stride)).clamp(0, @world.h - @player[:size])

        @player.x = new_x.clamp(0, @world.w - @player[:size])
        @player.y = new_y.clamp(0, calc_arena_upper_bounds(new_x))

        if vec_x.abs > vec_y.abs
          if vec_x > 0.0
            @player.facing = :right
          else
            @player.facing = :left
          end
        else
          if vec_y > 0.0
            @player.facing = :up
          else
            @player.facing = :down
          end
        end
      end
    end

    # advance frames: reset if state changed
    if last_state != @player.state
      @player.frame = 0
    else
      @player.frame = (@player.frame + 1) % 4 if @player.state == :run && args.tick_count.zmod?(3)
      @player.frame = (@player.frame + 1) % 4 if @player.state == :idle && args.tick_count.zmod?(10)
      @player.frame = (@player.frame + 1) % 4 if @player.state == :dying && args.tick_count.zmod?(40)
      @player.frame = 3 if @player.state == :dead && args.tick_count.zmod?(10)

      if @player.state == :attack && args.tick_count.zmod?(@player.attack_speed) # <-- TICKS PER FRAME WHEN SHOOTING
        @player.frame = (@player.frame + 1) % 4
        @player.state = :idle if @player.frame == 0 && !keep_shooting # go back to idle if space not held

        #spawn arrow if this is frame 2
        if @player.frame == 2
          spawn_player_arrow(args)

          # spawn_spikes(args)

          # if @player.caffine_meter <= 0.0
          #   spawn_coffee_pickup(args, @player.x + 128, @player.y)
          # else
          #   spawn_player_arrow(args)
          # end

          #@context.trauma = 0.35

          #args, start_x, start_y, thrown_x, thrown_y, duration
          #spawn_coffee_thrown(args, 8, 8, 640, 640, 50)
        end
      end
    end

    Player.update(@player)
  end

  def load_arena_boundary
    @arena_path_data ||= []
    $gtk.read_file("resources/arena_data.csv").each_line { |line|
      next if line.start_with?("/") # allow comments
      line.split(",").each { |value|
        value = value.strip
        @arena_path_data << value.to_i if value != ""
      }
    }
    #log "Loaded #{@arena_path_data.length} values from arena_data.csv"
  end

  def render_boss(args)
    unit_frames = { # row values go in here
                    :down => { :idle => 0, :run => 1, :attack => 2, :dying => 3, :dead => 3, :wind_up_1 => 2, :wind_up_2 => 2, :lunge_1 => 2, :jump_prepare_1 => 0, :jump_prepare_2 => 1, :jump_up => 3, :jump_down => 2 },
                    :up => { :idle => 4, :run => 5, :attack => 6, :dying => 7, :dead => 7, :wind_up_1 => 6, :wind_up_2 => 6, :lunge_1 => 2, :jump_prepare_1 => 4, :jump_prepare_2 => 5, :jump_up => 7, :jump_down => 2 },
                    :left => { :idle => 8, :run => 9, :attack => 10, :dying => 11, :dead => 11, :wind_up_1 => 10, :wind_up_2 => 10, :lunge_1 => 2, :jump_prepare_1 => 8, :jump_prepare_2 => 9, :jump_up => 11, :jump_down => 2 },
                    :right => { :idle => 12, :run => 13, :attack => 14, :dying => 15, :dead => 15, :wind_up_1 => 14, :wind_up_2 => 14, :lunge_1 => 2, :jump_prepare_1 => 12, :jump_prepare_2 => 13, :jump_up => 15, :jump_down => 2 },
    }

    tile_size = 256
    row = unit_frames[@boss.facing][@boss.state]
    col = @boss.frame

    x = @boss.x + @boss.render_offset.x
    y = @boss.y + @boss.render_offset.y + @boss.z

    if $flags[:hide_boss] == true
      {
        x: x, y: y, w: @boss[:size], h: @boss[:size],
        tile_x: col * tile_size, tile_y: row * tile_size, tile_w: tile_size, tile_h: tile_size,
        r: 0, g: 0, b: 255,
        a: @alive_alpha
      }.solid!
    else
      alpha = @boss.death_at > -1 ? 255 : @alive_alpha
      {
        x: x, y: y, w: @boss[:size], h: @boss[:size],
        tile_x: col * tile_size, tile_y: row * tile_size, tile_w: tile_size, tile_h: tile_size,
        path: '/sprites/iceturtlestudios.itch.io-Shades.png',
        a: alpha
      }.sprite!
    end
  end

  def render_boss_health(args)
    health_to_ease = @boss.health_last - @boss.health
    if health_to_ease > 0
      health_to_ease *= @boss.damage_at.ease(20) # @boss.damage_at = tick where boss was hit
    end

    # alpha = @alive_alpha > 192 ? 192 : @alive_alpha
    alpha = (@boss.context.phase < Boss::BOSS_START_PHASE ? context.ui_fade_in : @alive_alpha).clamp(0, 192)

    if health_to_ease > 0
      args.outputs.primitives << {
        x: (1280 * (@boss.health / Boss::BOSS_MAX_HEALTH)),
        y: 720 - 32,
        w: 1280 * (((@boss.health_last - @boss.health) - health_to_ease) / Boss::BOSS_MAX_HEALTH),
        h: 32,
        r: 255, g: 255, b: 0, a: 192,
        a: alpha
      }.solid!
    end

    args.outputs.primitives << {
      x: 0,
      y: 720 - 32,
      w: (1280 * (@boss.health / Boss::BOSS_MAX_HEALTH)),
      h: 32,
      r: 0, g: 255, b: 0, a: 192,
      a: alpha
    }.solid!

  end

  def render_boss_shadow(args)
    return if @boss.z < 1

    tile_size = 256
    row = 1
    col = 1

    x = @boss.x + @boss.render_offset.x
    y = @boss.y + @boss.render_offset.y

    args.outputs[:scene].primitives << {
      x: x, y: y, w: @boss[:size], h: @boss[:size],
      tile_x: col * tile_size, tile_y: row * tile_size, tile_w: tile_size, tile_h: tile_size,
      path: '/sprites/iceturtlestudios.itch.io-Shades-Shadows.png',
      a: @boss.context.phase < Boss::BOSS_START_PHASE ? context.background_fade_in : @alive_alpha
    }.sprite!
  end

  def render_npc(args)

    unit_frames = {
      :down => { :idle => 0, :run => 1, :attack => 2, :dying => 3, :dead => 3 },
      :up => { :idle => 4, :run => 5, :attack => 6, :dying => 7, :dead => 7 },
      :left => { :idle => 8, :run => 9, :attack => 10, :dying => 11, :dead => 11 },
      :right => { :idle => 12, :run => 13, :attack => 14, :dying => 15, :dead => 15 },
    }

    tile_size = 128
    row = unit_frames[@npc.facing][@npc.state]
    col = @npc.frame

    {
      x: @npc.x, y: @npc.y, w: @npc[:size], h: @npc[:size],
      tile_x: col * tile_size, tile_y: row * tile_size, tile_w: tile_size, tile_h: tile_size,
      path: '/sprites/iceturtlestudios.itch.io-male_warrior.png',
      a: $flags[:hide_boss] == true ? 0 : context.npc_fade_in
    }.sprite!
  end

  def render_player_health(args)
    offset_x = 0
    offset_y = 0
    hurt_alpha = 255

    if args.tick_count < @player.hurt_until
      # shake hearts
      hurt_alpha = 255 - (((player.hurt_until - args.tick_count) / player.hurt_duration) * 255)
      offset_range = 8
      offset_x = rand(offset_range) - (offset_range / 2.0)
      offset_y = rand(offset_range) - (offset_range / 2.0)
    end

    g = hurt_alpha
    b = hurt_alpha

    scale = 1
    args.outputs.primitives << {
      x: 2 + offset_x, y: 656 + offset_y, w: 96 * scale, h: 32 * scale,
      path: "/sprites/sarturxz.itch.io-CoolLittleHearts/health-#{@player.health.to_i}.png",
      g: g, b: b,
      a: @boss.context.phase < Boss::BOSS_START_PHASE ? context.ui_fade_in : @alive_alpha
    }.sprite!
  end

  def render_player(args)
    unit_frames = {
      :down => { :idle => 0, :run => 1, :attack => 2, :dying => 3, :dead => 3 },
      :up => { :idle => 4, :run => 5, :attack => 6, :dying => 7, :dead => 7 },
      :left => { :idle => 8, :run => 9, :attack => 10, :dying => 11, :dead => 11 },
      :right => { :idle => 12, :run => 13, :attack => 14, :dying => 15, :dead => 15 },
      # :down  => { :idle => 0,  :run => 1,  :attack => 2,  :die => 3 },
      # :up    => { :idle => 4,  :run => 5,  :attack => 6,  :die => 7 },
      # :left  => { :idle => 8,  :run => 9,  :attack => 10, :die => 11 },
      # :right => { :idle => 12, :run => 13, :attack => 14, :die => 15 },
    }

    # args.outputs[:scene].primitives << {
    #   x: @player.x, y: @player.y, w: @player[:size], h: @player[:size], r: 0, g: 0, b: 255,
    # }.solid!

    tile_size = 128
    row = unit_frames[@player.facing][@player.state]
    col = @player.frame

    hurt_alpha = 255
    if player.hurt_until > args.tick_count
      hurt_alpha = 255 - (((player.hurt_until - args.tick_count) / player.hurt_duration) * 255)
    end

    g = hurt_alpha
    b = hurt_alpha

    {
      x: @player.x, y: @player.y, w: @player[:size], h: @player[:size],
      tile_x: col * tile_size, tile_y: row * tile_size, tile_w: tile_size, tile_h: tile_size,
      path: '/sprites/iceturtlestudios.itch.io-male_archer.png',
      g: g, b: b,
      a: @boss.context.phase < Boss::BOSS_START_PHASE ? context.player_fade_in : 255
    }.sprite!
  end

  def render_projectiles(args)
    result = []

    i = 0
    while i < @projectiles.length
      p = @projectiles[i]

      case p.object_type
      when :arrow
        #result << { x: p.x, y: p.y, w: p.w, h: p.h, r: 0, g: 0, b: 255 }.border!
        case p.facing
        when :left
          result << { x: p.x - 4, y: p.y - 2, w: p.w + 48, h: p.h + 4, path: 'sprites/Arrow-02.png', angle: 180 }.sprite!
        when :right
          result << { x: p.x - 44, y: p.y - 2, w: p.w + 48, h: p.h + 4, path: 'sprites/Arrow-02.png' }.sprite!
        when :up
          result << { x: p.x - 24, y: p.y - 22, w: p.w + 48, h: p.h + 4, path: 'sprites/Arrow-02.png', angle: 90 }.sprite!
        when :down
          result << { x: p.x - 24, y: p.y + 18, w: p.w + 48, h: p.h + 4, path: 'sprites/Arrow-02.png', angle: 270 }.sprite!
        else
          raise "Unknown arrow facing #{p.facing}!"
        end

      when :spike
        if $flags[:hide_boss] == true
          result << {
            x: p.x, y: p.y, w: p.w, h: p.h,
            tile_x: p.frame * 32, tile_y: 0, tile_w: 32, tile_h: 41,
            r: 255, g: 0, b: 0,
            a: 255 # are there alpha considerations I need to look at for player death?
          }.solid!
        else
          result << {
            x: p.x, y: p.y, w: p.w, h: p.h,
            tile_x: p.frame * 32, tile_y: 0, tile_w: 32, tile_h: 41,
            path: '/sprites/stealthix.itch.io-Traps/Fire_Trap.png',
            a: 255 # are there alpha considerations I need to look at for player death?
          }.sprite!
        end
      else
        # cube
        if $flags[:hide_boss] == true
          result << {
            x: p.x, y: p.y, w: p.w, h: p.h,
            tile_x: 0, tile_y: 0, tile_w: 32, tile_h: 32,
            r: 0, g: 255, b: 0,
            a: 255 # are there alpha considerations I need to look at for player death?
          }.solid!
        else
          result << {
            x: p.x, y: p.y, w: p.w, h: p.h,
            tile_x: 0, tile_y: 0, tile_w: 32, tile_h: 32,
            path: '/sprites/free-game-assets.itch.io-desert-2d-tileset-pixel-art/Tile_31-white.png',
            a: @alive_alpha # are there alpha considerations I need to look at for player death?
          }.sprite!
        end
      end

      i += 1
    end

    result
  end

  def render_scene(args)
    # camera's x/y value tracks with the center of the view (render the player in the center of the view)
    # We should be able to move the camera as a percentage of the player's position in the arena
    # If I am X percent in the world, render the center that much off?

    args.outputs.primitives << {
      x: 0, y: 0, w: 1280, h: 720,
      r: 0, g: 0, b: 0
    }.solid!

    # draw full scale arena (world is 2048x1152)
    args.outputs[:scene].w = @world.w
    args.outputs[:scene].h = @world.h

    if $flags[:hide_boss].nil?
      # draw background (black)
      args.outputs[:scene].primitives << {
        x: 0, y: 0, w: @world.w, h: @world.h,
        r: 0, g: 0, b: 0
      }.solid!

      # draw background (ground)
      args.outputs[:scene].primitives << {
        x: 0, y: 0, w: @world.w, h: @world.h, r: 255, g: 255, b: 255,
        path: '/sprites/free-game-assets.itch.io-battle-arena-backgrounds-pack/layers/battleground-pixelmash-edited.png',
        a: @boss.context.phase < Boss::BOSS_START_PHASE ? context.background_fade_in : @alive_alpha
      }.sprite!
    end

    # draw background (back)
    args.outputs[:scene].primitives << {
      x: 0, y: 0, w: @world.w, h: @world.h,
      path: '/sprites/free-game-assets.itch.io-battle-arena-backgrounds-pack/layers/back_decor-pixelmash.png',
      a: @boss.context.phase < Boss::BOSS_START_PHASE ? context.background_fade_in : @alive_alpha
    }.sprite!

    # draw torches (back)
    render_torch(args, 0, 136, 672)
    render_torch(args, 1, 572, 760)
    render_torch(args, 2, 812, 778)
    render_torch(args, 3, 1144, 778)
    render_torch(args, 4, 1378, 760)
    render_torch(args, 5, 1810, 672)

    # draw boss shadow if boss offscreen
    render_boss_shadow(args)

    # draw things in the middle (boss/archer should be sorted according to h)
    hero = render_player(args)
    boss = render_boss(args)
    arrows = render_projectiles(args)
    pickups = render_pickups(args)
    thrown = render_thrown(args)

    # args.outputs[:scene].primitives << [hero, boss].sort_by{ |s| 0 - s[:y] }
    # args.outputs[:scene].primitives << pickups.sort_by{ |s| 0 - s[:y] }
    args.outputs[:scene].primitives << [hero, boss, *pickups].sort_by { |s| 0 - s[:y] }
    args.outputs[:scene].primitives << arrows.sort_by { |s| 0 - s[:y] }

    # draw background (front)
    args.outputs[:scene].primitives << {
      x: 0, y: 0, w: @world.w, h: @world.h,
      path: '/sprites/free-game-assets.itch.io-battle-arena-backgrounds-pack/layers/front_decor-pixelmash.png',
      a: @boss.context.phase < Boss::BOSS_START_PHASE ? context.background_fade_in : @alive_alpha
    }.sprite!

    args.outputs[:scene].primitives << render_npc(args)
    args.outputs[:scene].primitives << thrown.sort_by { |s| 0 - s[:y] }

    # draw torches (front)
    render_torch(args, 6, 112, 122)
    render_torch(args, 7, 566, 14)
    render_torch(args, 8, 988, -24)
    render_torch(args, 9, 1392, 14)
    render_torch(args, 10, 1840, 122)

    # draw camera view
    view = calc_viewport(args)
    #args.state.view = view if args.tick_count.zmod?(10) # debug

    # camera shake
    if @context.trauma > 0
      shake = @context.trauma ** 3
      camera_offset_x = 1024 * shake * ((rand * 2.0) - 1.0) * @camera.scale
      camera_offset_y = 1024 * shake * ((rand * 2.0) - 1.0) * @camera.scale
      camera_angle = 60 * shake * ((rand * 2.0) - 1.0) * @camera.scale
    else
      camera_offset_x = 0
      camera_offset_y = 0
      camera_angle = 0
    end

    #hitbox debugging
    # args.outputs[:scene].primitives << { **@player.hitbox, r: 0, g: 0, b: 255 }.border!
    # args.outputs[:scene].primitives << { **@boss.hitbox, r: 0, g: 0, b: 255 }.border!

    args.outputs.primitives << {
      x: view.x + camera_offset_x,
      y: view.y + camera_offset_y,
      w: view.w,
      h: view.h,
      angle: camera_angle,
      path: :scene
    }.sprite!

  end

  def render_thrown(args)
    result = []

    pi = 0
    while pi < @thrown.length
      p = @thrown[pi]

      case p.object_type
      when :coffee
        result << {
          x: p.x, y: p.y, w: p.w, h: p.h,
          tile_x: p.frame * 32, tile_y: 0, tile_w: 32, tile_h: 41,
          path: p.state == :full ? 'sprites/cazwolf.itch.io-caz-pixel-1/cup-coffee.png' : 'sprites/cazwolf.itch.io-caz-pixel-1/cup-empty.png',
          angle: p.state == :full ? 0 : 90,
          flip_horizontally: p.facing == :right,
          r: 207, g: 180, b: 160,
          a: 255 # are there alpha considerations I need to look at for player death?
        }.sprite!
      else
        raise "Unknown object_type #{p.object_type}!"
      end

      pi += 1
    end

    result
  end

  def render_pickups(args)
    result = []

    pi = 0
    while pi < @pickups.length
      p = @pickups[pi]

      case p.object_type
      when :coffee
        result << {
          x: p.x, y: p.y, w: p.w, h: p.h,
          tile_x: p.frame * 32, tile_y: 0, tile_w: 32, tile_h: 41,
          path: p.state == :full ? 'sprites/cazwolf.itch.io-caz-pixel-1/cup-coffee.png' : 'sprites/cazwolf.itch.io-caz-pixel-1/cup-empty.png',
          angle: p.state == :full ? 0 : 90,
          flip_horizontally: p.facing == :right,
          r: 207, g: 180, b: 160,
          a: 255 # are there alpha considerations I need to look at for player death?
        }.sprite!
      else
        raise "Unknown object_type #{p.object_type}!"
      end

      pi += 1
    end

    result
  end

  def render_torch(args, id, x, y)
    unless @torches.key?(id)
      @torches[id] = { frame: id % 4 }
    end

    if args.tick_count.zmod?(8)
      @torches[id][:frame] = (@torches[id][:frame] + 1) % 4
    end

    # torch 1
    args.outputs[:scene].primitives << {
      x: x, y: y, w: 84, h: 192,
      tile_x: 0 * 16, tile_y: @torches[id][:frame] * 20, tile_w: 16, tile_h: 20,
      path: "/sprites/finalbossblues.itch.io-fantasyrpgtilesetpack/torch.png",
      a: @boss.context.phase < Boss::BOSS_START_PHASE ? context.background_fade_in : @alive_alpha
    }.sprite!

  end

  def render_pipeline(args)
    args.outputs.primitives << @pipeline # args.outputs.sprites.concat args.state.lots_of_enemies
    @pipeline.clear
  end

  def track_boss(args)
    if @boss.state != :dying && @boss.state != :dead && @boss.health == 0
      # transition to dying
      @boss.frame = 0
      @boss.state = :dying
    elsif @boss.state == :dying && @boss.frame == 3
      # transition to dead
      @boss.frame = 0
      @boss.state = :dead
      @boss.death_at = args.tick_count

      transition_to_game_over_win(args)
    else
      # do boss logic
      track_boss_logic(args) unless @boss.state == :dead || @boss.state == :dying
    end

    # frame states (generic)
    @boss.frame = (@boss.frame + 1) % 4 if @boss.state != :dying && args.tick_count.zmod?(@boss.speed)
    @boss.frame = (@boss.frame + 1) % 4 if @boss.state == :dying && args.tick_count.zmod?(22)

    # don't animate during these states
    @boss.frame = 3 if @boss.state == :dead
    @boss.frame = 2 if @boss.state == :lunge_1
    @boss.frame = 1 if @boss.state == :jump_prepare_1
    @boss.frame = 3 if @boss.state == :jump_prepare_2
    @boss.frame = 1 if @boss.state == :jump_up
    @boss.frame = 2 if @boss.state == :jump_down
    @boss.frame = 0 if @boss.state == :wind_up_1
    @boss.frame = 1 if @boss.state == :wind_up_2

    # ease out to just player, if dead
    if @boss.death_at > -1
      ease_val = @boss.death_at.ease(150, [:flip, :quad, :flip]) # smoothest start?
      @alive_alpha = 255 * (1 - ease_val)
    end

    Boss.update(@boss)
  end

  def track_boss_logic(args)
    return unless args.tick_count.zmod?(@boss.speed)

    context = @boss.context
    phase = @game_phases[context.phase]

    # do the thing if it's time to do it
    unless context.action.nil?
      action = context.action
      move = context.move

      if GameActions.respond_to?(action[:type])
        action_result = GameActions.method(action[:type]).call(
          args, self, action, @boss, @player, @world)
      else
        raise "[GAME] GameAction #{action[:type]} is missing!"
      end

      if action_result == :next_phase
        transition_to_next_phase
        phase = @game_phases[context.phase]
        log "[GAME] GameAction #{action[:type]} advanced phase. (tick: #{args.tick_count})"
      elsif action_result == :done
        # normal logic: if this was last action, then next move - otherwise next action
        context.action = nil

        if context.action_index >= move.actions.length - 1
          context.move = nil
          context.action_index = -1
        end
        log "[GAME] GameAction #{action[:type]} complete (#{context.action_index + 1} of #{move.actions.length}). (tick: #{args.tick_count})"
      end
    end

    # reset things if we completed a thing and there aren't more things to do
    if context.move.nil?
      # get next move
      context.move_index = (context.move_index + 1) % phase.moves.length
      context.move = phase.moves[context.move_index]
      log "[GAME] Starting move: #{context.move.id}... (#{context.move_index + 1} of #{phase.moves.length})"
    end

    if context.action.nil? && !context.move.nil?
      # get next part
      context.action_index = (context.action_index + 1) % context.move.actions.length
      context.action = context.move.actions[context.action_index]
      @boss.state = context.action.state
      @boss.speed = context.action.speed unless context.action.speed.nil?
      log "[GAME] Starting action: #{context.action.id}..."
    end

    #debugging
    @boss.move_index = context.move_index
    @boss.action_index = context.action_index
  end

  def track_camera(args)

    @context.trauma -= CAMERA_TRAUMA_DECAY
    @context.trauma = 0 if @context.trauma < 0

    player_pct = (@player.x.to_f / @world.w.to_f)
    @camera.x = player_pct * 1280
    # @camera.scale = 1
    # args.outputs.primitives << { x: @camera.x, y: @camera.y, text: "Camera #{player_pct} #{@camera.x} #{@camera.y}" }.label!
  end

  def track_collisions(args)
    # what hit the boss?
    boss_hits = @projectiles.select { |p| p.source_id != :boss }.select { |p| p.intersect_rect?(@boss.hitbox) }
    boss_hits.each do |p|
      if @boss.health > 0 && @boss.z < 1
        if @boss.context.phase > Boss::BOSS_START_PHASE
          @boss.damage_at = args.tick_count
          @boss.health_last = @boss.health
          @boss.health -= p.damage # do damage
          @boss.health = @boss.health.clamp(0, Boss::BOSS_MAX_HEALTH)

          # remove bullet
          @projectiles.delete(p)

          args.sfx.play :boss_hit_1
        end
      end
    end

    # what hit the player?
    player_hits = @projectiles.select { |p| p.source_id != :player }.select { |p| p.intersect_rect?(@player.hitbox) }
    player_hits.each do |p|
      if @player.health > 0 && @player.hurt_until < args.tick_count
        Player.take_damage(args, @player, p.damage)

        # remove projectile
        @projectiles.delete(p)
      end
    end

    # allow a lunging boss to hurt the player
    if @player.hurt_until < args.tick_count && @boss.state == :lunge_1 && @player.state != :dead
      if @boss.intersect_rect?(@player.hitbox)
        Player.take_damage(args, @player, Boss::BOSS_DAMAGE_LUNGE)
      end
    end
  end

  def track_npc(args)
    @npc.frame = (@npc.frame + 1) % 4 if @npc.state != :dying && args.tick_count.zmod?(@npc.speed)
  end

  def track_pickups(args)
    # what hit the player?
    pickups = @pickups.select { |p| p.intersect_rect?(@player.hitbox) }
    pickups.each do |p|
      if p.object_type == :coffee && p.state == :full
        p.state = :empty
        @player.caffine_meter += 1.0
        args.sfx.play :player_drink_1
        break
      end
    end
  end

  def track_player(args)
    if @player.state != :dying && @player.state != :dead && @player.health == 0
      # transition to dying
      @player.frame = 1
      @player.state = :dying
      @player.death_at = args.tick_count
    elsif @player.state == :dying && @player.frame == 3
      # transition to dead
      @player.frame = 3
      @player.state = :dead

      transition_to_game_over_lose(args)
    else
      @player.caffine_meter -= Player::PLAYER_CAFFINE_DECAY

      if @player.caffine_meter < 0.0
        # state change to decaffinated
        @player.caffine_meter = 0.0
        if @player.attack_speed == Player::PLAYER_CAFFINATED_ATTACK_SPEED
          @player.attack_speed = Player::PLAYER_NORMAL_ATTACK_SPEED
          @player.speed = Player::PLAYER_NORMAL_SPEED
          @player.stride = Player::PLAYER_NORMAL_STRIDE
          args.sfx.play :player_power_down_1
        end
      elsif @player.caffine_meter > 0.0 && @player.attack_speed == Player::PLAYER_NORMAL_ATTACK_SPEED
        # state change to caffinated
        @player.attack_speed = Player::PLAYER_CAFFINATED_ATTACK_SPEED
        @player.speed = Player::PLAYER_CAFFINATED_SPEED
        @player.stride = Player::PLAYER_CAFFINATED_STRIDE
        args.sfx.play :player_power_up_1
      end
    end

    # ease out to just player, if dead
    if @player.death_at > -1
      ease_val = @player.death_at.ease(150, [:flip, :quad, :flip]) # smoothest start?
      @alive_alpha = 255 * (1 - ease_val)
    end
  end

  def track_projectiles(args)
    i = @projectiles.length

    while i > 0
      i -= 1
      p = @projectiles[i]

      # coffee roaster animation
      if p.object_type == :spike && args.tick_count.zmod?(p.track_speed)
        if p.frame == (p.num_frames - 1)
          p.frame -= 4
        else
          p.frame = (p.frame + 1).clamp(0, p.num_frames - 1)
        end
      end

      p.x += p.speed_x
      p.y += p.speed_y

      if (p.x > (@world.w + 100)) || (p.x < -100) || (p.y > (@world.h + 100)) || (p.y < -100)
        @projectiles.delete_at(i) # remove items out of the world
      end
    end
  end

  def track_thrown(args)
    i = @thrown.length

    while i > 0
      i -= 1
      t = @thrown[i]

      if t.thrown_until <= args.tick_count
        @thrown.delete_at(i)

        t.x = t.thrown_target_xy.x
        t.y = t.thrown_target_xy.y

        @pickups << t
      else
        x_dist = t.thrown_target_xy.x - t.thrown_source_xy.x
        y_dist = t.thrown_target_xy.y - t.thrown_source_xy.y

        ease_val = t.thrown_at.ease(t.thrown_duration, [:quad])
        t.x = t.thrown_source_xy.x + (ease_val * x_dist)
        t.y = t.thrown_source_xy.y + (ease_val * y_dist)
      end
    end
  end

  def tick(args)
    #render/handle/track
    is_paused = @widgets.select { |w| w.modal? == true }.length > 0

    render_scene(args)
    render_boss_health(args)
    render_player_health(args)
    widget_render(args)

    widget_track(args)
    unless is_paused
      track_projectiles(args)
      track_collisions(args)
    end
    track_boss(args) # calls track_boss_logic when not :dead | :dying
    track_player(args) # :dead | :dying
    track_npc(args)
    track_pickups(args)
    track_thrown(args)
    track_camera(args)

    # TBD: Hero Input Handling
    widget_handle_input args
    handle_player_input(args, is_paused)

    #widget cleanup
    widget_cleanup args

    # Debugging
    if $gtk.production == false
      args.state.player = @player if args.tick_count.zmod?(10)
      args.state.boss = @boss if args.tick_count.zmod?(10)
      args.state.game_phases = @game_phases if args.tick_count.zmod?(10)
      args.state.camera = @camera if args.tick_count.zmod?(10)
      args.state.is_paused = is_paused if args.tick_count.zmod?(10)
      args.state.scene.context = @context if args.tick_count.zmod?(10)
      args.state.scene.widgets.length = @widgets.length if args.tick_count.zmod?(10)
      args.state.projectiles = @projectiles if args.tick_count.zmod?(10)
      args.state.pickups = @pickups if args.tick_count.zmod?(10)
      args.state.projectile_zero = (@projectiles.length > 0 ? @projectiles[0] : nil) #if args.tick_count.zmod?(10)
    end
  end

  def transition_to_game_over_lose(args)
    @widgets << GameOverWidget.new(args, :lose)
    @projectiles.clear if @projectiles.length > 0

    now_playing = args.sfx.looping_now?
    args.sfx.stop!(now_playing)
    args.sfx.play(:stinger_lose)
  end

  def transition_to_game_over_win(args)
    @widgets << GameOverWidget.new(args, :win)
    @projectiles.clear if @projectiles.length > 0

    now_playing = args.sfx.looping_now?
    args.sfx.stop!(now_playing)
    args.sfx.play(:stinger_win)
  end

  def transition_to_next_phase
    context = @boss.context
    context.phase += 1 # next phase please
    GameActions.reset_boss_context(context)

    @player.state_shoot_interrupt = false # not resetting this is problematic for movement if player holding key down
    @player.speed = 10
    @player.state = :idle

    @boss.speed = 5
    @boss.state = :idle

    @projectiles.clear
  end

  def widget_cleanup(args)
    # remove completed widgets
    i = @widgets.length - 1
    while i >= 0
      widget = @widgets[i]
      @widgets.delete_at(i) if widget.finished?
      i -= 1
    end

    # create new widgets, if needed
    if !context.dialog_status.nil? && context.dialog_status == :starting
      context.dialog_status = :in_progress
      @widgets << DialogWidget.new(args, context)
    end
  end

  def widget_handle_input(args)
    @widgets.each do |w|
      result = w.handle_input(args)
      if result == :menu
        @gom.app.transition_to(:menu, args)
      end
    end
  end

  def widget_render(args, pipeline = nil)
    pipeline = @pipeline if pipeline.nil?

    @widgets.each do |w|
      w.render(args, pipeline)
    end
  end

  def widget_track(args)
    @widgets.each do |w|
      w.track(args)
    end
  end
end
