let roupaID = null;
let dataPart = null;
let change = {}
let oldPart = {}
let guardaRoupa = {}

$(document).ready(function() {
    document.onkeydown = function(data) {
        if (data.keyCode == 27) {
            $('footer').html('');
            $(".loja-de-roupa").fadeOut();
            $('#total').html('0'); 
            change = {};
            $.post('http://nyo_guardaroupas/reset', JSON.stringify({}))
            $.post('http://ph-hud/fechar', JSON.stringify({ id: false }))
        }
    }

    $("#leftHeading").click(function() {
        $.post('http://nyo_guardaroupas/leftHeading', JSON.stringify({ value: 10 }));
    })

    $("#handsUp").click(function() {
        $.post('http://nyo_guardaroupas/handsUp', JSON.stringify({}));
    })

    $("#rightHeading").click(function() {
        $.post('http://nyo_guardaroupas/rightHeading', JSON.stringify({ value: 10 }));
    })

    $("#payament").click(function() {
        $(".loja-de-roupa").fadeOut()
        $.post('http://ph-hud/fechar', JSON.stringify({ id: false }));
        $.post('http://nyo_guardaroupas/payament', JSON.stringify({ price: $('#total').text(), parts: oldPart }));
        $('#total').html('0');
        change = {};
    })

    window.addEventListener('message', function(event) {
        let item = event.data;

        if (item.action == 'setPrice') {
            if (item.typeaction == "add") {
                $('#total').html(item.price)
            }
            if (item.typeaction == "remove") {
                $('#total').html(item.price)
            }
        }
        
        if (item.openLojaRoupa) {
            oldPart = item.oldCustom
            guardaRoupa = item.infoGRoupas
            change = {};
            $(".loja-de-roupa").fadeIn()
            $.post('http://ph-hud/fechar', JSON.stringify({ id: true }))
            dataPart = item.category
            $('footer').html('')
            for (var i = 0; i <= item.drawa; i++) {    
                if(guardaRoupa[item.category][i]){
                    $("footer").append(`
                    <div class="item-clothe" data-id="${i}" onclick="select(this)" id="${item.category}${i}">
                        <div class="img-clothe" style="background-image: url('http://8.9.37.88/imgnoxcity233223/vrp_roupas/${item.category}/${item.sexo}/${item.prefix}(${i}).jpg')">  
                            <div class="overlay">
                                <span>${i}</span>
                            </div>
                        </div>
                    </div>
                `);
                }    
                if (oldPart[item.category][0] == i) {
                    select2(i);
                   }
            };
        }
        if (item.changeCategory) {
            dataPart = item.category            
            $('footer').html('')
            for (var i = 0; i <= item.drawa; i++) {    
                if (guardaRoupa[item.category][i]){
                    $("footer").append(`
                    <div class="item-clothe" data-id="${i}" onclick="select(this)" id="${item.category}${i}">
                        <div class="img-clothe" style="background-image: url('http://8.9.37.88/imgnoxcity233223/vrp_roupas/${item.category}/${item.sexo}/${item.prefix}(${i}).jpg')">  
                            <div class="overlay">
                                <span>${i}</span>
                            </div>
                        </div>
                    </div>
                `);
                if (oldPart[item.category][0] == i) {
                    select2(i);
                   }
                }            
            };
        }

        if(item.atualizaRoupa) { 
            oldPart[dataPart][1] = item.color;
        }
    })
});

function update_valor() {
    const formatter = new Intl.NumberFormat('pt-BR', { minimumFractionDigits: 2 })
    let total = 0
    for (let key in change) { if (!change[key] == 0) { total += 40 } }
    $('#total').html(formatter.format(total))
}


function selectPart(element) {
    let dataPart = element.dataset.idpart
    $('header h1').html(dataPart)
    $('.submenu-item').find('img').css('filter', 'brightness(100%)')
    $('.submenu-item').removeClass('subActive')
    $(element).addClass('subActive')
    $.post('http://nyo_guardaroupas/changePart', JSON.stringify({ part: dataPart }))
}

function select(element) {
    roupaID = element.dataset.id;
    $("footer div").css("border", "0");
    $('footer div').find('.overlay').css("background-color", "rgba(0, 0, 0, 0.507)");
    $(element).css("border", "1px solid #85a016");
    $(element).find('.overlay').css("background-color", "#0c961f");
    oldPart[dataPart][0] = roupaID;
    $.post('http://nyo_guardaroupas/changeCustom', JSON.stringify({ type: dataPart, id: roupaID, color: oldPart[dataPart][1] }));
}

function select2(id) {
    roupaID = id;
    $("footer div").css("border", "0");
    $('footer div').find('.overlay').css("background-color", "rgba(0, 0, 0, 0.507)");
    $(`#${dataPart}${id}`).css("border", "1px solid #85a016");
    $(`#${dataPart}${id}`).find('.overlay').css("background-color", "#0c961f");
    oldPart[dataPart][0] = roupaID;
    $.post('http://nyo_guardaroupas/changeCustom', JSON.stringify({ type: dataPart, id: roupaID, color: oldPart[dataPart][1] }));
}

$(".fa-angle-right").click(function() {
    $.post('http://nyo_guardaroupas/changeColor', JSON.stringify({ type: dataPart, id: roupaID, action: "mais" }));
})

$(".fa-angle-left").click(function() {
    $.post('http://nyo_guardaroupas/changeColor', JSON.stringify({ type: dataPart, id: roupaID, action: "menos" }));
})


