-- Menu API by ComputerCrafter
-- buffer added by Missooni
-- installer concept by shorun (Minux)
 
local ogTerm = term.current()
local termX, termY = term.getSize()
local bufferWindow = window.create(ogTerm, 1, 1, termX, termY)

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

-- mitsu os netinstaller
term.clear()
term.setCursorPos(1,1)
-- print("Welcome to the Mitsu OS installer")
-- print("")
-- print("type 'install' to install minux")
-- print("'reinstall' to overwrite an existing install")
-- print("'repair' to reinstall an existing system") 
-- print("anything else to launch a prompt/abort.")
-- write("Choice:")
-- input = read()

	local title = "Mitsu OS Installer"
	local choices = {"Install Mitsu OS", "Reinstall Mitsu OS", "Repair Mistu OS", "Start an empty shell"}
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
			print("Clear it out before installing Mitsu OS")
			print("Hit Enter to exit to a normal shell")
			input = read()
			return 0
		end
	end

-- selecting installation source
	local title = "Mitsu OS Installation source"
	local choices = {"Stable", "Beta"}
	local actions = {}

	actions[1] = function()
	print("stable selected")
	input = "stable"
	end
	actions[2] = function()
	print("beta selected")
	input = "beta"
	end
	end	
menuOptions(title, choices, actions)

if input == "stable" then
	local repoUrl = "https://api.github.com/repos/Asano_Senpai/lua-scripts-for-cc-tweaked/Mitsu%20OS/stable/contents"
elseif input == "beta" then
	local repoUrl = "https://api.github.com/repos/Asano_Senpai/lua-scripts-for-cc-tweaked/Mitsu%20OS/beta/contents"
end

print("Downloading files...")

-- GitHub repository URL
-- local repoUrl = "https://api.github.com/repos/Asano_Senpai/lua-scripts-for-cc-tweaked/Mitsu%20OS/stable/contents"

-- Download file using wget
local function downloadFile(url, destination)
  shell.run("wget", url, destination)
end

-- Download directory and its contents recursively
local function downloadDirectory(url, destination)
  shell.run("mkdir", destination)
  shell.run("cd", destination)
  
  local listing = http.get(url)
  local content = listing.readAll()
  listing.close()
  
  local files = textutils.unserializeJSON(content)
  
  for _, file in ipairs(files) do
    if file.type == "file" then
      downloadFile(file.download_url, file.name)
    elseif file.type == "dir" then
      downloadDirectory(file.url, file.name)
    end
  end
  
  shell.run("cd", "..")
end

-- Get repository name from URL
local function getRepositoryName(url)
  local _, _, repositoryName = string.find(url, "https://github.com/(.-)/")
  return repositoryName
end

-- Delete existing files in the repository
local function deleteExistingFiles(repositoryName)
  shell.run("rm", "-rf", repositoryName)
end

-- Start repository download
print("Welcome to the Mitsu OS Installation Program")
print("-------------------------------------------")

-- Prompt user for confirmation
print("This program will install Mitsu OS on your computer.")
print("Note: All existing files will be deleted.")
print("Do you want to continue? (y/n)")
local confirm = read()
	if confirm == "y" or confirm == "Y" then
	-- Delete existing files
	local repositoryName = getRepositoryName(repoUrl)
	deleteExistingFiles(repositoryName)
  
	-- Start download
	print("Downloading Mitsu OS...")
	downloadDirectory(repoUrl, repositoryName)

	print("Download Finished")

	-- we wait for an enter, then reboot
	term.clear()
	term.setCursorPos(1,1)
	print("Mistu OS installed, remove any disks in the drive and hit Enter to reboot")
	input = read()
	os.reboot()
	end
else
	print("Mitsu OS installation canceled. Exiting program.")
end