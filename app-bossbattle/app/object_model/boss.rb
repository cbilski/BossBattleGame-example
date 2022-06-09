class Boss
  BOSS_MAX_HEALTH = 100
  BOSS_START_PHASE = 4
  BOSS_DAMAGE_CUBE = 0.5 # player has 6 health
  BOSS_DAMAGE_LUNGE = 0.5 # player has 6 health
  BOSS_DAMAGE_SPIKE = 0.25 # player has 6 health
  BOSS_LANDS_TRAUMA = 0.70

  def self.create_boss
    boss = {
      x: (2048 / 3) * 2, y: 304, z: 0, w: 256, h: 256,
      size: 256,
      damage_at: 0,
      death_at: -1,
      health: BOSS_MAX_HEALTH,
      health_last: BOSS_MAX_HEALTH,
      facing: :left,
      state: :idle, # :dying, :dead, :run, :attack
      frame: 0,
      speed: 5, stride: 9,
      move_index: -1,
      action_index: -1,
      context: {
        phase: 0,
        phase_next_at: 0, #health
        move: nil,
        move_index: -1,
        action: nil,
        action_index: -1
      },
      render_offset: {x: 0, y: 0}
    }

    update(boss)

    boss
  end

  def self.update(boss)
    boss.hitbox = {x: boss.x + 72, y: boss.y + 40, h: boss.h - 112, w: boss.w - 144}
  end
end
