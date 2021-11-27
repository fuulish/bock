function love.load(args)
  width = love.graphics.getWidth()
  height = love.graphics.getHeight()

  debug = false
  debug_time = false

  for i, arg in ipairs(args) do
    if 'debug' == arg then
      debug = true
    elseif 'debugtime' == arg then
      debugtime = true
    end
  end

  dist_cut = 224

  world_speed = 30

  max_bugs = 20
  dm = nil

  def_bug_width = 5
  def_bug_length = 10
  max_vel = 100

  bug_creation_rate = 0.010
  max_rand_vel = 30
  bug_rando_red = 0.2

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

  if debug then
    dt_vel_inp = 1
  else
    dt_vel_inp = 5
  end

  -- use metatables and fun to create these more dynamically
  bugs = {
    -- {
    --   pos = { x = width / 2, y = height / 2 },
    --   vel = { x = 0, y = 0 },
    --   shape = { width = def_bug_width },
    -- }
  }

  max_cookies = 3
  cookies = {}
  def_cookie_width = def_bug_width * 10
  cookie_creation_rate = bug_creation_rate / 4

  cookie_margin = 1.1 * def_cookie_width
  cookie_min_neigh = 5

  max_frogs = 5
  frogs = {}

  def_frog_width = def_bug_width * 5
  frog_creation_rate = 0.0005 -- alternate sides as well

  main_bug_width = def_bug_width
  main_bug_length = def_bug_length

  if debug then
    main_bug_width = main_bug_width * 10
    main_bug_length = main_bug_length * 10
    max_bugs = 0
    max_death_vel = 10
  end

  add_bug(width / 2, height / 2, 0, math.random(0.1 * max_vel),
          main_bug_width, main_bug_length)

  init_dist_mat()
  calc_dist_mat()

  curtime = os.clock()

  registered_tables = {
    bugs,
    cookies,
    frogs
  }

  -- also create an overall container for bugs, objects, frogs, and feet
end


function init_dist_mat()
  dm = {}
  for i=1,#bugs do
    dm[i] = {}
    for j=1,#bugs do
      dm[i][j] = 0
    end
  end
end


function calc_dist_mat()
  for i, bi in ipairs(bugs) do
    for j, bj in ipairs(bugs) do
      if i == j then
        dm[i][j] = 0
      elseif i < j then
        -- refactor into reusable function
        dm[i][j] = vec_len({
          x = bi.pos.x - bj.pos.x,
          y = bi.pos.y - bj.pos.y
        })
      elseif i > j then
        dm[i][j] = dm[j][i]
      end
    end
  end
end


function get_init_frog_orientation(x, y)
  local ori = { x = 0, y = 0 }

  if x < 0.1 * width then
    ori.x = 1
    ori.y = 0
  elseif x > 0.9 * width then
    ori.x = -1
    ori.y = 0
  else
    ori.x = 0
    ori.y = -1
  end

  return ori
end


-- frogs need an orientation in which to shoot with their tongue
function add_frog(x, y, radius, orientation)
  radius = radius or def_frog_width
  x = x or math.random(width)
  y = y or 0

  orientation = orientation or get_init_frog_orientation(x, y)
  frogs[#frogs + 1] = {
    pos = { x = x, y = y },
    shape = { width = radius },
    orientation = orientation,
  }
end


function add_cookie(x, y, width)
  x = x or width / 2
  y = y or height / 2

  local width = width or def_cookie_width

  cookies[#cookies + 1] = {
    pos = { x = x, y = y },
    vel = { x = 0, y = 0 },
    shape = { width = width },
  }
end


function add_bug(x, y, vx, vy, width, length)
  x = x or width / 2
  y = y or height / 2

  vx = vx or 0
  vy = vy or 0

  local width = width or def_bug_width
  local length = length or def_bug_length

  bugs[#bugs + 1] = {
    pos   = {  x = x,   y = y  },
    vel   = {  x = vx,  y = vy },
    shape = {  width = width, length = length},
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


function update_frogs(dt)
  local lost_frogs = {}

  for i, f in pairs(frogs) do
    if f.pos.y > death_bar then
      table.insert(lost_frogs, i)
    end
  end

  for i = #lost_frogs, 1, -1 do
    table.remove(frogs, lost_frogs[i])
  end
end


function update_cookies(dt)
  local lost_cookies = {}

  for i, c in ipairs(cookies) do
    local numneighs = 0
    local cumvel = { x = 0, y = 0 }

    for j, b in ipairs(bugs) do
      if vec_len({
        x = b.pos.x - c.pos.x,
        y = b.pos.y - c.pos.y
      }) < cookie_margin then
        cumvel.x = cumvel.x + b.vel.x
        cumvel.y = cumvel.y + b.vel.y

        numneighs = numneighs + 1
      end
    end

    if numneighs > cookie_min_neigh then
      --local vel = calc_prop_avg('vel', nil, c.pos)
      c.vel.x = cumvel.x / numneighs
      c.vel.y = cumvel.y / numneighs
    else
      c.vel.x = c.vel.x * 0.95
      c.vel.y = c.vel.y * 0.95
    end

    c.pos.x = c.pos.x + dt * c.vel.x
    c.pos.y = c.pos.y - dt * c.vel.y

    -- if there are a certain number of bugs under the cookie, move it
    -- use the average velocity of boid flock centered around cookie

    if c.pos.y > death_bar then
      table.insert(lost_cookies, i)
    end
  end

  for i = #lost_cookies, 1, -1 do
    table.remove(cookies, lost_cookies[i])
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
end


function move_world(dt)
  if bugs[1].pos.y > height / 2 then
    return
  end

  for t in pairs(registered_tables) do
    for i, obj in ipairs(registered_tables[t]) do
      obj.pos.y = obj.pos.y + dt * world_speed
    end
  end
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

      if math.sqrt(dist.x*dist.x + dist.y*dist.y) <
                    (bugs[me].shape.width + bugs[i].shape.width) * 2 then
        bias.x = bias.x + dist.x
        bias.y = bias.y + dist.y
      end
    end
  end

  return bias
end


function alignment()
  local align = { x = 0, y = 0 }

  for i in pairs(bugs) do
    local avel = calc_bug_avel(i)

    align.x = avel.x - bugs[i].vel.x
    align.y = avel.y - bugs[i].vel.y

    bugs[i].vel.x = bugs[i].vel.x + align.x * bug_alignment
    bugs[i].vel.y = bugs[i].vel.y + align.y * bug_alignment
  end
end


function randomize()
  for i, b in ipairs(bugs) do
    if i ~= 1 then
      b.vel.x = b.vel.x + (math.random() * 2 - 1.) * max_rand_vel * bug_rando_red
      b.vel.y = b.vel.y + (math.random() * 2 - 1.) * max_rand_vel * bug_rando_red
    end
  end
end


function cohesion()
  local coh = { x = 0, y = 0 }
  local fac = 1


  for i in pairs(bugs) do
    local center = calc_bug_center(i)

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


function calc_bug_center(bug_idx)
  return calc_prop_avg('pos', bug_idx)
end


function calc_bug_avel(bug_idx)
  return calc_prop_avg('vel', bug_idx)
end


function calc_prop_avg(prop, bug_idx, center)
  local x = 0.
  local y = 0.
  local num_bugs = 0
  local dlt = 0

  if not bug_idx and not center then
    return nil
  end

  for i, bug in ipairs(bugs) do
    if center then
      dlt = vec_len({
        x = center.x - bugs[i][prop].x,
        y = center.y - bugs[i][prop].y
      })
    else
      dlt = dm[i][bug_idx]
    end

    -- calculate distance to central bug or just take all if no center provided
    if not bug_idx or dlt < dist_cut then
      x = x + bugs[i][prop].x
      y = y + bugs[i][prop].y
      num_bugs = num_bugs + 1
    end
  end

  x = x / num_bugs
  y = y / num_bugs

  return { x = x, y = y }
end


function love.update(dt)
  local tstart = os.clock()

  -- add new entities
  if #bugs < max_bugs and math.random() <= bug_creation_rate then
    add_bug(math.random(width),
            0,
            math.random(max_rand_vel),
            math.random(max_rand_vel))
  end

  if #cookies < max_cookies and math.random() <= cookie_creation_rate then
    add_cookie(math.random(width), 0)
  end

  -- always have at least one frog to indicate plane movement
  if #frogs < max_frogs and (math.random() <= frog_creation_rate or #frogs < 1) then
    add_frog()
  end

  -- update things in the world
  death_vel = math.min(death_vel + 1, max_death_vel) / death_vel_red
  death_bar = death_bar - death_vel

  -- move the plane of existence by moving all of the objects
  move_world(dt)

  init_dist_mat()
  calc_dist_mat()

  -- flocking update
  cohesion()
  alignment()
  chill()
  randomize()

  -- just zip all relevant lists together (like in python, if it exists)
  -- or collect those functions in a global table
  update_bugs(dt)
  update_cookies(dt)
  update_frogs(dt)

  handle_input()

  if bugs[1].pos.y > height then
    love.event.quit()
  end

  local tstop = os.clock()
  if debug or debugtime then
    io.write(string.format("took %.6f for update, %.6f seconds for the full loop\r",
                           tstop - tstart,
                           tstop - curtime))
  end
  curtime = tstop
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

  if bug.vel.y > 0 then
    angle = -angle
  end

  love.graphics.rotate(angle)
  love.graphics.ellipse('fill', bug.pos.x * math.cos(math.pi * 2 - angle) -
                                  bug.pos.y * math.sin(math.pi * 2 - angle),
                                bug.pos.x * math.sin(math.pi * 2 - angle) +
                                  bug.pos.y * math.cos(math.pi * 2 - angle),
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

function draw_cookie(cookie)
  love.graphics.setColor(1, 1, 0)
  love.graphics.circle('fill', cookie.pos.x, cookie.pos.y, cookie.shape.width)
end

function draw_frog(frog)
  love.graphics.setColor(0, 0, 1)
  love.graphics.circle('fill', frog.pos.x, frog.pos.y, frog.shape.width)

  local tongue = {
    x = frog.pos.x + frog.orientation.x * frog.shape.width * 0.9,
    y = frog.pos.y + frog.orientation.y * frog.shape.width * 0.9,
  }

  love.graphics.setColor(0, 0, 0)
  love.graphics.circle(
    'fill',
    tongue.x,
    tongue.y,
    frog.shape.width * 0.1
  )
end


function love.draw()
  for i, bug in ipairs(bugs) do
    love.graphics.setColor(1, 1, 1)
    if 1 == i then
      love.graphics.setColor(1, 0, 0)
    end
    draw_bug(bug)
  end

  for i, cok in ipairs(cookies) do
    draw_cookie(cok)
  end

  for i, frg in ipairs(frogs) do
    draw_frog(frg)
  end

  love.graphics.setBackgroundColor(0.1, 1, 0.3)

  love.graphics.setColor(0, 0, 0)
  love.graphics.line(0, death_bar, width, death_bar)

  for i=1,#bugs do
    center = calc_bug_center(i)
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle('fill', center.x, center.y, def_bug_width / 2)
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
