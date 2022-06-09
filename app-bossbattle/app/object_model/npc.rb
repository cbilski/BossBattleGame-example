class Npc
  NPC_SIZE = 128

  def self.create_npc
    {
      x: 8,
      y: 8,
      w: NPC_SIZE,
      h: NPC_SIZE,
      size: NPC_SIZE,
      caffine_meter: 0.0,
      death_at: -1,
      facing: :up,
      frame: 0,
      health: 999999,
      health_shake: 0,
      hurt_duration: 25,
      hurt_until: 0,
      state: :idle, # :run, :attack
      state_shoot_interrupt: false,
      attack_speed: 0,
      speed: 8,
      stride: 0,
    }
  end
end
