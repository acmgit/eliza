-- rnd 2016 
-- fixed and adapted for minetest, added possibility of several variations in responses


------------------------------------------------------------------------
-- Joseph Weizenbaum's classic Eliza ported to SciTE Version 2
-- Kein-Hong Man <khman@users.sf.net> 20060905
-- This program is hereby placed into PUBLIC DOMAIN
------------------------------------------------------------------------

------------------------------------------------------------------------
-- Original ELIZA paper:
--   ELIZA--A Computer Program For the Study of Natural Language
--   Communication Between Man and Machine,
--   Joseph Weizenbaum, 1966, Communications of the ACM Volume 9,
--   Number 1 (January 1966): 36-35.
--   URL: http://i5.nyu.edu/~mm64/x52.9265/january1966.html

eliza = {}
local S = nil

if(minetest.get_translator) then
    print("Übersetze: " .. minetest.get_current_modname())
   S = minetest.get_translator(minetest.get_current_modname())

else
    S = function ( s ) return s end

end

eliza.S = S

-- SETTINGS
eliza.elizachatcharacter = " "; -- chat must begin with this character to trigger eliza response!
eliza.elizatarget = ""; -- player with this name gets response from eliza when he talks

-- END OF SETTINGS


 -- randomly selected replies if no keywords
eliza.randReplies = {
    S("what does that suggest to you?"),
    S("i see..."),
    S("i'm not sure i understand you fully."),
    S("can you explain that?"),
    S("that is quite interesting!"),
    S("that's so interesting... please continue..."),
    S("i understand..."),
    S("well, well... do go on"),
    S("why are you saying that?"),
    S("please explain the background to that remark..."),
    S("could you say that again, in a different way?"),
  }

  -- keywords, replies: if reply ends with something thats not a letter it wont transform sentence.
  
eliza.replies = {
	[S(" how to")] = {"@" .. S("howto")}, -- this will trigger special response, useful to ask things like: how to craft apple?
	[S(" how do i")] = {"@" .. S("howto")},
	
	[S(" hi")] = {S("hello."), "hi.",S("hello, how are you today.")},
	[S(" hello")] = {S("hello."), "hi.",S("hello, how are you today.")},
	[S(" can you")] = {S("perhaps you would like to be able to"),S("Don't you believe that I can"),S("You want me to be able to")},
    [S(" do you")] = {S("yes, i"), S("i dont always")},
    [S(" can i")] = {S("Do you want to be able to"),S("perhaps you don't want to be able to")},
    [S(" you are")] = {S("what makes you think i am"),S("Does it please you to believe I am"),S("Perhaps you would like to be"),S("Do you sometimes wish you were")},
    [S(" you're")] = {S("what is your reaction to me being")},
    [S(" i don't")] = {S("why don't you"),S("Don't you really"),S("Do you wish to be able to"),S("Does that trouble you?")},
    [S(" i feel")] = {S("tell me more about feelings"),S("Do you often feel"),S("Do you enjoy feeling")},
    [S(" why don't you")] = {S("why would you want me to"),S("Do you really believe I don't"), S("Perhaps in good time I will"),S("Do you want me to")},
    [S(" why can't i")] = {S("what makes you think you should be able to"),S("Why can't you")},
    [S(" are you")] = {S("why are you interested in whether or not i am"),S("Would you prefer if I were not"),S("Perhaps in your fantasies I am")},
    [S(" i can't")] = {S("how do you know you can't"),S("Have you tried?"),S("Perhaps you can now")},
    [S(" sex")] = {S("i feel you should discuss this with a human.")},
    [S(" i am")] = {S("how long have you been"),S("Did you come to me because you are"),S("How long have you been"),S("Do you believe it is normal to be"),S("Do you enjoy being")},
    [S(" i'm")] = {S("how long have you been"),S("Did you come to me because you are"),S("How long have you been"),S("Do you believe it is normal to be"),S("Do you enjoy being")},
    [S(" i want")] = {S("why do you want"), S("What would it mean to you if you got"),S("Suppose you got"),S("What if you never got"),
	S("I sometimes also want")},
    [S(" what")] = {
		S("what do you think?"),S("Why do you ask?"),S("Does that question interest you?"),S("What answer would please you the most?"), S("Are such questions on your mind often?"),	S("What is it that you really want to know?"),
		S("Have you asked anyone else?"),	S("Have you asked such questions before?"), S("What else comes to mind when you ask that?")
		},
    [S(" how")] = {
		S("what do you think?"),S("Why do you ask?"),S("Does that question interest you?"),S("What answer would please you the most?"), S("Are such questions on your mind often?"),	S("What is it that you really want to know?"),
		S("Have you asked anyone else?"),	S("Have you asked such questions before?"), S("What else comes to mind when you ask that?")
		},
    [S(" who")] = {
		S("what do you think?"),S("Why do you ask?"),S("Does that question interest you?"),S("What answer would please you the most?"), S("Are such questions on your mind often?"),	S("What is it that you really want to know?"),
		S("Have you asked anyone else?"),	S("Have you asked such questions before?"), S("What else comes to mind when you ask that?")
		},
    [S(" where")] = {
		S("what do you think?"),S("Why do you ask?"),S("Does that question interest you?"),S("What answer would please you the most?"), S("Are such questions on your mind often?"),	S("What is it that you really want to know?"),
		S("Have you asked anyone else?"),	S("Have you asked such questions before?"), S("What else comes to mind when you ask that?")
		},
    [S(" when")] = {
		S("what do you think?"),S("Why do you ask?"),S("Does that question interest you?"),S("What answer would please you the most?"), S("Are such questions on your mind often?"),	S("What is it that you really want to know?"),
		S("Have you asked anyone else?"),	S("Have you asked such questions before?"), S("What else comes to mind when you ask that?")
		},
    [S(" why")] = {
		S("what do you think?"),S("Why do you ask?"),S("Does that question interest you?"),S("What answer would please you the most?"), S("Are such questions on your mind often?"),	S("What is it that you really want to know?"),
		S("Have you asked anyone else?"),	S("Have you asked such questions before?"), S("What else comes to mind when you ask that?")
		},
	[S(" name")] = {S("Names don't interest me."), S("I don't care about names, please go on.")},
	[S(" cause")] = {
		S("Is that the real reason?"),
		S("Don't any other reasons come to mind?"),
		S("Does that reason explain anything else?"),
		S("What other reasons might there be?")
		},
	[S(" perhaps")] = {S("you're not very firm on that!")},
    [S(" drink")] = {S("moderation in all things should be the rule.")},
    [S(" sorry")] = {
		S("why are you apologizing?"),
		S("Please don't apologise!"),
		S("Apologies are not necessary."),
		S("What feelings do you have when you apologise?"),
		S("Don't be so defensive!")
		},
    [S(" dream")] = {
	S("why did you bring up the subject of dreams?"),
	S("What does that dream suggest to you?"),
    S("Do you dream often?"),
    S("What persons appear in your dreams?"),
    S("Are you disturbed by your dreams?")
	},
    [S(" i like")] = {S("is it good that you like")},
    [S(" maybe")] = {
		S("You don't seem quite certain."),
		S("Why the uncertain tone?"),
		S("Can't you be more positive?"),
		S("You aren't sure?"),
		S("Don't you know?")
		},
    [S(" no")] = {
		S("why are you being negative?"),
		S("Are you saying no just to be negative?"),
		S("You are being a bit negative."),
		S("Why not?"),
		S("Are you sure?"),
		S("Why no?")		
		},
    [S(" your")] = {S("why are you concerned about my"),S("What about your own")},
    [S(" always")] = {
		S("can you think of a specific example?"),
		S("When?"),
		S("What are you thinking of?"),
		S("Really, always?")
		},
    [S(" think")] = {
		S("do you doubt"),
		S("Do you really think so?"),
		S("But you are not sure your"),
		},
	[S(" alike")] = {
		S("In what way?"),
		S("What resemblence do you see?"),
		S("What does the similarity suggest to you?"),
		S("What other connections do you see?"),
		S("Could there really be some connection?"),
		S("How?"),
		S("You seem quite positive.")	
		},
    [S(" yes")] = {S("you seem quite certain. why is this so?"),S("Are you Sure?"),
    S("I see."),S("I understand.")},
    [S(" friend")] = {
		S("why do you bring up the subject of friends?"),
		S("Why do you bring up the topic of friends?"),
		S("Do your friends worry you?"),
		S("Do your friends pick on you?"),
		S("Are you sure you have any friends?"),
		S("Do you impose on your friends?"),
		S("Perhaps your love for friends worries you.")
		},
    [S(" computer")] = {
	S("why do you mention computers?"),
	S("Do computers worry you?"),
    S("Are you frightened by machines?"),
    S("What do you think machines have to do with your problems?"),
    S("Don't you think computers can help people?"),
    S("What is it about machines that worries you?")
	},
    [S(" am i")] = {S("you are")},
	
  }

  -- conjugate
eliza.conjugate = {
    [S(" i ")] = S("you"),
    [S(" are ")] = S("am"),
    [S(" were ")] = S("was"),
	[S(" was ")] = S("were"),
    [S(" you ")] = S("me"),
    [S(" your ")] = S("my"),
	[S(" my ")] = S("your"),
	[S(" mine ")] = S("your's"),
	[S(" your's ")] = S("mine"),
	[S(" myself ")] = S("yourself"),
    [S(" i've ")] = S("you've"),
    [S(" i'm ")] = S("you're"),
    [S(" me ")] = S("you"),
	[S(" you ")] = S("me"),
    [S(" am i ")] = S("you are"),
    [S(" am ")] = S("are"),
  }


eliza.howto = function(text)
eliza.craft = function (text) -- will say out recipe to player
		
eliza.recipe = "";
eliza.searchlists = {minetest.registered_items,minetest.registered_nodes,minetest.registered_craftitems,minetest.registered_tools}
eliza.mkeylength = 99;
eliza.mrecipe = "";
		
		for _,list in ipairs(eliza.searchlists) do
			if recipe=="" then
				for key,_ in pairs(list) do
					if string.find(key,text) then 
						if string.len(key)<mkeylength then 
							mkeylength = string.len(key);
							
							recipe = minetest.get_craft_recipe(key);
						
							if recipe.type and recipe.items then
								recipe = S("To make ") .. key .. S(" do ") .. recipe.type .. S(" recipe with ingredients ") .. dump(recipe.items); 
								recipe = string.gsub(recipe, "\n", ""); -- remove newlines
								mrecipe = recipe;
							else
								recipe = "";
							end
						end
						
					end
				end
			end
		end
		
		if mrecipe == "" then mrecipe = S("There is no craft item with the name ") .. text end
		return mrecipe

	end

	local get = function (text) -- 
		local node = "";
		local mkeylength = 99;
		local y_max = -99999;
		local def;
		
		for _,v in pairs(minetest.registered_ores) do
		
			if string.find(v.ore,text) then 
				if string.len(v.ore)<=mkeylength then 
					mkeylength = string.len(v.ore);
					node = v.ore;
					def = v;
					if v.y_max and v.y_max<0 and v.y_max>y_max then y_max=v.y_max end
				end
			end
		end
		
		if y_max == -99999 then y_max = 0 end
		
		if node == "" then 
			node = S("There is no material with that name. Perhaps you need to craft it?") 
		else
			
			if y_max<0 then
				node = S("Full name of material is ") .. node .. S(" You can find it if you dig down at least ") .. -y_max .. S(" blocks .")
			else 
				if def.wherein then
					node = S("Full name of material is ") .. node .. S(" You can find it if you dig around in ") .. dump(def.wherein);
				end
			end
		end
		
		return node;
	end

	local topic = {[S("craft")]=eliza.craft,[S("make")]=eliza.craft,[S("get")]=get,[S("find")]=get};
	
	-- process input
	for key,v in pairs(topic) do
		local i = string.find(text,key);
		if i then
			return v(string.sub(text,i+string.len(key)+1));
		end
	end
	
	return "";

end

  

local function Eliza(text)
  local response = ""
  local user = string.lower(text)
  local userOrig = user

 
  -- random replies, no keyword
  local function replyRandomly()
    response = eliza.randReplies[math.random(#eliza.randReplies)]; --.."\n"
  end

  -- find keyword, phrase
  local function processInput()
    for keyword, reply in pairs(eliza.replies) do
      local d, e = string.find(user, keyword, 1, 1) -- check user message keyword against list of keyword, reply pairs
  
	  reply = reply [ math.random(#reply) ] ; -- select random reply from many possibilities
	  
	  if d then
        
		if string.byte(reply,1) == 64 then -- @
			local info = eliza.howto(string.sub(user, e+1, -2)); 
			if info and info ~= "" then 
				response = info return 
			else
				
				replyRandomly()
				reply = response; response = "";
			end
		end
		
		-- process keywords
        response = response..reply.." "

        if string.byte(string.sub(reply, -1)) < 65 then -- not an alphabet character in response. return response!
          --response = response.."\n"; 
		  return response
        end
        
		local h = string.len(user) - (d + string.len(keyword))
        if h > 0 then
          user = string.sub(user, -h) -- remainder of user msg after phrase
        end
		
        for cFrom, cTo in pairs(eliza.conjugate) do -- do conjugate replacements on remainder
          local f, g = string.find(user, cFrom, 1, 1)
          if f then
            local j = string.sub(user, 1, f - 1).." "..cTo
            local z = string.len(user) - (f - 1) - string.len(cTo) -- again remainder length
            response = response..j; 
			
			if z > 2 then
              local l = string.sub(user, -(z - 1))
			  if l and not string.find(userOrig .. " ", l) then 
				return response 
			  end
            end
            if z > 2 then response = response.. " " .. string.sub(user, -(z - 1)) end 
            if z < 2 then response = response end
            return response
          end
        end
        response = response..user
        return response
      end
    end
	
	
    replyRandomly()
    return response
  end

  -- main()
  -- accept user input
  
  if string.sub(user, 1, 3) == S("bye") then
    response = S("bye, bye for now.") .. "\n" .. S("see you again some time.")
	return response
  end
  if string.sub(user, 1, 7) == S("because") then
    user = string.sub(user, 8)
  end
  user = " "..user.." "
   
  
  processInput()
   
  return response
end



local lastmessage;

minetest.register_on_chat_message(
function(name, message)

	if string.char(string.byte(message,1)) ~= eliza.elizachatcharacter and name~=eliza.elizatarget then return false end -- chat must begin with special character
	local response 
	if message == lastmessage then
		response = S("Please don't repeat yourself!")
	else
		response = string.lower(Eliza(message));
	end
	lastmessage = message;
	
	local players = minetest.get_connected_players(); -- to prevent msg duplication
	for _,player in pairs(players) do
		local pname = player:get_player_name();
		if pname~=name then
			minetest.chat_send_player(pname,"<"..name .. "> " .. message);
		end
	end
	
	minetest.chat_send_all("<Eliza> " .. response)
	return true
end
)



minetest.register_chatcommand("elizatarget", {
	description = "",
	privs = {
		privs = true
	},
	func = function(name, param)
		eliza.elizatarget = param;
	end
});

	
-- http functionality
--package.path = package.path..";"..minetest.get_modpath("eliza").."/?.lua";
--package.cpath = package.cpath..";"..minetest.get_modpath("eliza").."/?.dll";
--local socket = require("socket.core") -- why does this crash server

--this works
--local tcp = package.loadlib(minetest.get_modpath("eliza").."/core.dll","tcp");
--print("eliza tcp loaded");
