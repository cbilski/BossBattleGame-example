class GameActions
  # helper
  def self.face_player(boss, player)
    # face player
    x_diff = (player.x - boss.x).round(0)
    y_diff = (player.y - boss.y).round(0)

    if x_diff.abs > 0
      boss.facing = x_diff < 0 ? :left : :right
    elsif y_diff.abs > 0
      boss.facing = y_diff < 0 ? :down : :up
    end
  end

  def self.boss_cube_setup(args, scene, action, boss, player, world)
    if boss.context.cube_until.nil?
      face_player(boss, player)
      boss.context.cube_until = args.tick_count + action.duration
      boss.context.cube_1_at = args.tick_count
      boss.context.cube_2_at = args.tick_count + (action.duration / 3).to_i
      boss.context.cube_3_at = args.tick_count + (action.duration / 3).to_i * 2
      #scene.projectiles.clear # temp (clear out cubes from last run during dev)
    end

    if boss.context.cube_1_at <= args.tick_count && boss.context.cube_1.nil?
      boss.context.cube_1 = scene.spawn_boss_cube(args, 1)
      args.sfx.play :boss_build_cube_1 if player.health > 0
    end

    if boss.context.cube_2_at <= args.tick_count && boss.context.cube_2.nil?
      boss.context.cube_2 = scene.spawn_boss_cube(args, 2)
      args.sfx.play :boss_build_cube_1 if player.health > 0
    end

    if boss.context.cube_3_at <= args.tick_count && boss.context.cube_3.nil?
      boss.context.cube_3 = scene.spawn_boss_cube(args, 3)
      args.sfx.play :boss_build_cube_1 if player.health > 0
    end

    # wait for duration of move
    result = wait(args, scene, action, boss, player, world)

    # cleanup if done
    if result == :done
      # set vectors according to player
      speed = action.bullet_speed
      # #1 attacks _above_ player
      target = { x: player.x, y: player.y - 256 }
      angle = GTK::Geometry.angle_to(boss.context.cube_2, target).to_radians
      boss.context.cube_1.speed_x = Math.cos(angle) * speed
      boss.context.cube_1.speed_y = Math.sin(angle) * speed
      # #2 attacks player
      target = { x: player.x, y: player.y }
      angle = GTK::Geometry.angle_to(boss.context.cube_2, target).to_radians
      boss.context.cube_2.speed_x = Math.cos(angle) * speed
      boss.context.cube_2.speed_y = Math.sin(angle) * speed
      # #3 attacks _below_ player
      target = { x: player.x, y: player.y + 256 }
      angle = GTK::Geometry.angle_to(boss.context.cube_2, target).to_radians
      boss.context.cube_3.speed_x = Math.cos(angle) * speed
      boss.context.cube_3.speed_y = Math.sin(angle) * speed
      # cleanup context
      boss.context.delete(:cube_until)
      boss.context.delete(:cube_1)
      boss.context.delete(:cube_1_at)
      boss.context.delete(:cube_2)
      boss.context.delete(:cube_2_at)
      boss.context.delete(:cube_3)
      boss.context.delete(:cube_3_at)

      args.sfx.play :boss_attack_phase_3 if player.health > 0
    end

    # return result
    result
  end

  def self.boss_jump_offscreen(args, scene, action, boss, player, world)

    if boss.context.jump_until.nil?
      boss.context.jump_start = args.tick_count
      boss.context.jump_until = args.tick_count + action.duration
      :in_progress
    elsif boss.context.jump_until <= args.tick_count
      boss.context.delete(:jump_start)
      boss.context.delete(:jump_until)
      boss.z = action.z_target
      :done
    else
      ease_val = boss.context.jump_start.ease(action.duration, [:flip, :quad, :flip]) # smoothest start?
      boss.z = ease_val * action.z_target
      :in_progress
    end

  end

  def self.boss_jump_onscreen(args, scene, action, boss, player, world)

    if boss.context.jump_until.nil?
      boss.context.jump_start_z = boss.z
      boss.context.jump_start = args.tick_count
      boss.context.jump_until = args.tick_count + action.duration
      args.sfx.play :boss_attack_phase_2 if player.health > 0
      :in_progress
    elsif boss.context.jump_until <= args.tick_count
      boss.context.delete(:jump_start_z)
      boss.context.delete(:jump_start)
      boss.context.delete(:jump_until)
      boss.z = 0

      scene.context.trauma = Boss::BOSS_LANDS_TRAUMA
      :done
    else
      ease_val = boss.context.jump_start.ease(action.duration, [:quad]) # smoothest start?
      boss.z = boss.context.jump_start_z - (ease_val * boss.context.jump_start_z)
      :in_progress
    end

  end

  def self.boss_jump_prepare(args, scene, action, boss, player, world)
    face_player(boss, player)
    result = wait(args, scene, action, boss, player, world)

    if boss.context.jump_prepare.nil?
      boss.context.jump_prepare = action.state
    elsif result == :done
      if action.state == :jump_prepare_1
        args.sfx.play :boss_jump_1 if player.health > 0
      else
        args.sfx.play :boss_jump_2 if player.health > 0
      end

      boss.context.delete(:jump_prepare)
    end

    result
  end

  def self.boss_lunge_at_player(args, scene, action, boss, player, world)

    if boss.context.lunge_until.nil?
      boss.context.lunge_start = args.tick_count
      boss.context.lunge_until = args.tick_count + action.duration
      args.sfx.play :boss_attack_phase_1 if player.health > 0
      :in_progress
    elsif boss.context.lunge_until <= args.tick_count
      boss.context.delete(:lunge_start)
      boss.context.delete(:lunge_until)
      boss.context.delete(:attack_xy_target)
      boss.context.delete(:attack_xy_from)
      :done
    else
      #boss.context.attack_xy_target
      ease_val = boss.context.lunge_start.ease(action.duration, [:flip, :quad, :flip]) # smoothest start?
      boss.x = boss.context.attack_xy_from.x + ((boss.context.attack_xy_target.x - boss.context.attack_xy_from.x) * ease_val)
      boss.y = boss.context.attack_xy_from.y + ((boss.context.attack_xy_target.y - boss.context.attack_xy_from.y) * ease_val)
      :in_progress
    end

  end

  def self.boss_moveto_xy(args, scene, action, boss, player, world)
    stride = 0.7 * boss.stride # dir vector * stride
    # stride = 1.0 * boss.stride

    target = boss.context.move_xy_target
    return :done if target.nil?

    x_diff = (target.x - boss.x)
    y_diff = (target.y - boss.y)

    if x_diff.abs > stride && y_diff.abs > stride
      boss.x += ((x_diff < 0 ? -1 : 1) * stride)
      boss.y += ((y_diff < 0 ? -1 : 1) * stride)
      boss.facing = y_diff < 0 ? :down : :up
    elsif x_diff.abs > stride
      boss.x += ((x_diff < 0 ? -1 : 1) * stride)
      boss.facing = x_diff < 0 ? :left : :right
    elsif y_diff.abs > stride
      boss.y += ((y_diff < 0 ? -1 : 1) * stride)
      boss.facing = y_diff < 0 ? :down : :up
    else
      boss.context.delete(:move_xy_target)
      return :done
    end

    #boss.context.move_x_diff = x_diff
    #boss.context.move_y_diff = y_diff

    :in_progress
  end

  def self.boss_select_xy(args, scene, action, boss, player, world)
    #boss.speed = 4
    boss.stride = boss.speed * 2.5
    #                 X   Y
    #     top/left:  256 578
    #  bottom/left:  256  88
    # bottom/right: 1726  88
    # bottom/right: 1726 578

    if action.limit.nil?
      x = $gtk.rand(1726 - 256) + 256
      y = $gtk.rand(578 - 88) + 88
    else
      x_dist = rand(action.limit)
      y_dist = rand(action.limit)
      case rand(4)
      when 0
        # normal
      when 1
        x_dist *= -1
      when 2
        y_dist *= -1
      else
        x_dist *= -1
        y_dist *= -1
      end

      x = (boss.x + x_dist).clamp(256, 1726)
      y = (boss.y + y_dist).clamp(88, 578)
    end

    boss.context.move_xy_target = { x: x, y: y }
    :done
  end

  def self.boss_spike_attack(args, scene, action, boss, player, world)

    # setup
    if boss.context.attack_start_at.nil?
      boss.context.attack_start_at = args.tick_count
      face_player(boss, player)
    end

    result = wait(args, scene, action, boss, player, world)

    if result == :done
      # cleanup
      boss.context.delete(:attack_start_at)
    else
      #scene.create_spikes(args)
      if player.health > 0.0
        scene.spawn_spikes(args, :left)
        scene.spawn_spikes(args, :right)
        scene.spawn_spikes(args, :up)
        scene.spawn_spikes(args, :down)
      end
    end

    result
  end

  def self.boss_target_player_xy(args, scene, action, boss, player, world)
    boss.context.move_xy_target = { x: player.x, y: player.y }
    :done
  end

  def self.boss_wait(args, scene, action, boss, player, world)
    #boss.speed = 12

    wait(args, scene, action, boss, player, world)
  end

  def self.boss_wait_for_player(args, scene, action, boss, player, world)
    result = player.x > 880 ? :next_phase : :in_progress

    if result == :next_phase
      now_playing = args.sfx.looping_now?
      args.sfx.stop!(now_playing)
      args.sfx.loop(:music_fight_1)
      args.sfx.loop_to(:music_fight_1, :music_fight_2)
    end

    result
  end

  def self.boss_wind_up(args, scene, action, boss, player, world)
    # select attack position
    if boss.context.attack_xy_target.nil? || (!action.target_interval.nil? && args.tick_count.zmod?(action.target_interval))
      boss.context.attack_xy_target = { x: player.x, y: player.y }
      boss.context.attack_xy_from = { x: boss.x, y: boss.y }
    end

    face_player(boss, player)

    # shake in place
    offset_range = boss.state == :wind_up_1 ? 12 : 24
    boss.render_offset.x = rand(offset_range) - (offset_range / 2.0)
    boss.render_offset.y = rand(offset_range) - (offset_range / 2.0)

    # wait for duration of move
    result = wait(args, scene, action, boss, player, world)

    if boss.context.boss_wind_up_sfx.nil?
      boss.context.boss_wind_up_sfx = true
      if player.health > 0
        args.sfx.play action.state == :wind_up_1 ? :boss_prepare_1 : :boss_prepare_2
      end
    end

    boss.context.delete(:boss_wind_up_sfx) if result == :done

    # reset shake offset if done
    boss.render_offset = { x: 0, y: 0 } if result == :done

    # return result
    result
  end

  def self.dialog_init(args, scene, action, boss, player, world)
    if scene.context.dialog_start_at.nil?
      scene.context.dialog_start_at = args.tick_count
      scene.context.dialog_status = :starting
      scene.context.dialog_id = action.dialog_id
      :done
    else
      :error # we really should never find a different condition
    end
  end

  def self.dialog_wait(args, scene, action, boss, player, world)
    if !scene.context.dialog_status.nil? && scene.context.dialog_status != :done
      :in_progress
    else
      scene.context.delete(:dialog_start_at)
      scene.context.delete(:dialog_status)
      scene.context.delete(:dialog_id)
      :next_phase
    end
  end

  def self.fade_in_background(args, scene, action, boss, player, world)

    if scene.context.background_fade_in_at.nil?
      scene.context.background_fade_in_at = args.tick_count
    end

    # wait for duration of move
    result = wait(args, scene, action, boss, player, world)

    scene.context.background_fade_in = 255 * scene.context.background_fade_in_at.ease(action.duration)

    # return result
    if result == :done
      scene.context.delete(:background_fade_in_at)
      return :next_phase
    else
      return result
    end
  end

  def self.fade_in_npc(args, scene, action, boss, player, world)

    if scene.context.npc_fade_in_at.nil?
      scene.context.npc_fade_in_at = args.tick_count
    end

    # wait for duration of move
    result = wait(args, scene, action, boss, player, world)

    scene.context.npc_fade_in = 255 * scene.context.npc_fade_in_at.ease(action.duration)

    # return result
    if result == :done
      scene.context.npc_fade_in = 255
      scene.context.delete(:npc_fade_in_at)
      return :next_phase
    else
      return result
    end
  end

  def self.fade_in_player(args, scene, action, boss, player, world)

    if scene.context.player_fade_in_at.nil?
      scene.context.player_fade_in_at = args.tick_count
    end

    # wait for duration of move
    result = wait(args, scene, action, boss, player, world)

    scene.context.player_fade_in = 255 * scene.context.player_fade_in_at.ease(action.duration)

    # return result
    if result == :done
      scene.context.delete(:player_fade_in_at)
      return :next_phase
    else
      return result
    end
  end

  def self.fade_in_ui(args, scene, action, boss, player, world)

    if scene.context.ui_fade_in_at.nil?
      scene.context.ui_fade_in_at = args.tick_count
    end

    # wait for duration of move
    result = wait(args, scene, action, boss, player, world)

    scene.context.ui_fade_in = 255 * scene.context.ui_fade_in_at.ease(action.duration)

    # return result
    if result == :done
      scene.context.delete(:ui_fade_in_at)
      return :next_phase
    else
      return result
    end
  end

  def self.music_change(args, scene, action, boss, player, world)
    now_playing = args.sfx.looping_now?

    if now_playing != action.sound_id
      args.sfx.stop!(now_playing)
      args.sfx.loop(action.sound_id)
    end

    :done
  end

  def self.npc_throw_coffee(args, scene, action, boss, player, world)
    return :done if $flags[:hide_boss] == true
    thrown_x = $gtk.rand(1726 - 256) + 256
    thrown_y = $gtk.rand(578 - 88) + 88
    scene.context.ui_fade_in = 255 # sanity check: something broken here
    scene.spawn_coffee_thrown(args, 96, 48, thrown_x, thrown_y, 50)
    :done
  end

  def self.phase_set_target(args, scene, action, boss, player, world)
    boss.context.phase_next_at = action.phase_next_at
    :done
  end

  def self.reset_boss_context(context)
    context.move = nil
    context.action = nil
    context.move_index = -1
    context.action_index = -1
  end

  #helper
  def self.wait(args, scene, action, boss, player, world)
    #boss.speed = 12

    # common function: advance phase if boss health reaches phase target
    if boss.health <= boss.context.phase_next_at
      boss.context.phase_next_at = 0 # fix later
      return :next_phase
    end

    # wait
    if boss.context.wait_until.nil?
      boss.context.wait_until = args.tick_count + action.duration
      :in_progress
    elsif boss.context.wait_until <= args.tick_count
      boss.context.delete(:wait_until)
      :done
    else
      :in_progress
    end
  end
end
