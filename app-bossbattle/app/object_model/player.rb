class Player
  PLAYER_MAX_HEALTH = 6
  PLAYER_SIZE = 128
  PLAYER_ARROW_DAMAGE = 0.625 # use 5 for phase testing
  PLAYER_NORMAL_SPEED = 9
  PLAYER_NORMAL_STRIDE = 9
  PLAYER_NORMAL_ATTACK_SPEED = 5
  PLAYER_CAFFINATED_SPEED = 9
  PLAYER_CAFFINATED_STRIDE = 13
  PLAYER_CAFFINATED_ATTACK_SPEED = 3
  PLAYER_CAFFINE_DECAY = 0.006

  def self.create_player
    player = {
      x: 2048 / 8,
      y: 320,
      w: PLAYER_SIZE,
      h: PLAYER_SIZE,
      size: PLAYER_SIZE,
      caffine_meter: 0.0,
      death_at: -1,
      facing: :down,
      frame: 0,
      health: PLAYER_MAX_HEALTH,
      health_shake: 0,
      hurt_duration: 25,
      hurt_until: 0,
      state: :idle, # :run, :attack
      state_shoot_interrupt: false,
      attack_speed: PLAYER_NORMAL_ATTACK_SPEED,
      speed: PLAYER_NORMAL_SPEED,
      stride: PLAYER_NORMAL_STRIDE,
    }

    update(player)

    player
  end

  def self.update(player)
    player.hitbox = {x: player.x + 32, y: player.y + 16, h: player.h - 32, w: player.w - 64}
  end

  def self.take_damage(args, player, amount)
    player.hurt_until = args.tick_count + player.hurt_duration
    player.health = (player.health - amount).clamp(0, PLAYER_MAX_HEALTH)
    args.sfx.play :player_hurt_1
  end
end
