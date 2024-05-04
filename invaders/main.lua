-- entity object; used for size computation 
function Entity()
    local entity = {}
    entity.width = 64
    entity.height = 64
    return entity
end

-- player object
function Player()
    local player = {}
    player.width = entity.width
    player.height = entity.height
    player.x = screen.width / 2
    player.y = screen.height / 10 * 8
    player.dx = 300
    player.image = love.graphics.newImage("player.png")
    return player
end

-- enemy object
function Enemy(index)
    local enemy = {}
    enemy.width = entity.width
    enemy.height = entity.height
    enemy.x = enemy.width * 2  * (1 + ((index - 1) % row_enemies))
    enemy.y = screen.height / 10 + enemy.height * 1.4 * math.floor((index - 1) / row_enemies)
    enemy.dx = 100 + 10 * waves
    enemy.dy = enemy.height * 1.4
    enemy.image = love.graphics.newImage("enemy.png")
    enemy.sound = love.audio.newSource("explosion.wav", "stream")
    enemy.sound:setVolume(0.2)
    return enemy
end

-- bullet object
function Bullet()
    local bullet = {}
    bullet.width = entity.width / 4
    bullet.height = entity.height / 2
    bullet.x = player.x + player.width / 4
    bullet.y = player.y - player.height
    bullet.dy = 300 + 10 * waves
    bullet.image = love.graphics.newImage("bullet.png")
    bullet.sound = love.audio.newSource("laser.wav", "stream")
    return bullet
end

-- score object
function Score()
    local score = {}
    score.value = 0
    score.x = screen.width / 20
    score.y = screen.height / 20
    score.font = love.graphics.newFont(32)
    return score
end

-- background object
function Background()
    local background = {}
    background.image = love.graphics.newImage("background.png")
    background.music = love.audio.newSource("background.wav", "stream")
    background.music:setVolume(0.3)
    background.music:setLooping(true)
    return background
end

-- screen object; used to store dimensions
function Screen()
    local screen = {}
    screen.width, screen.height = love.graphics.getDimensions()
    return screen
end

-- spawn enemies
function spawn()
    for i=1, start_enemies + waves / 3 do
        enemies[i] = Enemy(i)
    end
end

-- detect collision
function collision(object, bullet)
    return object.x < bullet.x + bullet.width and
           bullet.x < object.x + object.width and
           object.y < bullet.y + bullet.height and
           bullet.y < object.y + object.height
end

function over()
    background.music:stop()
    love.graphics.clear()
    caption = {}
    caption.value = "Game Over.\nYour Score is "..score.value
    caption.font = love.graphics.newFont(32)
    caption.x = screen.width / 3
    caption.y = screen.height / 2
    love.graphics.print(caption.value, caption.font, caption.x, caption.y)
    love.graphics.present()
end

-- initialize game environment
function love.load()
    screen = Screen()
    entity = Entity()
    player = Player()
    score  = Score()
    background = Background()
    enemies = {}
    bullets = {}
    cooldown = 0
    waves = 0
    row_enemies = 5
    start_enemies = row_enemies * 2
    love.audio.play(background.music)
end

-- update entities positions
function love.update(dt)
    -- handle input
    if love.keyboard.isDown("left") and player.x > 0 then
        player.x = player.x - player.dx * dt
    end if  love.keyboard.isDown("right")  and
            player.x < screen.width - player.width then
        player.x = player.x + player.dx * dt
    end if love.keyboard.isDown("space") and
           love.timer.getTime() - cooldown > 1 then
        bullets[#bullets+1] = Bullet()
        local bullet = bullets[#bullets]
        cooldown = love.timer.getTime()
        love.audio.play(bullet.sound)
    end if love.keyboard.isDown("escape") then
        love.event.quit()
    end

    -- spawn enemies if none
    if #enemies == 0 then
        waves = waves + 1
        spawn()
    end

    -- move bullets
    for i, bullet in pairs(bullets) do
        bullet.y = bullet.y - bullet.dy * dt
        if bullet.y <= 0 then
            table.remove(bullets, i)
        end
        for j, enemy in pairs(enemies) do
            if collision(enemy, bullet) then
                table.remove(bullets, i)
                table.remove(enemies, j)
                score.value = score.value + 1
                love.audio.play(enemy.sound)
            end
        end
    end

    -- move enemies
    for i, enemy in pairs(enemies) do
        if enemy.x <= 0 or enemy.x >= screen.width - enemy.width then
            if enemy.y < player.y then
                enemy.y = enemy.y + enemy.dy
            else
                table.remove(enemies, i)
            end
            enemy.dx = enemy.dx * -1
        end
        if collision(player, enemy) then
            over()
            love.timer.sleep(1)
            love.run()
        end
        enemy.x = enemy.x + enemy.dx * dt
    end
end

-- draw entities
function love.draw()
    love.graphics.draw(background.image, 0, 0)
    love.graphics.setColor(255, 255, 255)
    love.graphics.setFont(score.font)
    love.graphics.print("Score: "..score.value, score.x, score.y)
    love.graphics.draw(player.image, player.x, player.y)
    for i, bullet in pairs(bullets) do
        love.graphics.draw(bullet.image, bullet.x, bullet.y)
    end
    for i, enemy in pairs(enemies) do
        love.graphics.draw(enemy.image, enemy.x, enemy.y)
    end
end
