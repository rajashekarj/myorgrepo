        
         $(window).load(function() {
             setFocusOnLoad();checkValue();
            $(".loader").fadeOut("fast");
             document.getElementById("j_id0:frm:sRNId:j_id197_mlktp").style.display = 'none';            
        });                 
         
        function bodyOnLoad(){setFocusOnLoad();}
        function setFocusOnLoad(){}
        
         
        $(function(){
            $('#dispenserCopy').click(function(){
                var ctx;
                $("input.rowDESelectBoxRad:radio:checked").each(function(){
                    ctx = $(this).closest('tr');
                });
                debugger;
                var disCop1 = $('.deCls1', ctx).val();                
                var disCop3 = $('.deCls3', ctx).val();
                var disCop4 = $('.deCls4', ctx).val();                                
                
                //copying brandset values
                var objP1=$(ctx)[0].rowIndex-1+"\\:plat1";
                var discopP1 = $($("[id$="+objP1+"]"),ctx).text();
                
                var objP2=$(ctx)[0].rowIndex-1+"\\:plat2";
                var discopP2 = $($("[id$="+objP2+"]"),ctx).text();
                
                var objP3=$(ctx)[0].rowIndex-1+"\\:plat3";
                var discopP3 = $($("[id$="+objP3+"]"),ctx).text();                            
                
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
                var disCop6 = $('.deCls6', ctx).val();
                var disCop12 = $('.deCls12', ctx).val();  
                var disCop18 = $('.deCls18', ctx).val();
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
                $("input.rowDESelectBox:checkbox:checked").each(function(){
                        $(this).closest('tr').find('.deCls1').val(disCop1);                        
                        $(this).closest('tr').find('.deCls3').val(disCop3);
                        $(this).closest('tr').find('.deCls4').val(disCop4);                        
                    
                        var objP1a=$(ptx)[0].rowIndex-1+"\\:plat1";
                        var discopP1a = $($("[id$="+objP1a+"]"),ptx).text();
                        
                        var objP2a=$(ptx)[0].rowIndex-1+"\\:plat2";
                        var discopP2a = $($("[id$="+objP2a+"]"),ptx).text();
                        
                        var objP3a=$(ptx)[0].rowIndex-1+"\\:plat3";
                        var discopP3a = $($("[id$="+objP3a+"]"),ptx).text();
                                            
                        if(discopP1a == discopP1 || discopP1a == discopP2 || discopP1a == discopP3 )
                        {
                        $(this).closest('tr').find('.deCls2').val(map[discopP1a]);
                        $(this).closest('tr').find('.deCls5').val(map2[discopP1a]); 
                        $(this).closest('tr').find('.deCls6').val(map3[discopP1a]);    
                        }
                    
                        if(discopP2a == discopP1 || discopP2a == discopP2 || discopP2a == discopP3 )                 
                        {
                        $(this).closest('tr').find('.deCls8').val(map[discopP2a]);
                        $(this).closest('tr').find('.deCls11').val(map2[discopP2a]);
                        $(this).closest('tr').find('.deCls12').val(map3[discopP2a]);                                
                        }
                    
                        if(discopP3a == discopP1 || discopP3a == discopP2 || discopP3a == discopP3 )                 
                        {
                        $(this).closest('tr').find('.deCls14').val(map[discopP3a]);   
                        $(this).closest('tr').find('.deCls17').val(map2[discopP3a]);
                        $(this).closest('tr').find('.deCls18').val(map3[discopP3a]);    
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
                });
                return false;
            });
        });
        //Site Survey Request Copy
        function ssrcopy(obj)
        {                 
            var ctx;
            $("input.rowSSReqSelectBoxRad:radio:checked").each(function(){                
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
            var cusCop13 = $('.ssreqCls13', ctx).val();                
            var cusCop14 = $('.ssreqCls14', ctx).val();
            //var cusCop14id = $("[id$=fieldValue_lkid]").val();
            var objlkid=$(ctx)[0].rowIndex-1+"\\:fieldValue_lkid";
            var cusCop14id1 = $($("[id$="+objlkid+"]"),ctx).val();
            var objlkold=$(ctx)[0].rowIndex-1+"\\:fieldValue_lkold";
            var cusCop14id2 = $($("[id$="+objlkold+"]"),ctx).val();
            var objlktp=$(ctx)[0].rowIndex-1+"\\:fieldValue_lktp";
            var cusCop14id3 = $($("[id$="+objlktp+"]"),ctx).val();
            var objlspf=$(ctx)[0].rowIndex-1+"\\:fieldValue_lspf";
            var cusCop14id4 = $($("[id$="+objlspf+"]"),ctx).val();
            var objlspfsub=$(ctx)[0].rowIndex-1+"\\:fieldValue_lspfsub";
            var cusCop14id5 = $($("[id$="+objlspfsub+"]"),ctx).val();
            var objlkmod=$(ctx)[0].rowIndex-1+"\\:fieldValue_mod";
            var cusCop14id6 = $($("[id$="+objlkmod+"]"),ctx).val();
            //var cusCop14id3 = $($("[id$=fieldValue_lktp]"),ctx).val();
            //var cusCop14id4 = $($("[id$=fieldValue_lspf]"),ctx).val();
            //var cusCop14id5 = $($("[id$=fieldValue_lspfsub]"),ctx).val();
            //var cusCop14id6 = $($("[id$=fieldValue_mod]"),ctx).val();                                
            
            var cusCop19 = $('.ssreqCls19', ctx).val();
            var cusCop20 = $('.ssreqCls20', ctx).val();
            var cusCop21 = $('.ssreqCls21', ctx).val();
            var cusCop22 = $('.ssreqCls22', ctx).val();
            var cusCop23 = $('.ssreqCls23', ctx).val();
            var cusCop25 = $('.ssreqCls25', ctx).val();
            var cusCop24 = $('.ssreqCls24', ctx).prop('checked');
            var cusCop26 = $('.ssreqCls26', ctx).val();
            var cusCop27 = $('.ssreqCls27', ctx).prop('checked');
            var cusCop28 = $('.ssreqCls28', ctx).val();
            var cusCop29 = $('.ssreqCls29', ctx).val();
            var cusCop30 = $('.ssreqCls30', ctx).val();
            var cusCop31 = $('.ssreqCls31', ctx).val();
            var cusCop32 = $('.ssreqCls32', ctx).val();
            var cusCop33 = $('.ssreqCls33', ctx).val();
            $("input.rowSSReqSelectBox:checkbox:checked").each(function(){
                ptx = $(this).closest('tr');
                $('.ssreqCls14', ptx).show();
                $('.assreqCls14', ptx).hide();
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
                $(this).closest('tr').find('.ssreqCls13').val(cusCop13);                                                        
                $(this).closest('tr').find('.ssreqCls14').val(cusCop14);   
                
                
                var objlkid=$(ptx)[0].rowIndex-1+"\\:fieldValue_lkid";
                $($("[id$="+objlkid+"]"),ptx).val(cusCop14id1);
                
                var objlkold=$(ptx)[0].rowIndex-1+"\\:fieldValue_lkold";
                $($("[id$="+objlkold+"]"),ptx).val(cusCop14id2);
                //$($("[id$=fieldValue_lktp]"),ptx).val(cusCop14id3);
                //$($("[id$=fieldValue_lspf]"),ptx).val(cusCop14id4);
                //$($("[id$=fieldValue_lspfsub]"),ptx).val(cusCop14id5);
                //$($("[id$=fieldValue_mod]"),ptx).val(cusCop14id6);
                
                var a = $($("[id$=fieldValue_lkid]"),ptx).val();
                var b = $($("[id$=fieldValue_lkold]"),ptx).val();
                var c = $($("[id$=fieldValue_lktp]"),ptx).val();
                var d = $($("[id$=fieldValue_lspf]"),ptx).val();
                var e = $($("[id$=fieldValue_lspfsub]"),ptx).val();
                var f = $($("[id$=fieldValue_mod]"),ptx).val();                    
                
                $(this).closest('tr').find('.ssreqCls19').val(cusCop19);
                $(this).closest('tr').find('.ssreqCls20').val(cusCop20);
                $(this).closest('tr').find('.ssreqCls21').val(cusCop21);
                $(this).closest('tr').find('.ssreqCls22').val(cusCop22);
                $(this).closest('tr').find('.ssreqCls23').val(cusCop23);
                $(this).closest('tr').find('.ssreqCls25').val(cusCop25);
                $(this).closest('tr').find('.ssreqCls24').prop('checked',cusCop24);
                $(this).closest('tr').find('.ssreqCls26').val(cusCop26);
                $(this).closest('tr').find('.ssreqCls27').prop('checked',cusCop27);
                $(this).closest('tr').find('.ssreqCls28').val(cusCop28);
                $(this).closest('tr').find('.ssreqCls29').val(cusCop29);
                $(this).closest('tr').find('.ssreqCls30').val(cusCop30);
                $(this).closest('tr').find('.ssreqCls31').val(cusCop31);
                $(this).closest('tr').find('.ssreqCls32').val(cusCop32);
                $(this).closest('tr').find('.ssreqCls33').val(cusCop33);
            });
            return false;
        }

        // Site Survey Results Copy
        $(function(){
            $('#SSResCopy').click(function(){
                var ctx;
                $("input.rowSSResSelectBoxRad:radio:checked").each(function(){
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
                $("input.rowSSResSelectBox:checkbox:checked").each(function(){
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
                return false;
            });
        });
        // Installation Copy
        function instalCopy()
         {
                var ctx;
                $("input.rowInsSelectBoxRad:radio:checked").each(function(){
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

                var objlkid=$(ctx)[0].rowIndex-1+"\\:contractorcon_lkid";             
                var InsCop10id1 = $($("[id$="+objlkid+"]"),ctx).val();
                var objlkold=$(ctx)[0].rowIndex-1+"\\:contractorcon_lkold";               
                var InsCop10id2 = $($("[id$="+objlkold+"]"),ctx).val();
                                  
             //var InsCop10id3 = $($("[id$=contractorcon_lktp]"),ctx).val();
             // var InsCop10id4 = $($("[id$=contractorcon_lspf]"),ctx).val();
             // var InsCop10id5 = $($("[id$=contractorcon_lspfsub]"),ctx).val();
             // var InsCop10id6 = $($("[id$=contractorcon_mod]"),ctx).val();
                
                var InsCop13 = $('.InsCls13', ctx).val();
                var obj2lkid=$(ctx)[0].rowIndex-1+"\\:outletcon_lkid";
                var InsCop13id1 = $($("[id$="+obj2lkid+"]"),ctx).val();
                var obj2lkold=$(ctx)[0].rowIndex-1+"\\:outletcon_lkold";                  
                var InsCop13id2 = $($("[id$="+obj2lkold+"]"),ctx).val();
                
             //   var InsCop13id3 = $($("[id$=outletcon_lktp]"),ctx).val();
             // var InsCop13id4 = $($("[id$=outletcon_lspf]"),ctx).val();
             // var InsCop13id5 = $($("[id$=outletcon_lspfsub]"),ctx).val();
             // var InsCop13id6 = $($("[id$=outletcon_mod]"),ctx).val();
                
                var InsCop14 = $('.InsCls14', ctx).val();
                var InsCop15 = $('.InsCls15', ctx).val();
                var InsCop16 = $('.InsCls16', ctx).val();
                $("input.rowInsSelectBox:checkbox:checked").each(function(){
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
                    var objlkid=$(ptx)[0].rowIndex-1+"\\:contractorcon_lkid";                    
                    $($("[id$="+objlkid+"]"),ptx).val(InsCop10id1);
                    var objlkold=$(ptx)[0].rowIndex-1+"\\:contractorcon_lkold";
                    $($("[id$="+objlkold+"]"),ptx).val(InsCop10id2);
                    
                    //$($("[id$=contractorcon_lktp]"),ptx).val(InsCop10id3);
                    //$($("[id$=contractorcon_lspf]"),ptx).val(InsCop10id4);
                    //$($("[id$=contractorcon_lspfsub]"),ptx).val(InsCop10id5);
                    //$($("[id$=contractorcon_mod]"),ptx).val(InsCop10id6);
                    
                    $(this).closest('tr').find('.InsCls13').val(InsCop13);
                    var obj2lkid=$(ptx)[0].rowIndex-1+"\\:outletcon_lkid";
                    $($("[id$="+obj2lkid+"]"),ptx).val(InsCop13id1);
                    var obj2lkold=$(ptx)[0].rowIndex-1+"\\:outletcon_lkold";                    
                    $($("[id$="+obj2lkold+"]"),ptx).val(InsCop13id2);
                    
                    //$($("[id$=outletcon_lktp]"),ptx).val(InsCop13id3);
                    //$($("[id$=outletcon_lspf]"),ptx).val(InsCop13id4);
                    //$($("[id$=outletcon_lspfsub]"),ptx).val(InsCop13id5);
                    //$($("[id$=outletcon_mod]"),ptx).val(InsCop13id6);
                    
                    $(this).closest('tr').find('.InsCls14').val(InsCop14);
                    $(this).closest('tr').find('.InsCls15').val(InsCop15);
                    $(this).closest('tr').find('.InsCls16').val(InsCop16);                        
                });
                return false;
        }
        // IceMaker/WaterFilter Copy
        function imwfCopy()
         {
                //alert($("input.colIWSelectBox1:checkbox:checked").val());
                var ctx;
                $("input.rowIWSelectBoxRad:radio:checked").each(function(){
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
             
                var objlkid=$(ctx)[0].rowIndex-1+"\\:wfcustcon_lkid";             
                var iwCop10id1 = $($("[id$="+objlkid+"]"),ctx).val();
                var objlkold=$(ctx)[0].rowIndex-1+"\\:wfcustcon_lkold";               
                var iwCop10id2 = $($("[id$="+objlkold+"]"),ctx).val();
                          
             //var iwCop10id3 = $($("[id$=wfcustcon_lktp]"),ctx).val();
             // var iwCop10id4 = $($("[id$=wfcustcon_lspf]"),ctx).val();
             // var iwCop10id5 = $($("[id$=wfcustcon_lspfsub]"),ctx).val();
             // var iwCop10id6 = $($("[id$=wfcustcon_mod]"),ctx).val();
                
                var iwCop13 = $('.iwCls13', ctx).val();
                var obj2lkid=$(ctx)[0].rowIndex-1+"\\:wfinstcon_lkid";
                var iwCop13id1 = $($("[id$="+obj2lkid+"]"),ctx).val();
                var obj2lkold=$(ctx)[0].rowIndex-1+"\\:wfinstcon_lkold";                  
                var iwCop13id2 = $($("[id$="+obj2lkold+"]"),ctx).val();
                          
             //  var iwCop13id3 = $($("[id$=wfinstcon_lktp]"),ctx).val();
             // var iwCop13id4 = $($("[id$=wfinstcon_lspf]"),ctx).val();
             // var iwCop13id5 = $($("[id$=wfinstcon_lspfsub]"),ctx).val();
             // var iwCop13id6 = $($("[id$=wfinstcon_mod]"),ctx).val();
                
                var iwCop16 = $('.iwCls16', ctx).val();
                var iwCop17 = $('.iwCls17', ctx).val();
                var iwCop18 = $('.iwCls18', ctx).val();
                var iwCop19 = $('.iwCls19', ctx).val();
                $("input.rowIWSelectBox:checkbox:checked").each(function(){
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
                    
                    var objlkid=$(ptx)[0].rowIndex-1+"\\:wfcustcon_lkid";  
                    $($("[id$="+objlkid+"]"),ptx).val(iwCop10id1);
                    var objlkold=$(ptx)[0].rowIndex-1+"\\:wfcustcon_lkold";
                    $($("[id$="+objlkold+"]"),ptx).val(iwCop10id2);
                                        
                    //$($("[id$=wfcustcon_lktp]"),ptx).val(iwCop10id3);
                    //$($("[id$=wfcustcon_lspf]"),ptx).val(iwCop10id4);
                    //$($("[id$=wfcustcon_lspfsub]"),ptx).val(iwCop10id5);
                    //$($("[id$=wfcustcon_mod]"),ptx).val(iwCop10id6);
                    
                    $(this).closest('tr').find('.iwCls13').val(iwCop13);
                    var obj2lkid=$(ptx)[0].rowIndex-1+"\\:wfinstcon_lkid";  
                    $($("[id$="+obj2lkid+"]"),ptx).val(iwCop13id1);
                    var obj2lkold=$(ptx)[0].rowIndex-1+"\\:wfinstcon_lkold";
                    $($("[id$="+obj2lkold+"]"),ptx).val(iwCop13id2);   
                                        
                    //$($("[id$=wfinstcon_lktp]"),ptx).val(iwCop13id3);
                    //$($("[id$=wfinstcon_lspf]"),ptx).val(iwCop13id4);
                    //$($("[id$=wfinstcon_lspfsub]"),ptx).val(iwCop13id5);
                    //$($("[id$=wfinstcon_mod]"),ptx).val(iwCop13id6);
                    
                    $(this).closest('tr').find('.iwCls16').val(iwCop16);
                    $(this).closest('tr').find('.iwCls17').val(iwCop17);
                    $(this).closest('tr').find('.iwCls18').val(iwCop18);
                    $(this).closest('tr').find('.iwCls19').val(iwCop19);
                });
                return false;
        }
        
        //Product Copy
        function productCopy()
         {
                var ctx;
                $("input.rowProdSelectBoxRad:radio:checked").each(function(){
                    ctx = $(this).closest('tr');
                });
                var prodCop1 = $('.prodCls1', ctx).val();
                var prodCop2 = $('.prodCls2', ctx).val();
                var prodCop3 = $('.prodCls3', ctx).val();
                var prodCop7 = $('.prodCls7', ctx).val();
                var prodCop5 = $('.prodCls5', ctx).val();
                var prodCop6 = $('.prodCls6', ctx).val();
             
                var objlkid=$(ctx)[0].rowIndex-1+"\\:admincon_lkid"; 
                var prodCop6id1 = $($("[id$="+objlkid+"]"),ctx).val();
                var objlkold=$(ctx)[0].rowIndex-1+"\\:admincon_lkold";
                var prodCop6id2 = $($("[id$="+objlkold+"]"),ctx).val();
             
             // var prodCop6id3 = $($("[id$=admincon_lktp]"),ctx).val();
             // var prodCop6id4 = $($("[id$=admincon_lspf]"),ctx).val();
             // var prodCop6id5 = $($("[id$=admincon_lspfsub]"),ctx).val();
             // var prodCop6id6 = $($("[id$=admincon_mod]"),ctx).val();
                
                var prodCop10 = $('.prodCls10', ctx).val();
                var obj2lkid=$(ctx)[0].rowIndex-1+"\\:stdusercon_lkid";
                var prodCop10id1 = $($("[id$="+obj2lkid+"]"),ctx).val();
                var obj2lkold=$(ctx)[0].rowIndex-1+"\\:stdusercon_lkold";
                var prodCop10id2 = $($("[id$="+obj2lkold+"]"),ctx).val();
             
             //  var prodCop10id3 = $($("[id$=stdusercon_lktp]"),ctx).val();
             //  var prodCop10id4 = $($("[id$=stdusercon_lspf]"),ctx).val();
             // var prodCop10id5 = $($("[id$=stdusercon_lspfsub]"),ctx).val();
             // var prodCop10id6 = $($("[id$=stdusercon_mod]"),ctx).val();
                
                var prodCop14 = $('.prodCls14', ctx).val();
                var prodCop15 = $('.prodCls15', ctx).val();
                $("input.rowProdSelectBox:checkbox:checked").each(function(){
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
                    
                        var objlkid=$(ptx)[0].rowIndex-1+"\\:admincon_lkid"; 
                        $($("[id$="+objlkid+"]"),ptx).val(prodCop6id1);
                        var objlkold=$(ptx)[0].rowIndex-1+"\\:admincon_lkold";
                        $($("[id$="+objlkold+"]"),ptx).val(prodCop6id2);
                    //$($("[id$=admincon_lktp]"),ptx).val(prodCop6id3);
                    //$($("[id$=admincon_lspf]"),ptx).val(prodCop6id4);
                    //  $($("[id$=admincon_lspfsub]"),ptx).val(prodCop6id5);
                    //  $($("[id$=admincon_mod]"),ptx).val(prodCop6id6);
                        
                        $(this).closest('tr').find('.prodCls10').val(prodCop10);
                        var obj2lkid=$(ptx)[0].rowIndex-1+"\\:stdusercon_lkid"; 
                        $($("[id$="+obj2lkid+"]"),ptx).val(prodCop10id1);
                        var obj2lkold=$(ptx)[0].rowIndex-1+"\\:stdusercon_lkold";
                        $($("[id$="+obj2lkold+"]"),ptx).val(prodCop10id2);
                    
                    //   $($("[id$=stdusercon_lktp]"),ptx).val(prodCop10id3);
                    //  $($("[id$=stdusercon_lspf]"),ptx).val(prodCop10id4);
                    //  $($("[id$=stdusercon_lspfsub]"),ptx).val(prodCop10id5);
                    //  $($("[id$=stdusercon_mod]"),ptx).val(prodCop10id6);
                        $(this).closest('tr').find('.prodCls14').val(prodCop14);
                        $(this).closest('tr').find('.prodCls15').val(prodCop15);
                });
                return false;
        }
        //Training Copy
        function trainingCopy()
         {
                var ctx;
                $("input.rowTrnSelectBoxRad:radio:checked").each(function(){
                    ctx = $(this).closest('tr');
                });
                var trnCop1 = $('.trnCls1', ctx).val();
                var trnCop2 = $('.trnCls2', ctx).val();
                var trnCop3 = $('.trnCls3', ctx).val();
                var trnCop4 = $('.trnCls4', ctx).val();
                var trnCop5 = $('.trnCls5', ctx).val();
                
                var objlkid=$(ctx)[0].rowIndex-1+"\\:onboardcon_lkid"; 
                var trnCop5id1 = $($("[id$="+objlkid+"]"),ctx).val();
                var objlkold=$(ctx)[0].rowIndex-1+"\\:onboardcon_lkold";
                var trnCop5id2 = $($("[id$="+objlkold+"]"),ctx).val();
             
             //   var trnCop5id3 = $($("[id$=onboardcon_lktp]"),ctx).val();
             // var trnCop5id4 = $($("[id$=onboardcon_lspf]"),ctx).val();
             // var trnCop5id5 = $($("[id$=onboardcon_lspfsub]"),ctx).val();
             // var trnCop5id6 = $($("[id$=onboardcon_mod]"),ctx).val();
                
                var trnCop8 = $('.trnCls8', ctx).val();
                $("input.rowTrnSelectBox:checkbox:checked").each(function(){
                        ptx = $(this).closest('tr');
                        $('.trnCls5', ptx).show();
                        $('.atrnCls5', ptx).hide();
                        $('.editCont', ptx).hide();
                    
                        $(this).closest('tr').find('.trnCls1').val(trnCop1);
                        $(this).closest('tr').find('.trnCls2').val(trnCop2);
                        $(this).closest('tr').find('.trnCls3').val(trnCop3);
                        $(this).closest('tr').find('.trnCls4').val(trnCop4);
                        $(this).closest('tr').find('.trnCls5').val(trnCop5);
                        
                        var objlkid=$(ptx)[0].rowIndex-1+"\\:onboardcon_lkid"; 
                        $($("[id$="+objlkid+"]"),ptx).val(trnCop5id1);
                        var objlkold=$(ptx)[0].rowIndex-1+"\\:onboardcon_lkold";
                        $($("[id$="+objlkold+"]"),ptx).val(trnCop5id2);
                    
                    //     $($("[id$=onboardcon_lktp]"),ptx).val(trnCop5id3);
                    //  $($("[id$=onboardcon_lspf]"),ptx).val(trnCop5id4);
                    //  $($("[id$=onboardcon_lspfsub]"),ptx).val(trnCop5id5);
                    //  $($("[id$=onboardcon_mod]"),ptx).val(trnCop5id6);
                        
                        $(this).closest('tr').find('.trnCls8').val(trnCop8);
                    
                });
                return false;
            }
         /*window.onload=function(){
            document.getElementById("j_id0:frm:sRNId:j_id197_mlktp").style.display = 'none';            
            } */ 
         
        //Finance Copy
        $(function(){
            $('#finCopy').click(function(){
                var ctx;
                $("input.rowFinSelectBoxRad:radio:checked").each(function(){
                    ctx = $(this).closest('tr');
                });
                var finCop1 = $('.finCls1', ctx).val();
                var finCop2 = $('.finCls2', ctx).val();
                var finCop4 = $('.finCls4', ctx).val();
                var finCop5 = $('.finCls5', ctx).val();
                var finCop6 = $('.finCls6', ctx).val();
                var finCop7 = $('.finCls7', ctx).val();
                var finCop8 = $('.finCls8', ctx).val();
                var finCop9 = $('.finCls9', ctx).val();
                var finCop10 = $('.finCls10', ctx).val();
                var finCop11 = $('.finCls11', ctx).val();
                var finCop12 = $('.finCls12', ctx).val();
                var finCop13 = $('.finCls13', ctx).val();
                var finCop14 = $('.finCls14', ctx).val();
                var finCop15 = $('.finCls15', ctx).val();
                var finCop16 = $('.finCls16', ctx).val();
                $("input.rowFinSelectBox:checkbox:checked").each(function(){
                    $(this).closest('tr').find('.finCls1').val(finCop1);
                    $(this).closest('tr').find('.finCls2').val(finCop2);
                    $(this).closest('tr').find('.finCls4').val(finCop4);
                    $(this).closest('tr').find('.finCls5').val(finCop5);
                    $(this).closest('tr').find('.finCls6').val(finCop6);
                    $(this).closest('tr').find('.finCls7').val(finCop7);
                    $(this).closest('tr').find('.finCls8').val(finCop8);
                    $(this).closest('tr').find('.finCls9').val(finCop9);
                    $(this).closest('tr').find('.finCls10').val(finCop10);
                    $(this).closest('tr').find('.finCls11').val(finCop11);
                    $(this).closest('tr').find('.finCls12').val(finCop12);
                    $(this).closest('tr').find('.finCls13').val(finCop13);
                    $(this).closest('tr').find('.finCls14').val(finCop14);
                    $(this).closest('tr').find('.finCls15').val(finCop15);
                    $(this).closest('tr').find('.finCls16').val(finCop16);
                });
                return false;
            });
        });
        function toggleCheck(id) {
            var inputList = document.getElementsByClassName('selectInput');
            for(var i=0;i<inputList.length;i++)
                document.getElementsByClassName('selectInput')[i].checked = id.checked;
        }
        function openWindow(url){
            // url="https://freestyle--fetdemo.cs3.my.salesforce.com/a0f/o";            
             newWin=window.open(url, 'Popup','height=600,width=600,left=100,top=100,resizable=yes,scrollbars=yes,toolbar=no,status=no');
             newWin.focus();
            
        } 
        function showEle(eleID) {
            //document.getElementById("dThreshold").display ="block";
            document.getElementById(eleID).style.display ="block";
        }
        function openLookup(baseURL, width, modified, searchParam){
       // alert('Inside custom lookup');
            var originalbaseURL = baseURL;
            var originalwidth = width;
            var originalmodified = modified;
            var originalsearchParam = searchParam;
        
            var lookupType = baseURL.substr(baseURL.search("lktp")+5, 3);
            
            if (modified == '1') baseURL = baseURL + searchParam;
           // alert(lookupType);
            var isCustomLookup = false;
            // Following "001" is the lookup type for Account object so change this as per your standard or custom object
            if(lookupType == "a0K" || lookupType == "003"){
           
              var urlArr = baseURL.split("&");
              var txtId = '';
              if(urlArr.length > 2) {
                urlArr = urlArr[1].split('=');
                txtId = urlArr[1];
              }
        
              // Following is the url of Custom Lookup page. You need to change that accordingly
              baseURL = "/apex/FSCIFSalesRepInfoCustLookup?txt=" + txtId;
        
              // Following is the id of apex:form control "myForm". You need to change that accordingly
              baseURL = baseURL + "&frm=" + escapeUTF("{!$Component.myForm}");
              if (modified == '1') {
               
                if(baseURL.includes("sRNFID")){
                
                    baseURL = baseURL + "&lksearch=" + searchParam + "&sri='Sales Team Member'";
                }
                else if(baseURL.includes("fieldValue") || baseURL.includes("contractorcon") || baseURL.includes("outletcon") || baseURL.includes("wfcustcon") 
                        || baseURL.includes("wfinstcon") || baseURL.includes("admincon") || baseURL.includes("stdusercon") || baseURL.includes("onboardcon"))
                {
                    
                    baseURL =   "/apex/FSCIFContactCustLookup?txt=" + txtId; 
                    baseURL = baseURL + "&lksearch=" + searchParam + "&sri='Contact Lookup'";
                }
                
                
                else {
                    baseURL = baseURL + "&lksearch=" + searchParam + "&sri='COM'";
                }
                baseURL = baseURL + "&fshq='FS Headquarters'" +"&accID='{!accId}'";
              }
              
              
            
              // Following is the ID of inputField that is the lookup to be customized as custom lookup
              if(txtId.indexOf('RNId') > -1 || txtId.indexOf('con') > -1 || txtId.indexOf('fieldValue') > -1){
                   isCustomLookup = true;
              }
            }
        
        
            if(isCustomLookup == true){
              openPopup(baseURL, "lookup", 350, 480, "width="+width+",height=480,toolbar=no,status=no,directories=no,menubar=no,resizable=yes,scrollable=no", true);
            }
            else {
              if (modified == '1') originalbaseURL = originalbaseURL + originalsearchParam;
              openPopup(originalbaseURL, "lookup", 350, 480, "width="+originalwidth+",height=480,toolbar=no,status=no,directories=no,menubar=no,resizable=yes,scrollable=no", true);
            } 
          }    
        $(function(){
            $('.editCont').click(function(e){
                e.preventDefault();
                var ctx;
                ctx = $(this).closest('td');
                $('.fpsCls10', ctx).show();$('.comCls10', ctx).show();$('.salCls10', ctx).show();$('.InsCls10', ctx).show();$('.ssreqCls14', ctx).show();$('.InsCls13', ctx).show();$('.iwCls10', ctx).show();$('.iwCls13', ctx).show();$('.prodCls6', ctx).show();$('.prodCls10', ctx).show();$('.trnCls5', ctx).show();
                $('.afpsCls10', ctx).hide();$('.acomCls10', ctx).hide();$('.asalCls10', ctx).hide();$('.aInsCls10', ctx).hide();$('.assreqCls14', ctx).hide();$('.aInsCls13', ctx).hide();$('.aiwCls10', ctx).hide();$('.aiwCls13', ctx).hide();$('.aprodCls6', ctx).hide();$('.aprodCls10', ctx).hide();$('.atrnCls5', ctx).hide();
                $('.editCont', ctx).hide();
            }); 
        });
         $(function(){
            $('.editCont1').click(function(e){
                e.preventDefault();
                var ctx;
                ctx = $(this).closest('td');
                $('.InsCls13', ctx).show();$('.iwCls13', ctx).show();$('.prodCls10', ctx).show();
                $('.aInsCls13', ctx).hide();$('.aiwCls13', ctx).hide();$('.aprodCls10', ctx).hide();
                $('.editCont1', ctx).hide();
            }); 
        });
        function toggling(obj)
        {
                var link = $(obj);
                link.closest('tr').find(".secondSite").slideToggle("fast", function (){
                    if ($(this).is(':visible')) {
                         link.text('-');
                         link.attr('title','Close Second Site Survey');                
                    } else {
                         link.text('+');
                         link.attr('title','Open Second Site Survey');                
                    }
                    var counter = 0;
                var hideCounter = 0;
                var rowCount = $('#sssurtab tr').length;                
                $("tr.dataRow").each(function() {
                    if($(this).find(".secondSite").is(':visible')){
                        counter=counter+1;                        
                    }else{
                        hideCounter = hideCounter+1;
                    }
                });
                if(counter > 0){                    
                    $("tr.headerRow").find(".secondSite1").show("fast");
                }else{
                    $("tr.headerRow").find(".secondSite1").hide("fast");
                }               
                });
                 
            }
        function checkValue(){
            $(function(){                
                $("tr.dataRow").each(function() {
                    var allListElements = $( ".ssreqCls14,.InsCls10,.iwCls10,.prodCls6,.trnCls5,.salCls10,.comCls10,.fpsCls10" );
                    var allListElements1 = $( ".InsCls13,.iwCls13,.prodCls10" );
                    var allLinkElements = $( ".assreqCls14,.aInsCls10,.aiwCls10,.aprodCls6,.atrnCls5,.asalCls10,.acomCls10,.afpsCls10" );
                    var allLinkElements1 = $( ".aInsCls13,.aiwCls13,.aprodCls10" );
                    $('td.zxcv', this).each(function(){
                        var quantity1 = $(this).find(allListElements).val();
                        var quantity1a = $(this).find(allLinkElements).text();
                        if((quantity1 != null && quantity1 != '' && quantity1a != '')){
                          $(this).find(".fpsCls10").hide();$(this).find(".comCls10").hide();$(this).find(".salCls10").hide();$(this).find(".ssreqCls14").hide();$(this).find(".InsCls10").hide();$(this).find(".iwCls10").hide();$(this).find(".prodCls6").hide();$(this).find(".trnCls5").hide();
                          $(this).find(".afpsCls10").show();$(this).find(".acomCls10").show();$(this).find(".asalCls10").show();$(this).find(".assreqCls14").show();$(this).find(".aInsCls10").show();$(this).find(".aiwCls10").show();$(this).find(".aprodCls6").show();$(this).find(".atrnCls5").show();
                          $(this).find(".editCont").show();
                        }else if((quantity1 == '' && quantity1a == '') || (quantity1 != '' && quantity1a == '')){
                          $(this).find(".fpsCls10").show();$(this).find(".comCls10").show();$(this).find(".salCls10").show();$(this).find(".ssreqCls14").show();$(this).find(".InsCls10").show();$(this).find(".iwCls10").show();$(this).find(".prodCls6").show();$(this).find(".trnCls5").show();
                          $(this).find(".afpsCls10").hide();$(this).find(".acomCls10").hide();$(this).find(".asalCls10").hide();$(this).find(".assreqCls14").hide();$(this).find(".aInsCls10").hide();$(this).find(".aiwCls10").hide();$(this).find(".aprodCls6").hide();$(this).find(".atrnCls5").hide();
                          $(this).find(".editCont").hide();
                        }
                        var quantity2 = $(this).find(allListElements1).val();
                        var quantity2a = $(this).find(allLinkElements1).text();
                        if(quantity2 != null && quantity2 != '' && quantity2a != null && quantity2a != ''){
                          $(this).find(".InsCls13").hide();$(this).find(".iwCls13").hide();$(this).find(".prodCls10").hide();
                          $(this).find(".aInsCls13").show();$(this).find(".aiwCls13").show();$(this).find(".aprodCls10").show();
                          $(this).find(".editCont1").show();
                        }else if((quantity2 == '' && quantity2a == '') || (quantity2 != '' && quantity2a == '')){
                          $(this).find(".InsCls13").show();$(this).find(".iwCls13").show();$(this).find(".prodCls10").show();
                          $(this).find(".aInsCls13").hide();$(this).find(".aiwCls13").hide();$(this).find(".aprodCls10").hide();
                          $(this).find(".editCont1").hide();
                        }
                    });
                }); 
            });     
        } 
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
           
        
         $("input").datepicker({
            beforeShow: function(input, obj) {
                $(input).after($(input).datepicker('widget'));
            }
             });
         