# NYO GUARDA ROUPA
Sistema de guarda roupa diferenciado o qual salva as roupas compradas na loja de roupa e possibilida a troca sem custo (e não apenas o padrão que salva outfit montados)

**FrameWork:** VRPEX


**Instalação:** 
* Abrir **server.cfg** adicionar **ensure nyo_guardaroupa**
* Abrir html/ui.js, alterar o IP (2 lugares) para o do seu host de imagem
* Abrir seu script de residencia e ir na função que abre o outfit atual

Caso Client:
```lua
TriggerEvent("guardaroupa:abrir", x, y, z, x2, y2, z2) 
```
Alterar x,y,z x2,y2,z2 para a localização do player e do guarda roupa, caso não possua localização do guarda roupa (vrp_homes que é por comando) passar tudo 1

Caso Server:
```lua
TriggerClientEvent("guardaroupa:abrir", source, x, y, z, x2, y2, z2)
```
Nesta caso (que é usado pelo vrp_homes) basta passar as variáveis de x,y e z todas como 1


**Duvidas/Suporte:**

https://discord.gg/nyo

