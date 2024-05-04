function Screen()
    local screen = {}
    screen.rows, screen.columns = 20, 20
    screen.width, screen.height = love.graphics.getDimensions()
    return screen
end

function Block()
    local block = {}
    block.size = 32
    return block
end

function Snake()
    local snake = {}
    snake.x = math.random(screen.rows / 2)
    snake.y = math.random(screen.columns)
    snake.blocks = {}
    for i=1,3 do
        local block = {}
        block.x = snake.x - i + 1
        block.y = snake.y
        snake.blocks[i] = block
    end
    snake.dx = 1
    snake.dy = 0
    snake.head = snake.blocks[1]
    snake.sound = love.audio.newSource("crunch.wav", "stream")
    snake.sound:setVolume(0.2)
    load_snake_images(snake)
    return snake
end

function Fruit()
    local fruit = {}
    fruit.x = math.random(screen.rows - 1)
    fruit.y = math.random(screen.columns - 1)
    fruit.image = love.graphics.newImage("graphics/apple.png")
    return fruit
end

function Score()
    local score = {}
    score.value = 0
    score.x = screen.width / 20
    score.y = screen.height / 20
    score.font = love.graphics.newFont(block.size)
    return score
end

function collide(head, object)
    return head.x == object.x and
           head.y == object.y
end

function grow(snake)
    local new_block = {}
    new_block.x = snake.x + snake.dx
    new_block.y = snake.y + snake.dy
    table.insert(snake.blocks, 1, new_block)
    snake.head = snake.blocks[1]
    snake.x, snake.y = snake.head.x, snake.head.y
end

function draw_grass()
    for x=1,screen.rows do
        for y=1,screen.columns do
            if x % 2 == y % 2 then
                love.graphics.rectangle("fill", (x - 1) * block.size, (y - 1) * block.size, block.size, block.size)
            end
        end
    end
end

function load_snake_images(snake)
    snake.images = {}
    snake.images.head = {}
    snake.images.body = {}
    snake.images.tail = {}
    snake.images.head.down = love.graphics.newImage("graphics/head_down.png")
    snake.images.head.left = love.graphics.newImage("graphics/head_left.png")
    snake.images.head.right = love.graphics.newImage("graphics/head_right.png")
    snake.images.head.up = love.graphics.newImage("graphics/head_up.png")
    snake.images.body.back = {}
    snake.images.body.turn = {}
    snake.images.body.static = {}
    snake.images.body.back.left = love.graphics.newImage("graphics/body_bl.png")
    snake.images.body.back.right = love.graphics.newImage("graphics/body_br.png")
    snake.images.body.turn.left = love.graphics.newImage("graphics/body_tl.png")
    snake.images.body.turn.right = love.graphics.newImage("graphics/body_tr.png")
    snake.images.body.static.horizontal = love.graphics.newImage("graphics/body_horizontal.png")
    snake.images.body.static.vertical = love.graphics.newImage("graphics/body_vertical.png")
    snake.images.tail.down = love.graphics.newImage("graphics/tail_down.png")
    snake.images.tail.left = love.graphics.newImage("graphics/tail_left.png")
    snake.images.tail.right = love.graphics.newImage("graphics/tail_right.png")
    snake.images.tail.up = love.graphics.newImage("graphics/tail_up.png")
end

function draw_snake_block(snake_block, i)
    if i == 1 then
        head_direction = direction(snake.blocks[2], snake.blocks[1])
        if tables_equal(head_direction, {1, 0}) then
            love.graphics.draw(snake.images.head.left, snake_block.x * block.size, snake_block.y * block.size)
        elseif tables_equal(head_direction, {-1, 0}) then
            love.graphics.draw(snake.images.head.right, snake_block.x * block.size, snake_block.y * block.size)
        elseif tables_equal(head_direction, {0, 1}) then
            love.graphics.draw(snake.images.head.up, snake_block.x * block.size, snake_block.y * block.size)
        elseif tables_equal(head_direction, {0, -1}) then
            love.graphics.draw(snake.images.head.down, snake_block.x * block.size, snake_block.y * block.size)
        end
    elseif i == #snake.blocks then
        tail_direction = direction(snake.blocks[#snake.blocks], snake.blocks[#snake.blocks-1])
        if tables_equal(tail_direction, {1, 0}) then
            love.graphics.draw(snake.images.tail.right, snake_block.x * block.size, snake_block.y * block.size)
        elseif tables_equal(tail_direction, {-1, 0}) then
            love.graphics.draw(snake.images.tail.left, snake_block.x * block.size, snake_block.y * block.size)
        elseif tables_equal(tail_direction, {0, 1}) then
            love.graphics.draw(snake.images.tail.down, snake_block.x * block.size, snake_block.y * block.size)
        elseif tables_equal(tail_direction, {0, -1}) then
            love.graphics.draw(snake.images.tail.up, snake_block.x * block.size, snake_block.y * block.size)
        end
    else
        previous = direction(snake.blocks[i + 1], snake_block)
        next = direction(snake.blocks[i - 1], snake_block)
        if previous[1] == next[1] then
            love.graphics.draw(snake.images.body.static.vertical, snake_block.x * block.size, snake_block.y * block.size)
        elseif previous[2] == next[2] then
            love.graphics.draw(snake.images.body.static.horizontal, snake_block.x * block.size, snake_block.y * block.size)
        else
            if  tables_equal({previous[1], next[2]}, {-1, -1}) or
                tables_equal({previous[2], next[1]}, {-1, -1}) then
                    love.graphics.draw(snake.images.body.turn.left, snake_block.x * block.size, snake_block.y * block.size)
            elseif  tables_equal({previous[1], next[2]}, {-1, 1}) or
                    tables_equal({previous[2], next[1]}, {1, -1}) then
                        love.graphics.draw(snake.images.body.back.left, snake_block.x * block.size, snake_block.y * block.size)
            elseif  tables_equal({previous[1], next[2]}, {1, -1}) or
                    tables_equal({previous[2], next[1]}, {-1, 1}) then
                        love.graphics.draw(snake.images.body.turn.right, snake_block.x * block.size, snake_block.y * block.size)
            elseif  tables_equal({previous[1], next[2]}, {1, 1}) or
                    tables_equal({previous[2], next[1]}, {1, 1}) then
                        love.graphics.draw(snake.images.body.back.right, snake_block.x * block.size, snake_block.y * block.size)
            end
        end
    end
end

function tables_equal(first, second)
    for i=1,#first do
        if i > #second or first[i] ~= second[i] then
            return false
        end
    end
    return true
end

function direction(first, second)
    local direction = {}
    direction[1] = first.x - second.x
    direction[2] = first.y - second.y
    return direction
end

function over()
    love.graphics.clear()
    love.graphics.setColor(255, 255, 255)
    caption = {}
    caption.value = "Game Over.\nYour Score is "..score.value
    caption.font = love.graphics.newFont(32)
    caption.x = screen.width / 3
    caption.y = screen.height / 2
    love.graphics.print(caption.value, caption.font, caption.x, caption.y)
    love.graphics.present()
end

function love.load()
    block  = Block()
    screen = Screen()
    snake  = Snake()
    fruit  = Fruit()
    score  = Score()
    countdown = 0
end

function love.update(dt)
    if  love.keyboard.isDown("left") and
        not (snake.dx == 1 and snake.dy == 0) then
            snake.dx, snake.dy = -1, 0
    end if love.keyboard.isDown("up") and
        not (snake.dx == 0 and snake.dy == 1) then
            snake.dx, snake.dy = 0, -1
    end if love.keyboard.isDown("right") and
        not (snake.dx == -1 and snake.dy == 0) then
            snake.dx, snake.dy = 1, 0
    end if love.keyboard.isDown("down") and
        not (snake.dx == 0 and snake.dy == -1) then
            snake.dx, snake.dy = 0, 1
    end if love.keyboard.isDown("escape") then
        love.event.quit()
    end
    if  snake.x >= 0 and snake.x < screen.rows and
        snake.y >= 0 and snake.y < screen.columns then
        if love.timer.getTime() > countdown then
            table.remove(snake.blocks, #snake.blocks)
            countdown = love.timer.getTime() + 0.1
            grow(snake)
        end
    else
        over()
        love.timer.sleep(1)
        love.run()
    end
    if  collide(snake.head, fruit) then
        fruit.x = math.random(screen.rows - 1)
        fruit.y = math.random(screen.columns - 1)
        score.value = score.value + 1
        love.audio.play(snake.sound)
        grow(snake)
    end
    for i, snake_block in pairs(snake.blocks) do
        if i > 1 and collide(snake.head, snake_block) then
            over()
            love.timer.sleep(1)
            love.run()
        end
    end
end

function love.draw()
    love.graphics.setBackgroundColor(175/255, 215/255, 70/255)
    love.graphics.setColor(167/255, 209/255, 61/255)
    draw_grass()
    love.graphics.setColor(255/255, 255/255, 255/255)
    love.graphics.print("Score: "..score.value, score.font, score.x, score.y)
    love.graphics.setColor(255/255, 255/255, 255/255)
    for i, snake_block in pairs(snake.blocks) do
        draw_snake_block(snake_block, i)
        -- love.graphics.rectangle("fill", snake_block.x * block.size, snake_block.y * block.size, block.size, block.size)
    end
    love.graphics.setColor(255/255, 255/255, 255/255)
    love.graphics.draw(fruit.image, fruit.x * block.size, fruit.y * block.size)
end