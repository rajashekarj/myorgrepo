var elementFocus = null;
$(window).load(function () {

	hideEdit();
	setFocusOnLoad();
	checkValue();
	checkTmv();
	onchangeCrewServeLoad();
	$(".loader").fadeOut("fast");
	//  document.getElementById("j_id0:frm:sRNId:j_id209:j_id227:j_id229_mlktp").style.display = 'none';

});

function lookupchange(elem) {
	var leftval = $(elem).offset().left;
	var topval = $(elem).offset().top + 18;
	setTimeout(function () {
		$('.autoCompleteBoxScrolling').offset({
			top: topval,
			left: leftval
		});
	}, 1000);
}

function recentLookupItemsHide(elem, idstr) {
	var leftval = $(elem).offset().left;
	var topval = $(elem).offset().top + 18;

	//$('.autoCompleteBoxScrolling').hide();

	/*setTimeout(function(){
	$('.autoCompleteBoxScrolling').hide();
	}, 500);*/
	//event.stopPropagation();
	var strid = "[id$=" + idstr + "_autoCompleteBoxId]";
	$(strid).attr('autocomplete', 'off');
	//console.log('--- this id'+elem.id+'--- strid --'+strid);
	var timedelay = 300;
	if (idstr === 'onboardcon') {
		timedelay = 100;
	}

	var timeinterval = setInterval(function () {
			//console.log(' ------- size ------'+ $(strid).size() );
			if ($(strid).size() > 0) {
				//console.log(' ---- before hideeee ---'+$(strid).attr('autocomplete') );
				//$(strid).css('display','none');
				//$(strid).hide();
				//console.log(' ---- after hideeee ---'+$(strid).css('display') + '-- auto css ---'+$('.autoCompleteBoxScrolling').css('display') );
				//$('.autoCompleteBoxScrolling').hide();

				$('.autoCompleteBoxScrolling').offset({
					top: topval,
					left: leftval
				});
				clearInterval(timeinterval);
			}
		}, timedelay);

}

function trainingLookupHide() {

	$("[id$=onboardcon_autoCompleteBoxId]").css('display', 'none');

	var timeinterval = setInterval(function () {
			//console.log(' ---- size ---'+ $("[id$=onboardcon_autoCompleteBoxId]").size()  );
			if ($("[id$=onboardcon_autoCompleteBoxId]").size() > 0) {
				//console.log(' list loadedddd');
				$("[id$=onboardcon_autoCompleteBoxId]").css('display', 'none');
				clearInterval(timeinterval);
			}
			//$("[id$=onboardcon_autoCompleteBoxId]").offset({left:leftval});

		}, 100);
}

/*
var container = $(".list");
var autocompletebox=$('.autoCompleteBoxScrolling');

$(document).on('mouseup mousedown',function (e) {
//console.log('--- targetContainer ---');
if ( !container.is(e.target) && !autocompletebox.is(e.target) ) // nor the scrollbar{
//$('.autoCompleteBoxScrolling').css('display','none');
$('.autoCompleteBoxScrolling').hide();
//e.stopPropagation();
}else{
//$('.autoCompleteBoxScrolling').css('display','block');
$('.autoCompleteBoxScrolling').show();
//e.stopPropagation();
}
});
 */

/*$(function(){
$(".list").bind('scroll', function() {
alert('scroll or click occurred');
});
});*/

function bodyOnLoad() {
	setFocusOnLoad();
}

function setFocusOnLoad() {}
$(function () {
	$('#dispenserCopy').click(function () {
		var ctx;
		$("input.rowDESelectBoxRad:radio:checked").each(function () {
			ctx = $(this).closest('tr');
		});
		
		var disCop1 = $('.deCls1', ctx).val();
		var disCop3 = $('.deCls3', ctx).val();
		var disCop4 = $('.deCls4', ctx).val();

		//copying brandset values
		var objP1 = $(ctx)[0].rowIndex - 1 + "\\:plat1";
		var discopP1 = $($("[id$=" + objP1 + "]"), ctx).text();

		var objP2 = $(ctx)[0].rowIndex - 1 + "\\:plat2";
		var discopP2 = $($("[id$=" + objP2 + "]"), ctx).text();

		var objP3 = $(ctx)[0].rowIndex - 1 + "\\:plat3";
		var discopP3 = $($("[id$=" + objP3 + "]"), ctx).text();

		var disCop2 = $('.deCls2', ctx).val();
		var disCop8 = $('.deCls8', ctx).val();
		var disCop14 = $('.deCls14', ctx).val();

		var map = {};
		map[discopP1] = disCop2;
		map[discopP2] = disCop8;
		map[discopP3] = disCop14;

		//Copying water values
		var disCop5 = $('.deCls5', ctx).val();
		var disCop11 = $('.deCls11', ctx).val();
		var disCop17 = $('.deCls17', ctx).val();
		var map2 = {};
		map2[discopP1] = disCop5;
		map2[discopP2] = disCop11;
		map2[discopP3] = disCop17;

		//Copying color values
        var disCop6 = $("select[id$='color1']", ctx).val();
        var disCop12 = $("select[id$='color2']", ctx).val();
        var disCop18 = $("select[id$='color3']", ctx).val();
		var map3 = {};
		map3[discopP1] = disCop6;
		map3[discopP2] = disCop12;
		map3[discopP3] = disCop18;
		
        var disCop53 = $('.deCls53', ctx).val();
		var disCop54 = $('.deCls54', ctx).val();
		var disCop55 = $('.deCls55', ctx).val();
        var map4 = {};
		map4[discopP1] = disCop53;
		map4[discopP2] = disCop54;
		map4[discopP3] = disCop55;
        
		//
		var disCop10 = $('.deCls10', ctx).val();
		var disCop16 = $('.deCls16', ctx).val();
		var disCop19 = $('.deCls19', ctx).val();
		var disCop21 = $('.deCls21', ctx).val();
		var disCop22 = $('.deCls22', ctx).val();
		var disCop23 = $('.deCls23', ctx).val();
		var disCop24 = $('.deCls24', ctx).val();
		var disCop25 = $('.deCls25', ctx).val();
		var disCop26 = $('.deCls26', ctx).val();
		var disCop27 = $('.deCls27', ctx).val();
		var disCop28 = $('.deCls28', ctx).val();
		var disCop29 = $('.deCls29', ctx).val();
		var disCop30 = $('.deCls30', ctx).val();
		var disCop31 = $('.deCls31', ctx).val();
		var disCop32 = $('.deCls32', ctx).val();
		var disCop33 = $('.deCls33', ctx).val();
		var disCop34 = $('.deCls34', ctx).val();
		var disCop35 = $('.deCls35', ctx).val();
		var disCop36 = $('.deCls36', ctx).val();
		var disCop37 = $('.deCls37', ctx).val();
		var disCop38 = $('.deCls38', ctx).val();
		var disCop39 = $('.deCls39', ctx).val();
		var disCop40 = $('.deCls40', ctx).val();
		var disCop41 = $('.deCls41', ctx).val();
		var disCop42 = $('.deCls42', ctx).val();
		var disCop43 = $('.deCls43', ctx).val();
		var disCop44 = $('.deCls44', ctx).val();
		var disCop45 = $('.deCls45', ctx).val();
		var disCop46 = $('.deCls46', ctx).val();
		var disCop47 = $('.deCls47', ctx).val();
		var disCop48 = $('.deCls48', ctx).val();
		var disCop49 = $('.deCls49', ctx).val();
		var disCop50 = $('.deCls50', ctx).val();
		var disCop51 = $('.deCls51', ctx).val();
		var disCop52 = $('.deCls52', ctx).val();
        var disCop56 = $('.deCls56', ctx).val();
		$("input.rowDESelectBox:checkbox:checked").each(function () {
			
			ptx = $(this).closest('tr');
			$(this).closest('tr').find('.deCls1').val(disCop1);
			$(this).closest('tr').find('.deCls3').val(disCop3);
			$(this).closest('tr').find('.deCls4').val(disCop4);

			var objP1a = $(ptx)[0].rowIndex - 1 + "\\:plat1";
			var discopP1a = $($("[id$=" + objP1a + "]"), ptx).text();

			var objP2a = $(ptx)[0].rowIndex - 1 + "\\:plat2";
			var discopP2a = $($("[id$=" + objP2a + "]"), ptx).text();

			var objP3a = $(ptx)[0].rowIndex - 1 + "\\:plat3";
			var discopP3a = $($("[id$=" + objP3a + "]"), ptx).text();

			//copying brandset, color, water fields
			if (discopP1a == discopP1 || discopP1a == discopP2 || discopP1a == discopP3) {
				$(this).closest('tr').find('.deCls2').val(map[discopP1a]);
				$(this).closest('tr').find('.deCls5').val(map2[discopP1a]);
				$(this).closest('tr').find("select[id$='color1']").val(map3[discopP1a]);
                $(this).closest('tr').find('.deCls53').val(map4[discopP1a]);
			}

			if (discopP2a == discopP1 || discopP2a == discopP2 || discopP2a == discopP3) {
				$(this).closest('tr').find('.deCls8').val(map[discopP2a]);
				$(this).closest('tr').find('.deCls11').val(map2[discopP2a]);
				$(this).closest('tr').find("select[id$='color2']").val(map3[discopP2a]);
                $(this).closest('tr').find('.deCls54').val(map4[discopP2a]);
			}

			if (discopP3a == discopP1 || discopP3a == discopP2 || discopP3a == discopP3) {
				$(this).closest('tr').find('.deCls14').val(map[discopP3a]);
				$(this).closest('tr').find('.deCls17').val(map2[discopP3a]);
				$(this).closest('tr').find("select[id$='color3']").val(map3[discopP3a]);
                $(this).closest('tr').find('.deCls55').val(map4[discopP3a]);
			}

			$(this).closest('tr').find('.deCls10').val(disCop10);
			$(this).closest('tr').find('.deCls16').val(disCop16);
			$(this).closest('tr').find('.deCls19').val(disCop19);
			$(this).closest('tr').find('.deCls21').val(disCop21);
			$(this).closest('tr').find('.deCls22').val(disCop22);
			$(this).closest('tr').find('.deCls23').val(disCop23);
			$(this).closest('tr').find('.deCls24').val(disCop24);
			$(this).closest('tr').find('.deCls25').val(disCop25);
			$(this).closest('tr').find('.deCls26').val(disCop26);
			$(this).closest('tr').find('.deCls27').val(disCop27);
			$(this).closest('tr').find('.deCls28').val(disCop28);
			$(this).closest('tr').find('.deCls29').val(disCop29);
			$(this).closest('tr').find('.deCls30').val(disCop30);
			$(this).closest('tr').find('.deCls31').val(disCop31);
			$(this).closest('tr').find('.deCls32').val(disCop32);
			$(this).closest('tr').find('.deCls33').val(disCop33);
			$(this).closest('tr').find('.deCls34').val(disCop34);
			$(this).closest('tr').find('.deCls35').val(disCop35);
			$(this).closest('tr').find('.deCls36').val(disCop36);
			$(this).closest('tr').find('.deCls37').val(disCop37);
			$(this).closest('tr').find('.deCls38').val(disCop38);
			$(this).closest('tr').find('.deCls39').val(disCop39);
			$(this).closest('tr').find('.deCls40').val(disCop40);
			$(this).closest('tr').find('.deCls41').val(disCop41);
			$(this).closest('tr').find('.deCls42').val(disCop42);
			$(this).closest('tr').find('.deCls43').val(disCop43);
			$(this).closest('tr').find('.deCls44').val(disCop44);
			$(this).closest('tr').find('.deCls45').val(disCop45);
			$(this).closest('tr').find('.deCls46').val(disCop46);
			$(this).closest('tr').find('.deCls47').val(disCop47);
			$(this).closest('tr').find('.deCls48').val(disCop48);
			$(this).closest('tr').find('.deCls49').val(disCop49);
			$(this).closest('tr').find('.deCls50').val(disCop50);
			$(this).closest('tr').find('.deCls51').val(disCop51);
			$(this).closest('tr').find('.deCls52').val(disCop52);
			$(this).closest('tr').find('.deCls56').val(disCop56);
		});
		return false;
	});
});
function dispnsrCopy() {

	var ctx;
	$("input.rowDESelectBoxRad:radio:checked").each(function () {
		ctx = $(this).closest('tr');
	});
	
	var disCop1 = $('.deCls1', ctx).val();
	var disCop3 = $('.deCls3', ctx).val();
	var disCop4 = $('.deCls4', ctx).val();

	//copying brandset values
	var objP1 = $(ctx)[0].rowIndex - 1 + "\\:plat1";
	var discopP1 = $($("[id$=" + objP1 + "]"), ctx).text();

	var objP2 = $(ctx)[0].rowIndex - 1 + "\\:plat2";
	var discopP2 = $($("[id$=" + objP2 + "]"), ctx).text();

	var objP3 = $(ctx)[0].rowIndex - 1 + "\\:plat3";
	var discopP3 = $($("[id$=" + objP3 + "]"), ctx).text();

	var disCop2 = $('.deCls2', ctx).val();
	var disCop8 = $('.deCls8', ctx).val();
	var disCop14 = $('.deCls14', ctx).val();
    
    var disCop53 = $('.deCls53', ctx).val();
	var disCop54 = $('.deCls54', ctx).val();
	var disCop55 = $('.deCls55', ctx).val();

	var map = {};
	map[discopP1] = disCop2;
	map[discopP2] = disCop8;
	map[discopP3] = disCop14;
    
    var map4 = {};
	map4[discopP1] = disCop53;
	map4[discopP2] = disCop54;
	map4[discopP3] = disCop55;

	//Copying water values
	var disCop5 = $('.deCls5', ctx).val();
	var disCop11 = $('.deCls11', ctx).val();
	var disCop17 = $('.deCls17', ctx).val();
	var map2 = {};
	map2[discopP1] = disCop5;
	map2[discopP2] = disCop11;
	map2[discopP3] = disCop17;

	//Copying color values
	var disCop6 = $("select[id$='color1']", ctx).val();
	var disCop12 = $("select[id$='color2']", ctx).val();
	var disCop18 = $("select[id$='color3']", ctx).val();
	var map3 = {};
	map3[discopP1] = disCop6;
	map3[discopP2] = disCop12;
	map3[discopP3] = disCop18;

	//
	var disCop10 = $('.deCls10', ctx).val();
	var disCop16 = $('.deCls16', ctx).val();
	var disCop19 = $('.deCls19', ctx).val();
	var disCop21 = $('.deCls21', ctx).val();
	var disCop22 = $('.deCls22', ctx).val();
	var disCop23 = $('.deCls23', ctx).val();
	var disCop24 = $('.deCls24', ctx).val();
	var disCop25 = $('.deCls25', ctx).val();
	var disCop26 = $('.deCls26', ctx).val();
	var disCop27 = $('.deCls27', ctx).val();
	var disCop28 = $('.deCls28', ctx).val();
	var disCop29 = $('.deCls29', ctx).val();
	var disCop30 = $('.deCls30', ctx).val();
	var disCop31 = $('.deCls31', ctx).val();
	var disCop32 = $('.deCls32', ctx).val();
	var disCop33 = $('.deCls33', ctx).val();
	var disCop34 = $('.deCls34', ctx).val();
	var disCop35 = $('.deCls35', ctx).val();
	var disCop36 = $('.deCls36', ctx).val();
	var disCop37 = $('.deCls37', ctx).val();
	var disCop38 = $('.deCls38', ctx).val();
	var disCop39 = $('.deCls39', ctx).val();
	var disCop40 = $('.deCls40', ctx).val();
	var disCop41 = $('.deCls41', ctx).val();
	var disCop42 = $('.deCls42', ctx).val();
	var disCop43 = $('.deCls43', ctx).val();
	var disCop44 = $('.deCls44', ctx).val();
	var disCop45 = $('.deCls45', ctx).val();
	var disCop46 = $('.deCls46', ctx).val();
	var disCop47 = $('.deCls47', ctx).val();
	var disCop48 = $('.deCls48', ctx).val();
	var disCop49 = $('.deCls49', ctx).val();
	var disCop50 = $('.deCls50', ctx).val();
	var disCop51 = $('.deCls51', ctx).val();
	var disCop52 = $('.deCls52', ctx).val();
    var disCop56 = $('.deCls56', ctx).val();
	$("input.rowDESelectBox:checkbox:checked").each(function () {
		
		ptx = $(this).closest('tr');
		$(this).closest('tr').find('.deCls1').val(disCop1);
		$(this).closest('tr').find('.deCls3').val(disCop3);
		$(this).closest('tr').find('.deCls4').val(disCop4);

		var objP1a = $(ptx)[0].rowIndex - 1 + "\\:plat1";
		var discopP1a = $($("[id$=" + objP1a + "]"), ptx).text();

		var objP2a = $(ptx)[0].rowIndex - 1 + "\\:plat2";
		var discopP2a = $($("[id$=" + objP2a + "]"), ptx).text();

		var objP3a = $(ptx)[0].rowIndex - 1 + "\\:plat3";
		var discopP3a = $($("[id$=" + objP3a + "]"), ptx).text();

		//copying brandset, color, water fields
		if (discopP1a == discopP1 || discopP1a == discopP2 || discopP1a == discopP3) {
			$(this).closest('tr').find('.deCls2').val(map[discopP1a]);
			$(this).closest('tr').find('.deCls5').val(map2[discopP1a]);
			$(this).closest('tr').find("select[id$='color1']").val(map3[discopP1a]);
            $(this).closest('tr').find('.deCls53').val(map4[discopP1a]);
		}

		if (discopP2a == discopP1 || discopP2a == discopP2 || discopP2a == discopP3) {
			$(this).closest('tr').find('.deCls8').val(map[discopP2a]);
			$(this).closest('tr').find('.deCls11').val(map2[discopP2a]);
			$(this).closest('tr').find("select[id$='color2']").val(map3[discopP2a]);
            $(this).closest('tr').find('.deCls54').val(map4[discopP2a]);
		}

		if (discopP3a == discopP1 || discopP3a == discopP2 || discopP3a == discopP3) {
			$(this).closest('tr').find('.deCls14').val(map[discopP3a]);
			$(this).closest('tr').find('.deCls17').val(map2[discopP3a]);
			$(this).closest('tr').find("select[id$='color3']").val(map3[discopP3a]);
            $(this).closest('tr').find('.deCls55').val(map4[discopP3a]);
		}

		$(this).closest('tr').find('.deCls10').val(disCop10);
		$(this).closest('tr').find('.deCls16').val(disCop16);
		$(this).closest('tr').find('.deCls19').val(disCop19);
		$(this).closest('tr').find('.deCls21').val(disCop21);
		$(this).closest('tr').find('.deCls22').val(disCop22);
		$(this).closest('tr').find('.deCls23').val(disCop23);
		$(this).closest('tr').find('.deCls24').val(disCop24);
		$(this).closest('tr').find('.deCls25').val(disCop25);
		$(this).closest('tr').find('.deCls26').val(disCop26);
		$(this).closest('tr').find('.deCls27').val(disCop27);
		$(this).closest('tr').find('.deCls28').val(disCop28);
		$(this).closest('tr').find('.deCls29').val(disCop29);
		$(this).closest('tr').find('.deCls30').val(disCop30);
		$(this).closest('tr').find('.deCls31').val(disCop31);
		$(this).closest('tr').find('.deCls32').val(disCop32);
		$(this).closest('tr').find('.deCls33').val(disCop33);
		$(this).closest('tr').find('.deCls34').val(disCop34);
		$(this).closest('tr').find('.deCls35').val(disCop35);
		$(this).closest('tr').find('.deCls36').val(disCop36);
		$(this).closest('tr').find('.deCls37').val(disCop37);
		$(this).closest('tr').find('.deCls38').val(disCop38);
		$(this).closest('tr').find('.deCls39').val(disCop39);
		$(this).closest('tr').find('.deCls40').val(disCop40);
		$(this).closest('tr').find('.deCls41').val(disCop41);
		$(this).closest('tr').find('.deCls42').val(disCop42);
		$(this).closest('tr').find('.deCls43').val(disCop43);
		$(this).closest('tr').find('.deCls44').val(disCop44);
		$(this).closest('tr').find('.deCls45').val(disCop45);
		$(this).closest('tr').find('.deCls46').val(disCop46);
		$(this).closest('tr').find('.deCls47').val(disCop47);
		$(this).closest('tr').find('.deCls48').val(disCop48);
		$(this).closest('tr').find('.deCls49').val(disCop49);
		$(this).closest('tr').find('.deCls50').val(disCop50);
		$(this).closest('tr').find('.deCls51').val(disCop51);
		$(this).closest('tr').find('.deCls52').val(disCop52);
		$(this).closest('tr').find('.deCls56').val(disCop56);
        var crewCopy1 = $(this).closest('tr').find('.deCls21');
        oncopyEnable(crewCopy1);
        
        var crewCopy3 = $(this).closest('tr').find('.deCls56');
        oncopyEnable(crewCopy3);
        
        var crewCopy2 = $(this).closest('tr').find('.deCls3');
        oncopyEnable(crewCopy2);
	});
	return false;
};
// Site Survey Request Copy

function ssrcopy(obj) {
	var ctx;
	$("input.rowSSReqSelectBoxRad:radio:checked").each(function () {
		ctx = $(this).closest('tr');
	});
	var cusCop1 = $('.ssreqCls1', ctx).val();
	var cusCop3 = $('.ssreqCls3', ctx).val();
	var cusCop4 = $('.ssreqCls4', ctx).val();
	var cusCop5 = $('.ssreqCls5', ctx).val();
	var cusCop6 = $('.ssreqCls6', ctx).val();
	var cusCop7 = $('.ssreqCls7', ctx).val();
	var cusCop8 = $('.ssreqCls8', ctx).val();
	var cusCop10 = $('.ssreqCls10', ctx).val();
	var cusCop11 = $('.ssreqCls11', ctx).val();
	var cusCop12 = $('.ssreqCls12', ctx).val();
	var cusCop13 = $('.ssreqCls13', ctx).val();//SIte Assessment Type
	var cusCop14 = $('.ssreqCls14', ctx).val();
    var cusCop15 = $('.ssreqCls15', ctx).val();//OCR
   var cusCop36 = $('.ssreqCls36', ctx).val();//FNF-58 FNF-6.0 M-Series Enable Code
   

	var objlkid = $(ctx)[0].rowIndex - 1 + "\\:fieldValue_lkid";
	var cusCop14id1 = $($("[id$=" + objlkid + "]"), ctx).val();
	var objlkold = $(ctx)[0].rowIndex - 1 + "\\:fieldValue_lkold";
	var cusCop14id2 = $($("[id$=" + objlkold + "]"), ctx).val();
    
    var objlkid2 = $(ctx)[0].rowIndex - 1 + "\\:fieldValue1_lkid";
	var cusCop15id1 = $($("[id$=" + objlkid2 + "]"), ctx).val();
	var objlkold2 = $(ctx)[0].rowIndex - 1 + "\\:fieldValue1_lkold";
	var cusCop15id2 = $($("[id$=" + objlkold2 + "]"), ctx).val();
    
 	
    
	var cusCop19 = $('.ssreqCls19', ctx).val();
	var cusCop20 = $('.ssreqCls20', ctx).val();
	var cusCop21 = $('.ssreqCls21', ctx).val();
	var cusCop22 = $('.ssreqCls22', ctx).val();
	var cusCop23 = $('.ssreqCls23', ctx).val();
	// var cusCop25 = $('.ssreqCls25', ctx).val();
	var cusCop24 = $('.ssreqCls24', ctx).prop('checked');
	var cusCop26 = $('.ssreqCls26', ctx).val();
	var cusCop27 = $('.ssreqCls27', ctx).prop('checked');
	var cusCop28 = $('.ssreqCls28', ctx).val();
	var cusCop29 = $('.ssreqCls29', ctx).val();
	var cusCop30 = $('.ssreqCls30', ctx).val();
	var cusCop31 = $('.ssreqCls31', ctx).val();
	var cusCop34 = $('.ssreqCls34',ctx).val();
	var cusCop35 = $('.ssreqCls35',ctx).val();
    
	// 'Dispenser Type/s for 1st SA' multi picklist copy Start
	var hexvalues = [];
	var labelvalues = [];
	var value;

	// To add Platforms to array 'valarr'.
	var valarr = [];
	$('.ssreqCls32').first().find('option').each(function (i) {
		valarr[i] = $(this).val();
	});

	var selectlist = [];
	$('.ssreqCls32', ctx).parent().find('select').each(function (i) {
		selectlist[i] = $(this).html();
	});

	$('.ssreqCls32 :selected', ctx).each(function (i, selectedElement) {

		hexvalues[i] = valarr.indexOf($(selectedElement).val());
		labelvalues[i] = $(selectedElement).text();

	});

	// 'Dispenser Type/s for 2nd SA' multi picklist copy Start
	var hexvalues2 = [];
	var labelvalues2 = [];

	// To add Platforms to array 'valarr'.
	var valarr2 = [];
	$('.ssreqCls33').first().find('option').each(function (i) {
		valarr2[i] = $(this).val();
	});

	var selectlist2 = [];
	$('.ssreqCls33', ctx).parent().find('select').each(function (i) {
		selectlist2[i] = $(this).html();
	});

	$('.ssreqCls33 :selected', ctx).each(function (i, selectedElement) {

		hexvalues2[i] = valarr2.indexOf($(selectedElement).val());
		labelvalues2[i] = $(selectedElement).text();

	});

	$("input.rowSSReqSelectBox:checkbox:checked").each(function () {
		ptx = $(this).closest('tr');
		$('.ssreqCls14', ptx).show();
		$('.assreqCls14', ptx).hide();
        $('.ssreqCls15', ptx).show();//OCR
		$('.assreqCls15', ptx).hide();//OCR
		$('.editCont', ptx).hide();
		$(this).closest('tr').find('.ssreqCls1').val(cusCop1);
		$(this).closest('tr').find('.ssreqCls3').val(cusCop3);
		$(this).closest('tr').find('.ssreqCls4').val(cusCop4);
		$(this).closest('tr').find('.ssreqCls5').val(cusCop5);
		$(this).closest('tr').find('.ssreqCls6').val(cusCop6);
		$(this).closest('tr').find('.ssreqCls7').val(cusCop7);
		$(this).closest('tr').find('.ssreqCls8').val(cusCop8);
		$(this).closest('tr').find('.ssreqCls10').val(cusCop10);
		$(this).closest('tr').find('.ssreqCls11').val(cusCop11);
		$(this).closest('tr').find('.ssreqCls12').val(cusCop12);
		$(this).closest('tr').find('.ssreqCls13').val(cusCop13); //Site assessment Value
		$(this).closest('tr').find('.ssreqCls14').val(cusCop14);
        $(this).closest('tr').find('.ssreqCls15').val(cusCop15);//OCR
        // FNF-6.0 M-Series Enable Code
       //FNF-56
       //Enable & Disable Site Assessor Field based on What Type of Site Assessement Field Value
    	var SAValue='SA Not Required - OSM approval required for local market';
    	
        if(cusCop13 != "" && cusCop13 != SAValue){
            console.log("SAType");
            $(this).closest('tr').find('.ssreqCls36').prop('disabled', false);
            $(this).closest('tr').find('.ssreqCls36').val(cusCop36);        
            $(this).closest('tr').find('.ssreqCls36').closest('td').find('.requiredBlock').css("display","block");
        }
        else{
            $(this).closest('tr').find('.ssreqCls36').prop('disabled', true);    
            $(this).closest('tr').find('.ssreqCls36').val("");
            $(this).closest('tr').find('.ssreqCls36').closest('td').find('.requiredBlock').css("display","none");
        }
        //FNF-56
		
		var objlkid = $(ptx)[0].rowIndex - 1 + "\\:fieldValue_lkid";
		$($("[id$=" + objlkid + "]"), ptx).val(cusCop14id1);
		var objlkold = $(ptx)[0].rowIndex - 1 + "\\:fieldValue_lkold";
		$($("[id$=" + objlkold + "]"), ptx).val(cusCop14id2);

        var objlkid2 = $(ptx)[0].rowIndex - 1 + "\\:fieldValue1_lkid";
		$($("[id$=" + objlkid2 + "]"), ptx).val(cusCop15id1);
		var objlkold2 = $(ptx)[0].rowIndex - 1 + "\\:fieldValue1_lkold";
		$($("[id$=" + objlkold2 + "]"), ptx).val(cusCop15id2);
        
		$(this).closest('tr').find('.ssreqCls19').val(cusCop19);
		$(this).closest('tr').find('.ssreqCls20').val(cusCop20);
		$(this).closest('tr').find('.ssreqCls21').val(cusCop21);
		$(this).closest('tr').find('.ssreqCls22').val(cusCop22);
		$(this).closest('tr').find('.ssreqCls23').val(cusCop23);
		// $(this).closest('tr').find('.ssreqCls25').val(cusCop25);
		$(this).closest('tr').find('.ssreqCls24').prop('checked', cusCop24);
		$(this).closest('tr').find('.ssreqCls26').val(cusCop26);
		$(this).closest('tr').find('.ssreqCls27').prop('checked', cusCop27);
		$(this).closest('tr').find('.ssreqCls28').val(cusCop28);
		$(this).closest('tr').find('.ssreqCls29').val(cusCop29);
		$(this).closest('tr').find('.ssreqCls30').val(cusCop30);
		$(this).closest('tr').find('.ssreqCls31').val(cusCop31);
		$(this).closest('tr').find('.ssreqCls34').val(cusCop34);
		$(this).closest('tr').find('.ssreqCls35').val(cusCop35);        
		
		var opt = $(this).closest('tr').find('.ssreqCls32');

		// copy values to 'Dispenser Type/s for 1st SA'
		$(this).closest('tr').find('.ssreqCls32').each(function (i) {
			if (i == 0) {
				$(this).html('');
				$(this).html(selectlist[i]).find('option').each(function () {
					if (labelvalues.indexOf($(this).attr('value')) != -1) {
						$(this).prop("selected", true);
					}
				});
			} else if (i == 1) {
				$(this).html('');
				$(this).html(selectlist[i]);
			} else if (i == 4) {
				$(this).html('');
				$(this).html(selectlist[selectlist.length - 1]);
			}

		});

		// copy values to 'Dispenser Type/s for 2nd SA'
		$(this).closest('tr').find('.ssreqCls33').each(function (i) {
			if (i == 0) {
				$(this).html('');
				$(this).html(selectlist2[i]).find('option').each(function () {
					if (labelvalues2.indexOf($(this).attr('value')) != -1) {
						$(this).prop("selected", true);
					}
				});
			} else if (i == 1) {
				$(this).html('');
				$(this).html(selectlist2[i]);
			} else if (i == 4) {
				$(this).html('');
				$(this).html(selectlist2[selectlist2.length - 1]);
			}

		});

	});

	return false;
}

// Installation Copy
function instalCopy() {
	var ctx;
	$("input.rowInsSelectBoxRad:radio:checked").each(function () {
		ctx = $(this).closest('tr');
	});
	var InsCop1 = $('.InsCls1', ctx).val();
	var InsCop2 = $('.InsCls2', ctx).val();
	var InsCop3 = $('.InsCls3', ctx).val();
	var InsCop4 = $('.InsCls4', ctx).val();
	var InsCop5 = $('.InsCls5', ctx).val();
	var InsCop6 = $('.InsCls6', ctx).val();
	var InsCop7 = $('.InsCls7', ctx).val();
	var InsCop8 = $('.InsCls8', ctx).val();
	var InsCop9 = $('.InsCls9', ctx).val();
	var InsCop10 = $('.InsCls10', ctx).val();

	var objlkid = $(ctx)[0].rowIndex - 1 + "\\:contractorcon_lkid";
	var InsCop10id1 = $($("[id$=" + objlkid + "]"), ctx).val();
	var objlkold = $(ctx)[0].rowIndex - 1 + "\\:contractorcon_lkold";
	var InsCop10id2 = $($("[id$=" + objlkold + "]"), ctx).val();
	//var InsCop10id3 = $($("[id$=contractorcon_lktp]"),ctx).val();
	// var InsCop10id4 = $($("[id$=contractorcon_lspf]"),ctx).val();
	// var InsCop10id5 = $($("[id$=contractorcon_lspfsub]"),ctx).val();
	// var InsCop10id6 = $($("[id$=contractorcon_mod]"),ctx).val();

	var InsCop13 = $('.InsCls13', ctx).val();
	var obj2lkid = $(ctx)[0].rowIndex - 1 + "\\:outletcon_lkid";
	var InsCop13id1 = $($("[id$=" + obj2lkid + "]"), ctx).val();
	var obj2lkold = $(ctx)[0].rowIndex - 1 + "\\:outletcon_lkold";
	var InsCop13id2 = $($("[id$=" + obj2lkold + "]"), ctx).val();
	//   var InsCop13id3 = $($("[id$=outletcon_lktp]"),ctx).val();
	// var InsCop13id4 = $($("[id$=outletcon_lspf]"),ctx).val();
	// var InsCop13id5 = $($("[id$=outletcon_lspfsub]"),ctx).val();
	// var InsCop13id6 = $($("[id$=outletcon_mod]"),ctx).val();

	var InsCop14 = $('.InsCls14', ctx).val();
	var InsCop15 = $('.InsCls15', ctx).val();
	var InsCop16 = $('.InsCls16', ctx).val();
	$("input.rowInsSelectBox:checkbox:checked").each(function () {
		ptx = $(this).closest('tr');
		$('.InsCls10', ptx).show();
		$('.aInsCls10', ptx).hide();
		$('.editCont', ptx).hide();

		$('.InsCls13', ptx).show();
		$('.aInsCls13', ptx).hide();
		$('.editCont1', ptx).hide();

		$(this).closest('tr').find('.InsCls1').val(InsCop1);
		$(this).closest('tr').find('.InsCls2').val(InsCop2);
		$(this).closest('tr').find('.InsCls3').val(InsCop3);
		$(this).closest('tr').find('.InsCls4').val(InsCop4);
		$(this).closest('tr').find('.InsCls5').val(InsCop5);
		$(this).closest('tr').find('.InsCls6').val(InsCop6);
		$(this).closest('tr').find('.InsCls7').val(InsCop7);
		$(this).closest('tr').find('.InsCls8').val(InsCop8);
		$(this).closest('tr').find('.InsCls9').val(InsCop9);
		$(this).closest('tr').find('.InsCls10').val(InsCop10);

		var objlkid = $(ptx)[0].rowIndex - 1 + "\\:contractorcon_lkid";
		$($("[id$=" + objlkid + "]"), ptx).val(InsCop10id1);
		var objlkold = $(ptx)[0].rowIndex - 1 + "\\:contractorcon_lkold";
		$($("[id$=" + objlkold + "]"), ptx).val(InsCop10id2);
		// $($("[id$=contractorcon_lktp]"),ptx).val(InsCop10id3);
		//$($("[id$=contractorcon_lspf]"),ptx).val(InsCop10id4);
		//$($("[id$=contractorcon_lspfsub]"),ptx).val(InsCop10id5);
		//$($("[id$=contractorcon_mod]"),ptx).val(InsCop10id6);

		$(this).closest('tr').find('.InsCls13').val(InsCop13);
		var obj2lkid = $(ptx)[0].rowIndex - 1 + "\\:outletcon_lkid";
		$($("[id$=" + obj2lkid + "]"), ptx).val(InsCop13id1);
		var obj2lkold = $(ptx)[0].rowIndex - 1 + "\\:outletcon_lkold";
		$($("[id$=" + obj2lkold + "]"), ptx).val(InsCop13id2);
		// $($("[id$=outletcon_lktp]"),ptx).val(InsCop13id3);
		//$($("[id$=outletcon_lspf]"),ptx).val(InsCop13id4);
		//$($("[id$=outletcon_lspfsub]"),ptx).val(InsCop13id5);
		//$($("[id$=outletcon_mod]"),ptx).val(InsCop13id6);

		$(this).closest('tr').find('.InsCls14').val(InsCop14);
		$(this).closest('tr').find('.InsCls15').val(InsCop15);
		$(this).closest('tr').find('.InsCls16').val(InsCop16);
        
	        var crewCopy1 = $(this).closest('tr').find('.InsCls8');
	        oncopyEnable(crewCopy1);
	});
	return false;
}
// IceMaker/WaterFilter Copy
function imwfCopy() {
	// alert($("input.colIWSelectBox1:checkbox:checked").val());
	var ctx;
	$("input.rowIWSelectBoxRad:radio:checked").each(function () {
		ctx = $(this).closest('tr');
	});
	var iwCop1 = $('.iwCls1', ctx).val();
	var iwCop2 = $('.iwCls2', ctx).val();
	var iwCop3 = $('.iwCls3', ctx).val();
	var iwCop4 = $('.iwCls4', ctx).val();
	var iwCop5 = $('.iwCls5', ctx).val();
	var iwCop6 = $('.iwCls6', ctx).val();
	var iwCop7 = $('.iwCls7', ctx).val();
	var iwCop8 = $('.iwCls8', ctx).val();
	var iwCop9 = $('.iwCls9', ctx).val();
	var iwCop10 = $('.iwCls10', ctx).val();

	var objlkid = $(ctx)[0].rowIndex - 1 + "\\:wfcustcon_lkid";
	var iwCop10id1 = $($("[id$=" + objlkid + "]"), ctx).val();
	var objlkold = $(ctx)[0].rowIndex - 1 + "\\:wfcustcon_lkold";
	var iwCop10id2 = $($("[id$=" + objlkold + "]"), ctx).val();
	//var iwCop10id3 = $($("[id$=wfcustcon_lktp]"),ctx).val();
	// var iwCop10id4 = $($("[id$=wfcustcon_lspf]"),ctx).val();
	// var iwCop10id5 = $($("[id$=wfcustcon_lspfsub]"),ctx).val();
	// var iwCop10id6 = $($("[id$=wfcustcon_mod]"),ctx).val();

	var iwCop13 = $('.iwCls13', ctx).val();
	var obj2lkid = $(ctx)[0].rowIndex - 1 + "\\:wfinstcon_lkid";
	var iwCop13id1 = $($("[id$=" + obj2lkid + "]"), ctx).val();
	var obj2lkold = $(ctx)[0].rowIndex - 1 + "\\:wfinstcon_lkold";
	var iwCop13id2 = $($("[id$=" + obj2lkold + "]"), ctx).val();
	// var iwCop13id3 = $($("[id$=wfinstcon_lktp]"),ctx).val();
	// var iwCop13id4 = $($("[id$=wfinstcon_lspf]"),ctx).val();
	// var iwCop13id5 = $($("[id$=wfinstcon_lspfsub]"),ctx).val();
	// var iwCop13id6 = $($("[id$=wfinstcon_mod]"),ctx).val();

	var iwCop16 = $('.iwCls16', ctx).val();
	var iwCop17 = $('.iwCls17', ctx).val();
	var iwCop18 = $('.iwCls18', ctx).val();
	var iwCop19 = $('.iwCls19', ctx).val();
	$("input.rowIWSelectBox:checkbox:checked").each(function () {
		ptx = $(this).closest('tr');
		$('.iwCls10', ptx).show();
		$('.aiwCls10', ptx).hide();
		$('.editCont', ptx).hide();

		$('.iwCls13', ptx).show();
		$('.aiwCls13', ptx).hide();
		$('.editCont1', ptx).hide();

		$(this).closest('tr').find('.iwCls1').val(iwCop1);
		$(this).closest('tr').find('.iwCls2').val(iwCop2);
		$(this).closest('tr').find('.iwCls3').val(iwCop3);
		$(this).closest('tr').find('.iwCls4').val(iwCop4);
		$(this).closest('tr').find('.iwCls5').val(iwCop5);
		$(this).closest('tr').find('.iwCls6').val(iwCop6);
		$(this).closest('tr').find('.iwCls7').val(iwCop7);
		$(this).closest('tr').find('.iwCls8').val(iwCop8);
		$(this).closest('tr').find('.iwCls9').val(iwCop9);
		$(this).closest('tr').find('.iwCls10').val(iwCop10);

		var objlkid = $(ptx)[0].rowIndex - 1 + "\\:wfcustcon_lkid";
		$($("[id$=" + objlkid + "]"), ptx).val(iwCop10id1);
		var objlkold = $(ptx)[0].rowIndex - 1 + "\\:wfcustcon_lkold";
		$($("[id$=" + objlkold + "]"), ptx).val(iwCop10id2);
		//$($("[id$=wfcustcon_lktp]"),ptx).val(iwCop10id3);
		//$($("[id$=wfcustcon_lspf]"),ptx).val(iwCop10id4);
		//$($("[id$=wfcustcon_lspfsub]"),ptx).val(iwCop10id5);
		//$($("[id$=wfcustcon_mod]"),ptx).val(iwCop10id6);

		$(this).closest('tr').find('.iwCls13').val(iwCop13);
		var obj2lkid = $(ptx)[0].rowIndex - 1 + "\\:wfinstcon_lkid";
		$($("[id$=" + obj2lkid + "]"), ptx).val(iwCop13id1);
		var obj2lkold = $(ptx)[0].rowIndex - 1 + "\\:wfinstcon_lkold";
		$($("[id$=" + obj2lkold + "]"), ptx).val(iwCop13id2);
		//$($("[id$=wfinstcon_lktp]"),ptx).val(iwCop13id3);
		//$($("[id$=wfinstcon_lspf]"),ptx).val(iwCop13id4);
		//$($("[id$=wfinstcon_lspfsub]"),ptx).val(iwCop13id5);
		//$($("[id$=wfinstcon_mod]"),ptx).val(iwCop13id6);

		$(this).closest('tr').find('.iwCls16').val(iwCop16);
		$(this).closest('tr').find('.iwCls17').val(iwCop17);
		$(this).closest('tr').find('.iwCls18').val(iwCop18);
		$(this).closest('tr').find('.iwCls19').val(iwCop19);
        
	        var crewCopy1 = $(this).closest('tr').find('.iwCls6');
	        oncopyEnable(crewCopy1);
	});
	return false;
}
//Product Copy
function productCopy() {
	var ctx;
	$("input.rowProdSelectBoxRad:radio:checked").each(function () {
		ctx = $(this).closest('tr');
	});
	var prodCop1 = $('.prodCls1', ctx).val();
	var prodCop2 = $('.prodCls2', ctx).val();
	var prodCop3 = $('.prodCls3', ctx).val();
	var prodCop7 = $('.prodCls7', ctx).val();
	var prodCop5 = $('.prodCls5', ctx).val();
	var prodCop6 = $('.prodCls6', ctx).val();

	var objlkid = $(ctx)[0].rowIndex - 1 + "\\:admincon_lkid";
	var prodCop6id1 = $($("[id$=" + objlkid + "]"), ctx).val();
	var objlkold = $(ctx)[0].rowIndex - 1 + "\\:admincon_lkold";
	var prodCop6id2 = $($("[id$=" + objlkold + "]"), ctx).val();

	// var prodCop6id3 = $($("[id$=admincon_lktp]"),ctx).val();
	// var prodCop6id4 = $($("[id$=admincon_lspf]"),ctx).val();
	// var prodCop6id5 = $($("[id$=admincon_lspfsub]"),ctx).val();
	// var prodCop6id6 = $($("[id$=admincon_mod]"),ctx).val();

	var prodCop10 = $('.prodCls10', ctx).val();
	var obj2lkid = $(ctx)[0].rowIndex - 1 + "\\:stdusercon_lkid";
	var prodCop10id1 = $($("[id$=" + obj2lkid + "]"), ctx).val();
	var obj2lkold = $(ctx)[0].rowIndex - 1 + "\\:stdusercon_lkold";
	var prodCop10id2 = $($("[id$=" + obj2lkold + "]"), ctx).val();

	//  var prodCop10id3 = $($("[id$=stdusercon_lktp]"),ctx).val();
	// var prodCop10id4 = $($("[id$=stdusercon_lspf]"),ctx).val();
	// var prodCop10id5 = $($("[id$=stdusercon_lspfsub]"),ctx).val();
	// var prodCop10id6 = $($("[id$=stdusercon_mod]"),ctx).val();

	var prodCop14 = $('.prodCls14', ctx).val();
	var prodCop15 = $('.prodCls15', ctx).val();
	$("input.rowProdSelectBox:checkbox:checked").each(function () {
		ptx = $(this).closest('tr');
		$('.prodCls6', ptx).show();
		$('.aprodCls6', ptx).hide();
		$('.editCont', ptx).hide();

		$('.prodCls10', ptx).show();
		$('.aprodCls10', ptx).hide();
		$('.editCont1', ptx).hide();

		$(this).closest('tr').find('.prodCls1').val(prodCop1);
		$(this).closest('tr').find('.prodCls2').val(prodCop2);
		$(this).closest('tr').find('.prodCls3').val(prodCop3);
		$(this).closest('tr').find('.prodCls5').val(prodCop5);
		$(this).closest('tr').find('.prodCls7').val(prodCop7);
		$(this).closest('tr').find('.prodCls6').val(prodCop6);

		var objlkid = $(ptx)[0].rowIndex - 1 + "\\:admincon_lkid";
		$($("[id$=" + objlkid + "]"), ptx).val(prodCop6id1);
		var objlkold = $(ptx)[0].rowIndex - 1 + "\\:admincon_lkold";
		$($("[id$=" + objlkold + "]"), ptx).val(prodCop6id2);

		//$($("[id$=admincon_lktp]"),ptx).val(prodCop6id3);
		//  $($("[id$=admincon_lspf]"),ptx).val(prodCop6id4);
		//  $($("[id$=admincon_lspfsub]"),ptx).val(prodCop6id5);
		//  $($("[id$=admincon_mod]"),ptx).val(prodCop6id6);

		$(this).closest('tr').find('.prodCls10').val(prodCop10);
		var obj2lkid = $(ptx)[0].rowIndex - 1 + "\\:stdusercon_lkid";
		$($("[id$=" + obj2lkid + "]"), ptx).val(prodCop10id1);
		var obj2lkold = $(ptx)[0].rowIndex - 1 + "\\:stdusercon_lkold";
		$($("[id$=" + obj2lkold + "]"), ptx).val(prodCop10id2);

		//$($("[id$=stdusercon_lktp]"),ptx).val(prodCop10id3);
		//  $($("[id$=stdusercon_lspf]"),ptx).val(prodCop10id4);
		//  $($("[id$=stdusercon_lspfsub]"),ptx).val(prodCop10id5);
		//  $($("[id$=stdusercon_mod]"),ptx).val(prodCop10id6);
		$(this).closest('tr').find('.prodCls14').val(prodCop14);
		$(this).closest('tr').find('.prodCls15').val(prodCop15);
	});
	return false;
}
//Training Copy
function trainingCopy() {
	var ctx;
	$("input.rowTrnSelectBoxRad:radio:checked").each(function () {
		ctx = $(this).closest('tr');
	});
	var trnCop1 = $('.trnCls1', ctx).val();
	var trnCop2 = $('.trnCls2', ctx).val();
	var trnCop3 = $('.trnCls3', ctx).val();
	var trnCop4 = $('.trnCls4', ctx).val();
	var trnCop5 = $('.trnCls5', ctx).val();

	var objlkid = $(ctx)[0].rowIndex - 1 + "\\:onboardcon_lkid";
	var trnCop5id1 = $($("[id$=" + objlkid + "]"), ctx).val();
	var objlkold = $(ctx)[0].rowIndex - 1 + "\\:onboardcon_lkold";
	var trnCop5id2 = $($("[id$=" + objlkold + "]"), ctx).val();

	//var trnCop5id3 = $($("[id$=onboardcon_lktp]"),ctx).val();
	// var trnCop5id4 = $($("[id$=onboardcon_lspf]"),ctx).val();
	// var trnCop5id5 = $($("[id$=onboardcon_lspfsub]"),ctx).val();
	// var trnCop5id6 = $($("[id$=onboardcon_mod]"),ctx).val();

	var trnCop8 = $('.trnCls8', ctx).val();
	$("input.rowTrnSelectBox:checkbox:checked").each(function () {
		ptx = $(this).closest('tr');
		$('.trnCls5', ptx).show();
		$('.atrnCls5', ptx).hide();
		$('.editCont', ptx).hide();

		$(this).closest('tr').find('.trnCls1').val(trnCop1);
		$(this).closest('tr').find('.trnCls2').val(trnCop2);
		$(this).closest('tr').find('.trnCls3').val(trnCop3);
		$(this).closest('tr').find('.trnCls4').val(trnCop4);
		$(this).closest('tr').find('.trnCls5').val(trnCop5);

		var objlkid = $(ptx)[0].rowIndex - 1 + "\\:onboardcon_lkid";
		$($("[id$=" + objlkid + "]"), ptx).val(trnCop5id1);
		var objlkold = $(ptx)[0].rowIndex - 1 + "\\:onboardcon_lkold";
		$($("[id$=" + objlkold + "]"), ptx).val(trnCop5id2);
		//    $($("[id$=onboardcon_lktp]"),ptx).val(trnCop5id3);
		//  $($("[id$=onboardcon_lspf]"),ptx).val(trnCop5id4);
		//  $($("[id$=onboardcon_lspfsub]"),ptx).val(trnCop5id5);
		//  $($("[id$=onboardcon_mod]"),ptx).val(trnCop5id6);

		$(this).closest('tr').find('.trnCls8').val(trnCop8);

	});
	return false;
}
function toggleCheck(id) {
	var inputList = document.getElementsByClassName('selectInput');
	for (var i = 0; i < inputList.length; i++)
		document.getElementsByClassName('selectInput')[i].checked = id.checked;
}
function openWindow(url) {
	// url="https://freestyle--fetdemo.cs3.my.salesforce.com/a0f/o";
	newWin = window.open(url, 'Popup', 'height=600,width=600,left=100,top=100,resizable=yes,scrollbars=yes,toolbar=no,status=no');
	newWin.focus();
}
function showEle(eleID) {
	//document.getElementById("dThreshold").display ="block";
	document.getElementById(eleID).style.display = "block";
}

$(function () {
	$('.editCont').click(function (e) {
		e.preventDefault();
		var ctx;
		ctx = $(this).closest('td');
		$('.InsCls10', ctx).show();
		$('.ssreqCls14', ctx).show();
        $('.ssreqCls15', ctx).show();//OCR
		$('.InsCls13', ctx).show();
		$('.iwCls10', ctx).show();
		$('.iwCls13', ctx).show();
		$('.prodCls6', ctx).show();
		$('.prodCls10', ctx).show();
		$('.trnCls5', ctx).show();
		$('.assreqCls14', ctx).hide();
        $('.assreqCls15', ctx).hide();//OCR
		$('.aInsCls10', ctx).hide();
		$('.aInsCls13', ctx).hide();
		$('.aiwCls10', ctx).hide();
		$('.aiwCls13', ctx).hide();
		$('.aprodCls6', ctx).hide();
		$('.aprodCls10', ctx).hide();
		$('.atrnCls5', ctx).hide();
		$('.editCont', ctx).hide();
	});
});
$(function () {
	$('.editCont1').click(function (e) {
		e.preventDefault();
		var ctx;
		ctx = $(this).closest('td');
		$('.InsCls13', ctx).show();
		$('.iwCls13', ctx).show();
		$('.prodCls10', ctx).show();
		$('.aInsCls13', ctx).hide();
		$('.aiwCls13', ctx).hide();
		$('.aprodCls10', ctx).hide();
		$('.editCont1', ctx).hide();
	});
});

function toggling(obj) {
	var link = $(obj);
	link.closest('tr').find(".secondSite").slideToggle("fast", function () {
		
		if ($(this).is(':visible')) {
			link.text('-');
			link.attr('title', 'Close Second Site Survey');
		} else {
			link.text('+');
			link.attr('title', 'Open Second Site Survey');
		}
		var counter = 0;
		var hideCounter = 0;
		var rowCount = $('#sssurtab tr').length;
		$("tr.dataRow").each(function () {
			if ($(this).find(".secondSite").is(':visible')) {
				counter = counter + 1;
			} else {
				hideCounter = hideCounter + 1;
			}
		});
		if (counter > 0) {
			$("tr.headerRow").find(".secondSite1").show("fast");
		} else {
			$("tr.headerRow").find(".secondSite1").hide("fast");
		}
	});
}



function setCocordinateFocus(cordValue) {
	/*var cordval = $(cordValue).val();
	var sid = $(cordValue).attr('id');
	if (cordval != "Customer" && cordval != '') {
		document.getElementById(sid).parentNode.parentNode.nextSibling.children[0].children[1].focus();
	} else {*/
		var sid1 = $(cordValue).attr('id');
		document.getElementById(sid1).focus();
//	}
	disableScroll();
}

function setNoDispnsdAccntFocus(dispAccValue) {
	/*var disAccval = $(dispAccValue).val();
	var sid = $(dispAccValue).attr('id');
	console.log('sid ::' + sid);
	if (disAccval == "No") {
		document.getElementById(sid).parentNode.parentNode.nextSibling.children[0].children[1].focus();
	} else {*/
		var sid1 = $(dispAccValue).attr('id');
		document.getElementById(sid1).focus();
	//}
	disableScroll();
}

function setApprovedWaterFilterFocus(dispWaterFiltValue) {
	//var dispWaterFiltVal = $(dispWaterFiltValue).val();
	//var sid = $(dispWaterFiltValue).attr('id');
	//var elem = document.getElementById(sid).getBoundingClientRect();
	//if (dispWaterFiltVal == "No - approved make/model to be installed") {
	//	document.getElementById(sid).parentNode.parentNode.nextSibling.children[0].children[1].focus();
	//} else {
		var sid1 = $(dispWaterFiltValue).attr('id');
		document.getElementById(sid1).focus();
	//}
	disableScroll();
}

function setFocusOnDependent(focusValue) {
	//var dispWaterFiltVal = $(dispWaterFiltValue).val();
	//var sid = $(dispWaterFiltValue).attr('id');
	//var elem = document.getElementById(sid).getBoundingClientRect();
	//if (dispWaterFiltVal == "No - approved make/model to be installed") {
	//	document.getElementById(sid).parentNode.parentNode.nextSibling.children[0].children[1].focus();
	//} else {
		var sid1 = $(focusValue).attr('id');
		document.getElementById(sid1).focus();
	//}
	disableScroll();
}

var keys = {
	37: 1,
	38: 1,
	39: 1,
	40: 1
};

function preventDefault(e) {
	e = e || window.event;
	if (e.preventDefault)
		e.preventDefault();
	e.returnValue = false;
}

function preventDefaultForScrollKeys(e) {
	if (keys[e.keyCode]) {
		preventDefault(e);
		return false;
	}
}

function disableScroll() {

	if (window.addEventListener) // older FF
	{
		window.addEventListener('DOMMouseScroll', preventDefault, false);
	}
	window.onwheel = preventDefault; // modern standard
	window.onmousewheel = document.onmousewheel = preventDefault; // older browsers, IE
	window.ontouchmove = preventDefault; // mobile
	document.onkeydown = preventDefaultForScrollKeys;
}

function enableScroll() {
	if (window.removeEventListener)
		window.removeEventListener('DOMMouseScroll', preventDefault, false);
	window.onmousewheel = document.onmousewheel = null;
	window.onwheel = null;
	window.ontouchmove = null;
	document.onkeydown = null;
}

function onSANotReq() {
	var typAssesment = $('.ssreqCls13').val();
	if (typAssesment == 'SA Not Required - OSM approval required for local market') {
		$(".ssreqCls21").val("");
		$(".ssreqCls20").attr("disabled", false);
	}
}

//Site Survey Results Copy
$(function () {
    $('#SSResCopy').click(function () {
        
        var ctx;
        $("input.rowSSResSelectBoxRad:radio:checked").each(function () {
            ctx = $(this).closest('tr');
        });
        var resCop1 = $('.ssresCls1', ctx).val();
        var resCop2 = $('.ssresCls2', ctx).val();
        var resCop3 = $('.ssresCls3', ctx).val();
        var resCop10 = $('.ssresCls10', ctx).val();
        var resCop11 = $('.ssresCls11', ctx).val();
        var resCop12 = $('.ssresCls12', ctx).val();
        var resCop13 = $('.ssresCls13', ctx).val();
        var resCop14 = $('.ssresCls14', ctx).val();
        var resCop15 = $('.ssresCls15', ctx).val();
        var resCop16 = $('.ssresCls16', ctx).val();
        if($("input.rowSSResSelectBoxRad:radio:checked").length>0){
            $("input.rowSSResSelectBox:checkbox:checked").each(function () {
                $(this).closest('tr').find('.ssresCls1').val(resCop1);
                $(this).closest('tr').find('.ssresCls2').val(resCop2);
                $(this).closest('tr').find('.ssresCls3').val(resCop3);
                $(this).closest('tr').find('.ssresCls10').val(resCop10);
                $(this).closest('tr').find('.ssresCls11').val(resCop11);
                $(this).closest('tr').find('.ssresCls12').val(resCop12);
                $(this).closest('tr').find('.ssresCls13').val(resCop13);
                $(this).closest('tr').find('.ssresCls14').val(resCop14);
                $(this).closest('tr').find('.ssresCls15').val(resCop15);
                $(this).closest('tr').find('.ssresCls16').val(resCop16);
            });
        }
        return false;
    });
});

function oncopyEnable(obj)
{   
    console.log('Inside onCopyEnable');
    console.log('value' + obj.val());
    console.log('value' + obj[0].id);
    
    var objVal = obj.val();
    var idStr, flag=false;
    var lookupid;
    
    if( obj[0].id.indexOf("crewServe") != -1 )
    {
        idStr=crewServeIds;
        if( objVal == "Yes" ){
            flag=true;
        }
    }
    else if( obj[0].id.indexOf("noDispnsdAccnt") != -1 )
    {
        idStr=noDispnsdAccntIds;
        if( objVal == "No" ){
            flag=true;
        }
    }
    else if( obj[0].id.indexOf("contractorCoord") != -1 )
    {
        idStr="[id$=contractorcon]";
        lookupid="[id$=contractorcon_lkwgt]";
        ctx = $(lookupid).closest('tr');
        if( objVal != "Customer" ){
            flag=true;
        }                 
    }
        else if( obj[0].id.indexOf("approvedWaterFilter") != -1 )
        {
            idStr="[id$=installWaterFilter],[id$=wfcustcon],[id$=wfinstcon]";
            lookupid="[id$=wfcustcon_lkwgt],[id$=wfinstcon_lkwgt]";
            ctx = $(lookupid).closest('tr');
            if( objVal.indexOf("Yes") == -1 ){
                flag=true;
            }                 
        }
    else if( obj[0].id.indexOf("doesInstallRO4W") != -1 )
    {
        idStr="[id$=ro4w1],[id$=ro4w2],[id$=ro4w3]";
        lookupid="[id$=ro4w1_lkwgt],[id$=ro4w2_lkwgt],[id$=ro4w3_lkwgt]";
        ctx = $(lookupid).closest('tr');
        if( objVal.indexOf("Yes") != -1 ){
            flag=true;
        } 
    }
	else if( obj[0].id.indexOf("doesInstallReplacement") != -1 )
    {
        idStr="[id$=Replacement1],[id$=Replacement2],[id$=Replacement3]";
        lookupid="[id$=Replacement1_lkwgt],[id$=Replacement2_lkwgt],[id$=Replacement3_lkwgt]";
        ctx = $(lookupid).closest('tr');
        if( objVal.indexOf("Yes") != -1 ){
            flag=true;
        } 
    }
    if( flag == true ) 
    {
        //console.log($(elem).parents().eq(2).closest('tr').find(idStr));
        $(obj[0]).parents().eq(2).closest('tr').find(idStr).prop('disabled', false);
        $(obj[0]).parents().eq(2).find(lookupid).css("visibility","visible"); 
        $(obj[0]).parents().eq(2).closest('tr').find(idStr).closest('td').find('.requiredBlock').css("display","block");
    }
    else
    {
        $(obj[0]).parents().eq(2).closest('tr').find(idStr).prop('disabled', true);
        $(obj[0]).parents().eq(2).find(lookupid).css("visibility","hidden"); 
        $(obj[0]).parents().eq(2).closest('tr').find(idStr).val("");
        $(obj[0]).parents().eq(2).closest('tr').find(idStr).closest('td').find('.requiredBlock').css("display","none");
    }
}
function queryRelocation(installName){
    idStr="[id$=ro4w1],[id$=ro4w2],[id$=ro4w3]";
    var myquery = "SELECT Id,Name,RecordType.Name from Fs_Installation__C WHERE Name LIKE '"+installName.value+"'";
    result = sforce.connection.query(myquery);
    records = result.getArray("records");
 	var installation=records[0];
    var recordTypeName=installation.RecordType.Name;
    if( installation.RecordType.Name.indexOf("Relocation (O4W)") != -1 ){
        return true;
    }
    else{
        alert('Please select Relocation(O4W) records only');
        setTimeout(function(){$(installName).val('');}, 100);
    }
}
function queryReplacement(installName){
    idStr="[id$=Replacement1],[id$=Replacement2],[id$=Replacement3]";
    var myquery = "SELECT Id,Name,RecordType.Name from Fs_Installation__C WHERE Name LIKE '"+installName.value+"'";
    result = sforce.connection.query(myquery);
    records = result.getArray("records");
 	var installation=records[0];
    var recordTypeName=installation.RecordType.Name;
    if( installation.RecordType.Name.indexOf("Replacement") != -1 ){
        return true;
    }
    else{
        alert('Please select Replacement records only');
        setTimeout(function(){$(installName).val('');}, 100);
    }
}
function onchangeCrewServe(elem)
{    
    console.log(elem);
    var idStr,flag=false;
    var crewval = $(elem).val();
    var lookupid,ctx;
    
    console.log('-- elem id ::'+elem.id);
    
    
    
    if( elem.id.indexOf("crewServe") != -1 )
    {
        idStr=crewServeIds;
        if( crewval == "Yes" ){
            flag=true;
           // $(".deCls30").val("No");
        }
    }
     if( elem.id.indexOf("noDispnsdAccnt") != -1 )
    {
        idStr=noDispnsdAccntIds;
               
        if( crewval == "No" ){            
            flag=true;
        }
    }
    else if( elem.id.indexOf("contractorCoord") != -1 )
    {
        idStr="[id$=contractorcon]";
        lookupid="[id$=contractorcon_lkwgt]";
        ctx = $(lookupid).closest('tr');
        if( crewval != "Customer" ){
            flag=true;
        }                 
    }
        else if( elem.id.indexOf("approvedWaterFilter") != -1 )
        {
            idStr="[id$=installWaterFilter],[id$=wfcustcon],[id$=wfinstcon]";
            lookupid="[id$=wfcustcon_lkwgt],[id$=wfinstcon_lkwgt]";
            ctx = $(lookupid).closest('tr');
            if( crewval.indexOf("Yes") == -1 ){
                flag=true;
            }                 
        }
    else if( elem.id.indexOf("doesInstallRO4W") != -1 )
    {
        idStr="[id$=ro4w1],[id$=ro4w2],[id$=ro4w3]";
        lookupid="[id$=ro4w1_lkwgt],[id$=ro4w2_lkwgt],[id$=ro4w3_lkwgt]";
        ctx = $(lookupid).closest('tr');
        if( crewval.indexOf("Yes") != -1 ){
            flag=true;
        }  
    }
	else if( elem.id.indexOf("doesInstallReplacement") != -1 )
    {
        idStr="[id$=Replacement1],[id$=Replacement2],[id$=Replacement3]";
        lookupid="[id$=Replacement1_lkwgt],[id$=Replacement2_lkwgt],[id$=Replacement3_lkwgt]";
        ctx = $(lookupid).closest('tr');
        if( crewval.indexOf("Yes") != -1 ){
            flag=true;
        }  
    }
    if( flag == true ) 
    {
        console.log("Test"+$(elem).parents().eq(2).closest('tr').find(idStr));
        $(elem).parents().eq(2).closest('tr').find(idStr).prop('disabled', false);
        $(elem).parents().eq(2).find(lookupid).css("visibility","visible"); 
        $(elem).parents().eq(2).closest('tr').find(idStr).closest('td').find('.requiredBlock').css("display","block");
    }
    else
    {
        $(elem).parents().eq(2).closest('tr').find(idStr).prop('disabled', true);
        $(elem).parents().eq(2).find(lookupid).css("visibility","hidden"); 
        $(elem).parents().eq(2).closest('tr').find(idStr).val("");
        $(elem).parents().eq(2).closest('tr').find(idStr).closest('td').find('.requiredBlock').css("display","none");
    }
    
    //var checkVal = $(elem).parents().eq(2).closest('tr').find(idStr).closest('td').find('.deCls22').val();
    if( crewval == "Yes" ){
        $(elem).parents().eq(2).closest('tr').find(idStr).closest('td').find('.deCls22').val("No");        
    }
    // FNF-6.0 M-Series Enable Code
    //FNF-56
    //Enable & Disable Site Assessor Field based on What Type of Site Assessement Field Value
    var siteAsseVal=$(elem).val();
    var SAValue='SA Not Required - OSM approval required for local market';
    var idSA="[id$=siteAssessor]";
     if(siteAsseVal !="" && siteAsseVal != SAValue){
         console.log("SAType");        
         $(elem).parents().eq(2).closest('tr').find(idSA).prop('disabled', false);         
         $(elem).parents().eq(2).closest('tr').find(idSA).closest('td').find('.requiredBlock').css("display","block");
     }
    else{
        $(elem).parents().eq(2).closest('tr').find(idSA).prop('disabled', true);       
        $(elem).parents().eq(2).closest('tr').find(idSA).val("");
        $(elem).parents().eq(2).closest('tr').find(idSA).closest('td').find('.requiredBlock').css("display","none");
    }
   //FNF-56    
}

var crewServeIds="[id$=porControl],[id$=custIceFill],[id$=topOffFeature],[id$=crewSize],[id$=crewCupName],";
//crewServeIds=crewServeIds+"[id$=fluidOunces],[id$=crewSize2],[id$=crewCupName2],[id$=fluidOunces2]";
crewServeIds=crewServeIds+"[id$=FluidOunces1],[id$=FluidOunces2a],[id$=FluidOunces3],[id$=FluidOunces4],[id$=FluidOunces5],[id$=FluidOunces6],";
crewServeIds=crewServeIds+"[id$=Cup1],[id$=Cup2],[id$=Cup3],[id$=Cup4],[id$=Cup5],[id$=Cup6],";
crewServeIds=crewServeIds+"[id$=Size1],[id$=Size2],[id$=Size3],[id$=Size4],[id$=Size5],[id$=Size6]";

var noDispnsdAccntIds="[id$=removeAllFTN],[id$=fountainEquipmentOwnership],[id$=currentEquipment],[id$=currentBIBRack],";
noDispnsdAccntIds=noDispnsdAccntIds+"[id$=currentBIBPump],[id$=ancillaryEquipmentToRemainOnSite]";
            
function setCrewFocus()
{            
    var crewval = $("[id$=crewServe]").val();
    
    if(crewval == "Yes") 
    {
        $("[id$=porControl]").focus(); 
    }
    else
    {
        $("[id$=crewServe]").focus();
    }
    
}

function setCrewFocus(crewValue) {
/*	var crewval = $(crewValue).val();
	var sid = $(crewValue).attr('id');
	var elem = document.getElementById(sid).getBoundingClientRect();
	if (crewval == "Yes") {
		document.getElementById(sid).parentNode.parentNode.nextSibling.children[0].focus();
	} else {*/
		var sid1 = $(crewValue).attr('id');
		document.getElementById(sid1).focus();
	//}
	disableScroll();
}
			
function onchangeCrewServeLoad(){
    //console.log('---- load size ---- '+$('.detailList').find("[id$=crewServe]").size() );
    $('.detailList').find("[id$=contractorCoord]").each(function(){
        onchangeCrewServe(this);
    });
    
    $('.detailList').find("[id$=crewServe]").each(function(){
        onchangeCrewServe(this);
    });
    
    $('.detailList').find("[id$=noDispnsdAccnt]").each(function(){
        onchangeCrewServe(this);
    });
    
    $('.detailList').find("[id$=approvedWaterFilter]").each(function(){
        onchangeCrewServe(this);
    });
     $('.detailList').find("[id$=doesInstallRO4W]").each(function(){
        onchangeCrewServe(this);
    });
	$('.detailList').find("[id$=doesInstallReplacement]").each(function(){
        onchangeCrewServe(this);
    });
   // FNF-6.0 M-Series Enable Code
   //Calling function to Enable & Disable Site Assessor Field based on What Type of Site Assessement Field Value
	$('.detailList').find("[id$=SAType]").each(function(){
        onchangeCrewServe(this);
    });
}



$(function () {
					$("tr.dataRow").each(function () {
						var allListElements = $(".ssreqCls14,.InsCls10,.iwCls10,.prodCls6,.trnCls5"); 
						var allListElements1 = $(".InsCls13,.iwCls13,.prodCls10,.ssreqCls15"); //OCR added .ssreqCls15
						var allLinkElements = $(".assreqCls14,.aInsCls10,.aiwCls10,.aprodCls6,.atrnCls5");
						var allLinkElements1 = $(".aInsCls13,.aiwCls13,.aprodCls10,.assreqCls15"); //OCR added .assreqCls15
						$('td.zxcv', this).each(function () {
							var quantity1 = $.trim($(this).find(allListElements).val());
							var quantity1a = $.trim($(this).find(allLinkElements).text());
							if (quantity1 != null && quantity1 != '' && quantity1a != '') {
								$(this).find(".ssreqCls14").hide();
								$(this).find(".InsCls10").hide();
								$(this).find(".iwCls10").hide();
								$(this).find(".prodCls6").hide();
								$(this).find(".trnCls5").hide();
								$(this).find(".assreqCls14").show();
								$(this).find(".aInsCls10").show();
								$(this).find(".aiwCls10").show();
								$(this).find(".aprodCls6").show();
								$(this).find(".atrnCls5").show();
								$(this).find(".editCont").show();
							} else if ((quantity1 == '' && quantity1a == '') || (quantity1 != '' && quantity1a == '')) {
								$(this).find(".ssreqCls14").show();
								$(this).find(".InsCls10").show();
								$(this).find(".iwCls10").show();
								$(this).find(".prodCls6").show();
								$(this).find(".trnCls5").show();
								$(this).find(".assreqCls14").hide();
								$(this).find(".aInsCls10").hide();
								$(this).find(".aiwCls10").hide();
								$(this).find(".aprodCls6").hide();
								$(this).find(".atrnCls5").hide();
								$(this).find(".editCont").hide();
							}
							var quantity2 = $.trim($(this).find(allListElements1).val());
							var quantity2a = $.trim($(this).find(allLinkElements1).text());
							if (quantity2 != null && quantity2 != '' && quantity2a != null && quantity2a != '') {
								$(this).find(".InsCls13").hide();
								$(this).find(".iwCls13").hide();
								$(this).find(".prodCls10").hide();
								$(this).find(".aInsCls13").show();
								$(this).find(".aiwCls13").show();
								$(this).find(".aprodCls10").show();
                                $(this).find(".ssreqCls15").hide();//OCR
                                $(this).find(".assreqCls15").show();//OCR
								$(this).find(".editCont1").show();
							} else if ((quantity2 == '' && quantity2a == '') || (quantity2 != '' && quantity2a == '')) {
								$(this).find(".InsCls13").show();
								$(this).find(".iwCls13").show();
								$(this).find(".prodCls10").show();
								$(this).find(".aInsCls13").hide();
								$(this).find(".aiwCls13").hide();
								$(this).find(".aprodCls10").hide();
                                $(this).find(".ssreqCls15").show();//OCR
                                $(this).find(".assreqCls15").hide();//OCR
								$(this).find(".editCont1").hide();
							}
						});
					});
				});
                