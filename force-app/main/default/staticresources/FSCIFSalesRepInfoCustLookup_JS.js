 var sbutton = document.getElementById("{!$Component.searchBtn}"); 
                function handleKeyPress(e){
                    var key= 0;
                    if(window.event){
                        key= e.keyCode;
                    }else if(e.which){
                        key= e.which;}
                    if(key==13){
                        sbutton.click();
                        e.preventDefault();
                    }
                }