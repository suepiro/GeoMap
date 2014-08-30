var map;
function initialize() {
	var latlng = new google.maps.LatLng(39.09213051830277, 138.64715929687495);
    var myOptions = {
	zoom: 5,
	center: latlng,
	mapTypeId: google.maps.MapTypeId.ROADMAP
	};
    varmap = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
}
