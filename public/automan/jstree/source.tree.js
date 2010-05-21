$(function () { 
	$("#tree_1").tree({
			callback : {
				onsearch : function (n,t) {
					t.container.find('.search').removeClass('search');
					n.addClass('search');
				}
			}
		});
	});
function dolink(link){
	parent.document.getElementById('content').src=link.href
}