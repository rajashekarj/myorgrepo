/**
 * @author bdiaz
 */

handleTables= function(){
	headers = dojo.query('.timbasurvey_list tr.header');
	dojo.forEach(headers,function(o,i,a){
		dojo.query('th:first-child',o).addClass('first');
		dojo.query('th:last-child',o).addClass('last');
	});
	/* Add Visual Functionality*/
	dojo.query('.timbasurvey_list tbody tr').onmouseover(function(e){
		if (!dojo.hasClass(this,'selected')) {
			dojo.addClass(this, 'hover');
		}
	});
	dojo.query('.timbasurvey_list tbody tr').onmouseout(function(e){
		if (!dojo.hasClass(this,'selected')) {
			dojo.removeClass(this, 'hover');
		}
	});
	dojo.query('.timbasurvey_list tbody tr').onclick(function(e){
		dojo.toggleClass(this,'selected');
		dojo.removeClass(this, 'hover');
	});
	dojo.query('.listnavigator .selectContainer').onclick(function(e){
		dojo.toggleClass(dojo.query('.selectList',this)[0],'displayBlock');
	});
	dojo.query('tr td .actionPanel a').onmouseover(function(e){
		dojo.addClass(this,'hover');
	});
	dojo.query('tr td .actionPanel a').onmouseout(function(e){
		dojo.removeClass(this,'hover');
	});
}
dojo.addOnLoad(handleTables);
