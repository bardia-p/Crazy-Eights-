setscreen ("graphics:800,800")
var cards : array 1 .. 52 of int %every card in the deck
var pics : array 1 .. 54 of int %pictures of all cards in the deck (pick 8 and back)
var discard : array 1 .. 52 of int %array holding all cards out of play
var clicked : array 1 .. 52 of int %used to select cards (which are selected)
var p_hand, d_hand : array 1 .. 52 of int %arrays of cards in players and computer hands
var played_cards : array 1 .. 4 of int %number of cards played in that one turn
var played_cards_count : int := 0 %how many cards have been played so far
var top : int %the card at the top of playing pile

var pickup : int := 0 %how many cards the current player must pick up
var p_cl, d_cl : int %how cards currently in each hand
var deck_size : int := 52 %number of cards left in deck
var new_deck_size : int := 0 %number of cards in discard pile

var chars : string (1) := "" %currently pressed character
var flag : int := 0 %
var turn : int %whos turn it is
var card : int %current card
var base : int %the top of the discard pile that cards will be played on top
var p_pickedup, d_pickedup : int %has picked up in this turn
var draw : int := 0 %how many cards they need to pick up
var choose : string := "" %which cards to play
var select : int := 0 %flag --> if a card has been selected
var p_two_flag, d_two_flag : int := 0 %if a two has been played
var base_suit : string %suit of base card
var mousex, mousey, button : int %where mouse is and if it's clicked
var which_card : int := 0 %which card is selected

class deck
    import cards, pics, top, turn, d_hand, p_hand, d_cl, p_cl, base, draw, card, p_two_flag, d_two_flag, discard, deck_size, new_deck_size, base_suit, mousex, mousey, button, Mouse
    %imports the procedures from the cards module
    
    export initialize, suit_letter, rank_name, shuffle, display, show, deal, valid, computer_play, can_play, best_move, pick_up, player_cards
    %exports procedures from the class
    
    proc initialize %makes the deck that cards will be drawn from
	for i : 1 .. 52
	    cards (i) := i - 1
	end for
	top := 1
	deck_size := 52
	new_deck_size := 0
    end initialize

    function rank (x : int) : int %determines the rank of the card
	result x mod 13
    end rank

    function suit (x : int) : int %determines the suit of the card
	result x div 13
    end suit

    function suit_letter (x : int) : string %determines the corresponding suit form the suit function
	if suit (x) = 0 then
	    result "clubs"
	elsif suit (x) = 1 then
	    result "diamonds"
	elsif suit (x) = 2 then
	    result "hearts"
	elsif suit (x) = 3 then
	    result "spades"
	end if
    end suit_letter

    function rank_name (x : int) : string %determines the corresponding value of the card
	case rank (x) of
	    label 0, 1, 2, 3, 4, 5, 6, 7 :
		result intstr (rank (x) + 2)
	    label 8 :
		result "10"
	    label 9 :
		result "jack"
	    label 10 :
		result "queen"
	    label 11 :
		result "king"
	    label 12 :
		result "ace"
	end case
    end rank_name

    proc swap (var a, b : int) %swaps two integers (used in shuffle)
	var temp : int
	temp := a
	a := b
	b := temp
    end swap

    proc shuffle %shuffles the deck by calling swap
	var new_pos : int
	for i : 1 .. deck_size
	    new_pos := Rand.Int (1, deck_size)
	    swap (cards (i), cards (new_pos))
	end for
	top := 1
    end shuffle

    proc re_initialize %used to bring the cards (except the base) from the playing pile to the drawing pile
	for i : 1 .. new_deck_size
	    if not (rank_name (discard (i)) = rank_name (base) and suit_letter (discard (i)) = base_suit) then
		cards (i) := discard (i)
	    end if
	end for
	deck_size := new_deck_size - 1
	new_deck_size := 0
	shuffle
    end re_initialize

    proc graph (var hand : array 1 .. * of int, who : string) %Draws the cards for each hand
	if who = "d" then
	    for i : 1 .. 10
		if i <= d_cl then
		    Pic.Draw (pics (53), 75 * (i - 1), 750, picCopy)
		end if
	    end for
	    if d_cl - 10 > 0 then
		Draw.Text (intstr (d_cl - 10), 750, 760, Font.New ("arial:18"), yellow)
	    end if
	elsif who = "p" then
	    for i : 0 .. p_cl - 1
		Pic.Draw (pics (hand (i + 1) + 1), 75 * (i mod 10), 540 - ((i div 10) * 110), picCopy)
	    end for
	end if
    end graph

    proc display %Draws the rest of the display
	cls
	Draw.FillBox (0, 0, 800, 800, green)
	graph (d_hand, "d")
	Pic.Draw (pics (53), 0, 645, picCopy)
	Draw.Text (intstr (deck_size - top + 1), 25, 695, Font.New ("arial:18"), black)
	Draw.Text (intstr (new_deck_size), 150, 670, Font.New ("arial:18"), black)
	Pic.Draw (pics (base + 1), 75, 645, picCopy)
	graph (p_hand, "p")
    end display

    proc show (var hand : array 1 .. * of int, cl : int) %shows which cards (not drawing but with text
	for i : 1 .. cl
	    if hand (i) >= 0 then
		put rank_name (hand (i)) + " " + suit_letter (hand (i)) + "  " ..
	    end if
	end for
	put ""
    end show

    proc deal (var x : int) %draws a card when the player or dealer can't play
	x := cards (top)
	top += 1
	if top > deck_size then
	    re_initialize
	end if
    end deal

    proc eight_play (who : string) %For player or dealer to choose which suit they want after they play and eight
	var suit_select : int
	var s_count : array 1 .. 4 of int := init (0, 0, 0, 0)
	var most_count : int := 0
	if who = "p" then
	    Draw.FillBox (0, 700, 800, 800, green)
	    Draw.Text ("Pick a suit", 50, 750, Font.New ("arial:15"), yellow)
	    Pic.Draw (pics (54), 250, 700, picMerge)
	    loop
		Mouse.Where (mousex, mousey, button)
		if mousex >= 250 and mousex <= 315 and mousey >= 715 and mousey <= 785 and button = 1 then
		    suit_select := 3
		    exit
		elsif mousex >= 320 and mousex <= 390 and mousey >= 705 and mousey <= 795 and button = 1 then
		    suit_select := 1
		    exit
		elsif mousex >= 405 and mousex <= 465 and mousey >= 705 and mousey <= 795 and button = 1 then
		    suit_select := 2
		    exit
		elsif mousex >= 485 and mousex <= 550 and mousey >= 705 and mousey <= 795 and button = 1 then
		    suit_select := 4
		    exit
		end if
	    end loop
	    display
	else
	    for i : 1 .. d_cl
		if suit_letter (d_hand (i)) = "clubs" then
		    s_count (1) += 1
		elsif suit_letter (d_hand (i)) = "diamonds" then
		    s_count (2) += 1
		elsif suit_letter (d_hand (i)) = "hearts" then
		    s_count (3) += 1
		elsif suit_letter (d_hand (i)) = "spades" then
		    s_count (4) += 1
		end if
	    end for

	    for i : 1 .. 4
		if s_count (i) > most_count then
		    most_count := s_count (i)
		    suit_select := i
		end if
	    end for
	end if
	if suit_select = 1 then
	    base_suit := "clubs"
	elsif suit_select = 2 then
	    base_suit := "diamonds"
	elsif suit_select = 3 then
	    base_suit := "hearts"
	elsif suit_select = 4 then
	    base_suit := "spades"
	end if
	Draw.Text ("The new suit is: " + base_suit, 150, 710, Font.New ("arial:15"), yellow)
	delay (1000)
    end eight_play

    function valid (move, base : int) : boolean %determines if the card that wants to be played can be played on that base
	if rank_name (base) not= rank_name (move) and base_suit not= suit_letter (move) then
	    result false
	end if
	result true
    end valid

    function can_play (var hand : array 1 .. * of int, base, cl : int) : boolean %determines if the player or dealer can play at all
	for i : 1 .. cl
	    if hand (i) >= 0 then
		if valid (hand (i), base) = true or rank_name (hand (i)) = "8" then
		    result true
		end if
	    end if
	end for
	result false
    end can_play

    proc shift (var hand : array 1 .. * of int, var cl : int) %shifts the hand down in the array when a card is removed
	var skips : int := 0
	var loop_count : int := 1
	var ccl : int := 0
	loop
	    if hand (loop_count) ~= -1 then
		ccl += 1
		hand (ccl) := hand (loop_count)
	    end if
	    loop_count += 1
	    exit when loop_count > cl
	end loop
	cl := ccl
    end shift

    proc delete (var hand : array 1 .. * of int, var discard, played_cards : array 1 .. * of int, var played_cards_count, new_deck_size, base, delete_card, cl, draw, turn, p_two_flag :
	    int)
	    %deletes a card from the hand and adjust the next turn and other values based on what was played
	var flag_card : int := 0
	var eight1 : int := 0
	for q : 1 .. cl
	    if hand (q) >= 0 then
		if rank_name (hand (q)) = rank_name (delete_card) then
		    if rank_name (hand (q)) = "2" then
			draw += 2
			p_two_flag := 1
		    elsif rank_name (hand (q)) = "jack" then
			turn += 1
		    elsif rank_name (hand (q)) = "8" then
			eight1 := 1
		    end if
		    if base_suit ~= suit_letter (hand (q)) and flag_card = 0 then
			flag_card := 1
			base := hand (q)
			base_suit := suit_letter (base)
		    end if
		    played_cards_count += 1
		    played_cards (played_cards_count) := hand (q)
		    new_deck_size += 1
		    discard (new_deck_size) := hand (q)
		    hand (q) := -1
		end if
	    end if
	end for

	shift (hand, cl)
	if flag_card = 0 then
	    base := delete_card
	    base_suit := suit_letter (base)
	end if

	if eight1 = 1 then
	    eight_play ("d")
	end if

	if rank_name (base) = "queen" and base_suit = "spades" then
	    draw := 5
	end if
    end delete

    proc best_move (var d_hand, possible_moves, pm2, discard, played_cards : array 1 .. * of int, var played_cards_count, new_deck_size, base, turn, draw, p_two_flag : int)
	%determine the best move for the dealer based on if it has special cards or pairs
	var most_cards : int := 0
	var count : int := 1
	var card_chosen : int := 0
	var base2 : int := 0
	for i : 1 .. upper (possible_moves)
	    if card_chosen = 0 then
		if rank_name (possible_moves (i)) ~= "2" and not (rank_name (possible_moves (i)) = "queen" and suit_letter (possible_moves (i)) = "spades") then
		    count := 0
		    for j : 1 .. upper (pm2)
			if rank_name (pm2 (j)) = rank_name (possible_moves (i)) then
			    count += 1
			end if
		    end for
		    if count >= most_cards then
			most_cards := count
			base2 := possible_moves (i)
		    end if
		else
		    %special cards cases
		    if rank_name (possible_moves (i)) = "queen" and suit_letter (possible_moves (i)) = "spades" then
			base2 := possible_moves (i)
			card_chosen := 1
		    elsif rank_name (possible_moves (i)) = "2" then
			base2 := possible_moves (i)
			card_chosen := 1
		    end if
		end if
	    end if
	end for
	delete (d_hand, discard, played_cards, played_cards_count, new_deck_size, base, base2, d_cl, draw, turn, p_two_flag)
    end best_move

    function computer_play (var hand : array 1 .. * of int, var discard, played_cards : array 1 .. * of int, var played_cards_count, new_deck_size, base, turn, draw, p_two_flag : int) :
	    int
	    %plays for the computer by calling other procedures
	var possible_moves : flexible array 1 .. 0 of int
	var pm2 : flexible array 1 .. 0 of int
	var exists : int := 0
	for i : 1 .. d_cl
	    exists := 0
	    if hand (i) >= 0 then
		if valid (hand (i), base) = true or rank_name (hand (i)) = "8" then
		    new possible_moves, upper (possible_moves) + 1
		    possible_moves (upper (possible_moves)) := hand (i)
		end if
	    end if
	end for

	for i : 1 .. d_cl
	    exists := 0
	    for j : 1 .. upper (possible_moves)
		if rank_name (hand (i)) = rank_name (possible_moves (j)) and exists = 0 then
		    new pm2, upper (pm2) + 1
		    pm2 (upper (pm2)) := hand (i)
		    exists := 1
		end if
	    end for
	end for

	best_move (d_hand, possible_moves, pm2, discard, played_cards, played_cards_count, new_deck_size, base, turn, draw, p_two_flag)
	result base
    end computer_play

    function player_cards (var p_hand, discard, played_cards : array 1 .. * of int, choose : string, var played_cards_count, new_deck_size, base, turn, draw, d_two_flag : int) : boolean
	%takes in the cards that you chose
	var player_moves : flexible array 1 .. 0 of int
	var chosen_card : string := ""
	var eight2 : int := 0
	var match : int := 0

	for i : 1 .. length (choose)
	    if choose (i) ~= " " then
		chosen_card += choose (i)
	    end if
	    if choose (i) = " " or i = length (choose) then
		if upper (player_moves) > 0 then
		    for j : 1 .. upper (player_moves)
			if rank_name (p_hand (strint (chosen_card))) ~= rank_name (player_moves (j)) then
			    result false
			end if
		    end for
		end if
		new player_moves, upper (player_moves) + 1
		player_moves (upper (player_moves)) := p_hand (strint (chosen_card))
		chosen_card := ""
	    end if
	end for

	var base_choose : int := 0

	for i : 1 .. upper (player_moves)
	    if valid (player_moves (i), base) = true or rank_name (player_moves (i)) = "8" then
		match := 1
	    end if
	end for

	if match = 0 then
	    result false
	end if

	if upper (player_moves) = 1 then
	    base := player_moves (1)
	    base_suit := suit_letter (base)
	end if
	for i : 1 .. upper (player_moves)
	    for j : 1 .. p_cl
		if p_hand (j) >= 0 then
		    if rank_name (p_hand (j)) = rank_name (player_moves (i)) and suit_letter (p_hand (j)) = suit_letter (player_moves (i)) then
			if rank_name (p_hand (j)) = "2" then
			    draw += 2
			    d_two_flag := 1
			elsif rank_name (p_hand (j)) = "jack" then
			    turn += 1
			elsif rank_name (p_hand (j)) = "8" then
			    eight2 := 1
			end if
			if suit_letter (p_hand (j)) ~= base_suit and base_choose = 0 then
			    base := p_hand (j)
			    base_suit := suit_letter (base)
			    base_choose := 1
			end if
			played_cards_count += 1
			played_cards (played_cards_count) := p_hand (j)
			new_deck_size += 1
			discard (new_deck_size) := p_hand (j)
			p_hand (j) := -1
			shift (p_hand, p_cl)
		    end if
		end if
	    end for
	end for

	if upper (player_moves) = 1 then
	    base := player_moves (1)
	    base_suit := suit_letter (base)
	end if

	if eight2 = 1 then
	    eight_play ("p")
	end if

	if rank_name (base) = "queen" and base_suit = "spades" then
	    draw := 5
	end if

	result true

    end player_cards
    
    proc pick_up (draw : int, var cl : int, who : string) %adds a card to the hand
	for i : 1 .. draw
	    deal (card)
	    if who = "p" then
		cl += 1
		p_hand (p_cl) := card
	    elsif who = "d" then
		cl += 1
		d_hand (d_cl) := card
	    end if
	end for
    end pick_up

end deck

var deck1 : ^deck
new deck, deck1

proc load_images %loads the images in
    var fname : string
    for i : 1 .. 52
	fname := "images/"+deck1 -> rank_name (cards (i)) + "_of_" + deck1 -> suit_letter (cards (i)) + ".jpg"
	pics (i) := Pic.FileNew (fname)
	pics (i) := Pic.Scale (pics (i), 70, 100)
    end for
    pics (53) := Pic.FileNew ("images/Back.jpg")
    pics (53) := Pic.Scale (pics (53), 70, 100)
    pics (54) := Pic.FileNew ("images/suits.bmp")
end load_images

deck1 -> initialize %initializes the deck

load_images %loads the images ini

Draw.FillBox (0, 0, 800, 800, green) %Draws background
loop
    if hasch then
	getch (chars)
    end if
    %gets the character pressed
    
    if flag = 0 then
	Draw.Text ("Press 'p' to play", 280, 770, Font.New ("arial:18"), white)
	flag := 1
    end if
    
    if chars = "p" then
	chars := ""
	played_cards_count := 0
	pickup := 0
	deck_size := 52
	new_deck_size := 0

	flag := 0
	draw := 0
	choose := ""
	select := 0
	p_two_flag := 0
	d_two_flag := 0
	which_card := 0
	deck1 -> shuffle
	p_cl := 8
	d_cl := 8
	turn := 0
	%sets the game up
	
	
	loop %deals the base and makes sure that it's not a 2, an 8, a jack, a queen of spades
	    deck1 -> deal (base)
	    base_suit := deck1 -> suit_letter (base)
	    exit when deck1 -> rank_name (base) ~= "2" and deck1 -> rank_name (base) ~= "8" and deck1 -> rank_name (base) ~= "jack" and not (deck1 -> rank_name (base) = "queen" and
		base_suit =
		"spades")
	    deck1 -> shuffle
	end loop

	
	new_deck_size += 1
	discard (new_deck_size) := base
	%adds the starting base to the discrad pile
	
	for i : 1 .. 8
	    deck1 -> deal (card)
	    p_hand (i) := card

	    deck1 -> deal (card)
	    d_hand (i) := card
	end for
	%deals the hands to the dealer(computer) and the player

	p_pickedup := 0
	d_pickedup := 0
	%sets the pickedup flag to 0 (not picked up)
	
	deck1 -> display
	loop
	    if turn mod 2 = 0 then %if it's the player's turn
		if draw > 0 then %if cards need to be picked up
		    deck1 -> pick_up (draw, p_cl, "p")
		    if p_two_flag = 0 then
			draw := 0
		    else
			p_two_flag := 0
		    end if
		end if

		deck1 -> display
		
		played_cards_count := 0
		%sets the number of cards played to 0
		
		if deck1 -> can_play (p_hand, base, p_cl) = true then
		%if the player can play on the current base then...
		
		    select := 0 %0 cards selected
		    choose := ""
		    Draw.Text ("Select", 225, 670, Font.New ("arial:18"), red)
		    loop
			for i : 1 .. p_cl %no cards clicked
			    clicked (i) := 0
			end for
			which_card := -1 %null value for which_card
			select := 0 
			for i : 0 .. p_cl - 1
			    Draw.Box (75 * (i mod 10), 540 - ((i div 10) * 110), 75 * (i mod 10) + 70, 540 - ((i div 10) * 110) + 100, green)
			end for
			loop %finds which card has been clicked and adds it to the clicked array
			    Mouse.Where (mousex, mousey, button)
			    if mousex <= 750 and mousey <= 650 and button = 1 then
				which_card := ((650 - mousey) div 110) * 10 + (mousex div 75) + 1
				if which_card <= p_cl and which_card >= 1 then
				    if clicked (which_card) = 0 then
					clicked (which_card) := 1
				    else
					clicked (which_card) := 0
				    end if
				    choose := ""
				    for i : 0 .. p_cl - 1
					if clicked (i + 1) = 0 then
					    Draw.Box (75 * (i mod 10), 540 - ((i div 10) * 110), 75 * (i mod 10) + 70, 540 - ((i div 10) * 110) + 100, green)
					else
					    choose += intstr (i + 1) + " "
					    Draw.Box (75 * (i mod 10), 540 - ((i div 10) * 110), 75 * (i mod 10) + 70, 540 - ((i div 10) * 110) + 100, yellow)
					end if
				    end for
				end if
				delay (500)
			    end if
			    if mousex >= 220 and mousex <= 280 and mousey >= 650 and mousey <= 690 and length (choose) > 0 and button = 1 then
				select := 1
			    end if
			    exit when select = 1
			end loop
			exit when deck1 -> player_cards (p_hand, discard, played_cards, choose, played_cards_count, new_deck_size, base, turn, draw, d_two_flag) = true
		    end loop
		    
		    %draws the card that got played
		    for i : 1 .. played_cards_count
			Pic.Draw (pics (played_cards (i) + 1), 375 + (i - 1) * 75, 645, picCopy)
		    end for
		    chars := ""
		    p_pickedup := 0
		    turn += 1
		else
		    if p_pickedup = 1 then
			p_pickedup := 0
			turn += 1
		    else
			deck1 -> pick_up (1, p_cl, "p")
			p_pickedup := 1
		    end if
		end if
		delay (1000)

		if d_two_flag = 0 and draw mod 2 = 0 then
		    draw := 0
		end if

	    elsif turn mod 2 = 1 then %if it's the dealer's (computer's) turn then...
		if draw > 0 then
		    deck1 -> pick_up (draw, d_cl, "d")
		    if d_two_flag = 0 then
			draw := 0
		    else
			d_two_flag := 0
		    end if
		end if

		deck1 -> display
		played_cards_count := 0

		if deck1 -> can_play (d_hand, base, d_cl) = true then %if the dealer can play then it does his turn by calling computer_play
		    base := deck1 -> computer_play (d_hand, discard, played_cards, played_cards_count, new_deck_size, base, turn, draw, p_two_flag)
		    for i : 1 .. played_cards_count
			Pic.Draw (pics (played_cards (i) + 1), 375 + (i - 1) * 75, 645, picCopy)
		    end for
		    chars := ""
		    d_pickedup := 0
		    turn += 1
		else
		    if d_pickedup = 1 then
			d_pickedup := 0
			turn += 1
		    else
			deck1 -> pick_up (1, d_cl, "d")
			d_pickedup := 1
		    end if
		end if
		delay (1000)

		if p_two_flag = 0 and draw mod 2 = 0 then
		    draw := 0
		end if
	    end if


	    exit when d_cl <= 0 or p_cl <= 0 %when somebody runs out of cards
	end loop

	deck1 -> display

	if d_cl <= 0 then %writes computer wins if the dealer (computer) wins
	    delay (1000)
	    cls
	    Draw.FillBox (0, 0, 800, 800, green)
	    Draw.Text ("Computer Wins", 300, 350, Font.New ("arial:18"), white)
	elsif p_cl <= 0 then %same thing but for the player
	    delay (1000)
	    cls
	    Draw.FillBox (0, 0, 800, 800, green)
	    Draw.Text ("Player Wins", 300, 350, Font.New ("arial:18"), white)
	end if
	flag := 0
	delay (1000)
	cls
	Draw.FillBox (0, 0, 800, 800, green)
    end if
end loop
