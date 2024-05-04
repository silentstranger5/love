function Screen()
    local screen = {}
    screen.width, screen.height = love.graphics.getDimensions()
    return screen
end

function Player()
    local player = {}
    player.x = screen.width / 2 - 50
    player.y = screen.height / 10 * 9
    player.width = 100
    player.height = 20
    player.dx = 300
    return player
end

function Brick(index)
    local brick = {}
    brick.width = 100
    brick.height = 30
    brick.gap = 20
    brick.row = ((index - 1) % 6)
    brick.column = math.floor((index - 1) / 6)
    brick.x = screen.width / 20 + brick.row * (brick.width + brick.gap)
    brick.y = screen.height / 20 + brick.column * (brick.height + brick.gap / 2)
    brick.color = {}
    brick.color.red = 0
    brick.color.green = 0
    brick.color.blue  = 0
    if brick.column == 0 then
        brick.color.red = 255/255
    elseif brick.column == 1 then
        brick.color.red = 255/255
        brick.color.green = 165/255
    elseif brick.column == 2 then
        brick.color.red = 255/255
        brick.color.green = 255/255
    elseif brick.column == 3 then
        brick.color.green = 255/255
    elseif brick.column == 4 then
        brick.color.green = 255/255
        brick.color.blue  = 255/255
    end
    return brick
end

function Ball()
    local ball = {}
    ball.size = 20
    ball.x = screen.width / 2 - ball.size / 2
    ball.y = screen.height / 3 * 2 - ball.size / 2
    ball.dx = math.random(200, 300)
    ball.dy = math.random(200, 300)
    ball.sound = love.audio.newSource("bounce.wav", "stream")
    ball.sound:setVolume(0.5)
    return ball
end

function Score()
    local score = {}
    score.value = 0
    score.x = screen.width / 10 * 9
    score.y = screen.height / 10 * 9
    score.font = love.graphics.newFont(32)
    return score
end

function collide(ball, object)
    return ball.x < object.x + object.width and
           object.x < ball.x + ball.size   and
           ball.y < object.y + object.height and
           object.y < ball.y + ball.size
end

function spawn_bricks(bricks)
    bricks_number = 30
    for i=1,bricks_number do
        brick = Brick(i)
        table.insert(bricks, brick)
    end
end

function over()
    love.graphics.clear()
    love.graphics.setColor(1, 1, 1)
    caption = {}
    caption.value = "Game Over.\nYour Score is "..score.value
    caption.font = love.graphics.newFont(32)
    caption.x = screen.width / 3
    caption.y = screen.height / 2
    love.graphics.print(caption.value, caption.font, caption.x, caption.y)
    love.graphics.present()
end

function love.load()
    screen = Screen()
    score  = Score()
    player = Player()
    ball = Ball()
    bricks = {}
    spawn_bricks(bricks)
end

function love.update(dt)
    if love.keyboard.isDown("left") and player.x > 0 then
        player.x = player.x - player.dx * dt
    end if love.keyboard.isDown("right") and player.x < screen.width - player.width then
        player.x = player.x + player.dx * dt
    end if love.keyboard.isDown("escape") then
        love.event.quit()
    end
    if collide(ball, player) then
        ball.dy = ball.dy * -1
        ball.y = ball.y - ball.size / 2
        love.audio.play(ball.sound)
    end
    if ball.x <= 0 or ball.x > screen.width - ball.size then
        ball.dx = ball.dx * -1
    end
    if ball.y <= 0 then
        ball.dy = ball.dy * -1
    end
    for i, brick in pairs(bricks) do
        if collide(ball, brick) then
            ball.dy = ball.dy * -1
            table.remove(bricks, i)
            score.value = score.value + 1
        end
    end
    if ball.y > screen.height then
        over()
        love.timer.sleep(1)
        love.run()
    end
    if #bricks == 0 and ball.y > screen.height / 6 * 5 then
        spawn_bricks(bricks)
    end
    ball.x = ball.x + ball.dx * dt
    ball.y = ball.y + ball.dy * dt
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(score.font)
    love.graphics.print(score.value, score.x, score.y)
    love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)
    love.graphics.rectangle("fill", ball.x, ball.y, ball.size, ball.size)
    for i, brick in pairs(bricks) do
        love.graphics.setColor(brick.color.red, brick.color.green, brick.color.blue)
        love.graphics.rectangle("fill", brick.x, brick.y, brick.width, brick.height)
    end
end