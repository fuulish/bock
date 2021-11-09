function love.load()
  width = love.graphics.getWidth()
  height = love.graphics.getHeight()

  world_speed = 50

  def_width = 10
  vel_max = 100

  bug_creation_rate = 0.025
  max_rand_vel = 30

  -- use metatables and fun to create these more dynamically
  bugs = {
    -- {
    --   pos = { x = width / 2, y = height / 2 },
    --   vel = { x = 0, y = 0 },
    --   shape = { width = def_width },
    -- }
  }

  add_bug(width / 2, height / 2, 0, 0)

  -- also create an overall container for bugs, objects, frogs, and feet
end

function add_bug(x, y, vx, vy)
  x = x or width / 2
  y = y or height / 2

  vx = vx or 0
  vy = vy or 0

  bugs[#bugs + 1] = {
    pos   = {  x = x,   y = y  },
    vel   = {  x = vx,  y = vy },
    shape = {  width = def_width },
  }
end


function handle_input()
  --no friction and continuous, floaty movement
  if love.keyboard.isDown('k') then
    bugs[1].vel.y = math.min(bugs[1].vel.y + 1, vel_max)
  end

  if love.keyboard.isDown('j') then
    bugs[1].vel.y = math.max(bugs[1].vel.y - 1, -vel_max)
  end

  if love.keyboard.isDown('h') then
    bugs[1].vel.x = math.max(bugs[1].vel.x - 1, -vel_max)
  end

  if love.keyboard.isDown('l') then
    bugs[1].vel.x = math.min(bugs[1].vel.x + 1, vel_max)
  end
end


function love.update(dt)
  if math.random() <= bug_creation_rate then
    add_bug(math.random(width), 0, math.random(max_rand_vel), math.random(max_rand_vel))
  end

  -- move the plane of existence by moving all of the objects?
  -- just zip all relevant lists together (like in python, if it exists)
  for i, o in ipairs(bugs) do
    o.pos.x = o.pos.x + dt * o.vel.x
    o.pos.y = o.pos.y + dt * world_speed - dt * o.vel.y
  end

  handle_input()

  if bugs[1].pos.y > height then
    love.event.quit()
  end
end


function love.draw()
  for i, bug in ipairs(bugs) do
    love.graphics.setColor(1, 1, 1)
    if 1 == i then
      love.graphics.setColor(1, 0, 0)
    end
    love.graphics.circle('fill', bug.pos.x, bug.pos.y, bug.shape.width)
  end

  -- debugging
  love.graphics.origin()
  love.graphics.setColor(1,1,1)
  love.graphics.print(#bugs)
  if #bugs > 0 then
    love.graphics.print(table.concat({
      'x:  '..bugs[1].pos.x,
      'y:  '..bugs[1].pos.y,
      'vx: '..bugs[1].vel.x,
      'vy: '..bugs[1].vel.y,
    }, '\n'))
  end
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
