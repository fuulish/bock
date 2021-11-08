function love.load()
  wdth = love.graphics.getWidth()
  hght = love.graphics.getHeight()

  world_speed = 50

  def_wdth = 10
  vel_max = 100

  -- use metatables and fun to create these more dynamically
  bugs = {
    {
      pos = { x = wdth / 2, y = hght / 2 },
      vel = { x = 0, y = 0 },
      shape = { width = def_wdth },
    }
  }

  -- also create an overall container for bugs, objects, frogs, and feet
end

function add_bug(x, y, vx, vy)
  bugs.insert(bugs, #bugs,
  {
    pos = {x,y}, vel = {vx, vy}, shape = {width = def_width}
  })
end


function love.update(dt)
  --no friction and continuous, floaty movement
  if love.keyboard.isDown('k') then
    bugs[1].vel.y = math.min(bugs[1].vel.y + 1, vel_max)
  end

  if love.keyboard.isDown('j') then
    bugs[1].vel.y = math.min(bugs[1].vel.y - 1, vel_max)
  end

  if love.keyboard.isDown('h') then
    bugs[1].vel.x = math.min(bugs[1].vel.x - 1, vel_max)
  end

  if love.keyboard.isDown('l') then
    bugs[1].vel.x = math.min(bugs[1].vel.x + 1, vel_max)
  end

  -- move the plane of existence by moving all of the objects?
  -- just zip all relevant lists together (like in python, if it exists)
  for i, o in ipairs(bugs) do
    o.pos.x = o.pos.x + dt * o.vel.x
    o.pos.y = o.pos.y + dt * world_speed - dt * o.vel.y

    if o.pos.y > hght then
      love.event.quit()
    end
  end
end


function love.draw()
  for i, bug in ipairs(bugs) do
    love.graphics.circle('fill', bug.pos.x, bug.pos.y, bug.shape.width)
  end

  -- debugging
  love.graphics.origin()
  love.graphics.setColor(1,1,1)
  love.graphics.print(table.concat({
    'x:  '..bugs[1].pos.x,
    'y:  '..bugs[1].pos.y,
    'vx: '..bugs[1].vel.x,
    'vy: '..bugs[1].vel.y,
  }, '\n'))
end


function love.mousepressed(x, y, button, istouch)
end


function love.mousereleased(x, y, button, istouch)
end


function love.keypressed(key)
end


function love.keyreleased(key)
  if 'q' == key then
    love.event.quit()
  end
end


function love.focus(f)
end


function love.quit()
end
