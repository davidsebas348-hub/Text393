repeat task.wait() until game:IsLoaded()

-- 🔥 INPUT
local rawInput = tostring(getgenv().FIND_TOOL or ""):lower()
if rawInput == "" then return end

-- 🔥 NORMALIZAR
local function normalize(str)
    return string.gsub(str:lower(), "%s+", "")
end

local input = normalize(rawInput)

-- 🔥 TODAS LAS TOOLS
local translate = {

-- COMIDA
["hamburguesa"]="burger",["burger"]="burger",
["refresco"]="cola",["cola"]="cola",
["pastel"]="cake",["cake"]="cake",
["tarta"]="pie",["pie"]="pie",
["perrocaliente"]="hotdog",["hotdog"]="hotdog",
["jamon"]="ham",["ham"]="ham",
["barraenergia"]="energybar",["energybar"]="energybar",

-- CURACIÓN
["botiquin"]="medkit",["medkit"]="medkit",
["cura"]="medkit",
["vendas"]="bandage",["bandage"]="bandage",

-- ARMAS
["katana"]="katana",["espada"]="katana",
["sable"]="saber",
["machete"]="machette",["machette"]="machette",

["pistola"]="pistol",["pistol"]="pistol",
["rifle"]="ar",["ar"]="ar",
["rifledorado"]="goldar",["goldar"]="goldar",

["escopeta"]="pumpshotgun",["pumpshotgun"]="pumpshotgun",
["escopetachatarra"]="scrappyshotgun",["scrappyshotgun"]="scrappyshotgun",

["subfusil"]="mac10",["mac10"]="mac10",
["smgchatarra"]="scrappysmg",["scrappysmg"]="scrappysmg",

["minigundorada"]="goldminigun",["goldminigun"]="goldminigun",

["armarefresco"]="sodagun",["sodagun"]="sodagun",

-- MUNICIÓN
["municion"]="ammo",["ammo"]="ammo",
["municionrifle"]="ammoarbasic",
["municionpistola"]="ammopistolbasic",
["municionescopeta"]="ammoshotgunbasic",

-- HERRAMIENTAS
["linterna"]="basicflashlight_standard",
["linternagrande"]="basicflashlight_big",
["linternaoculta"]="hiddenflashlight_standard",
["linternaocultagrande"]="hiddenflashlight_big",

["visionnocturna"]="nightvision",
["mochila"]="basicbackpack",
["martillo"]="buildinghammer",
["mesacrafteo"]="craftingtablet1",
["barrerapinchos"]="spikebarrier",
["trapeador"]="pointymop",

-- MATERIALES
["tela"]="cloth",["cloth"]="cloth",
["metal"]="metal",
["madera"]="wood",["wood"]="wood",
["hacha"]="axe",["axe"]="axe",
["hachuela"]="hatchet",["hatchet"]="hatchet",
["trampaoso"]="beartrap",["beartrap"]="beartrap",

-- CUBOS
["cuboazul"]="bluecube",["bluecube"]="bluecube",
["cuboverde"]="greencube",["greencube"]="greencube",
["cuborojo"]="redcube",["redcube"]="redcube",

-- TOKEN
["token"]="singletoken",["singletoken"]="singletoken",

-- LLAVES
["llavepuerta"]="frontdoorkey",
["tarjetaelectronica"]="electronicskeycard",
["tarjetamanager"]="managerkeycard",

-- OTROS
["elfo"]="elfbuddy",
["tabla"]="plank",["plank"]="plank",
["lanzadornieve"]="snowballlauncher",
["bastondulce"]="candycane"
}

-- 🔥 TARGET
local TARGET = normalize(input)

for k,v in pairs(translate) do
    if string.find(normalize(k), TARGET) then
        TARGET = normalize(v)
        break
    end
end
       

-- 🔥 SERVICIOS
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

local function SendNotif(title, text)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 3
    })
end

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Backpack = LocalPlayer:WaitForChild("Backpack")

local ItemsFolder = Workspace:WaitForChild("Map"):WaitForChild("Util"):WaitForChild("Items")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PickupRemote = Remotes:WaitForChild("RequestPickupItem")
local DropRemote = Remotes:WaitForChild("RequestDropItem")

-- 🔥 DROPS DE ESTA EJECUCIÓN
getgenv().SESSION_DROPS = {}

-- 🔥 BUSCAR TOOL POR NOMBRE, sin importar el slot
local function GetToolByName(name)
    name = normalize(name)
    
    -- Buscar en Character
    for _, tool in pairs(Character:GetChildren()) do
        if tool:IsA("Tool") and normalize(tool.Name) == name then
            return tool
        end
    end
    
    -- Buscar en Backpack
    for _, tool in pairs(Backpack:GetChildren()) do
        if tool:IsA("Tool") and normalize(tool.Name) == name then
            return tool
        end
    end
end

local function DropTool(tool)
    tool = tool or GetToolByName(TARGET)
    if tool then
        local Handle = tool:FindFirstChild("Handle")
        if Handle then
            table.insert(getgenv().SESSION_DROPS, tool)
            DropRemote:FireServer(tool, Handle.Position)
        end
    end
end

-- 🔥 BUSCAR
local function FindItem()
    for _, Item in pairs(ItemsFolder:GetChildren()) do
        if Item:IsA("Tool") then
            local name = normalize(Item.Name)

            if string.find(name, TARGET)
            and not table.find(getgenv().SESSION_DROPS, Item) then
                return Item
            end
        end
    end
end


    -- 🔥 EXISTE ITEM?
local function ExistsItem()
    for _, Item in pairs(ItemsFolder:GetChildren()) do
        if Item:IsA("Tool") then
            local name = normalize(Item.Name)
            if string.find(name, TARGET) then
                return true
            end
        end
    end
    return false
end

-- 🔥 CHEQUEO INICIAL (SOLO UNA VEZ)
if not ExistsItem() then
    SendNotif("HACK", "NO SE ENCONTRO EL ITEM")
    return
end
-- 🔥 LOOP FINITO (CORREGIDO)
while true do
    task.wait(0.1)


    local Item = FindItem()
    if not Item then
        SendNotif("HACK", "TERMINADO")
        break
    end

    -- Tirar Tool que ya tengas del mismo tipo
    local Tool = GetToolByName(TARGET)
    if Tool then
        DropTool(Tool)
        repeat task.wait() until not GetToolByName(TARGET)
    end

    -- Recoger la Tool encontrada
    PickupRemote:FireServer(Item)
    repeat task.wait() until GetToolByName(TARGET)

    -- Tirarla inmediatamente
    local ToolAfterPickup = GetToolByName(TARGET)
    if ToolAfterPickup then
        DropTool(ToolAfterPickup)
        repeat task.wait() until not GetToolByName(TARGET)
    end
end
