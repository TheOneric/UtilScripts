// ==UserScript==
// @name     AoD-Scroll-Mobile
// @version  0.3
// @include  https://anime-on-demand.de/*
// @run-at   document-start
// ==/UserScript==

//console.log("S");
window.addEventListener('beforescriptexecute',
	function(event)
	{
  	if(event.target.src.match(/\/assets\/application\/application-55ddcf7206510729d9d9d4b39a01b25077c66c1c802fbac027aad54441a1c319.js$/)) {
      console.log("Transform script to allow mobile touch scrolling.");
      var pnode = event.target.parentNode;
      pnode.removeChild(event.target);
      event.preventDefault();
      
      fetch(event.target.src)
      	.then(r => r.text(), console.log)
      	.then(src => src.replace(
        	'function t(t){if(i.preventDefaultEvents&&t.preventDefault(),s){var n=t.touches[0].pageX,o=t.touches[0].pageY,l=r-n,u=a-o;Math.abs(l)>=i.min_move_x?(e(),l>0?i.wipeLeft():i.wipeRight()):Math.abs(u)>=i.min_move_y&&(e(),u>0?i.wipeDown():i.wipeUp())}}',
        	`
					//----BEGIN-CHANGES----//
					function t(t){
						//console.log("¡DEBUG-MSG!");
						//if(i.preventDefaultEvents&&t.preventDefault(),s){
							var n=t.touches[0].pageX,o=t.touches[0].pageY,l=r-n,u=a-o;Math.abs(l)>=i.min_move_x?(e(),l>0?i.wipeLeft():i.wipeRight()):Math.abs(u)>=i.min_move_y&&(e(),u>0?i.wipeDown():i.wipeUp())
						//}
					}
					console.log("¡¡|Transformed|!!");
					//-----END-CHANGES-----//
        	`,
        	console.log
      	))
        .then(new_src => {unsafeWindow.eval(new_src)}, console.log);
        /*We (probably) need to use unsafeWindow to expose defined objects and functions
      		(which probably exists, but I wont read 1.3MiB of minified code to find out)
          — But this script is loaded from and by AoD, we just applied a small and sane patch.
            If you did not trust this script, then you would not allow JS-execution on this site in the first place.
        */
    }
	}
);
//unsafeWindow.console.log("T");

