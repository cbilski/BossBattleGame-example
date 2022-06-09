class GamePhases
  def self.create_phases

    phase_defs = []

    # Phase 0: fade player in
    phase_defs << {
      moves: [
        {
          id: :fade_in_player,
          actions: [
            { id: :intro_music_1, type: :music_change, state: :idle, sound_id: :music_intro_1 },
            { id: :fade_in_1, type: :fade_in_player, state: :idle, duration: 50 }, # wait for player to move onto screen: boss takes no dmg
          ]
        }
      ]
    }
    # Phase 0: intro dialog
    phase_defs << {
      moves: [
        {
          id: :dialog_1,
          actions: [
            { id: :dialog_init_1, type: :dialog_init, dialog_id: :dialog_text_1,  state: :idle }, # wait for player to move onto screen: boss takes no dmg
            { id: :dialog_wait_1, type: :dialog_wait, state: :idle }, # wait for player to move onto screen: boss takes no dmg
          ]
        }
      ]
    }
    # Phase 0: fade in ui
    phase_defs << {
      moves: [
        {
          id: :fade_in_ui,
          actions: [
            { id: :fade_in_1, type: :fade_in_ui, state: :idle, duration: 50 }, # wait for player to move onto screen: boss takes no dmg
          ]
        }
      ]
    }
    # Phase 0: fade in background
    phase_defs << {
      moves: [
        {
          id: :fade_in,
          actions: [
            { id: :fade_in_1, type: :fade_in_background, state: :idle, duration: 50 }, # wait for player to move onto screen: boss takes no dmg
          ]
        }
      ]
    }
    # Phase 1: boss waits for player to move to that side of map
    phase_defs << {
      moves: [
        {
          id: :wait_for_player,
          actions: [
            { id: :intro_music_2, type: :music_change, state: :idle, sound_id: :music_intro_2 },
            { id: :next_phase_at, type: :phase_set_target, phase_next_at: 80, state: :idle}, # when boss health at 75%, transition to next phase (wait actions test this threshold)
            { id: :wait_offscreen, type: :boss_wait_for_player, state: :idle}, # wait for player to move onto screen: boss takes no dmg
          ]
        }
      ]
    }
    # Phase 1: boss logic
    phase_defs << {
      moves: [
        {
          id: :move_away_from_player,
          actions: [
            { id: :random_target, type: :boss_select_xy, state: :idle, speed: 4,    limit: 100 }, # places target information in context (moveto_xy {x,y})
            { id: :moveto_target, type: :boss_moveto_xy, state: :run,  speed: 5 },                # moves to location in context (moveto_xy {x,y})
            { id: :wait,          type: :boss_wait,      state: :idle, speed: 12, duration: 25 }  # wait until context.duration == duration
          ]
        },
        {
          id: :lunge_punch,
          actions: [
            { id: :wind_up_1,    type: :boss_wind_up,         state: :wind_up_1, speed:   1, duration: 50, target_interval: 25 }, # wait until context.duration == duration, apply x/y offsets for shake effect
            { id: :wind_up_2,    type: :boss_wind_up,         state: :wind_up_2, speed:   1, duration: 25, target_interval: 25 }, # wait until context.duration == duration, apply x/y offsets for shake effect
            { id: :lunge,        type: :boss_lunge_at_player, state: :lunge_1,   speed:   1, duration: 25 },                      # move to context.attack_xy_target
            { id: :wait,         type: :boss_wait,            state: :idle,      speed:  12, duration: 25 },
          ]
        }
      ],
    }
    # Phase 2: boss dialog
    phase_defs << {
      moves: [
        {
          id: :dialog_2,
          actions: [
            { id: :next_phase_at, type: :phase_set_target, phase_next_at: 60, state: :idle}, # when boss health at 75%, transition to next phase (wait actions test this threshold)
            { id: :dialog_init_2, type: :dialog_init, dialog_id: :dialog_text_2,  state: :idle }, # wait for player to move onto screen: boss takes no dmg
            { id: :dialog_wait_2, type: :dialog_wait, state: :idle }, # wait for player to move onto screen: boss takes no dmg
          ]
        }
      ]
    }
    # Phase 2: boss logic
    phase_defs << {
      moves: [
        {
          id: :bean_roaster_attack,
          actions: [
            { id: :jump_prepare_1, type: :boss_jump_prepare,     state: :jump_prepare_1, speed: 4, duration: 50 },
            { id: :jump_prepare_2, type: :boss_jump_prepare,     state: :jump_prepare_2, speed: 4, duration: 50 },
            { id: :jump_offscreen, type: :boss_jump_offscreen,   state: :jump_up,        speed: 1, duration: 100, z_target: 2000 },
            { id: :target_player,  type: :boss_target_player_xy, state: :idle, },
            { id: :moveto_player,  type: :boss_moveto_xy,        state: :idle, speed: 1 },
            { id: :jump_onscreen,  type: :boss_jump_onscreen,    state: :jump_down, speed: 1, duration: 100 },
            { id: :spike_attack,   type: :boss_spike_attack,     state: :idle, speed: 4, duration: 100 },
            { id: :wait,           type: :boss_wait,             state: :idle, speed: 12, duration: 25 },
          ]
        }
      ]
    }
    # Phase 3: fade in NPC
    phase_defs << {
      moves: [
        {
          id: :dialog_3,
          actions: [
            { id: :fade_in_1,     type: :fade_in_npc, state: :idle, duration: 25 }, # wait for player to move onto screen: boss takes no dmg
          ]
        }
      ]
    }
    # Phase 3: boss dialog
    phase_defs << {
      moves: [
        {
          id: :dialog_3,
          actions: [
            { id: :next_phase_at, type: :phase_set_target, phase_next_at: 40, state: :idle}, # when boss health at 75%, transition to next phase (wait actions test this threshold)
            { id: :dialog_init_3, type: :dialog_init, dialog_id: :dialog_text_3,  state: :idle }, # wait for player to move onto screen: boss takes no dmg
            { id: :dialog_wait_2, type: :dialog_wait, state: :idle },
          ]
        }
      ]
    }
    # Phase 3: boss logic
    phase_defs << {
      moves: [
        {
          id: :spawn_coffee,
          actions: [
            { id: :npc_throw_coffee, type: :npc_throw_coffee, state: :idle, speed: 4, duration: 50 },
          ]
        },
        {
          id: :artificial_sweetener_attack,
          actions: [
            { id: :spawn_cubes, type: :boss_cube_setup, state: :attack, speed: 4, duration: 64, bullet_speed: 8 }, #128 },
            { id: :random_target, type: :boss_select_xy, state: :idle, speed: 4,  limit: 100 }, # places target information in context (moveto_xy {x,y})
            { id: :moveto_target, type: :boss_moveto_xy, state: :run,  speed: 5 },                # moves to location in context (moveto_xy {x,y})
            { id: :wait,          type: :boss_wait,      state: :idle, speed: 12, duration: 25 }  # wait until context.duration == duration
          ]
        },
      ]
    }
    # Phase 4: boss dialog
    phase_defs << {
      moves: [
        {
          id: :dialog_4,
          actions: [
            { id: :dialog_init_4, type: :dialog_init, dialog_id: :dialog_text_4,  state: :idle }, # wait for player to move onto screen: boss takes no dmg
            { id: :dialog_wait_4, type: :dialog_wait, state: :idle }, # wait for player to move onto screen: boss takes no dmg
          ]
        }
      ]
    }
    # Phase 4: boss logic
    phase_defs << {
      moves: [
        {
          id: :lunge_punch,
          actions: [
            { id: :wind_up_1,    type: :boss_wind_up,         state: :wind_up_1, speed:   1, duration: 50, target_interval: 25 }, # wait until context.duration == duration, apply x/y offsets for shake effect
            { id: :wind_up_2,    type: :boss_wind_up,         state: :wind_up_2, speed:   1, duration: 25, target_interval: 25 }, # wait until context.duration == duration, apply x/y offsets for shake effect
            { id: :lunge,        type: :boss_lunge_at_player, state: :lunge_1,   speed:   1, duration: 25 },                      # move to context.attack_xy_target
            { id: :wait,         type: :boss_wait,            state: :idle,      speed:  12, duration: 25 },
          ]
        },
        {
          id: :spawn_coffee,
          actions: [
            { id: :npc_throw_coffee, type: :npc_throw_coffee, state: :idle, speed: 4, duration: 50 },
          ]
        },
        {
          id: :bean_roaster_attack,
          actions: [
            { id: :jump_prepare_1, type: :boss_jump_prepare,     state: :jump_prepare_1, speed: 4, duration: 50 },
            { id: :jump_prepare_2, type: :boss_jump_prepare,     state: :jump_prepare_2, speed: 4, duration: 50 },
            { id: :jump_offscreen, type: :boss_jump_offscreen,   state: :jump_up,        speed: 1, duration: 100, z_target: 2000 },
            { id: :target_player,  type: :boss_target_player_xy, state: :idle, },
            { id: :moveto_player,  type: :boss_moveto_xy,        state: :idle, speed: 1 },
            { id: :jump_onscreen,  type: :boss_jump_onscreen,    state: :jump_down, speed: 1, duration: 100 },
            { id: :spike_attack,   type: :boss_spike_attack,     state: :idle, speed: 4, duration: 100 },
            { id: :wait,           type: :boss_wait,             state: :idle, speed: 12, duration: 25 },
          ]
        },
        {
          id: :spawn_coffee,
          actions: [
            { id: :npc_throw_coffee, type: :npc_throw_coffee, state: :idle, speed: 4, duration: 50 },
          ]
        },
        {
          id: :move_away_from_player,
          actions: [
            { id: :random_target, type: :boss_select_xy, state: :idle, speed: 4,    limit: 100 }, # places target information in context (moveto_xy {x,y})
            { id: :moveto_target, type: :boss_moveto_xy, state: :run,  speed: 5 },                # moves to location in context (moveto_xy {x,y})
            { id: :wait,          type: :boss_wait,      state: :idle, speed: 12, duration: 25 }  # wait until context.duration == duration
          ]
        },
        {
          id: :artificial_sweetener_attack,
          actions: [
            { id: :spawn_cubes, type: :boss_cube_setup, state: :attack, speed: 4, duration: 64, bullet_speed: 8 }, #128 },
            { id: :random_target, type: :boss_select_xy, state: :idle, speed: 4,  limit: 100 }, # places target information in context (moveto_xy {x,y})
            { id: :moveto_target, type: :boss_moveto_xy, state: :run,  speed: 5 },                # moves to location in context (moveto_xy {x,y})
            { id: :wait,          type: :boss_wait,      state: :idle, speed: 12, duration: 25 }  # wait until context.duration == duration
          ]
        },
        {
          id: :spawn_coffee,
          actions: [
            { id: :npc_throw_coffee, type: :npc_throw_coffee, state: :idle, speed: 4, duration: 50 },
          ]
        },
      ]
    }

    # add phases to phase map with unique IDs
    phases = {}
    phase_defs.each_with_index do |phase, index|
      phases[index] = phase
    end
    phases
  end
end
