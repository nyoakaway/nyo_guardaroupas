local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

nyoGRC = {}
vRP = Proxy.getInterface("vRP")
vRPserver = Tunnel.getInterface("vRP")
Tunnel.bindInterface("nyo_guardaroupas", nyoGRC)
--Proxy.addInterface("nyo_guardaroupas", nyoGRC)

nyoG = Tunnel.getInterface("nyo_guardaroupas")



local parts = {
    mascara = 1,
    mao = 3,
    calca = 4,
    mochila = 5,
    sapato = 6,
    gravata = 7,
    camisa = 8,
    jaqueta = 11,
    bone = "p0",
    oculos = "p1",
    brinco = "p2",
    relogio = "p6",
    bracelete = "p7"
}

local carroCompras = {
    mascara = false,
    mao = false,
    calca = false,
    mochila = false,
    sapato = false,
    gravata = false,
    camisa = false,
    jaqueta = false,
    bone = false,
    oculos = false,
    brinco = false,
    relogio = false,
    bracelete = false
}

local old_custom = {}
local nCustom = {}
local guardaRoupa = {}

local valor = 0
local precoTotal = 0

local in_loja = false
local atLoja = false

-- Provador
local chegou = false
local noProvador = false

-- Cam controll
local pos = nil
local camPos = nil
local cam = -1
local dataPart = 1
local texturaSelected = 0
local handsup = false

function SetCameraCoords()
    local ped = PlayerPedId()
	RenderScriptCams(false, false, 0, 1, 0)
    DestroyCam(cam, false)
    
	if not DoesCamExist(cam) then
        cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
		SetCamActive(cam, true)
        RenderScriptCams(true, true, 500, true, true)

        pos = GetEntityCoords(PlayerPedId())
        camPos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 2.0, 0.0)
        SetCamCoord(cam, camPos.x, camPos.y, camPos.z+0.75)
        PointCamAtCoord(cam, pos.x, pos.y, pos.z+0.15)
    end

end

function DeleteCam()
	SetCamActive(cam, false)
	RenderScriptCams(false, true, 0, true, true)
	cam = nil
end

RegisterNUICallback("changePart", function(data, cb)
    dataPart = parts[data.part]
    local ped = PlayerPedId()
    if GetEntityModel(ped) == GetHashKey("mp_m_freemode_01") then
        SendNUIMessage({ 
            changeCategory = true, 
            sexo = "Male", prefix = "M", 
            drawa = vRP.getDrawables(dataPart), category = dataPart,
        })
    elseif GetEntityModel(ped) == GetHashKey("mp_f_freemode_01") then 
        SendNUIMessage({ 
            changeCategory = true, 
            sexo = "Female", prefix = "F", 
            drawa = vRP.getDrawables(dataPart), category = dataPart,
        })
    end
end)

Citizen.CreateThread(function()
    --criarBlip()
end)


RegisterNetEvent("guardaroupa:abrir")
AddEventHandler("guardaroupa:abrir", function(x, y, z, x2, y2, z2)
    local distance = GetDistanceBetweenCoords(x,y,z,x2,y2,z2,true)
        if distance <= 1 then 
            nyoGRC.openGuardaRoupa()
        end    
end)

function nyoGRC.openGuardaRoupa() 
    CreateThread(function()
        while true do   
            if not noProvador and not in_loja then 
                valor = 0
                precoTotal = 0
                noProvador = true
                old_custom = vRP.getCustomization()
                Citizen.Wait(40)
                nCustom = old_custom
                guardaRoupa = nyoG.getRoupas()
                old = {}

                lojaProvador()

                cor = 0
                dados, tipo = nil

                Citizen.Wait(50)
                
                FreezeEntityPosition(ped, true)
                SetEntityInvincible(ped, false) --MQCU
                openGuiLojaRoupa()
            else 
                break
            end            
            Wait(4)
        end 
    end)
end


function openGuiLojaRoupa()
    local ped = PlayerPedId()
    SetNuiFocus(true, true)
    SetCameraCoords()
    if GetEntityModel(ped) == GetHashKey("mp_m_freemode_01") then
        SendNUIMessage({ 
            openLojaRoupa = true, 
            sexo = "Male", prefix = "M", 
            drawa = vRP.getDrawables(dataPart), category = dataPart,
            oldCustom = nCustom,
            infoGRoupas = guardaRoupa
        })
    elseif GetEntityModel(ped) == GetHashKey("mp_f_freemode_01") then 
        SendNUIMessage({ 
            openLojaRoupa = true, 
            sexo = "Female", prefix = "F", 
            drawa = vRP.getDrawables(dataPart), category = dataPart,
            oldCustom = nCustom,
            infoGRoupas = guardaRoupa
        })
    end
    in_loja = true
end

RegisterNUICallback("leftHeading", function(data, cb)
    local currentHeading = GetEntityHeading(PlayerPedId())
    heading = currentHeading-tonumber(data.value)
    SetEntityHeading(PlayerPedId(), heading)
end)

RegisterNUICallback("handsUp", function(data, cb)
    local dict = "missminuteman_1ig_2"
    
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(100)
    end
    
    if not handsup then
        TaskPlayAnim(PlayerPedId(), dict, "handsup_enter", 8.0, 8.0, -1, 50, 0, false, false, false)
        handsup = true
    else
        handsup = false
        ClearPedTasks(PlayerPedId())
    end
end)

RegisterNUICallback("rightHeading", function(data, cb)
    local currentHeading = GetEntityHeading(PlayerPedId())
    heading = currentHeading+tonumber(data.value)
    SetEntityHeading(PlayerPedId(), heading)
end)

function updateCarroCompras()
    valor = 0
    for k, v in pairs(carroCompras) do
        if carroCompras[k] == true then
            valor = valor + 0
        end
    end
    precoTotal = valor
    return valor
end

RegisterNUICallback("changeColor", function(data, cb)
    if type(dados) == "number" then
        max = GetNumberOfPedTextureVariations(PlayerPedId(), dados, tipo)
    elseif type(dados) == "string" then
        max = GetNumberOfPedPropTextureVariations(PlayerPedId(), parse_part(dados), tipo)
    end

    if data.action == "menos" then
        if cor > 0 then cor = cor - 1 else cor = max end
    elseif data.action == "mais" then
        if cor < max then cor = cor + 1 else cor = 0 end
    end
    if dados and tipo then 
            setRoupa(dados, tipo, cor) 
            SendNUIMessage({ 
                atualizaRoupa = true, 
                type = tipo,
                color = cor
            })
    end
end)

function changeClothe(type, id, color)
    dados = type
    tipo = tonumber(parseInt(id))
	cor = color
    setRoupa(dados, tipo, cor)
end

function setRoupa(dados, tipo, cor)
    local ped = PlayerPedId()

    if type(dados) == "number" then
		SetPedComponentVariation(ped, dados, tipo, cor, 1)
    elseif type(dados) == "string" then
        SetPedPropIndex(ped, parse_part(dados), tipo, cor, 1)
        dados = "p" .. (parse_part(dados))
	end
	  
  	custom = vRP.getCustomization()
  	custom.modelhash = nil

	aux = old_custom[dados]
	v = custom[dados]

    if v[1] ~= aux[1] and old[dados] ~= "custom" then
        carroCompras[dados] = true
        price = updateCarroCompras()
        SendNUIMessage({ action = "setPrice", price = price, typeaction = "add" })
    	old[dados] = "custom"
    end
    if v[1] == aux[1] and old[dados] == "custom" then
        carroCompras[dados] = false
        price = updateCarroCompras()
        SendNUIMessage({ action = "setPrice", price = price, typeaction = "remove" })
    	old[dados] = "0"
	end

	SendNUIMessage({ value = price })
end

RegisterNUICallback("changeCustom", function(data, cb)
    changeClothe(data.type, data.id, data.color)
end)

RegisterNUICallback("payament", function(data, cb)
    carroCompras = {
        mascara = false,
        mao = false,
        calca = false,
        mochila = false,
        sapato = false,
        gravata = false,
        camisa = false,
        jaqueta = false,
        bone = false,
        oculos = false,
        brinco = false,
        relogio = false,
        bracelete = false
    }
    TriggerServerEvent("GuardaRoupa:Comprar", tonumber(data.price), json.encode(data.parts)) 
end)

RegisterNUICallback("reset", function(data, cb)
    vRP.setCustomization(old_custom)
    closeGuiLojaRoupa()
    ClearPedTasks(PlayerPedId())
end)

function closeGuiLojaRoupa()
    local ped = PlayerPedId()
    DeleteCam()
    SetNuiFocus(false, false)
    SendNUIMessage({ openLojaRoupa = false })
    FreezeEntityPosition(ped, false)
    SetEntityInvincible(ped, false)
    PlayerReturnInstancia()
    SendNUIMessage({ action = "setPrice", price = 0, typeaction = "remove" })
    
    in_loja = false
    noProvador = false
    chegou = false
    old_custom = {}
end


function nyoGRC.finalizarCompra(comprar) 
    if comprar then
        in_loja = false
        closeGuiLojaRoupa()
    else
        in_loja = false
        vRP.setCustomization(old_custom)
        closeGuiLojaRoupa()
    end
end

function parse_part(key)
    if type(key) == "string" and string.sub(key, 1, 1) == "p" then
        return tonumber(string.sub(key, 2))
    else
        return false, tonumber(key)
    end
end

function PlayerInstancia()
    for _, player in ipairs(GetActivePlayers()) do
        local ped = PlayerPedId()
        local otherPlayer = GetPlayerPed(player)
        if ped ~= otherPlayer then
            SetEntityVisible(otherPlayer, false)
            SetEntityNoCollisionEntity(ped, otherPlayer, true)
        end
    end
end

function PlayerReturnInstancia()
    for _, player in ipairs(GetActivePlayers()) do
        local ped = PlayerPedId()
        local otherPlayer = GetPlayerPed(player)
        if ped ~= otherPlayer then
            SetEntityVisible(otherPlayer, true)
            SetEntityCollision(ped, true)
        end
    end
end

function criarBlip()
    for _, item in pairs(lojaderoupa) do
        item.blip = AddBlipForCoord(item.x, item.y, item.z)
        SetBlipSprite(item.blip, item.id)
        SetBlipColour(item.blip, item.color)
        SetBlipScale(item.blip, 0.5)
        SetBlipAsShortRange(item.blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(item.name)
        EndTextCommandSetBlipName(item.blip)
    end
end

function DrawText3D(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
end

function lojaProvador() 
    Citizen.CreateThread(function()
        while true do
            if noProvador then
                PlayerInstancia()
                DisableControlAction(1, 1, true)
                DisableControlAction(1, 2, true)
                DisableControlAction(1, 24, true)
                DisablePlayerFiring(PlayerPedId(), true)
                DisableControlAction(1, 142, true)
                DisableControlAction(1, 106, true)
                DisableControlAction(1, 37, true)
            else 
                noProvador = false
                break
            end
            Citizen.Wait(4)
        end
    end)
end

Citizen.CreateThread(function()
    while true do
        N_0xf4f2c0d4ee209e20()
        Citizen.Wait(1000)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        closeGuiLojaRoupa()
    end
end)