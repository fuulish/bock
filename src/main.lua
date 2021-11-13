function love.load()
  width = love.graphics.getWidth()
  height = love.graphics.getHeight()

  max_bugs = 20

  def_bug_width = 5
  def_bug_length = 10
  max_vel = 100

  bug_creation_rate = 0.025
  max_rand_vel = 30

  bug_adhesive = 0.0015
  bug_alignment = 0.02
  bug_bias = 0.3

  vel = 'vel'
  pos = 'pos'

  player_bug_enhancement = 15

  death_bar = height
  death_vel = 0
  death_vel_red = 100
  max_death_vel = 10

  dt_vel_inp = 5

  -- use metatables and fun to create these more dynamically
  bugs = {
    -- {
    --   pos = { x = width / 2, y = height / 2 },
    --   vel = { x = 0, y = 0 },
    --   shape = { width = def_bug_width },
    -- }
  }

  add_bug(width / 2, height / 2, 0, math.random(0.1 * max_vel))

  -- also create an overall container for bugs, objects, frogs, and feet
end


function add_bug(x, y, vx, vy, width, length)
  x = x or width / 2
  y = y or height / 2

  vx = vx or 0
  vy = vy or 0

  width = width or def_bug_width
  length = length or def_bug_length

  bugs[#bugs + 1] = {
    pos   = {  x = x,   y = y  },
    vel   = {  x = vx,  y = vy },
    shape = {  width = def_bug_width, length = def_bug_length },
  }
end


function handle_input()
  --no friction and continuous, floaty movement
  if love.keyboard.isDown('k') or love.keyboard.isDown('up') then
    bugs[1].vel.y = math.min(bugs[1].vel.y + dt_vel_inp, max_vel)
  end

  if love.keyboard.isDown('j') or love.keyboard.isDown('down') then
    bugs[1].vel.y = math.max(bugs[1].vel.y - dt_vel_inp, -max_vel)
  end

  if love.keyboard.isDown('h') or love.keyboard.isDown('left') then
    bugs[1].vel.x = math.max(bugs[1].vel.x - dt_vel_inp, -max_vel)
  end

  if love.keyboard.isDown('l') or love.keyboard.isDown('right') then
    bugs[1].vel.x = math.min(bugs[1].vel.x + dt_vel_inp, max_vel)
  end
end


function update_bugs(dt)
  lost_bugs = {}
  for i, o in ipairs(bugs) do
    o.pos.x = o.pos.x + dt * o.vel.x
    o.pos.y = o.pos.y - dt * o.vel.y -- up is down and down is up

    -- die at the bottom
    if o.pos.y > death_bar then
      table.insert(lost_bugs, i)
    else
      -- reflective boundaries left, right, top
      if o.pos.x < 0 then
        o.pos.x = -o.pos.x
        o.vel.x = -o.vel.x
      elseif o.pos.x > width then
        o.pos.x = 2 * width - o.pos.x
        o.vel.x = -o.vel.x
      end

      if o.pos.y < 0 then
        o.vel.y = -o.vel.y
        o.pos.y = -o.pos.y
      end
    end

  end

  for i = #lost_bugs, 1, -1 do
    table.remove(bugs, lost_bugs[i])
  end

  center = calc_bug_center()
  avel = calc_bug_avel()

  -- perform flocking update

  cohesion(center)
  alignment(avel)

  chill()
end


function chill()
  for i in pairs(bugs) do
    bias = calc_separation_bias(i)

    bugs[i].vel.x = bugs[i].vel.x + bias.x * bug_bias
    bugs[i].vel.y = bugs[i].vel.y + bias.y * bug_bias
  end
end


function calc_separation_bias(me)
  local bias = { x = 0, y = 0 }
  local dist = { x = 0, y = 0 }

  for i in pairs(bugs) do
    if i ~= me then

      dist.x = bugs[me].pos.x - bugs[i].pos.x
      dist.y = bugs[me].pos.y - bugs[i].pos.y

      if math.sqrt(dist.x*dist.x + dist.y*dist.y) < (bugs[me].shape.width + bugs[i].shape.width) * 2 then
        bias.x = bias.x + dist.x
        bias.y = bias.y + dist.y
      end
    end
  end

  return bias
end


function alignment(avel)
  local align = { x = 0, y = 0 }

  for i in pairs(bugs) do
    align.x = avel.x - bugs[i].vel.x
    align.y = avel.y - bugs[i].vel.y

    bugs[i].vel.x = bugs[i].vel.x + align.x * bug_alignment
    bugs[i].vel.y = bugs[i].vel.y + align.y * bug_alignment
  end
end


function cohesion(center)
  local coh = { x = 0, y = 0 }
  local fac = 1

  for i in pairs(bugs) do
    coh.x = center.x - bugs[i].pos.x
    coh.y = center.y - bugs[i].pos.y

    if 1 == i then
      fac = 1
    else
      fac = player_bug_enhancement
    end

    bugs[i].vel.x = bugs[i].vel.x + coh.x * bug_adhesive * fac
    bugs[i].vel.y = bugs[i].vel.y - coh.y * bug_adhesive * fac
  end
end


function calc_bug_center()
  return calc_prop_avg(pos)
end


function calc_bug_avel()
  return calc_prop_avg(vel)
end


function calc_prop_avg(prop)
  local x = 0.
  local y = 0.

  for i in pairs(bugs) do
    x = x + bugs[i][prop].x
    y = y + bugs[i][prop].y
  end

  x = x / #bugs
  y = y / #bugs

  return { x = x, y = y }
end


function love.update(dt)
  if #bugs < max_bugs and math.random() <= bug_creation_rate then
    add_bug(math.random(width), 0, math.random(max_rand_vel), math.random(max_rand_vel))
  end

  death_vel = math.min(death_vel + 1, max_death_vel) / death_vel_red
  death_bar = death_bar - death_vel

  -- move the plane of existence by moving all of the objects?
  -- just zip all relevant lists together (like in python, if it exists)
  update_bugs(dt)
  handle_input()

  if bugs[1].pos.y > height then
    love.event.quit()
  end
end


-- alternative bug visualization would be:
-- love.graphics.rotate() -- rotate coordinate system
-- love.graphics.ellipse() -- draw the bug
-- love.graphics.origin()

function vec_len(vec)
  return math.sqrt(vec.x*vec.x + vec.y*vec.y)
end

function draw_bug(bug)

  local angle = math.acos(bug.vel.x / vec_len(bug.vel))

  love.graphics.rotate(angle)
  love.graphics.ellipse('fill', bug.pos.x * math.cos(math.pi * 2 - angle) - bug.pos.y * math.sin(math.pi * 2 - angle),
                                bug.pos.x * math.sin(math.pi * 2 - angle) + bug.pos.y * math.cos(math.pi * 2 - angle),
                                bug.shape.length, bug.shape.width)
  love.graphics.origin()

  -- for this visualization to work properly, we need to rework the world
  -- movement and have the bug at rest when its vel is zero

  local norm = math.sqrt(bug.vel.x * bug.vel.x + bug.vel.y * bug.vel.y)
  local factor = bug.shape.width * 0.9 / norm

  love.graphics.setColor(0, 0, 0)
  love.graphics.circle('fill',
    bug.pos.x + bug.vel.x * factor,
    bug.pos.y - bug.vel.y * factor, bug.shape.width / 5)

end


function love.draw()
  for i, bug in ipairs(bugs) do
    love.graphics.setColor(1, 1, 1)
    if 1 == i then
      love.graphics.setColor(1, 0, 0)
    end
    draw_bug(bug)
  end

  love.graphics.setBackgroundColor(0.1, 1, 0.3)

  love.graphics.setColor(0, 0, 0)
  love.graphics.line(0, death_bar, width, death_bar)

  center = calc_bug_center()
  love.graphics.setColor(0, 0, 1)
  love.graphics.circle('fill', center.x, center.y, def_bug_width / 2)

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
