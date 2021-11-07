function love.load()
  wdth = love.graphics.getWidth()
  hght = love.graphics.getHeight()

  def_wdth = 10

  -- use metatables and fun to create these more dynamically
  bugs = {
    {
      pos = { x = wdth / 2, y = hght / 2 },
      shape = { width = def_wdth },
    }
  }

  -- also create an overall container for bugs, objects, frogs, and feet
end


function love.update(dt)
  -- move the plane of existence by moving all of the objects?

  -- just zip all relevant lists together (like in python, if it exists)
  for i, o in ipairs(bugs) do
    o.pos.y = o.pos.y + dt * 100
    if o.pos.y > hght then
      love.event.quit()
    end
  end

end


function love.draw()
  for i, bug in ipairs(bugs) do
    love.graphics.circle('fill', bug.pos.x, bug.pos.y, bug.shape.width)
  end
end


function love.mousepressed(x, y, button, istouch)
end


function love.mousereleased(x, y, button, istouch)
end


function love.keypressed(key)
end


function love.keyreleased(key)
end


function love.focus(f)
end


function love.quit()
end
