pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
local l={}a={I={{{1,0},{1,1},{1,2},{1,3}},{{0,2},{1,2},{2,2},{3,2}},{{2,0},{2,1},{2,2},{2,3}},{{0,1},{1,1},{2,1},{3,1}}},O={{{0,1},{0,2},{1,1},{1,2}}},T={{{0,1},{1,0},{1,1},{1,2}},{{0,1},{1,1},{1,2},{2,1}},{{1,0},{1,1},{1,2},{2,1}},{{0,1},{1,0},{1,1},{2,1}}},S={{{0,1},{0,2},{1,0},{1,1}},{{0,1},{1,1},{1,2},{2,2}},{{1,1},{1,2},{2,0},{2,1}},{{0,0},{1,0},{1,1},{2,1}}},Z={{{0,0},{0,1},{1,1},{1,2}},{{0,2},{1,1},{1,2},{2,1}},{{1,0},{1,1},{2,1},{2,2}},{{0,1},{1,0},{1,1},{2,0}}},J={{{0,0},{1,0},{1,1},{1,2}},{{0,1},{0,2},{1,1},{2,1}},{{1,0},{1,1},{1,2},{2,2}},{{0,1},{1,1},{2,0},{2,1}}},L={{{0,2},{1,0},{1,1},{1,2}},{{0,1},{1,1},{2,1},{2,2}},{{1,0},{1,1},{1,2},{2,0}},{{0,0},{0,1},{1,1},{2,1}}}}y={I=1,O=2,T=3,S=4,Z=5,J=6,L=7}_={[1]={[2]={{0,0},{0,-1},{-1,-1},{2,0},{2,-1}},[4]={{0,0},{0,1},{-1,1},{2,0},{2,1}}},[2]={[1]={{0,0},{0,1},{1,1},{-2,0},{-2,1}},[3]={{0,0},{0,1},{1,1},{-2,0},{-2,1}}},[3]={[2]={{0,0},{0,-1},{-1,-1},{2,0},{2,-1}},[4]={{0,0},{0,1},{-1,1},{2,0},{2,1}}},[4]={[3]={{0,0},{0,-1},{1,-1},{-2,0},{-2,-1}},[1]={{0,0},{0,-1},{1,-1},{-2,0},{-2,-1}}}}w={[1]={[2]={{0,0},{0,-2},{0,1},{1,-2},{-2,1}},[4]={{0,0},{0,-1},{0,2},{-2,-1},{1,2}}},[2]={[1]={{0,0},{0,2},{0,-1},{-1,2},{2,-1}},[3]={{0,0},{0,-1},{0,2},{-2,-1},{1,2}}},[3]={[2]={{0,0},{0,1},{0,-2},{2,1},{-1,-2}},[4]={{0,0},{0,2},{0,-1},{-1,2},{2,-1}}},[4]={[3]={{0,0},{0,-2},{0,1},{1,-2},{-2,1}},[1]={{0,0},{0,1},{0,-2},{2,1},{-1,-2}}}}function l:new(e,o,l,d)local n={}n.shapeId=e n.shape=a[e][o]n.rotation=o n.row=l n.column=d n.spr=y[e]self.__index=self setmetatable(n,self)return n end function l:rotate(n)self.rotation=(self.rotation+n)%#a[self.shapeId]+1self.shape=a[self.shapeId][self.rotation]end function l:set_rotation(n)self.rotation=n self.shape=a[self.shapeId][self.rotation]end n={}function n:new(e,o,l,d,t,f)local n={}n.name=e n.label=o n.is_victory=l n.is_defeat=d n.on_update=t n.on_init=f self.__index=self setmetatable(n,self)return n end function e()return function(n)return false end end function o()return function(n)end end function d()return function(n)end end r={n:new("casual","clear 15 lines",function(n)return n.lines_cleared>=15end,e(),o(),d()),n:new("marathon","clear 150 lines",function(n)return n.lines_cleared>=150end,e(),o(),d()),n:new("quickie","clear 15 lines in 3 minutes",function(n)return n.lines_cleared>=15and n.frame_count<=10800end,function(n)return n.frame_count>10800end,function(n)n.time_remaining-=1end,function(n)n.time_remaining=10800n.time_mode="countdown"end),n:new("reverse","use 40 pieces without, clearing a line",function(n)return n.pieces_used==40and n.lines_cleared==0end,function(n)return n.lines_cleared>0end,o(),d()),n:new("expert","reach level 10,no hold and no ghost",function(n)return n.level>=10end,e(),o(),function(n)n.challenge.no_ghost=true n.challenge.no_hold=true n.preview=1end),n:new("heavy g","survive 2 minutes,blocks fall faster",function(n)return n.frame_count>=7200end,e(),o(),function(n)n.drop_interval_max=5n.drop_interval=5end),n:new("perfect","get a perfect clear,no pieces after clearing lines",function(n)local e=#n.grid for o=1,#n.grid[1]do if(n.grid[e][o]~=n.grid_spr)return false
end return n.lines_cleared>0end,e(),o(),d()),n:new("tight","you only have 6 columns",nil,e(),function(n)local e,o=#n.grid,{1,2,9,10}for e=3,e do for o in all(o)do if(n.grid[e][o]==n.grid_spr)n.grid[e][o]=flr(rnd(7))+1
end end end,function(n)n.spawn_row=3local e,o=#n.grid,{1,2,9,10}for e=3,e do for o in all(o)do n.grid[e][o]=flr(rnd(7))+1end end end),n:new("garbage","clear the bottom row, lines are filled with garbage",function(n)return n.cleared_bottom_row end,e(),o(),function(e)local n,o,l=#e.grid,#e.grid[1],-1for d=n-9,n do local n=flr(rnd(o))+1while(n==l)n=flr(rnd(o))+1
for o=1,o do if(o~=n)e.grid[d][o]=flr(rnd(7))+1
end l=n end end),n:new("rush","clear lines to gain time,survive as long as possible",nil,function(n)return n.time_remaining<=0end,function(n)n.time_remaining-=1end,function(n)n.time_remaining=900n.time_mode="countdown"end)}for n,e in ipairs(r)do e.index=n end local e,o={PLAYING="playing",GAME_OVER="game_over",LINE_CLEAR="line_clear",VICTORY="victory"},{}function o:new(e,o,l)local n={}n.x=e n.y=o n.vx=(rnd(1)-.5)*.3n.vy=-.3-rnd(.4)n.color=l n.lifetime=40+rnd(20)n.age=0self.__index=self setmetatable(n,self)return n end function o:update()self.age+=1self.x+=self.vx self.y+=self.vy self.vx+=rnd(.2)-.1self.vy=self.vy*.98self.vx=self.vx*.95end function o:is_alive()return self.age<self.lifetime end function o:draw()pset(self.x,self.y,self.color)end local n={}function n:new(o)local n={}self.__index=self setmetatable(n,self)n.grid_spr=0n.grid={}for e=1,22do n.grid[e]={}for o=1,10do n.grid[e][o]=n.grid_spr end end n.piece_queue={}n.drop_interval_max=60n.drop_interval=n.drop_interval_max n.block_size=6n.state=e.PLAYING n.level=1n.lines_cleared=0n.board_x=(127-#n.grid[1]*n.block_size)/2n.board_y=-n.block_size*1n.das={left={timer=0,shift=0,btn=0,delta=-1},right={timer=0,shift=0,btn=1,delta=1}}n.can_hold=true n.timer={soft=0,drop=0,hard=0,victory_banner=0,game_over_banner=0}n.is_tspin=false n.is_mini_tspin=false n.spawn_row=2n.spawn_column=5n.spawn_rotation=1n.animation={timer=0,lines={},duration=12}n.shake_x=0n.shake_y=0n.preview=5n.challenge=o n.particles={}n.drop_trails={}n.ui_color=5n.border_color=1n.frame_count=0n.pieces_used=0n.cleared_bottom_row=false n.end_anim={pops={},pop_timer=0,pop_interval=6,done=false}n.time_mode="countup"n.frame_lo=0n.secs_hi,n.secs_lo=0,0n.score_hi,n.score_lo=0,0n:refill_queue()n:refill_queue()n:finish_turn()if(n.challenge.on_init)n.challenge.on_init(n)
return n end function n:reset_action_state()self.last_action=nil self.last_rotation_kick=nil self.is_tspin=false self.is_mini_tspin=false end function n:update_world()if(f:blocks_input())return
if self.state==e.PLAYING do self.frame_lo+=1if(self.frame_lo>=60)self.frame_lo=0self.secs_hi,self.secs_lo=p(self.secs_hi,self.secs_lo,1,6000)
if(self.challenge.on_update)self.challenge.on_update(self)
self:handle_input_playing()self:handle_auto_drop()self:update_particles()self:update_drop_trails()elseif self.state==e.LINE_CLEAR do self:update_line_clear_animation()elseif self.state==e.GAME_OVER do self:update_particles()self:update_drop_trails()self:update_end_anim()elseif self.state==e.VICTORY do self:update_particles()self:update_drop_trails()self:update_end_anim()end if(self.challenge.is_defeat and self.challenge.is_defeat(self))self.state=e.GAME_OVER self.end_anim.mode="defeat"music(-1)
end function n:update_end_anim()local n,e=self.end_anim,{}for o,n in ipairs(n.pops)do n.timer+=1if(n.timer==n.duration)self:spawn_end_particles(n)
if(n.timer<n.duration)add(e,n)
end n.pops=e local e=self:end_anim_count_filled()if e>0do n.pop_interval=max(2,6-flr((1-e/220)*4))n.pop_timer+=1if(n.pop_timer>=n.pop_interval)n.pop_timer=0self:end_anim_pop_random_block()
elseif#n.pops==0do if(not n.done)self:save_hs()
n.done=true end if(self.can_finish_game==true and(btnp(5)or btnp(4)))f:start("playing","menu")
end function n:end_anim_count_filled()local n=0for e=2,#self.grid do for o=1,#self.grid[e]do if(self.grid[e][o]~=self.grid_spr)n+=1
end end return n end function n:end_anim_pop_random_block()local n={}for e=2,#self.grid do for o=1,#self.grid[e]do if(self.grid[e][o]~=self.grid_spr)add(n,{row=e,col=o,spr=self.grid[e][o]})
end end if(#n==0)return
local n=n[flr(rnd(#n))+1]local e=n.spr local o,e=sget(e%16*8+3,flr(e/16)*8+3),self.end_anim local l=e.mode=="defeat"and 1or 7self.grid[n.row][n.col]=self.grid_spr if(e.mode=="victory")self.shake_x,self.shake_y=3,3
if(e.mode=="defeat")sfx(61,3)else sfx(60,3)
add(e.pops,{row=n.row,col=n.col,color=o,flash_col=l,timer=0,duration=12})end function n:spawn_end_particles(n)local l,d,e=self.board_x+(n.col-1)*6+3,self.board_y+(n.row-1)*6+3,self.end_anim.mode=="defeat"local t,n=e and 2or 4,e and 1or n.color for e=1,t do local e,l=l+rnd(6)-3,d+rnd(6)-3add(self.particles,o:new(e,l,n))end end function n:update_line_clear_animation()self.animation.timer+=1if(self.animation.timer>=self.animation.duration)self.state=e.PLAYING self:clear_completed_lines()self:finish_turn()
end function n:update_particles()local e={}for n in all(self.particles)do n:update()if(n:is_alive())add(e,n)
end self.particles=e end function n:update_drop_trails()local e={}for n in all(self.drop_trails)do n.timer+=1local o=n.timer/n.duration local o=1-(1-o)*(1-o)n.current_top=n.start_y+(n.end_y-n.start_y)*o if(n.timer<n.duration)add(e,n)
end self.drop_trails=e end function n:create_drop_trails(o)local e=self.active_piece for n in all(e.shape)do local t,o,d=e.column+n[2],o+n[1],e.row+n[1]if(d>o)local l,n=self.board_y,self.block_size local n={x=self.board_x+(t-1)*n+n/2,start_y=l+(o-1)*n,end_y=l+(d-1)*n,current_top=l+(o-1)*n,color=e.spr,timer=0,duration=5}add(self.drop_trails,n)
end end function n:handle_input_playing()for e,n in pairs(self.das)do if(btnp(n.btn)and self:can_move(0,n.delta))self.active_piece.column+=n.delta self.last_action="movement"if(stat(49)==-1)sfx(7,3)
if btn(n.btn)do n.timer+=1local e=n.shift==0and 10or 2if n.timer>=e do n.timer=0n.shift+=1if(self:can_move(0,n.delta))self.active_piece.column+=n.delta self.last_action="movement"if(stat(49)==-1)sfx(7,3)
end else n.timer=0n.shift=0end end if btn(3)do self.timer.soft=max(0,self.timer.soft-1)if(self.timer.soft==0)self.timer.soft=3self:update_score("soft_drop",1)self:try_move_piece_down()sfx(63,3)
else self.timer.soft=0end if btn(2)do self.timer.hard=max(0,self.timer.hard-1)if self.timer.hard==0do self.timer.hard=20local e,n=self.active_piece.row,1while(self:can_move(1,0))self.active_piece.row+=1n+=1
sfx(6,3)self.shake_y+=3self:create_drop_trails(e)self:update_score("hard_drop",n)self:try_move_piece_down()end else self.timer.hard=0end if btn(4)and btn(5)and self.can_hold do self:handle_hold()sfx(62,3)elseif btnp(5)do self:handle_rotation(-2)self.last_action="rotation"sfx(5,3)elseif btnp(4)do self:handle_rotation(0)self.last_action="rotation"sfx(5,3)end end function n:handle_hold()if(self.challenge.no_hold==true)return
self.can_hold=false if(self.held_piece==nil)self.held_piece=self.active_piece self:finish_turn()else local n=self.active_piece self.active_piece=self.held_piece self.held_piece=n
self.held_piece:set_rotation(1)local n=self.active_piece n.row=self.spawn_row n.column=self.spawn_column n.rotation=self.spawn_rotation self.timer.drop=0end function n:handle_rotation(e)local n=self.active_piece local o,d,t,f=n.rotation,n.shape,n.row,n.column n:rotate(e)local l=n.rotation if(n.shapeId=="O")return
local e if(n.shapeId=="I")e=w else e=_
local e,l=e[o][l],false for o,e in ipairs(e)do if(self:can_move(e[1],e[2]))n.row+=e[1]n.column+=e[2]self.last_rotation_kick,l=o,true break
end if(not l)n.rotation,n.shape,n.row,n.column=o,d,t,f
end function n:handle_auto_drop()self.timer.drop+=1if(self.timer.drop==self.drop_interval)self:try_move_piece_down()
end function n:try_move_piece_down()self.timer.drop=0if self:can_move(1,0)do self.active_piece.row+=1else self:lock_active_piece()local o,n=self:check_line_completion()if#o>0do assert(n)self:prepare_line_completion_animation(o,n)self.state=e.LINE_CLEAR else if(n)self:update_score(n,0)
self:finish_turn()end end end function n:prepare_line_completion_animation(n,e)sfx(4,2)self.animation.type=e self.animation.timer=0self.animation.lines=n self.animation.lines_count=#n self.shake_x+=1+#n self.shake_y+=1+#n end function n:finish_turn()self.active_piece=nil if(self.challenge.is_victory and self.challenge.is_victory(self))self.state=e.VICTORY self.end_anim.mode="victory"music(-1)return
self:spawn_next_piece()end function n:spawn_next_piece()self:create_new_active_piece()for n=1,#self.grid[1]do if(self.grid[2][n]~=self.grid_spr)self.state=e.GAME_OVER self.end_anim.mode="defeat"music(-1)
end if(not self:can_move(0,0))self.state=e.GAME_OVER self.end_anim.mode="defeat"music(-1)
end function n:create_particles_for_line_clear()local n,d=#self.grid[1],1+#self.animation.lines for l,e in ipairs(self.animation.lines)do for l=1,n do local n=self.grid[e][l]if(n~=self.grid_spr)local n,l,e=sget(n%16*8+3,flr(n/16)*8+3),self.board_x+(l-1)*6+3,self.board_y+(e-1)*6+3for d=1,d do local l,e=l+(rnd(6)-3),e+(rnd(6)-3)add(self.particles,o:new(l,e,n))end
end end end function n:clear_completed_lines()local n,o=#self.grid,#self.grid[1]local e=n self:create_particles_for_line_clear()for o,e in ipairs(self.animation.lines)do if(e==n)self.cleared_bottom_row=true break
end for n=n,1,-1do local l=false for o,e in ipairs(self.animation.lines)do if(n==e)l=true break
end if not l do if(e~=n)for o=1,o do self.grid[e][o]=self.grid[n][o]end
e-=1end end for n=1,#self.animation.lines do for e=1,o do self.grid[n][e]=self.grid_spr end end self:update_score(self.animation.type,self.animation.lines_count)self.animation.type=nil self.animation.lines={}end function n:check_line_completion()local e,o,n,d=0,{},#self.grid,#self.grid[1]for n=n,1,-1do local l=true for e=1,d do if(self.grid[n][e]==self.grid_spr)l=false break
end if(l)e+=1add(o,n)
end local n=nil if e>0do n=self.is_tspin and"tspin"or self.is_mini_tspin and"mini_tspin"or"lines"elseif self.is_tspin do n="tspin"elseif self.is_mini_tspin do n="mini_tspin"end return o,n end function n:update_score(n,e)if n=="lines"do local n,o={100,300,500,800},{180,300,480,720}self:update_score_line_clear(n,o,e)elseif n=="tspin"do local n,o={[0]=100,400,800,1200,1600},{300,600,900,1200}self:update_score_line_clear(n,o,e)elseif n=="mini_tspin"do local n,o={[0]=100,200,400},{180,360}self:update_score_line_clear(n,o,e)elseif n=="soft_drop"do self:add_score(e)elseif n=="hard_drop"do self:add_score(e*2)end end function n:add_score(n)self.score_hi,self.score_lo=p(self.score_hi,self.score_lo,n,10000)end function n:hs_slot()return self.challenge.index-1end function n:save_hs()if(self.state==e.GAME_OVER and self.challenge.is_victory~=nil)return
local n=self:hs_slot()local e,o=dget(n+10),dget(n)local l=e==0and o==0if(l or self.score_hi>e or self.score_hi==e and self.score_lo>o)dset(n,self.score_lo)dset(n+10,self.score_hi)
local e,o=dget(n+30),dget(n+20)local l=e==0and o==0if self.time_mode=="countdown"do local d=self.time_remaining\60if(l or d>e*6000+o)dset(n+20,d)dset(n+30,0)
else if(l or self.secs_hi<e or self.secs_hi==e and self.secs_lo<o)dset(n+20,self.secs_lo)dset(n+30,self.secs_hi)
end end function n:hs_str()local n=self:hs_slot()local e,n=dget(n+10),dget(n)if e>0do local n=tostring(n)while(#n<4)n="0"..n
return tostring(e)..n end return tostring(n)end function n:hs_time_str()local n=self:hs_slot()local n,e=dget(n+30),dget(n+20)if(n==0and e==0)return"--:--"
return g(n*6000+e)end function n:update_score_line_clear(e,o,n)self.lines_cleared+=n self.level=flr(self.lines_cleared/10)+1self.drop_interval=max(5,self.drop_interval_max-(self.level*2-2))self:add_score(e[n]*self.level)if(self.challenge.name=="rush"and self.time_remaining and n>0)self.time_remaining+=o[n]
end function n:refill_queue()local n={"I","O","T","S","Z","J","L"}for e=#n,2,-1do local o=flr(rnd(e))+1n[e],n[o]=n[o],n[e]end for n in all(n)do add(self.piece_queue,n)end end function n:create_new_active_piece()local n=deli(self.piece_queue,1)self.active_piece=l:new(n,self.spawn_rotation,self.spawn_row,self.spawn_column)if(#self.piece_queue<self.preview)self:refill_queue()
self:reset_action_state()end function n:lock_active_piece()for e,n in pairs(self.active_piece.shape)do local e,n=self.active_piece.row+n[1],self.active_piece.column+n[2]self.grid[e][n]=self.active_piece.spr end self:check_tspin()self.can_hold=true self.pieces_used+=1end function n:check_tspin()self.is_tspin=false self.is_mini_tspin=false if self.active_piece.spr==3and self.last_action=="rotation"do local o,l,n=self.active_piece.row+1,self.active_piece.column+1,{[1]={u,h,s,D={-1,-1},{-1,1},{1,-1},{1,1}},[2]={u,h,s,D={-1,1},{1,1},{-1,-1},{1,-1}},[3]={u,h,s,D={1,-1},{1,1},{-1,-1},{-1,1}},[4]={u,h,s,D={-1,-1},{1,-1},{-1,1},{1,1}}}local e,n=n[self.active_piece.rotation],{A=false,B=false,C=false,D=false}for d,e in pairs(e)do local o,e=o+e[1],l+e[2]if(not self:is_position_valid(o,e)or self.grid[o][e]~=self.grid_spr)n[d]=true
end local e=0for n in all(n)do if(n)e+=1
end if(e>=3)if self.last_rotation_kick==5do self.is_tspin=true elseif n.A and n.B and(n.C or n.D)do self.is_tspin=true elseif n.C and n.D and(n.A or n.B)do self.is_mini_tspin=true end
end end function n:can_move(o,l)local n=self.active_piece for e in all(n.shape)do local o,n=n.row+o+e[1],n.column+l+e[2]if(not self:is_position_valid(o,n))return false
if(self.grid[o][n]~=self.grid_spr)return false
end return true end function n:is_position_valid(n,e)return n>=1and n<=#self.grid and e>=1and e<=#self.grid[1]end function n:draw_world()if self.shake_x+self.shake_y>0do local n,e=rnd(self.shake_x)-self.shake_x/2,rnd(self.shake_y)-self.shake_y/2camera(n,e)self.shake_x=self.shake_x*.3self.shake_y=self.shake_y*.3if(self.shake_x<.1)self.shake_x=0
if(self.shake_y<.1)self.shake_y=0
end local n=self.state==e.GAME_OVER or self.state==e.VICTORY self:draw_diagonal_lines()self:draw_grid()self:draw_next_piece()self:draw_held_piece()self:draw_drop_trails()self:draw_border()self:draw_text_info()if(not n)self:draw_ghost_piece()self:draw_active_piece()
self:draw_particles()if self.state==e.LINE_CLEAR do self:draw_line_clear_animation()elseif n do self:draw_end_anim()end camera(0,0)end function n:draw_end_anim()local n=self.end_anim local e=n.mode=="defeat"palt(0,false)for o,n in ipairs(n.pops)do local o,e=e and 7or 4,self.block_size if(n.timer>=o)local o=(n.timer-o)/(n.duration-o)local o,l=e*(1-o),self.board_x+(n.col-1)*e local d=self.board_y+(n.row-1)*e+(e-o)/2rectfill(l,d,l+e-1,d+o-1,n.flash_col)else local o,l=self.board_x+(n.col-1)*e,self.board_y+(n.row-1)*e rectfill(o,l,o+e-1,l+e-1,n.flash_col)
end palt(0,true)if(n.done)if(e)self.timer.game_over_banner+=1self:draw_defeat_banner(self.timer.game_over_banner)else self.timer.victory_banner+=1self:draw_victory_banner(self.timer.victory_banner)
end function n:draw_end_stats()local n,e="score:"..self:score_str(),"best: "..self:hs_str()?n,32-#n*2,68,5
?e,96-#e*2,68,5
n,e="time: "..self:get_time(),"bst t:"..self:hs_time_str()?n,32-#n*2,76,5
?e,96-#e*2,76,5
local n="🅾️/❎ to return"?n,64-#n*2-4,88,6
end function n:draw_defeat_banner(n)local e=min(16,n)if(n>60)e=min(64,16+(n-60))
rectfill(0,64-e,127,63,0)rectfill(0,64,127,64+e-1,0)if(n==15)sfx(59)
if n>60do?"game over",45,54,1
if(n>160)self:draw_end_stats()self.can_finish_game=true
end end function n:draw_victory_banner(n)local e=min(16,n)if(n>60)e=min(64,16+(n-60))
rectfill(0,0,127,e,0)rectfill(0,127-e,127,127,0)if(n==30)sfx(58)
if n>60do?"victory!",48,60,7
if(n>150)self:draw_end_stats()self.can_finish_game=true
end end function n:draw_text_info()local e,d,l,o=self.board_x-1,self.ui_color,2,49local function n(e,t,n)v(e,l,n,o,d)o+=6v(t,l,n,o,d)o+=12end n("pieces",tostring(self.pieces_used),e)n("lines",tostring(self.lines_cleared),e)n("level",tostring(self.level),e)n("score",self:score_str(),e)l,o=e+self.block_size*#self.grid[1]+3,97n("mode",self.challenge.name,127)n("timer",self:get_time(),127)end function n:score_str()if self.score_hi>0do local n=tostring(self.score_lo)while(#n<4)n="0"..n
return tostring(self.score_hi)..n end return tostring(self.score_lo)end function n:get_time()local n if(self.time_mode=="countdown")n=self.time_remaining\60else n=self.secs_hi*6000+self.secs_lo
return g(n)end function g(n)local n,e=n\60,n%60return(n<10and"0"..n or tostring(n))..":"..(e<10and"0"..e or tostring(e))end function v(n,e,o,l,d)local t,o=#n*4,o-e local e=e+(o-t)/2?n,e,l,d
end function n:draw_particles()for e,n in ipairs(self.particles)do n:draw()end end function n:draw_border()local n=self.board_x+#self.grid[1]*self.block_size line(self.board_x-1,self.board_y,self.board_x-1,self.board_y+#self.grid*self.block_size,self.border_color)line(n,self.board_y,n,self.board_y+#self.grid*self.block_size,self.border_color)line(self.board_x-1,126,n,126,self.border_color)end function n:draw_line_clear_animation()if(self.animation.timer<5)return
local n=self.animation.timer/self.animation.duration local n=1-n local e,l=self.block_size*n,#self.grid[1]*self.block_size palt(0,false)for n in all(self.animation.lines)do for e=1,#self.grid[n]do self:draw_block(n,e,self.grid_spr)end local o,n=self.board_x,self.board_y+(n-1)*self.block_size+(self.block_size-e)/2rectfill(o,n,o+l-1,n+e-1,7)end palt(0,true)end function n:draw_held_piece()local n=-3if(not self.held_piece)return
local e=self.held_piece if(e.shapeId=="I")n=n-1
for l,o in pairs(e.shape)do self:draw_block(3+o[1],n+o[2],e.spr)end end function n:draw_next_piece()for n=1,self.preview do local n=l:new(self.piece_queue[n],1,3+(n-1)*3,12)for e in all(n.shape)do self:draw_block(n.row+e[1],n.column+e[2],n.spr)end end end function n:draw_grid()for n=1,#self.grid do for e=1,#self.grid[n]do self:draw_block(n,e,self.grid[n][e]or self.grid_spr)end end local n=self.board_y+self.block_size*2-1fillp(23130)line(self.board_x,n,self.board_x+self.block_size*#self.grid[1],n,self.border_color)fillp()end function n:draw_drop_trails()for e,n in ipairs(self.drop_trails)do local o,e=sget(n.color%16*8+3,flr(n.color/16)*8+3),n.current_top while(e<n.end_y)local l=min(self.block_size,n.end_y-e)rectfill(n.x-3,e,n.x+2,e+l-1,o)e+=self.block_size
end end function n:draw_active_piece()if(not self.active_piece)return
for e,n in pairs(self.active_piece.shape)do local e,n=self.active_piece.row+n[1],self.active_piece.column+n[2]self:draw_block(e,n,self.active_piece.spr)end end function n:draw_ghost_piece()if(not self.active_piece or self.challenge.no_ghost==true)return
local n=self.active_piece.row while(self:can_move(n-self.active_piece.row+1,0))n=n+1
self:draw_piece_outline(n,self.active_piece.column,self.active_piece.shape,self.active_piece.spr)end function n:draw_piece_outline(o,t,n,e)local l,e=sget(e%16*8+3,flr(e/16)*8+3),{}for o,n in pairs(n)do local n=n[1]..","..n[2]e[n]=true end local function d(n,o)return e[n..","..o]==true end for e,n in pairs(n)do local o,e=o+n[1],t+n[2]if(o<=3)goto n
local e,o,t,f,i,c=self.board_x+(e-1)*self.block_size,self.board_y+(o-1)*self.block_size,d(n[1]-1,n[2]),d(n[1]+1,n[2]),d(n[1],n[2]-1),d(n[1],n[2]+1)if(not t)line(e,o,e+self.block_size-1,o,l)
if(not f)line(e,o+self.block_size-1,e+self.block_size-1,o+self.block_size-1,l)
if(not i)line(e,o,e,o+self.block_size-1,l)
if(not c)line(e+self.block_size-1,o,e+self.block_size-1,o+self.block_size-1,l)
if(t and i and not d(n[1]-1,n[2]-1))pset(e,o,l)
if(t and c and not d(n[1]-1,n[2]+1))pset(e+self.block_size-1,o,l)
if(f and i and not d(n[1]+1,n[2]-1))pset(e,o+self.block_size-1,l)
if(f and c and not d(n[1]+1,n[2]+1))pset(e+self.block_size-1,o+self.block_size-1,l)
::n::end end function n:draw_block(e,n,o)local n,e=self.board_x+(n-1)*self.block_size,self.board_y+(e-1)*self.block_size if(o==self.grid_spr)rectfill(n,e,n+self.block_size-1,e+self.block_size-1,0)else spr(o,n,e)
end function n:draw_diagonal_lines()pal(11,129,1)local n=time()*20%16for e=-128,128,8do local o,n=e+n,e+128+n line(o,128,n,0,11)end end function p(o,n,l,e)n+=l if(n>=e)o+=flr(n/e)n=n%e
return o,n end function n:setup_tspin_test()for n=1,22do for e=1,10do self.grid[n][e]=self.grid_spr end end for n=20,22do for e=1,10do self.grid[n][e]=5end end self.grid[22][3]=self.grid_spr self.grid[21][3]=self.grid_spr self.grid[20][3]=self.grid_spr self.grid[21][2]=self.grid_spr self.grid[20][2]=self.grid_spr self.grid[21][4]=self.grid_spr self.piece_queue={"T","I","O","S","Z","J","L"}self:create_new_active_piece()end function n:setup_mini_tspin_test()for n=1,22do for e=1,10do self.grid[n][e]=self.grid_spr end end for n=1,10do self.grid[22][n]=5end self.grid[21][1]=5self.grid[20][1]=5self.grid[22][2]=self.grid_spr self.piece_queue={"T","I","O","S","Z","J","L"}self:create_new_active_piece()end function n:setup_i_srs_test()for n=14,22do for e=1,10do self.grid[n][e]=5end end self.grid[14][9]=self.grid_spr self.grid[15][9]=self.grid_spr self.grid[16][9]=self.grid_spr self.grid[17][9]=self.grid_spr self.grid[18][9]=self.grid_spr self.grid[18][9]=self.grid_spr self.grid[18][8]=self.grid_spr self.grid[18][7]=self.grid_spr self.grid[18][6]=self.grid_spr self.grid[18][5]=self.grid_spr self.grid[18][5]=self.grid_spr self.grid[19][5]=self.grid_spr self.grid[20][5]=self.grid_spr self.grid[21][5]=self.grid_spr self.grid[22][5]=self.grid_spr self.grid[22][5]=self.grid_spr self.grid[22][4]=self.grid_spr self.grid[22][3]=self.grid_spr self.grid[22][2]=self.grid_spr self.piece_queue={"I","I","I","I","I","I","I"}self:create_new_active_piece()end function n:setup_tspin_special_case_test()for n=1,22do for e=1,10do self.grid[n][e]=self.grid_spr end end for n=20,22do for e=1,10do self.grid[n][e]=5end end self.grid[18][1]=5self.grid[19][1]=5self.grid[18][2]=5self.grid[20][2]=self.grid_spr self.grid[21][2]=self.grid_spr self.grid[22][2]=self.grid_spr self.grid[21][3]=self.grid_spr self.grid[22][3]=self.grid_spr self.piece_queue={"T","I","O","S","Z","J","L"}self:create_new_active_piece()end function I()end function b()end local e={}function e:new()local n={}n.items={"start","mode","music"}n.selected=1n.selected_challenge=1n.dark_map={[7]=6,[6]=6,[5]=1,[1]=5,[12]=13,[13]=1}n.flash_timer=0n.flash_total=8self.__index=self setmetatable(n,self)return n end function e:current_challenge()return r[self.selected_challenge]end function e:update_menu()if(f:blocks_input())return
if self.flash_timer>0do self.flash_timer-=1if(self.flash_timer==0)f:start("menu","playing")
return end if(btnp(2))self.selected-=1sfx(1)
if(btnp(3))self.selected+=1sfx(0)
if(self.selected==2)if btnp(1)do sfx(1)self.selected_challenge=self.selected_challenge%#r+1elseif btnp(0)do sfx(0)self.selected_challenge=(self.selected_challenge-2)%#r+1end
self.selected=mid(1,self.selected,#self.items)if btnp(5)or btnp(4)do if self.selected==1do?"⁷2s4i0v3c3e3g3c4 "
self.flash_timer=self.flash_total elseif self.selected==2do elseif self.selected==3do i=not i if(i==false)music(-1,1000)else music(12,1000)
end end end function e:darken_pixel(n,e)local o=pget(n,e)local o=self.dark_map[o]if(o)pset(n,e,o)else pset(n,e,1)
end function e:bevel_box(n,e,o,l)rect(n-1,e-1,n+o,e+l,7)rect(n-2,e-2,n+o+1,e+l+1,0)for o=0,o-1do for l=0,l-1do self:darken_pixel(n+o,e+l)end end end function e:draw_diagonal_lines()pal(6,129,1)local n=time()*20%16for e=-128,128,8do local o,n=e+n,e+128+n line(o,128,n,0,6)end end function e:draw_cursor(o,l,n)n=n or 1local d={2,3,4,5,4,3,2}for e=0,6do for d=1,d[e+1]-2do pset(o+d*n,l+e,7)end end end function e:draw_menu_items(e,o,l,n)self:bevel_box(e,o,l,n)local t=#self.items local d=n/t for n=1,t do local t=o+(n-1)*d if(n==self.selected)rectfill(e,t,e+l-1,t+d,1)
local o=self.items[n]if n==2do o="mode: "..self:current_challenge().name elseif n==3do o="music "..(i and"on"or"off")end local f=#o*4local e,l,d=e+(l-f)/2,t+(d-6)/2+1if(n==self.selected and self.flash_timer>0)d=self.flash_timer%4==0and 7or 5else d=n==self.selected and 7or 5
?o,e,l,d
if(n==self.selected and n==2)self:draw_cursor(e+f+1,l-1,1)self:draw_cursor(e-3,l-1,-1)
end self:draw_challenge_description(o,n)end function e:draw_challenge_description(n,e)local o=self:current_challenge().label local o,n=split(o),n+e+5for e in all(o)do local o=#e*4?e,(127-o)/2,n,5
n+=6end end function e:draw_menu()self:draw_diagonal_lines()local n=time()local n=sin(n*.5)*2circfill(63.5,14.5+n+19,31,0)circfill(63.5,14.5+n+19,30,1)for n=1,15do pal(n,k[n])end spr(16,34.5,14.5+n+2,62,38)pal(0)spr(16,32.5,14.5+n,62,38)self:draw_menu_items(28.5,72,70,37)end local o={}o.__index=o local d={0,32768,32896,34952,54613,43690,61149,61166,-18,-1}local l=#d function o:new()local n={}n.active=false n.target_mode=nil n.timer=0n.duration=30n.phase="idle"setmetatable(n,self)return n end function o:start(n,e)music(-1,1000*self.duration/60)self.active=true self.from_mode=n self.target_mode=e self.timer=0self.phase="fade_out"end function o:blocks_input()return self.active end function o:update()if(not self.active)return
self.timer+=1if self.phase=="fade_out"and self.timer>=self.duration do O(self.target_mode)self.phase="fade_in"self.timer=0if(self.target_mode=="playing"and i)music(21,1000*50/60,1)
if(self.target_mode=="menu"and i)music(12,1000*50/60,1)
elseif self.phase=="fade_in"and self.timer>=self.duration do self.active=false self.phase="idle"end end function o:draw()if(self.phase=="idle")return
local e,n=min(self.timer/self.duration,1)if(self.phase=="fade_in")n=flr(e*(l-1))+1else n=l-flr(e*(l-1))
fillp(d[n]+.5)rectfill(0,0,127,127,0)fillp()end function _init()cartdata"lex_yapt"poke(24366,1)k={[0]=0,0,1,1,2,1,5,6,2,4,9,3,1,1,2,5}c="menu"m=e:new()f=o:new()i=true music(12)end function _update60()if c=="playing"do x:update_world()I()elseif c=="menu"do m:update_menu()end f:update()end function _draw()cls(0)if c=="playing"do x:draw_world()b()elseif c=="menu"do m:draw_menu()end if(f.active)f:draw()
end function O(e)pal()if(e=="playing")x=n:new(m:current_challenge())
c=e end
__gfx__
0000000077777600eeeee800aaaaa90077777f0066666d0077777a00fffffe000000000000000000000000000000000000000000000000000000000000000000
0000000076666500e8888200a99994007ffffe006dddd1007aaaa900feeee2000000000000000000000000000000000000000000000000000000000000000000
0000000076666500e8888200a99994007ffffe006dddd1007aaaa900feeee2000000000000000000000000000000000000000000000000000000000000000000
0000000076666500e8888200a99994007ffffe006dddd1007aaaa900feeee2000000000000000000000000000000000000000000000000000000000000000000
0000000076666500e8888200a99994007ffffe006dddd1007aaaa900feeee2000000000000000000000000000000000000000000000000000000000000000000
00000000655555008222220094444400feeeee00d1111100a9999900e22222000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000000000000000000000000000000000000000000000000000000000000000000
d111111111111111111111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000
d18888888881aaaaaaaaa1aaaaaaaaa1bbbbbbbbb1111ccc11eeeeeeeee11d000000000000000000000000000000000000000000000000000000000000000000
d18888888881aaaaaaaaa1aaaaaaaaa1bbbbbbbbbb111ccc11eeeeeeeee11d000000000000000000000000000000000000000000000000000000000000000000
d18888888881aaaaaaaaa1aaaaaaaaa1bbbbbbbbbb111ccc11eeeeeeee111d000000000000000000000000000000000000000000000000000000000000000000
d11118888111aaaa11111111aaaa1111bbbb11bbbb111ccc11eeee1111111d000000000000000000000000000000000000000000000000000000000000000000
d11118888111aaaa11111111aaaa1111bbbb11bbbb111ccc11eeeee111111d000000000000000000000000000000000000000000000000000000000000000000
d11118888111aaaaaaaaa111aaaa1111bbbb1bbbbb111ccc11eeeee111111d000000000000000000000000000000000000000000000000000000000000000000
d11118888111aaaaaaaaa11199991111333b1bbbbb111ccc111eeeee11111d000000000000000000000000000000000000000000000000000000000000000000
d11118888111aaaaaa441111999911113333333bb1111ccc1111eeeee1111d000000000000000000000000000000000000000000000000000000000000000000
d11118888111aa4444441111999911113333133333111dcc11111eeeee111d000000000000000000000000000000000000000000000000000000000000000000
d11118888111444411111111999911113333113333111ddd11111eeeeee11d000000000000000000000000000000000000000000000000000000000000000000
d11118882111444411111111999911113333113333311ddd1111112eeee11d000000000000000000000000000000000000000000000000000000000000000000
d11118822111444444444411999911113333111333331ddd122222222ee11d000000000000000000000000000000000000000000000000000000000000000000
d11118222111444444444411999911113333111133331ddd1222222222211d000000000000000000000000000000000000000000000000000000000000000000
d11112222111144444444411999911113333111133331ddd1222222222211d000000000000000000000000000000000000000000000000000000000000000000
d11112222111144444444411999911113333111113331ddd1222222222111d000000000000000000000000000000000000000000000000000000000000000000
d111111111111111111111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000
d111111111111111111111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000
ddddddddddddddddddddd11111111111111111111ddddddddddddddddddddd000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000d11111111111111111111d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000d11111111111111111111d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000d11111111111111111111d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000d11111111111111111111d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000d11111111111111111111d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000d11111111111111111111d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000d11111111111111111111d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000d11111111111111111111d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000d11111111111111111111d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000d11111111111111111111d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000d11111111111111111111d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000d11111111111111111111d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000d11111111111111111111d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000d11111111111111111111d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000d11111111111111111111d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000d11111111111111111111d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000d11111111111111111111d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000dddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000400002152526535005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000300002f73534735000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300003053534535044000440010400044000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800000255002551035510455005550065500755008550095500d55010550135001850019500245002350000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400002472526725297252e7253072532725357253a7252400526005290052e0053000532005350053a00500000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000471005721067310c74110751077510070000700007001970000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
0112000015753047000500005700070000770009000097000b0000b7000c0000c7000c000180000c000180000c000180000c00018000210022100221002000000000000000000000000000000000000000000000
0004000006033047000000005700000000770009000097000b0000b7000c0000c7000c000180000c000180000c000180000c00018000210022100221002000000000000000000000000000000000000000000000
011800200c0151001515015170150c0151001515015170150c0151001513015180150c0151001513015180150c0151101513015150150c0151101513015150150c0151101513015150150c015110151301515015
010c0020102151c0071c007102151c0071c007102151c007000001021510005000001021500000000001021013215000001320013215000001320013215000001320013215000001320013215000001320013215
0130002000010000100001000010020100201004010040100501005010050100501005010050100501005010070100701007010070100b0100b0100b0100b0100c0100c0100c0100c0100c0100c0100c0100c010
01180020071000e1000a1000e100071000e1003701033000071002f0000a1000e100071000e1000a1000e100081000f1000c1000f100081000f1000c1000f100081000f1000c1000f100081000f1000c1000f100
013000202871028710287102871026710267101c7101c7101d7101d7101d7101d7101d7101d7101d7101d71023710237102371023710267102671026710267101c7101c7101c7101c7101c7101c7101c7101c710
01180020010130170000000010131f613000000000000000010130000000000000001f613000000000000000010130000000000010131f613000000000000000010130000001013000001f613000000000000000
01180020176151761515615126150e6150c6150b6150c6151161514615126150d6150e61513615146150e615136151761517615156151461513615126150f6150e6150a615076150561504615026150161501615
011800101151300000000001051300000000000e51300000000000c513000000b5130951300003075130c00300000000000000000000000000000000000000000000000000000000000000000000000000000000
011800200e0151001511015150150e0151001511015150150e0151001511015150150e0151001511015150150c0150e01510015130150c0150e01510015130150c0150e01510015130150c0150e0151001513015
0112000003734030150a7040a005137341301508734080151b7110a704037340301524615080140a7340a01508734087150a7040c0141673416015167151651527515140140c7340c015220152e015220150a515
011200000c023247151f5152271524615227151b5051b5151f5101f5101f5121f510225112251022512225150c0231b7151b5151b715246151b5151b5051b515275102751027512275151f5111f5101f5121f515
011200000c0230801508734080150871508034187151b7151b7000f0151173411015246150f0140c7340c0150c0230801508734080150871508034247152b715275020f0151173411015246150f0140c7340c015
011200002451024510245122451524615187151b7151f71527510275102751227515246151f7151b7151f715295102b5112b5122b5152461524715277152e715275002e715275022e715246152b7152771524715
011200002351023510235122351524615177151b7151f715275102751027512275152461523715277152e7152b5102c5112c5102c5102c5102c5122c5122c5122b5102b5102b5122b515225151f5151b51516515
011200000c0230801508734080150871508034177151b7151b7000f0151173411015246150f0140b7340b0150c0230801508734080150871524715277152e715080142e715080142e715246150f0140c7340c015
01180020071150e1150a1150e115071150e1150a1150e115071150e1150a1150e115071150e1150a1150e115051150c115081150c115051150c115081150c115051150c115081150c115051150c117081150c115
01180020071150e1150a1150e115071150e1150a1150e115071150e1150a1150e115071150e1150a1150e115081150f1150c1150f115081150f1150c1150f115081150f1150c1150f115081150f1170c1150f115
011800201301015010160101601016010160151301015010160101601016010160151601015010160101a01018010160101801018010180101801018010180150000000000000000000000000000000000000000
011800201301015010160101601016010160151301015010160101601016010160151601015010160101a0101b0101b0101b0101b0101b0101b0101b0101b0150000000000000000000000000000000000000000
011800202271024710267102671026710267152271024710267102671026710267152671024710267102971027710267102471024710247102471024710247150000000000000000000000000000000000000000
01180020227102471026710267102671026715227102471026710267102671026715267102471026710297102b7102b7102b7102b7102b7102b7102b7102b7150000000000000000000000000000000000000000
01180020081150f1150c1150f115081150f1150c1150f115081150f1150c1150f115081150f1150c1150f115071150e1150a1150e115071150e1150a1150e115071150e1150a1150e115071150e1170a1150e115
011800201b1101a1101b1101b1101b1101b1151b1101a1101b1101b1101b1101b1151b1101a1101b1101f1101a110181101611016110161101611016110161150000000000000000000000000000000000000000
01180020081150f1150c1150f115081150f1150c1150f115081150f1150c1150f115081150f1150c1150f1150a115111150e115111150a115111150e115111150a115111150e115111150a115111150e11511115
011800201b1101a1101b1101b1101b1101b1151b1101a1101b1101b1101b1101b1151b1101a1101b1101f1101d1101d1101d1101d1101d1101d1101d1101d1150000000000000000000000000000000000000000
011800202b710297102b7102b7102b7102b7152b710297102b7102b7102b7102b7152b710297102b7102e71029710277102671026710267102671026710267150000000000000000000000000000000000000000
011800202b710297102b7102b7102b7102b7152b710297102b7102b7102b7102b7152b710297102b7102e7102e7102e7102e7102e7102e7102e7102e7102e7150000000000000000000000000000000000000000
010d00200c0001b50019500195002070020700145001450018600317001d5001d500125000c00014500145000c0000150019500195000d500205001450014500186003170020500205000d5000c000145000c000
001a00000a7000a00011700110000d7000d00005700050000670006000147001400011700110000d7000d0000a7000a00011700110000d7000d00008700080000370003000127001200011700110000d7000d000
010d00200c0001b500295002950020700207002c5002c50018600315003150031500295000c00029500295000c0000150025500255000d500205002050020500186003170020500205000d5000c000145000c000
01180020071000e1000a1000e100071000e1000a1000e100071000e1000a1000e100071000e1000e100051000c1000c100081000c100051000c100081000c100051000c100081000c10000000000000000000000
011800200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00040000215002650000500005000050000500005002f000005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000300002f70034700000000000000000270000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300003050034500044000440010400044000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800000250002500035000450005500065000750008500095000d50010500135001850019500245002350000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400002470026700297002e7003070032700357003a7002400026000290002e0003000032000350003a00000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000470005700067000c70010700077000070000700007001970000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
0012000015700047000500005700070000770009000097000b0000b7000c0000c7000c000180000c000180000c000180000c00018000210002100021000000000000000000000000000000000000000000000000
0004000006000047000000005700000000770009000097000b0000b7000c0000c7000c000180000c000180000c000180000c00018000210002100021000000000000000000000000000000000000000000000000
000300000c1000e100101001210013100141001510015100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000006400084000d4000f4001a400214002240000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400
00180020010000170000000010001f600000000000000000010000000000000000001f600000000000000000010000000000000010001f600000000000000000010000000001000000001f600000000000000000
01180020071000e1000a1000e100071000e1000a1000e1000a1000e100071000e1000a1000e100081000f1000c1000f100081000f1000c1000f100081000f1000c1000f100081000f1000c1000f1000000000000
011800201300015000160001600016000160001300015000160001600016000160001600015000160001a00018000160001800018000180001800018000180000000000000000000000000000000000000000000
011800201300015000160001600016000160001300015000160001600016000160001600015000160001a0001b0001b0001b0001b0001b0001b0001b0001b0000000000000000000000000000000000000000000
001800202470026700267002670026700227002470026700267002670026700267002470026700297002770026700247002470024700247002470024700000000000000000000000000000000000000000000000
01180020227002470026700267002670026700227002470026700267002670026700267002470026700297002b7002b7002b7002b7002b7002b7002b7002b7000000000000000000000000000000000000000000
00180020081000f1000c1000f100081000f1000c1000f100081000f1000c1000f100081000f1000c1000f100071000e1000a1000e100071000e1000a1000e100071000e1000a1000e100071000e1000a1000e100
001800201b1001a1001b1001b1001b1001b1001b1001a1001b1001b1001b1001b1001b1001a1001b1001f1001a100181001610016100161001610016100161000000000000000000000000000000000000000000
0110000024040280402b0403004130032300220f100081000f1000c1000f1000a100111000e100111000a100111000e100111000a100111000e100111000a100111000e100111000000000000000000000000000
011800001c0401c0401804018040160401604013033130231b1001b1001b1001b1001b1001a1001b1001f1001d1001d1001d1001d1001d1001d1001d1001d1000000000000000000000000000000000000000000
0006000020113297002b7002b7002b7002b7002b700297002b7002b7002b7002b7002b700297002b7002e70029700277002670026700267002670026700267000000000000000000000000000000000000000000
000800000a1132b7002b7002b7002b7002b700297002b7002b7002b7002b7002b700297002b7002e7002e7002e7002e7002e7002e7002e7002e7002e700000000000000000000000000000000000000000000000
0003000004750047500a7500a75000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00060000007531a603006030570305703047030470307703037030060300603006030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
__music__
01 08084243
00 09094308
00 0a094308
00 0c0a0d08
00 0c0a0d08
00 0a414308
00 0e094508
00 0a0e0d08
00 0a0c0d08
00 0a0c0d08
02 0f090f10
00 73757772
00 11424344
00 11424344
00 11124344
00 11124344
01 11124344
00 11124344
00 13144344
02 15164344
00 41424344
01 1745430d
00 1842430d
00 17194344
00 181a4344
00 17191b0d
00 181a1c0d
00 1d1e4344
00 1f204344
00 1d1e210d
02 1f20220d
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000001111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000006600660066066606660000000006660000000
00000000000000000000000001111111111111111111111111111111111111111111111111111111111110000060006000606060606000060000006060000000
00000000000000000000000001111111111111111111111111111111111117777767777767777767777760000066606000606066006600000000006060000000
00000000000000000000000001000011000011000011000011000011000017666657666657666657666650000000606000606060606000060000006060000000
00000000000000000000000001000011000011000011000011000011000017666657666657666657666650000066000660660060606660000000006660000000
00000000000000000000000001000011000011000011000011000011000017666657666657666657666650000000000000000000000000000000000000000000
70000000000000000000000001000011000011000011000011000011000017666657666657666657666650000000000000000000000000000000000000000000
07000000000000000000000001111111111111111111111111111111111116555556555556555556555550000000000000000000000000000000000000000000
007000000000000000000000011111111111111111111111111111111111111111111111111111111111100000000000077777f77777f0000000000000000000
07000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000007ffffe7ffffe0000000000000000000
70000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000007ffffe7ffffe0000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000007ffffe7ffffe0000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000007ffffe7ffffe0000000000000000000
0000000000000000000000000111111111111111111111111111111111111111111111111111111111111000000000000feeeeefeeeee0000000000000000000
000000000000000000000000011111111111111111111111111111111111111111111111111111111111100000077777f77777f0000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000007ffffe7ffffe0000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000007ffffe7ffffe0000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000007ffffe7ffffe0000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000007ffffe7ffffe0000000000000000000000000
0000000000000000000000000111111111111111111111111111111111111111111111111111111111111000000feeeeefeeeee0000000000000000000000000
00000000000000000000000001111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000
00000000000000000000000001111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000
00000000000000000000000001111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000
00000000000000000000000001111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000
00000000000000000000000001111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000
00000000000000000000000001111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000
00000000000000000000000001111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000
00000000000000000000000001111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000
00000000000000000000000001111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000
00000000000000000000000001111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000
00000000000000000000000001111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000
00000000000000000000000001111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000
00000000000000000000000001111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000
00000000000000000000000001111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000
00000000000000000000000001111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000011000011000011000011000010000000000000000000000000000000000000000000
00000000000000000000000001111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000000
000000000000000000000000011111111111111111111111111111111111166666d66666d66666d66666d0000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000016dddd16dddd16dddd16dddd10000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000016dddd16dddd16dddd16dddd10000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000016dddd16dddd16dddd16dddd10000000000000000000000000000000000000000000
00000000000000000000000001000011000011000011000011000011000016dddd16dddd16dddd16dddd10000000000000000000000000000000000000000000
0000000000000000000000000111111111111111111111111111111111111d11111d11111d11111d111110000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__meta:title__
TetrisPieces are represented by 4x4 matrices, where 1s represent blocks and 0s represent empty space.
- @class TetrisPiece
