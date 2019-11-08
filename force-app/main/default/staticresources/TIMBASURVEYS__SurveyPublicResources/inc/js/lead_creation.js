/**
 * Lead Creation Scripts
 * Bruno Fagundez @ TimbaSoftware 2009
 */   

function createLead(){
			if(validateLeadData()){
				var postUrl = DATA_COLLECTOR_URL+"?newLead=true&";
				$.post(postUrl, $("form#leadDataForm").serialize());
				$.fn.fancybox.close();
				return false;	
			}
		}
		
		function imposeMaxLength(Object, MaxLen)
		{
		 	if (Object.value.length > MaxLen) {
				Object.value = Object.value.substring(0, MaxLen);
			} 
		}
		
		function preloadImg(image) {
			var img = new Image();
			img.src = image;
		}
		
		function validateLeadData(){ 
			
			var noErrorFound = true;
			$('#errorLeadForm').hide();
			
			$('#leadDataForm input').each(function(i,e){
				
				$(e).parent().removeClass('leadErrorField')
				if(e.value != null && (e.value).length > 0){
					
					// Check email format
					if(e.name == 'email'){
						var filter = /^(("[\w-\s]+")|([\w-]+(?:\.[\w-]+)*)|("[\w-\s]+")([\w-]+(?:\.[\w-]+)*))(@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$)|(@\[?((25[0-5]\.|2[0-4][0-9]\.|1[0-9]{2}\.|[0-9]{1,2}\.))((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[0-9]{1,2})\.){2}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[0-9]{1,2})\]?$)/i ;
						
						if(!filter.test(e.value)){
							noErrorFound = false;
							$(e).parent().addClass('leadErrorField')
						}
					}	
					
					
										
				} else {
					$(e).parent().addClass('leadErrorField')
					noErrorFound = false;
					$('#errorLeadForm').show();
				}
				
			});
			
			return noErrorFound;
		}