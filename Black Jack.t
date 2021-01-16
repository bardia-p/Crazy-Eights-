setscreen ("graphics:800,800")
var cards : array 1 .. 52 of int
var pics : array 1 .. 53 of int
var top : int

var p_score, d_score : int := 0
var p_bet, d_bet : int := 500
var p_money, d_money : int := 10000
var chars : string (1) := ""
var flag, flag2, flag3 : int := 0
var turn : int
var card : int
var p_ace, d_ace : boolean := false
var dealers_top : int := 0

class deck
    import cards, pics, top, p_ace, d_ace, turn, dealers_top
    export initialize, suit_letter, rank_name, shuffle, display, show, points, deal

    proc initialize
	for i : 1 .. 52
	    cards (i) := i - 1
	end for
	top := 1
    end initialize

    function rank (x : int) : int
	result x mod 13
    end rank

    function suit (x : int) : int
	result x div 13
    end suit

    function suit_letter (x : int) : string
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

    function rank_name (x : int) : string
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

    function points (score : int, x : int) : int
	case rank (x) of
	    label 0, 1, 2, 3, 4, 5, 6, 7 :
		result rank (x) + 2
	    label 8, 9, 10, 11 :
		result 10
	    label 12 :
		if score + 11 <= 21 then
		    if (turn mod 2 = 0 and turn ~= 2) or turn = 1 then
			p_ace := true
		    elsif (turn mod 2 = 1 and turn ~= 1) or turn = 2 then
			d_ace := true
		    end if
		    result 11
		else
		    result 1
		end if
	end case
    end points

    proc swap (var a, b : int)
	var temp : int
	temp := a
	a := b
	b := temp
    end swap

    proc shuffle
	var new_pos : int
	for i : 1 .. 52
	    new_pos := Rand.Int (1, 52)
	    swap (cards (i), cards (new_pos))
	end for
	top := 1
    end shuffle

    proc display (x : int)
	if turn = 1 then
	    Pic.Draw (pics (cards (x) + 1), 100, 100, picCopy)
	elsif turn = 2 then
	    Pic.Draw (pics (53), 0, 500, picCopy)
	    dealers_top := x
	elsif turn mod 2 = 0 then
	    Pic.Draw (pics (cards (x) + 1), 100 * (turn div 2), 100, picCopy)
	elsif turn mod 2 = 1 then
	    Pic.Draw (pics (cards (x) + 1), 100 * (turn div 2), 500, picCopy)
	end if
    end display

    proc show (x : int)
	put rank_name (cards (x)) + " " + suit_letter (cards (x))
	put ""
    end show

    proc deal (var x : int)
	x := cards (top) + 1
	top += 1
    end deal
end deck

var deck1 : ^deck
new deck, deck1

proc load_images
    var fname : string
    for i : 1 .. 52
	fname := "images/"+deck1 -> rank_name (cards (i)) + "_of_" + deck1 -> suit_letter (cards (i)) + ".jpg"
	pics (i) := Pic.FileNew (fname)
	pics (i) := Pic.Scale (pics (i), 100, 150)
    end for
    pics (53) := Pic.FileNew ("images/Back.jpg")
    pics (53) := Pic.Scale (pics (53), 100, 150)
end load_images

deck1 -> initialize

load_images


Draw.FillBox (0, 0, 800, 800, green)
loop
    if hasch then
	getch (chars)
    end if
    if flag = 0 and p_money > 0 and d_money > 0 then
	Draw.FillBox (280, 750, 700, 800, green)
	Draw.Text ("Press 'P' to play", 280, 770, Font.New ("arial:18"), white)
	flag := 1
    end if
    if chars = "p" then
	Draw.FillBox (280, 750, 700, 800, green)
	put "Enter your bet:"
	loop
	    get p_bet
	    if p_bet <= p_money and p_bet<=d_money then
		exit
	    else
		put "Error"
	    end if
	end loop
	d_bet := p_bet
	cls
	Draw.FillBox (0, 0, 800, 800, green)
	Draw.Text ("Dealer", 50, 475, Font.New ("arial:18"), white)
	Draw.Text ("Player", 50, 270, Font.New ("arial:18"), white)
	Draw.Text ("Money:", 500, 475, Font.New ("arial:18"), white)
	Draw.Text ("Money:", 500, 270, Font.New ("arial:18"), white)
	Draw.Text ("$" + intstr (d_money), 600, 475, Font.New ("arial:18"), white)
	Draw.Text ("$" + intstr (p_money), 600, 270, Font.New ("arial:18"), white)
	Draw.Text ("Score:", 150, 270, Font.New ("arial:18"), white)

	dealers_top := 0
	p_ace := false
	d_ace := false
	flag2 := 0
	flag3 := 0
	chars := ""
	deck1 -> shuffle
	p_score := 0
	d_score := 0
	turn := 0

	deck1 -> deal (card)
	deck1 -> display (card)
	p_score += deck1 -> points (p_score, cards (card))
	delay (500)
	turn += 1
	deck1 -> deal (card)
	deck1 -> display (card)
	p_score += deck1 -> points (p_score, cards (card))
	delay (500)
	Draw.FillBox (250, 270, 300, 370, green)
	Draw.Text (intstr (p_score), 250, 270, Font.New ("arial:18"), white)
	turn += 1
	if p_score = 21 then
	    flag2 := 1
	end if

	deck1 -> deal (card)
	deck1 -> display (card)
	d_score += deck1 -> points (d_score, cards (card))
	delay (500)
	turn += 1
	deck1 -> deal (card)
	deck1 -> display (card)
	d_score += deck1 -> points (d_score, cards (card))
	delay (500)
	turn += 1
	if d_score > 16 or d_score = 21 then
	    flag3 := 1
	end if
	loop
	    if turn mod 2 = 0 then
		if flag2 = 0 then
		    Draw.Text ("Press 'H' for hit and 'S' for stand", 280, 770, Font.New ("arial:18"), white)
		    loop
			if hasch then
			    getch (chars)
			end if
			if chars = "h" then
			    deck1 -> deal (card)
			    deck1 -> display (card)
			    p_score += deck1 -> points (p_score, cards (card))
			    Draw.FillBox (250, 270, 300, 370, green)
			    Draw.Text (intstr (p_score), 250, 270, Font.New ("arial:18"), white)
			    exit
			elsif chars = "s" or p_score = 21 then
			    flag2 := 1
			    exit
			end if
		    end loop
		    chars := ""
		    delay (500)
		end if
		turn += 1
	    elsif turn mod 2 = 1 then
		if flag3 = 0 then
		    Draw.FillBox (280, 770, 700, 800, green)
		    deck1 -> deal (card)
		    deck1 -> display (card)
		    d_score += deck1 -> points (d_score, cards (card))
		    if d_score > 16 then
			flag3 := 1
		    end if
		    delay (500)
		end if
		turn += 1
	    end if
	    if p_score > 21 and p_ace = true then
		p_score -= 10
		p_ace := false
		Draw.FillBox (250, 270, 300, 370, green)
		Draw.Text (intstr (p_score), 250, 270, Font.New ("arial:18"), white)
	    end if
	    if d_score > 21 and d_ace = true then
		d_score -= 10
		d_ace := false
		flag3 := 0
	    end if

	    exit when d_score > 21 or p_score > 21 or (d_score >= p_score and flag2 = 1) or (flag2 = 1 and flag3 = 1)
	end loop
	Draw.FillBox (280, 770, 700, 800, green)
	if (d_score = 21 and p_score ~= 21) or (d_score > p_score and d_score <= 21 and flag2 = 1) or p_score > 21 then
	    Draw.Text ("Dealer Wins", 280, 770, Font.New ("arial:18"), white)
	    d_money += p_bet
	    p_money -= d_bet
	elsif (p_score = 21 and d_score ~= 21) or (p_score > d_score and p_score <= 21 and flag3 = 1) or d_score > 21 then
	    Draw.Text ("Player Wins", 280, 770, Font.New ("arial:18"), white)
	    p_money += d_bet
	    d_money -= p_bet
	else
	    Draw.Text ("Tie", 280, 770, Font.New ("arial:18"), white)
	end if
	Pic.Draw (pics (cards (dealers_top) + 1), 0, 500, picCopy)
	Draw.Text ("Score:", 150, 475, Font.New ("arial:18"), white)
	Draw.Text (intstr (d_score), 250, 475, Font.New ("arial:18"), white)
	flag := 0
	Draw.FillBox (600, 475, 800, 500, green)
	Draw.FillBox (600, 270, 800, 375, green)
	Draw.Text ("$" + intstr (d_money), 600, 475, Font.New ("arial:18"), white)
	Draw.Text ("$" + intstr (p_money), 600, 270, Font.New ("arial:18"), white)
    elsif flag = 0 and p_money <= 0 then
	delay(1000)
	cls
	Draw.FillBox (0, 0, 800, 800, green)
	Draw.Text ("You lost!!!!", 350, 350, Font.New ("arial:20"), white)
	exit
    elsif flag = 0 and d_money <= 0 then
	delay(1000)
	cls
	Draw.FillBox (0, 0, 800, 800, green)
	Draw.Text ("You won!", 350, 350, Font.New ("arial:20"), white)
	exit
    end if
end loop
