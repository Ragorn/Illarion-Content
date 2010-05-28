-- empty container with drink

-- UPDATE common SET com_script='item.bottles' WHERE com_itemid IN (2500, 2496, 2497, 2501, 2499);

-- uses items of the new client - don't put this on the RS yet!
require("base.common")

module("item.bottles", package.seeall)

function InitDrinks()  -- initialisiert die coolen softdrinks in da hood.
    if ( drinkList == nil) then
        -- item ID,  food value,  leftover item
        drinkList={};
        drinkList[2500] = {  "Weinflasche", "bottle of wine", 2498,
        {{1858, 1860}, {224, 1857}, {2055, 2057}, {1840, 1842}, {2185, 2187}} };  -- Kelch, Goldkelch, Glas, Kupferkelch, Holzbecher

        drinkList[2496] = {  "Wasserflasche", "bottle of water", 2498,
        { {1858, 1855}, {224, 1854}, {2055, 2058},{1840, 1841}, {2185, 2186} } };

        drinkList[2497] = {  "Metflasche", "bottle of mead", 2498,
        { {1858, 1853}, {224, 1856}, {2055, 2056},{1840, 1843}, {2185, 2188} } };

        drinkList[2501] = {  "Bierflasche", "bottle of dark beer", 2498,
        { {1908, 1909} } };             -- Krug

        drinkList[2499] = {  "Ciderflasche", "bottle of cider", 2498,
        { {1858, 1859}, {224, 1861},{2055, 2059},{1840, 1844}, {2185, 2189} } };

        -- init german descriptions
        BottleQualDe={"randvolle ","volle ","halbvolle ","fast leere "};
        BottleQualEn={"brimfull ", "full ","half full ","almost empty "};

        BottleQualLm={8,6,3,1};
    end
end



function UseItem(User,SourceItem,TargetItem,Counter,Param)
    --User:inform("drinking");
    if firstcall==nil then
        InitDrinks();
        --User:inform("drinking2");
        firstcall=1;
        --User:inform("ini");
    end
    MegaPotion=false;
    --User:inform("Hier");
    --User:inform("Test= "..SourceItem.id)

    local progress = User:getQuestProgress(1);
    --if blessed water and
    --   (not drank before) or (not drank this month)
    if (SourceItem.id==2496 and SourceItem.data==3) then
        if ( ((LuaAnd( progress, 128 ) == 0) or
           (LuaAnd( progress, 61440 ) ~= (world:getTime("month")-1)*4096)) ) then  -- cool bottle
		User:increaseAttrib("hitpoints", 10000);
		User:increaseAttrib("mana", 10000);
		User:setPoisonValue(0);
		User:increaseAttrib("foodlevel", 30000);
		User:setMentalCapacity(0);
		User:tempChangeAttrib("constitution", 250, 60);
		--User:inform("You're going to drink that megapotion, sucker");
		world:erase(SourceItem,1);
		world:gfx( 53, User.pos );
		world:makeSound( 12, User.pos );
		progress = LuaOr( progress, 128 ); -- set "drank at least once"
		progress = LuaAnd( progress, 4294905855 ); -- clear bit 13-16 (last month when used)
		progress = LuaOr( progress, (world:getTime("month")-1)*4096 ); -- set bit 13-16 (last month when used)
		User:setQuestProgress( 1, progress );
        else
		base.common.InformNLS( User,
		"Pl�tzlich kommen dir aus unerkl�rlichen Gr�nden Bedenken die Flasche zu auszutrinken.",
		"Suddenly you begin to doubt whether it would be wise to quaff this potion");
        end;
    else
        local food = drinkList[ SourceItem.id ];
        if (food ~= nil ) then

            -- bottle in hand
            if( User:countItemAt("body", SourceItem.id) > 0) then

                -- search target container
                for i, combo in pairs(food[4]) do
                    if combo[1] == TargetItem.id then

                        -- glass in hand or belt
                        if( User:countItemAt("belt", combo[1]) > 0) or (User:countItemAt("body", combo[1]) > 0) then

                            -- fill drink
                            if (TargetItem.number > 1) then
                                world:erase( TargetItem, 1 );
                                User:createItem( combo[2], 1, 333,0);
                            else
                                TargetItem.id = combo[2];
                                world:changeItem(TargetItem);
                            end
                            world:makeSound(10,User.pos)

                            -- create leftovers
                            if( SourceItem.quality > 199 ) then
                                -- reduce one portion
                                world:changeQuality( SourceItem, -100 );
                            else
                                if( math.random( 50 ) <= 1 ) then
                                    base.common.InformNLS( User,
                                    "Die leere Flasche ist angeschlagen und unbrauchbar.",
                                    "The empty bottle is broken and no longer usable.");
                                    world:erase(SourceItem,1);
                                else
                                    SourceItem.id = food[3];
                                    SourceItem.quality = 333;
                                    world:changeItem(SourceItem);
                                end
                            end

                        else
                            base.common.InformNLS( User,
                            "Das Gef�� ist nicht in Griffweite.",
                            "The vessel is out of reach.");
                        end

                        -- cancel after one found item
                        break;
                    end -- found item

                end -- search loop
            else
                base.common.InformNLS( User,
                "Nimm die Flasche in die Hand.",
                "Take the bottle in your hands.");
            end
        else
            User:inform("unkown bottle item ");
        end
    end
end


function LookAtItem(User,Item)

    if (Item.id==2496) and (Item.data >= 1) and (Item.data <= 3) then

        if (Item.data == 1) then
            DisplayText = base.common.GetNLS( User, "Quellwasser der Troll's Vein", "Water from the Troll's Vein spring");
        elseif (Item.data == 2) then
            DisplayText = base.common.GetNLS( User, "Quellwasser der Fairy's Tears", "Water from the Fairy's Tears spring");
        elseif (Item.data == 3) then
            DisplayText = base.common.GetNLS( User, "Gesegnetes Wasser von Irundar", "Blessed Water of Irundar");
        end
        -- end
        -- end

        world:itemInform(User,Item, DisplayText );

    else
        if firstcall==nil then
            InitDrinks();
            firstcall=1;
        end

        local food = drinkList[ Item.id ];
        if food == nil then
            User:inform("unkown bottle item ");
            return
        end

        -- decode item quality, extract duration
        local itemDura=math.mod(Item.quality,100);
        local itemQual=(Item.quality-itemDura)/100;
        --User:inform("portions "..itemQual);

        -- build description

        local DisplayText="";

        -- build quality text
        for i,qualLimit in pairs(BottleQualLm) do
            if (itemQual>=qualLimit ) then
                DisplayText = base.common.GetNLS( User, BottleQualDe[i], BottleQualEn[i] );
                break;
            end
        end
        DisplayText = DisplayText..base.common.GetNLS( User, food[1], food[2] );
        --User:inform( DisplayText );

        world:itemInform(User,Item, DisplayText );

    end

end

--Please don't remove!!!
------------------------AB HIER,SKRIPT F�R DIE PRIESTER SILBERBRANDS(Heilung)-------------------
function UseItemWithCharacter(User,SourceItem,TargetChar,Counter,Param)
  InitDrinks();
  if (SourceItem.id==2501) then
	if (User.id==1048559757 or User.id==1322717830) then --for the Priests in Silverbrand(1048559757=Surian Silverbeard, 1322717830=Thogrimm)
    	if (TargetChar.id~=User.id) then

        	world:gfx(37,TargetChar.pos);
			if (User.id==1048559757) then --Surian Silverbeard gets not so strong healing
				TargetChar:increaseAttrib("hitpoints",3000); --heal the char
        		TargetChar:setPoisonValue(0);
				User:increaseAttrib("hitpoints",-300); --300HP damage for the Bragon priest
			elseif (User.id==1322717830) then  --Thogrimm gets strong healing
				TargetChar:increaseAttrib("hitpoints",5000); --heal the char
        		TargetChar:setPoisonValue(0);
        		User:increaseAttrib("hitpoints",-500); --500HP damage for the Irmorom priest
			end

			base.common.InformNLS( TargetChar, "Du f�hlst wie eine heilende W�rme deinen K�rper durchstr�mt und dir neue Kraft schenkt.",
					         "You feel how a healing warmth runs through your body and spends you new strength.");




		else
			base.common.InformNLS( User, "Du kannst dich nicht selber heilen.",
					     "You can't heal yourself.");
		end

    end
  end
end