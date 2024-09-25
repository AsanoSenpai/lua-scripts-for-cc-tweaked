-- Menu API by ComputerCrafter
-- buffer added by Missooni
-- installer concept by shorun (Minux)
 
local ogTerm = term.current()
local termX, termY = term.getSize()
local bufferWindow = window.create(ogTerm, 1, 1, termX, termY)
-- Uses ">" as pointer instead of "->"
function menuOptions(title, tChoices, tActions)
local check = true
local nSelection = 1
repeat
bufferWindow.setVisible(false)
term.redirect(bufferWindow)
term.clear()
local width, height = term.getSize()
paintutils.drawLine(1, 1, width, 1, colors.gray)
term.setCursorPos(1, 1)
term.setBackgroundColor(colors.gray)
print(title)
term.setBackgroundColor(colors.black)
print("")
    for nLine = 1, #tChoices do 
        local sLine = " "
        if nSelection == nLine then
            sLine = ">"
            pLine = true
        else
            pLine = false
        end
        sLine = sLine .." "..tChoices[nLine] 
        if pLine == true then
            term.setTextColor(colors.lightGray)
            print(sLine)
            term.setTextColor(colors.white)
        else
            print(sLine)
        end
    end
    bufferWindow.setVisible(true)
    local sEvent, nKey = os.pullEvent("key")
    if nKey == keys.up or nKey == keys.w then
        if tChoices[nSelection - 1] then
            nSelection = nSelection - 1
        end
    elseif nKey == keys.down or nKey == keys.s  then
        if tChoices[nSelection + 1] then 
            nSelection = nSelection + 1
        end
    elseif nKey == keys.enter then 
        if tActions[nSelection] then
            tActions[nSelection]() 
            check = false
        else
            print("Error: Selection out of bounds: ", nSelection)
            print("Press Enter to continue...")
            read() 
        end
    end
until check == false 
end

-- minux netinstaller
term.clear()
term.setCursorPos(1,1)
-- print("Welcome to the Minux installer")
-- print("")
-- print("type 'install' to install minux")
-- print("'reinstall' to overwrite an existing install")
-- print("'repair' to reinstall an existing system") 
-- print("anything else to launch a prompt/abort.")
-- write("Choice:")
-- input = read()

	local title = "Minux Installer"
	local choices = {"Install minux", "reinstall minux", "repair minux", "start an empty shell"}
	local actions = {}

	actions[1] = function()
	print("installation selected")
	input = "install"
	end
	actions[2] = function()
	print("reinstall selected")
	input = "reinstall"
	end
	actions[3] = function()
	print("repair selected")
	input = "repair"
	end
	actions[4] = function()
	print("shell selected")
	input = "shell"
	end	
menuOptions(title, choices, actions)
if input == "repair" then
	if fs.exists("/boot/alias.ls") then
		print("attempting to load api's")
		shell.run("/boot/alias.ls")
		print("attempting to force-update software")
		shell.run("/bin/apt.sh -U")
		print("Finished, restart the system")
	else
		print("Can't find instructions file, aborting")
	end	
elseif input == "shell" then return 0 
elseif input == "install" or "reinstall" then
	if input == "install" then 

-- we check to see if startup file already exists
		if fs.exists("/startup") then
			print("This system already has software installed")
			print("Clear it out before installing minux")
			print("Hit Enter to exit to a normal shell")
			input = read()
			return 0
		end
	end

-- selecting installation source
	local title = "Minux Installation source"
	local choices = {"Stable server", "Beta server", "Custom server"}
	local actions = {}

	actions[1] = function()
	print("stable selected")
	input = "stable"
	end
	actions[2] = function()
	print("beta selected")
	input = "beta"
	end
	actions[3] = function()
	print("custom")
	input = "custom"
	end	
menuOptions(title, choices, actions)

if input == "stable" then aptsource = "https://minux.vtchost.com/apt/"
elseif input == "beta" then aptsource = "https://minux.vtchost.com/beta/"
elseif input == "custom" then 
	print("what is the server's url?")
	print("give full path including https://")
	input = read()
	if input == nil or input == "" then print("invalid input, aborting") return 0
	else aptsource = input end
end

-- we check if the provided source is valid/live
print("Downloading File manifest..")
shell.run("wget "..aptsource.."/manifest/minux-main.db /etc/apt/manifest/minux-main.db")

-- now we open the manifest file and check if it is actually a manifest file at all (invalid url catcher)
print("Retrieving files")
file = "start"
local temp = fs.open("etc/apt/manifest/minux-main.db", "r")
-- 404 error catcher
file = temp.readLine()
if file ~= "AIF" then
	print("Error 404, Pack data missing or corrupt, aborting.")
	print("AIF verification failed, the downloaded file is not a manifest file")
	print("This means the provided source URL is invalid")
	return 0
end

-- we download the files for "minux-main" as described in the manifest
print("manifest retrieved, downloading files")
while file ~= nil do
	file = temp.readLine()
	if file ~= nil then
		fs.delete(file)
		shell.run("wget "..aptsource.."repository/minux-main/"..file.." "..file)
	end
end
temp.close()
			
print("Download Finished")

-- now we write the files down
print("Generating installed.db")
file = fs.open("/etc/apt/list/installed.db" , "w")
file.writeLine("minux-main")
file.close()
print("Generating source file")
sourcefile = fs.open("/usr/apt/source.ls" , "w")
sourcefile.writeLine(aptsource)
sourcefile.close()
print("Generating additional files")
file = fs.open("/etc/apt/list/version/minux-main.v" , "w")
file.writeLine("cleaninstall")
file.close()
print("Building boot configuration")
shell.run("/etc/apt/sys/rebuildalias.sys")



-- we wait for an enter, then reboot
term.clear()
term.setCursorPos(1,1)
print("Minux installed, remove any disks in the drive and hit Enter to reboot")
input = read()
os.reboot()
end