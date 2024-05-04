function love.load()
    screen = {}
    screen.width, screen.height = love.graphics.getDimensions()

    paddle = {}
    paddle.width = 20
    paddle.height = 100

    player = {}
    player.width = paddle.width
    player.height = paddle.height
    player.x = screen.width / 10
    player.y = screen.height / 2 - player.height / 2
    player.dy = 300

    enemy = {}
    enemy.x = screen.width / 10 * 9
    enemy.y = screen.height / 2 - 50
    enemy.width = paddle.width
    enemy.height = paddle.height

    ball  = {}
    ball.x = screen.width / 2
    ball.y = screen.height / 2
    ball.size = 20
    sign = {-1, 1}
    ball.speed = {}
    ball.speed.x = math.random(200, 300) * sign[math.random(2)]
    ball.speed.y = math.random(200, 300) * sign[math.random(2)]

    score = {}
    score.value = 0
    score.x = screen.width / 20
    score.y = screen.height / 20
    score.font = love.graphics.newFont(32)

    bounce = love.audio.newSource("bounce.wav", "stream")
    bounce:setVolume(0.5)
end

function love.draw()
    love.graphics.print("Score: "..score.value, score.font, score.x, score.y)
    love.graphics.rectangle("fill", player.x, player.y, paddle.width, paddle.height)
    love.graphics.rectangle("fill", enemy.x, enemy.y, paddle.width, paddle.height)
    love.graphics.rectangle("fill", ball.x, ball.y, ball.size, ball.size)
end

function love.update(dt)
    if love.keyboard.isDown("up") and player.y > 0 then
        player.y = player.y - player.dy * dt
    end if love.keyboard.isDown("down") and player.y < screen.height - paddle.height then
        player.y = player.y + player.dy * dt
    end if love.keyboard.isDown("escape") then
        love.event.quit()
    end

    enemy.y = ball.y - (paddle.height / 2) + ball.size
    if enemy.y <= 0 then
        enemy.y = 0
    elseif enemy.y >= screen.height - paddle.height then
        enemy.y = screen.height - paddle.height
    end

    if ball.y <= 0 or ball.y >= screen.height - ball.size then
        ball.speed.y = ball.speed.y * -1
    elseif collision(enemy, ball) then
        ball.speed.x = ball.speed.x * -1
        ball.x = ball.x - ball.size / 2
        love.audio.play(bounce)
    elseif collision(player, ball) then
        ball.speed.x = ball.speed.x * -1
        ball.x = ball.x + ball.size / 2
        love.audio.play(bounce)
        score.value = score.value + 1
    end

    if ball.x <= 0 or ball.x >= screen.width then
        over()
        love.timer.sleep(1)
        love.run()
    end

    ball.x = ball.x + ball.speed.x * dt
    ball.y = ball.y + ball.speed.y * dt
end

function collision(paddle, ball)
    return paddle.x < ball.x + ball.size and
           ball.x < paddle.x + paddle.width and
           paddle.y < ball.y + ball.size and
           ball.y < paddle.y + paddle.height
end

function over()
    love.graphics.clear()
    caption = {}
    caption.value = "Game Over.\nYour Score is "..score.value
    caption.font = love.graphics.newFont(32)
    caption.x = screen.width / 3
    caption.y = screen.height / 2
    love.graphics.print(caption.value, caption.font, caption.x, caption.y)
    love.graphics.present()
end
