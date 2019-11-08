		/**
		* Validate form info
		*/
		function validateSurvey(formId){
			
			// Submit flag
			var canSubmit = true;
			
			// clean Notifications
			$('#warning').hide();			
			
			/*
				Due to the difference of names when the user fills the survey, the required ids are given to check  
			*/
			var requiredIds = $('#requiredIds');
			var requiredIdsString = requiredIds.html();
			
			// If the survey have required inputs
			if(requiredIdsString.length > 0){
				
				// Put the ids on a id array
				requiredIdsString = requiredIdsString.substr(1);		
				
				// An array of requried ids
				var requiredIdsArray = requiredIdsString.split('|');
				
				if(requiredIdsArray.size == 0){
					requiredIdsArray.push(requiredIdsString);
				}
				
				// Create a object to associate responses with required ids
				var Answered = {};
				
				for(var i = 0; i < requiredIdsArray.length; i ++) {
					Answered[requiredIdsArray[i]] = false;
				}				
				
				// Get form textareas
				var formTextareas = $('textarea');
								
				// Iterate over form textareas
				formTextareas.each(function(i,e){
					var qid = e.name;
					// If the question are in the required array
					if($.inArray(qid,requiredIdsArray) > -1){
						if(e.value != null && (e.value).length > 0){
							Answered[qid] = true;							
						}
					
					
						// set the classes to items with errors
						if(!Answered[qid]){
							var h2 = document.getElementById(qid+'-label');
						
							if(h2 != null){
								$(h2).addClass('invalid');							
							} else {
								var h2id = e.getAttribute('ParentQuestion')+'-label';
								var h2 = document.getElementById(h2id);
							
								if(h2 != null){
									$(h2).addClass('invalid');
								}
							}
							
						} else {
						// set the classes to items without errors
							
							var h2 = document.getElementById(qid+'-label');
						
							if(h2 != null){
								$(h2).removeClass('invalid');
							
							} else {
								var h2id = e.getAttribute('ParentQuestion')+'-label';
								var h2 = document.getElementById(h2id);
							
								if(h2 != null){
									$(h2).removeClass('invalid');
								}
							}
						}
					}
				});
				
				// Get form inputs
				var formElements = $('input');
				
				// Iterate over form inputs
				formElements.each(function(i,e){
					
					var qid = e.name;
				
					if((e.name).indexOf('-') > -1 && e.type == 'checkbox'){
						qid = (e.name).split('-')[0];	
					}
					
					if(e.getAttribute('rel') != null){
						qid = e.getAttribute('rel');
					}
					
					
					// If the question are in the required array
					if($.inArray(qid,requiredIdsArray) > -1){
						
						// Based on the kind of control check the values
						switch(e.type){
							// checkbox and radio
							case 'checkbox':
							case 'radio':		
								if(e.checked){
									Answered[qid] = true;
								} 
							break;
							// if the input is a textbox..						
							case 'text':
							case 'select':
								if(e.value != null && (e.value).length > 0){
									Answered[qid] = true;							
								}
							break;
						
						}
						
						
						// set the classes to items with errors
						if(!Answered[qid]){
							
							var h2 = document.getElementById(qid+'-label');
						
							if(h2 != null){
								$(h2).addClass('invalid');							
							} else {
								var h2id = e.getAttribute('ParentQuestion')+'-label';
								var h2 = document.getElementById(h2id);
							
								if(h2 != null){
									$(h2).addClass('invalid');
								}
							}
							
						} else {
						// set the classes to items without errors
							
							var h2 = document.getElementById(qid+'-label');
						
							if(h2 != null){
								$(h2).removeClass('invalid');
							
							} else {
								var h2id = e.getAttribute('ParentQuestion')+'-label';
								var h2 = document.getElementById(h2id);
							
								if(h2 != null){
									$(h2).removeClass('invalid');
								}
							}
						}					
					}					
				});
			}
			
			var log = '';
			
			for(property in Answered){
				
				log += 'This id '+property+' are answered ? '+ Answered[property] + ' \n ' ;
		
				if(!Answered[property]){
					canSubmit = false;
				}
			}
			
			if(!canSubmit){
				$('#warning').show();  
			} 

			//canSubmit = false
			return canSubmit;
			
		}
		
				
		function chkNumber(obj){
			reg = /[^0-9.,]/g;
			obj.value =  obj.value.replace(reg,"");
		}

		function datePickerClear(input){
			input.value = '';
		}