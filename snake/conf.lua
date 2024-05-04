function love.conf(t)
    rows, columns = 20, 20
    block_size = 32
    t.window.width = rows * block_size
    t.window.height = columns * block_size
end