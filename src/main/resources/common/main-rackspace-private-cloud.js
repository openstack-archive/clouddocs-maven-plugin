/**
 * Miscellaneous js functions for WebHelp
 */

$(document).ready(function() {  
    $('#rax-contentsid').click(function(){
    	showTocArea();
    });

    $('#rax-searchid').click(function(){
    	showSearchArea();
    	checkSearchCookie();
    });

	// When you click on a link to an anchor, scroll down
	// 105 px to cope with the fact that the banner
	// hides the top 95px or so of the page.
	// This code deals with the problem when
	// you click on a link within a page.
	$('a[href*=#]').click(function() {
		if (location.pathname.replace(/^\//,'') == this.pathname.replace(/^\//,'')
		    && location.hostname == this.hostname) {
		    var $target = $(this.hash);
		    $target = $target.length && $target
			|| $('[name=' + this.hash.slice(1) +']');
		if (!(this.hash == "#searchDiv" || this.hash == "#treeDiv" || this.hash == "") && $target.length) {
			var targetOffset = $target.offset().top - 140;
			$('html,body')
			    .animate({scrollTop: targetOffset}, 200);
			return false;
		    }
		}
	    });

    //Generate the tree
     $("#ulTreeDiv").attr("style","");
    $("#tree").treeview({
        collapsed: true,
        animated: "medium",
        control: "#sidetreecontrol",
        persist: "cookie"
    });

    //after toc fully styled, display it. Until loading, a 'loading' image will be displayed
    $("#tocLoading").attr("style","display:none;");

    var sidebarState = readCookie("webhelp-sidebar");
    if(sidebarState == "showing" || sidebarState == "hidden") {
	showHideToc(sidebarState);
    }else{
	showHideToc("showing");
    }

    //Check to see if we should display the search tab or the content tab
    checkSearchCookie();

    syncToc(); //Synchronize the toc tree with the content pane, when loading the page.   


    $('.gloss').each(function() { 
        $(this).qtip({
            content: {
		attr: 'def'
            },
            position: {
                target: 'mouse', 
                adjust: { x: 5, y: 5 } 
            }
        });
    });

    //.searchButton is the css class applied to 'Go' button
    $(function() {
		$("button", ".searchButton").button();

		$("button", ".searchButton").click(function() { return false; });
	});

    //'ui-tabs-1' is the cookie name which is used for the persistence of the tabs.(Content/Search tab)
    if ($.cookie('ui-tabs-1') === '1') {    //search tab is visible
        if ($.cookie('textToSearch') != undefined && $.cookie('textToSearch').length > 0) {
            document.getElementById('textToSearch').value = $.cookie('textToSearch');
            Effectuer_recherche($.cookie('textToSearch'));
            searchHighlight($.cookie('textToSearch'));
            $("#showHideHighlight").css("display","block");
        }
    }

    // When you click on a link to an anchor, scroll down
    // 140 px to cope with the fact that the banner
    // hides the top 95px or so of the page.
    // This code deals with the problem when
    // you click on a link from another page.
    var hash = window.location.hash;
    if(hash){
    	var offsetFuncExists=!!$(hash).offset();
    	if(undefined!=offsetFuncExists && offsetFuncExists){
	        var targetOffset = $(hash).offset().top - 140;
	        $('html,body').animate({scrollTop: targetOffset}, 200);
	        return false;
    	}
    }

    $('#searchCheckBox:checkbox').change(function(){
    	var isChecked=$('#searchCheckBox:checkbox').is(':checked');
    	toggleHighlight(isChecked);
    });

    //We only want the first treeview-black to be visible by default
    if($('.treeview-black').length>1){
    	$('.treeview-black').hide();
    	$($('.treeview-black')[0]).show();
    }

});

function highLightText(){
	//We only want to do something if there is something in the input field
	var textToSearch=$('#textToSearch').val();

	searchHighlight(textToSearch);

}

function containsDisqusInclude(){
   var retVal=false;
   if($('#disqus_thread').length){
           retVal=true;
   }
   return retVal;
}

//This function tries to make sure the left hand navigation/search pane, has the same height as the content pane
function checkLeftHandNavigationHeightWithContentHeight(){
	//First remove all style from the id="rax-leftnavigation'
	var rhsHeight=$('#content').height();
	var lhsHeight=$('#rax-leftnavigation').height();

    if(containsDisqusInclude() && rhsHeight>lhsHeight){
        //rhsHeight+=290;
    }
	if(rhsHeight!=lhsHeight){
	    $('#rax-leftnavigation').removeAttr('style');
	    var newLhsHeight='height:'+rhsHeight+"px;";
	    $('#rax-leftnavigation').attr('style',newLhsHeight)
	}
}

//Checks to see if the textToSearch cookie exists, if so populate the searc with the textToSearch results
function checkSearchCookie(){
    //Check to see if we should display the search tab or the content tab
    var tab=readCookie('rax-tab-clicked');
    //By default we show the content tab
    if(tab==='content'||tab===null||tab===undefined){
        showTocArea();
    }
    else{
        showSearchArea();
        var searchText=$.cookie('textToSearch');
        if(null!==searchText && undefined!==searchText){
            $('#textToSearch').val(searchText);
            Effectuer_recherche(searchText);
            searchHighlight(searchText);
            $("#showHideHighlight").css("display","block");
        }
    }
}

/**
 * Synchronize with the tableOfContents 
 */
function syncToc(){
    var a = document.getElementById("webhelp-currentid");
    if (a != undefined) {
        var b = a.getElementsByTagName("a")[0];

        if (b != undefined) {
            //Setting the background for selected node.
            var style = a.getAttribute("style", 2);
            if (style != null && !style.match(/background-color: Background;/)) {
                a.setAttribute("style", "background-color: #D8D8D8;  " + style);
                b.setAttribute("style", "color: black;");
            } else if (style != null) {
                a.setAttribute("style", "background-color: #D8D8D8;  " + style);
                b.setAttribute("style", "color: black;");
            } else {
                a.setAttribute("style", "background-color: #D8D8D8;  ");
                b.setAttribute("style", "color: black;");
            }
        }

        //shows the node related to current content.
        //goes a recursive call from current node to ancestor nodes, displaying all of them.
        while (a.parentNode && a.parentNode.nodeName) {
            var parentNode = a.parentNode;
            var nodeName = parentNode.nodeName;

            if (nodeName.toLowerCase() == "ul") {
                parentNode.setAttribute("style", "display: block;");
            } else if (nodeName.toLocaleLowerCase() == "li") {
                parentNode.setAttribute("class", "collapsable");
                parentNode.firstChild.setAttribute("class", "hitarea collapsable-hitarea ");
            }
            a = parentNode;
        }
    }
}

/**
 * Code for Show/Hide TOC
 *
 */
function showHideToc(state) {
    var showHideButton = $("#showHideButton");
    var leftNavigation = $("#rax-leftnavigation");
    var content = $("#content");


    if (state != "showing" && showHideButton != undefined && showHideButton.hasClass("pointLeft")) {
        //Hide TOC
        showHideButton.removeClass('pointLeft').addClass('pointRight');
        content.css("margin", "0 0 0 0");
        leftNavigation.css("display","none");
        showHideButton.attr("title", "Show the TOC tree");
	content.css("padding-left","0px");
	$("body").addClass("sidebar");
	eraseCookie("webhelp-sidebar");
	createCookie("webhelp-sidebar","hidden",365);
    } else {
        //Show the TOC
        showHideButton.removeClass('pointRight').addClass('pointLeft');
        content.css("margin", "0 0 0 250px");
	content.css("padding-left","40px");
        leftNavigation.css("display","block");
        showHideButton.attr("title", "Hide the TOC Tree");
	$("body").removeClass("sidebar");
	eraseCookie("webhelp-sidebar");
	createCookie("webhelp-sidebar","showing",365);
    }
}


function createCookie(name,value,days) {
	if (days) {
		var date = new Date();
		date.setTime(date.getTime()+(days*24*60*60*1000));
		var expires = "; expires="+date.toGMTString();
	}
	else var expires = "";
	document.cookie = name+"="+value+expires+"; path=/";
}

function readCookie(name) {
	var nameEQ = name + "=";
	var ca = document.cookie.split(';');
	for(var i=0;i < ca.length;i++) {
		var c = ca[i];
		while (c.charAt(0)==' ') c = c.substring(1,c.length);
		if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
	}
	return null;
}

function eraseCookie(name) {
	createCookie(name,"",-1);
}

/**
 * Code for search highlighting
 */
var highlightOn = true;
function searchHighlight(searchText) {
    highlightOn = true;
    if (searchText != undefined) {
        var wList;
        var sList = new Array();    //stem list
        //Highlight the search terms
        searchText = searchText.toLowerCase().replace(/<\//g, "_st_").replace(/\$_/g, "_di_").replace(/\.|%2C|%3B|%21|%3A|@|\/|\*/g, " ").replace(/(%20)+/g, " ").replace(/_st_/g, "</").replace(/_di_/g, "%24_")
        searchText = searchText.replace(/  +/g, " ");
        searchText = searchText.replace(/ $/, "").replace(/^ /, "");

        wList = searchText.split(" ");

        //Do stemmed highlighting
        if(typeof stemmer != "undefined" ){
            //Highlight the stems
            for (var i = 0; i < wList.length; i++) {
                var stemW = stemmer(wList[i]);
                sList.push(stemW);
            }
        } else {
            sList = wList;
        }
        highlightAll(sList); //Highlight the search input's all stems     
    } 
}

function highlightAll(wList){
    for(i=0;i<wList.length;++i){
        var theSearch=wList[i];
        $("#content").highlight(theSearch);//Highlight the search input
    }
}

function searchUnhighlight(){
    highlightOn = false;
     //unhighlight the search input's all stems
    $("#content").removeHighlight();
}

function toggleHighlight(isChecked){
    if(!isChecked) {
        searchUnhighlight();
    } else {
        searchHighlight($.cookie('textToSearch'));
    }
}

function showTocArea(){
    var searchArea=$($('#rax-searchDiv'));
    searchArea.hide();

    var searchId=$($('#searchid'));

    var contentsAnchor=$('#rax-contentsid');
    contentsAnchor.removeAttr('class');
    contentsAnchor.attr('class','selectedUnderline');
    contentsAnchor.removeAttr('style');
    contentsAnchor.attr('style','color:black;');

    var searchAnchor=$('#rax-searchid');
    searchAnchor.removeAttr('class');
    searchAnchor.removeAttr('style');
    searchAnchor.attr('style','color:#AAAAAA;')

    $('#rax-treeDiv').show();
    eraseCookie("rax-tab-clicked");
    createCookie("rax-tab-clicked","content",2);
    syncToc();
}

function showSearchArea(){
    var searchArea=$('#rax-searchDiv');
    searchArea.show();

    var searchId=$('#rax-searchid');
    searchId.removeAttr('style');
    searchId.attr('style','color:black;');

    var contents=$('#rax-contentsid');
    contents.removeAttr('style');
    contents.attr('style','color:#AAAAAA;')

    $('#rax-treeDiv').hide();

    var contentsAnchor=$('#rax-contentsid');
    contentsAnchor.removeAttr('class');

    var searchAnchor=$('#rax-searchid');
    searchAnchor.removeAttr('class');
    searchAnchor.attr('class','selectedUnderline');

    eraseCookie("rax-tab-clicked");
    createCookie("rax-tab-clicked","search",2);
}

/*

highlight v4

Highlights arbitrary terms.

<http://johannburkard.de/blog/programming/javascript/highlight-javascript-text-higlighting-jquery-plugin.html>

MIT license.

Johann Burkard
<http://johannburkard.de>
<mailto:jb@eaio.com>

*/

jQuery.fn.highlight = function(pat) {
 function innerHighlight(node, pat) {
  var skip = 0;
  if (node.nodeType == 3) {
   var pos = node.data.toUpperCase().indexOf(pat);
   if (pos >= 0) {
    var spannode = document.createElement('span');
    spannode.className = 'highlight';
    var middlebit = node.splitText(pos);
    var endbit = middlebit.splitText(pat.length);
    var middleclone = middlebit.cloneNode(true);
    spannode.appendChild(middleclone);
    middlebit.parentNode.replaceChild(spannode, middlebit);
    skip = 1;
   }
  }
  else if (node.nodeType == 1 && node.childNodes && !/(script|style)/i.test(node.tagName)) {
   for (var i = 0; i < node.childNodes.length; ++i) {
    i += innerHighlight(node.childNodes[i], pat);
   }
  }
  return skip;
 }
 return this.length && pat && pat.length ? this.each(function() {
  innerHighlight(this, pat.toUpperCase());
 }) : this;
};

jQuery.fn.removeHighlight = function() {
 return this.find("span.highlight").each(function() {
  this.parentNode.firstChild.nodeName;
  with (this.parentNode) {
   replaceChild(this.firstChild, this);
   normalize();
  }
 }).end();
};


/*
CSS Browser Selector v0.4.0 (Nov 02, 2010)
Rafael Lima (http://rafael.adm.br)
http://rafael.adm.br/css_browser_selector
License: http://creativecommons.org/licenses/by/2.5/
Contributors: http://rafael.adm.br/css_browser_selector#contributors
*/
// function css_browser_selector(u){var ua=u.toLowerCase(),is=function(t){return ua.indexOf(t)>-1},g='gecko',w='webkit',s='safari',o='opera',m='mobile',h=document.documentElement,b=[(!(/opera|webtv/i.test(ua))&&/msie\s(\d)/.test(ua))?('ie ie'+RegExp.$1):is('firefox/2')?g+' ff2':is('firefox/3.5')?g+' ff3 ff3_5':is('firefox/3.6')?g+' ff3 ff3_6':is('firefox/3')?g+' ff3':is('gecko/')?g:is('opera')?o+(/version\/(\d+)/.test(ua)?' '+o+RegExp.$1:(/opera(\s|\/)(\d+)/.test(ua)?' '+o+RegExp.$2:'')):is('konqueror')?'konqueror':is('blackberry')?m+' blackberry':is('android')?m+' android':is('chrome')?w+' chrome':is('iron')?w+' iron':is('applewebkit/')?w+' '+s+(/version\/(\d+)/.test(ua)?' '+s+RegExp.$1:''):is('mozilla/')?g:'',is('j2me')?m+' j2me':is('iphone')?m+' iphone':is('ipod')?m+' ipod':is('ipad')?m+' ipad':is('mac')?'mac':is('darwin')?'mac':is('webtv')?'webtv':is('win')?'win'+(is('windows nt 6.0')?' vista':''):is('freebsd')?'freebsd':(is('x11')||is('linux'))?'linux':'','js']; c = b.join(' '); h.className += ' '+c; return c;}; css_browser_selector(navigator.userAgent);
/* End CSS Browser Selector code */
