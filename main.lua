
player = {}
player.x = 100
player.y = 580
player.w = 45
player.h = 18
player.lives = 3
player.score = 0

bullets = {}
bullets_generation_tick = 0.5

invaders = {}
invaders.array = {}
invaders.speedX = 25
invaders.speedY = 10
invaders.offX = 0
invaders.offY = 0
invaders.reloadTime = 1
invaders.reload = 1
invaders.bullets = {}

level = {}
level.lvl = 1

-- Collision detection function;
-- Returns true if two boxes overlap, false if they don't;
-- x1,y1 are the top-left coords of the first box, while w1,h1 are its width and height;
-- x2,y2,w2 & h2 are the same, but for the second box.
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
	return x1 < x2+w2 and
		   x2 < x1+w1 and
		   y1 < y2+h2 and
		   y2 < y1+h1
end

function level:load()
	invaders.offX = 0
	invaders.offY = 0
	for i=1,10 do
		for j=1,level.lvl do
			invader = {}
			invader.w = 60
			invader.h = 30
			invader.x = 50 + 70*(i-1)
			invader.y = 60 + 40*(j-1) 
			table.insert(invaders.array, invader)
		end
	end
	invaders.bottom = 60 + 40*(level.lvl-1) + 30 
end

function level:levelUp()
	level.lvl = level.lvl + 1
	if level.lvl > 9 then
		return
	end

	level.load()
end

function level:gameOver()
	level.lvl = 0
end

function level:restart()
	count = #invaders.array
	for i=0, count do invaders.array[i]=nil end

	player.lives = 3
	player.score = 0
	player.x = 400 + player.w*0.5

	level.lvl = 1
	level.load()
end

function invaders:draw()
	for it, invader in pairs(invaders.array) do
		love.graphics.draw(invaders.image, invader.x + invaders.offX, invader.y + invaders.offY, 0, 0.5, 0.5)
	end

	for it, bullet in pairs(invaders.bullets) do
		love.graphics.rectangle("line",bullet.x, bullet.y, bullet.w, bullet.h)
	end
end

function invaders:checkCollisions()
	bi = 0
	ii = 0
	for it, b in pairs(bullets) do
		bi = bi + 1
		for it2, i in pairs(invaders.array) do
			ii = ii + 1
			if CheckCollision(b.x, b.y, b.w, b.h, i.x + invaders.offX, i.y + invaders.offY, i.w, i.h) then
				table.remove(bullets, bi)
				table.remove(invaders.array, ii)
				player.score = player.score + 20

				if tablelength(invaders.array) == 0 then
					level.levelUp()
				end

				-- Calc new bottom of the invaders column
				lowest = 0
				for it, invader in pairs(invaders.array) do
					bottom = invader.y + 30
					if bottom > lowest then
						lowest = bottom
					end
				end
				invaders.bottom = lowest

				break
			end
		end
		ii = 0
	end

	-- Check collisions of invaders' bullets
	bi = 0
	for it, b in pairs(invaders.bullets) do
		bi = bi + 1
		if CheckCollision(b.x, b.y, b.w, b.h, player.x, player.y, player.w, player.h) then
			table.remove(invaders.bullets, bi)
			player.death()
		end
	end
end

function player:shoot()
	if bullets_generation_tick <= 0 then
		bullets_generation_tick = 0.5
		bullet = {}
		bullet.x = player.x + 15
		bullet.y = 520
		bullet.w = 5
		bullet.h = 20
		table.insert(bullets, bullet)
		love.audio.play(player_shoot_sound)
	end
end

function player:death()
	player.lives = player.lives - 1
	player.x = 400 + player.w*0.5

	if player.lives == 0 then
		level.gameOver()
	end
end

function tablelength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
  end

function invaders:shoot()
	if invaders.reload <= 0 then
		invaders.reload = invaders.reloadTime

		length = tablelength(invaders.array)
		if length > 0 then
			invaderIndex = math.random(length)
			invader = invaders.array[invaderIndex]

			bullet = {}
			bullet.x = invader.x + invaders.offX + invader.w*0.5
			bullet.y = invader.y + invaders.offY + invader.h*0.5
			bullet.w = 5
			bullet.h = 20
			table.insert(invaders.bullets, bullet)
			--love.audio.play(player_shoot_sound)
			end
	end
end

function love.load()
	player.image = love.graphics.newImage('images/player.png')
	player.explose_shoot = love.audio.newSource('sounds/shoot.mp3','static')

	invaders.image = love.graphics.newImage('images/invader.png')
	level.load()

	music = love.audio.newSource('sounds/music.mp3','static')
	player_shoot_sound = love.audio.newSource('sounds/shoot.mp3','static')
	music:setLooping(true)
	--love.audio.play(music)
end

function love.draw()
	love.graphics.print("Level " .. level.lvl .. " Lives: " .. player.lives .. " Score: " .. player.score , 5, 5, 0, 2)

	if level.lvl == 0 then
		love.graphics.print("GAME OVER", 320, 250, 0, 2)
		love.graphics.print("Press R to restart", 340, 280, 0, 1)
	end

	if level.lvl > 9 then
		love.graphics.print("YOU WIN!", 320, 250, 0, 2)
		love.graphics.print("Press R to restart", 340, 280, 0, 1)
	end

	love.graphics.setColor(1,1,1)
    for it, bullet in pairs(bullets) do
		love.graphics.rectangle("fill",bullet.x, bullet.y, bullet.w, bullet.h)
	end

	if level.lvl > 0 then
		love.graphics.draw(player.image, player.x, player.y, 0, 0.3)
	end

	invaders.draw()
end

function love.update(dt)
	if love.keyboard.isDown('right') then
		if player.x > 750 then
			player.x = 750
		end
		print("Right key pressed")
		player.x = player.x + 500 * dt
	end
	if love.keyboard.isDown('left') then
		if player.x  < 10 then
			player.x = 10
		end
		print("Left key pressed")
		player.x = player.x - 500 * dt
	end
	if love.keyboard.isDown('space') and level.lvl > 0 then
		player.shoot()
	end
	if love.keyboard.isDown('q') then
		love.event.quit()
	end
	if love.keyboard.isDown('r') and (level.lvl == 0 or level.lvl > 9) then
		level.restart()
	end

	-- move bullets of the player
	bi = 0
	for it, bullet in pairs(bullets) do
		bi = bi + 1
		bullet.y = bullet.y - 500 * dt

		if bullet.y < 0 then
			table.remove(bullets, bi)
		end
	end

	if level.lvl < 10 then
		invaders.reload = invaders.reload - dt
		invaders.shoot()
		-- move bullets of the invaders
		bi = 0
		for it, bullet in pairs(invaders.bullets) do
			bi = bi + 1
			bullet.y = bullet.y + 500 * dt

			if bullet.y > 600 then
				table.remove(invaders.bullets, bi)
			end
		end

		invaders.checkCollisions()

		invaders.offX = invaders.offX + invaders.speedX * dt
		if invaders.offX > 50 or invaders.offX < -50 then
			invaders.speedX = invaders.speedX * -1
		end

		invaders.offY = invaders.offY + invaders.speedY * dt
		if invaders.offY + invaders.bottom > 600 then
			level.gameOver()
		end
	end

	bullets_generation_tick = bullets_generation_tick - 1 * dt
end
