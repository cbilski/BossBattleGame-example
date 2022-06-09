class Sfx
  attr_accessor :heli_engine_low_pitch
  attr_accessor :queued
  attr_accessor :loop_watcher

  attr_reader :music_mast
  attr_reader :sfx_mast

  def initialize(args)
    @args = args
    @music_mast = 0.5
    @sfx_mast = 0.5
    @loop_watcher = []

    @mech_shoot_index = 0
    @mech_shoot_max = 2

    @mech_bullet_explode_index = 0
    @mech_bullet_explode_max = 3

    @mech_impact_index = 0
    @mech_impact_max = 2

    @heli_engine_low_pitch = 0.72

    @queued = []
    @last_played = -5
  end

  def music_mast=(level)
    @music_mast = level.clamp(0, 1.0)
    @args.audio.each do |key, value|
      if value.type == :music
        value.gain = @music_mast * value.vol
        value.changed_at = @args.tick_count # debugging only
      end
    end
  end

  def sfx_mast=(level)
    @sfx_mast = level.clamp(0, 1.0)
    @args.audio.each do |key, value|
      if value.type == :sfx
        value.gain = @sfx_mast * value.vol
        value.changed_at = @args.tick_count # debugging only
      end
    end
  end

  def stop(sound_id)
    pause(sound_id)
    # if @args.audio.key?(sound_id)
    #   @args.audio.delete(sound_id)
    # end
  end

  def stop!(sound_id)
    if @args.audio.key?(sound_id)
      @args.audio.delete(sound_id)
    end
  end

  def pause(sound_id)
    if @args.audio.key?(sound_id)
      @args.audio[sound_id][:paused] = true
    end
  end

  def resume(sound_id)
    if @args.audio.key?(sound_id)
      @args.audio[sound_id][:paused] = false
    end
  end

  def loop(sound_id, queue: true)
    if @args.audio.key?(sound_id)
      resume(sound_id)
    end

    sound_data = nil
    sounds = {
      :dialog_text_1 => { type: :sfx,   vol: 0.50, pitch: 1.0, input: "sounds/dialog/chrislsound.itch.io-textdialoguesfxpack/subTri_2b.wav" },
      :music_menu_1  => { type: :music, vol: 0.25, pitch: 1.0, input: "sounds/music/cyberleaf.itch.io-chiptunesmusicandsfxpack/AdventureAwaits(loop)(124).wav" },
      :music_intro_1 => { type: :music, vol: 0.25, pitch: 1.0, input: "sounds/music/cyberleaf.itch.io-chiptunesmusicandsfxpack/MeetTheBoss_Approaching(loop)(90).wav" },
      :music_intro_2 => { type: :music, vol: 0.25, pitch: 1.0, input: "sounds/music/cyberleaf.itch.io-chiptunesmusicandsfxpack/MeetTheBoss_Fight(loop)(90).wav" },
      :music_fight_1 => { type: :music, vol: 0.25, pitch: 1.0, input: "sounds/music/cyberleaf.itch.io-chiptunesmusicandsfxpack/TheBossBattle(loop-intro).wav" },
      :music_fight_2 => { type: :music, vol: 0.25, pitch: 1.0, input: "sounds/music/cyberleaf.itch.io-chiptunesmusicandsfxpack/TheBossBattle(loop)(75).wav" },
    }

    if sounds.key?(sound_id)
      sound = sounds[sound_id]
      gain = (sound.type == :music ? @music_mast : @sfx_mast) * sound.vol
      sound_data = [sound_id, { input: sound.input, gain: gain, pitch: sound.pitch, looping: true, paused: false, vol: sound.vol, type: sound.type }]
    else
      # special case logic
      # case sound_id
      # when :heli_engine_low
      #   loopee = @args.audio[sound_id]
      #   if loopee.nil?
      #     vol = 0.20
      #     sound_data = [sound_id, { type: :sfx, input: "/sounds/heli/opengameart.org-helicopter-sounds-helicopter.wav", gain: @sfx_mast * vol, pitch: @heli_engine_low_pitch, looping: true, paused: false, vol: vol }]
      #   end
      # when :heli_engine_high
      #   loopee = @args.audio[sound_id]
      #   if loopee.nil?
      #     vol = 0.25
      #     sound_data = [sound_id, { type: :sfx, input: "/sounds/heli/opengameart.org-helicopter-sounds-helicopter.wav", gain: @sfx_mast * vol, pitch: 1.5, looping: true, paused: false, vol: vol }]
      #   end
      # else
      # end
      raise "args.sfx.loop: Unknown loop #{sound_id}!"
    end

    if queue
      if sound_data != nil
        @queued << sound_data
      end
    else
      @args.audio[sound_data[0]] = sound_data[1]
    end
  end

  def looping?(sound_id)
    result = false

    if @args.audio.key?(sound_id)
      result = @args.audio[sound_id].looping == true
    end

    result
  end

  def looping_now?
    result = :no_loop
    # issue: only returns one looper (need to rework with tag to find :music vs. :stinger, :ambient, etc.)
    @args.audio.each do |sound_id, sound_data|
      if sound_data.looping == true
        result = sound_id
        break
      end
    end

    result
  end

  def loop_to(sound_id1, sound_id2)
    @loop_watcher << [sound_id1, sound_id2] # change to sound_id2 after sound_id1 is gone
  end

  def play(sound_id)
    return unless @queued.length < 5

    sounds = {
      :boss_attack_phase_1 => { type: :sfx, vol: 0.80, pitch: 1.0, input: "sounds/attack/prosoundcollection/retro_impact_hit_general_01.wav" },
      :boss_attack_phase_2 => { type: :sfx, vol: 0.80, pitch: 1.0, input: "sounds/attack/esm-Blockbuster_Trailer/FlameThrower_Hit_4_with_Swell.wav" },
      :boss_attack_phase_3 => { type: :sfx, vol: 0.80, pitch: 1.0, input: "sounds/attack/prosoundcollection/retro_impact_colorful_02.wav" },
      :boss_build_cube_1 => { type: :sfx, vol: 0.80, pitch: 1.0, input: "sounds/attack/prosoundcollection/retro_impact_colorful_08.wav" },
      :boss_hit_1 => { type: :sfx, vol: 0.50, pitch: 1.0, input: "sounds/hit/prosoundcollection/retro_impact_hit_11.wav" },
      :boss_jump_1 => { type: :sfx, vol: 0.50, pitch: 1.0, input: "sounds/jump/prosoundcollection/retro_jump_bounce_01.wav" },
      :boss_jump_2 => { type: :sfx, vol: 0.50, pitch: 1.0, input: "sounds/jump/prosoundcollection/retro_jump_bounce_02.wav" },
      :boss_prepare_1 => { type: :sfx, vol: 0.50, pitch: 1.0, input: "sounds/attack/prosoundcollection/retro_powerup_collect_27.wav" },
      :boss_prepare_2 => { type: :sfx, vol: 0.50, pitch: 1.0, input: "sounds/attack/prosoundcollection/retro_powerup_collect_28.wav" },
      :game_enter => { type: :sfx, vol: 0.50, pitch: 1.0, input: "" }, # TBD:?
      :player_hurt_1 => { type: :sfx, vol: 1.0, pitch: 1.0, input: "sounds/hurt/prosoundcollection/retro_damage_hurt_ouch_56.wav" },
      :player_power_down_1 => { type: :sfx, vol: 1.0, pitch: 1.0, input: "sounds/power_up/esm-Mobile Game/Power Down Pickup 1.wav" },
      :player_power_up_1 => { type: :sfx, vol: 1.0, pitch: 1.0, input: "sounds/power_up/esm-Mobile Game/Blocky Power Up 2.wav" },
      :splash_transition_1 => { type: :sfx, vol: 0.8, pitch: 1.0, input: "sounds/transitions/War_UI_MenuFuturistic_Menu_Rounded_Transition_1.wav" },
      :splash_transition_2 => { type: :sfx, vol: 0.8, pitch: 1.0, input: "sounds/transitions/War_UI_MenuFuturistic_Menu_Rounded_Transition_2.wav" },
      :stinger_win => { type: :music, vol: 0.35, pitch: 1.0, input: "sounds/music/cyberleaf.itch.io-chiptunesmusicandsfxpack/Stinger_Success6.wav" },
      :stinger_lose => { type: :music, vol: 0.35, pitch: 1.0, input: "sounds/music/cyberleaf.itch.io-chiptunesmusicandsfxpack/Stinger_Fail2.wav" },
    }

    if sounds.key?(sound_id)
      sound = sounds[sound_id]
      gain = (sound.type == :music ? @music_mast : @sfx_mast) * sound.vol
      sound_data = [sound_id, { input: sound.input, gain: gain, pitch: sound.pitch, looping: false, paused: false, vol: sound.vol }]
    else
      # special case logic (randomize SFX, etc.)
      #
      case sound_id
      when :player_attack_1, :menu_item_changed
        wav_vol = 0.9
        rand_id = rand(4) + 1
        sound_data = [sound_id, { type: :sfx, input: "sounds/attack/esm-16bit_Builder_Game/Builder_Game_Weapon_Arrow_Fire_#{rand_id}.wav", gain: @sfx_mast * wav_vol, pitch: 1.0, looping: false, paused: false, vol: wav_vol }]
      when :player_drink_1
        wav_vol = 0.9
        rand_id = rand(2) + 1
        sound_data = [sound_id, { type: :sfx, input: "sounds/drink/inventorysoundspack/Drink_0#{rand_id}.wav", gain: @sfx_mast * wav_vol, pitch: 1.0, looping: false, paused: false, vol: wav_vol }]
      else
        raise "args.sfx.play: Unknown sound #{sound_id}!"
      end
    end

    if sound_data != nil
      @queued << sound_data
    end
  end

  def tick(args)
    @args = args

    if @queued.length > 0
      tick_count = args.state.tick_count
      tick_diff = tick_count - @last_played
      if tick_diff > 4
        @last_played = tick_count
        sound_data = @queued[0]
        @queued.delete_at(0)
        args.audio[sound_data[0]] = sound_data[1]
      end
    end

    if @loop_watcher.length > 0
      music_data = @loop_watcher[0]
      if args.audio.key?(music_data[0]) == false
        loop(music_data[1], queue: false)
        @loop_watcher.delete_at(0)
      else
        @args.audio[music_data[0]][:looping] = false # stop looping sound_id1
      end
    end

    if $gtk.production == false
      args.state.audio = args.audio if args.tick_count.zmod?(10)
      args.state.sfx_mast = @sfx_mast if args.tick_count.zmod?(10)
      args.state.music_mast = @music_mast if args.tick_count.zmod?(10)
    end
  end
end
