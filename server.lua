local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","nyo_guardaroupas")
vRPloja = Tunnel.getInterface("nyo_guardaroupas")
nyo = Proxy.getInterface("nyo")

-----------------------------------------------------------------------------------------------------------------------------------------
-- CONEXÃO
-----------------------------------------------------------------------------------------------------------------------------------------
nyoGRS = {}
Tunnel.bindInterface("nyo_guardaroupas",nyoGRS)

RegisterServerEvent("GuardaRoupa:Comprar")
AddEventHandler("GuardaRoupa:Comprar", function(preco, dataParts)
    local user_id = vRP.getUserId(source)
    local parts = json.decode(dataParts)
    if preco then
        if vRP.tryFullPayment(user_id,parseInt(preco)) then
            TriggerClientEvent("Notify",source,"sucesso","Você pagou <b>$"..preco.." dólares</b> em roupas e acessórios.",10000)

            local userSource = vRP.getUserSource(user_id)
            vRPloja.finalizarCompra(userSource, true)
        else
            local userSource = vRP.getUserSource(user_id)
            TriggerClientEvent("Notify",source,"negado","Você não tem dinheiro suficiente",10000)
            vRPloja.finalizarCompra(userSource, false)
        end 
    end
end)


function nyoGRS.getRoupas()
    local user_id = vRP.getUserId(source)
    local roupas = vRP.getUData(user_id, "nyo:GuardaRoupa")
    if roupas then 
        return json.decode(roupas) 
    else 
        return {}
    end
end

--------------------------------------------------
-- Check Procurado
function nyoGRS.checkProcurado()
	local user_id = vRP.getUserId(source)
	return vRP.searchReturn(source,user_id)
end
--------------------------------------------------
