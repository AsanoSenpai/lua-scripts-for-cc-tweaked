local w,h = term.getSize()

function printCentered (y,s)
	local x = math.floor((w - string.len(s)) /2)
	term.setCursorPos(x,y)
	term.clearLine()
	term.write(s)
end

-- Bootloader

term.clear
term.setCursorPos(1,1)
print("ETA | Elythera Transport Authority |")
print("OS v1.0")
term.setCursorPos(1,5)
printCentered(math.floor(h/2) - 2, "")
printCentered(math.floor(h/2) - 1, "   Loading...")
printCentered(math.floor(h/2) + 0, "")
term.setCursorPos(1,10)
sleep(1)
textutils.slowWrite("             #########################")
sleep(1)
shell.run("./os/.menu")