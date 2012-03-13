 function StringBuffer() { 
   this.buffer = []; 
 } 

 StringBuffer.prototype.append = function append(string) { 
   this.buffer.push(string); 
   return this; 
 }; 

 StringBuffer.prototype.toString = function toString() { 
   return this.buffer.join(""); 
 }; 

  var Searcher = {};
  Searcher.SearchPage = function() {
    // --- default values
    this.searchDefaultText = "Search on this page";
    this.startSearchingLength = 3;
    this.textWrapper = "#body";
    this.searchBoxWrapper = "#pageSearcher";
    this.searchBoxId = "pageSearcherTextBox";
    this.activeCssClass = "active";
    
    // --- public methods
    this.getOriginalText = function() {
      return originalText;
    }
    
    this.init = function() {
    var instance = this;
      
      oText=document.getElementById('body').innerHTML;
      $(this.searchBoxWrapper).html('<span style="white-space: nowrap; "><input type="text" id="' + this.searchBoxId + '"/> <a id="searchid" class="btn info" onclick="searchText(document.getElementById(\'pageSearcherTextBox\'));" href="#">Search</a></span>');
      var searchBox = "#" + this.searchBoxId;
      
      $(searchBox).attr("value", this.searchDefaultText)
      .focus(function() {
        if (this.value == instance.searchDefaultText) {
          this.value = "";
          $(this).addClass(instance.activeCssClass);
        }
      }).
      blur(function() {
        if (this.value == "") {
          $(this).removeClass(instance.activeCssClass);
          this.value = instance.searchDefaultText;
        }
  
      });
        }
        

}

 //Get the text between commentStart and CommentEnd and see if there is at least one highlighted text
 //If there is, make sure that the area in sectionId is expanded 
function processADetailBtn(theText, btnId, commentStart, commentEnd, sectionId){
    //var enterTime=new Date().getTime();
    var start_index=theText.indexOf(commentStart);
    var end_index=-1;
    var theSubstr='';
    var high_light_index=-1;
    
    if(-1!=start_index){
        end_index=theText.indexOf(commentEnd);
        if(-1!=end_index){
            theSubstr=theText.substring(start_index, end_index);
            high_light_index=theSubstr.indexOf('<span class=\"highlight\">');
            if(-1!=high_light_index){
                $("#"+sectionId).show();
                $("#"+btnId).html("close");
                $("#"+btnId).attr("class","btn2 small info");
                $("#"+btnId).attr("style","text-decoration:none;");       
                return true;
            }                        
        }
    }    
    //console.log("processADetailBtn: time in function: "+((new Date().getTime())-enterTime));   
    return false;
}

//Get the text between commentStart and commentEnd and see if there is at least one highlighted text
//If there is, then make sure that the are in the selectionId is expanded
function processSelection(theText, commentStart, commentEnd, parentId, selectionId){
    var enterTime=new Date().getTime();
    var retVal=processADetailBtn(theText,commentStart,commentEnd,selectionId);
    if(retVal==true){
        $("#"+parentId).show();
        $("#"+selectionId).show();
    }  
    console.log("processSelection: time in function: "+((new Date().getTime())-enterTime));  
}


function toggleSelection(selectedId){
    var optionId =  $('#'+selectedId+ ' :selected').val();
    showSelected(selectedId,optionId);
}

  
function toggleDetailsBtn(event, btnId, toggleId, focusId){
    $("#"+toggleId).toggle();
    //IE Browser does not support event.preventDefault, so check to make sure the browser supports it first
    if(event.preventDefault){
        event.preventDefault();
    }
    else{
        event.returnValue=false;
    }
    if($("#"+toggleId).is(":visible")){
        $("#"+focusId).focus();
        $("#"+btnId).html("close");
        $("#"+btnId).attr("class","btn2 small info");
        $("#"+btnId).attr("style","text-decoration:none;");
    }
    else{
        $('#'+btnId).focus();
        $("#"+btnId).html("detail");
        $("#"+btnId).attr("class","btn small info");
    }   
}
function highlightTextNodes(element, regex) {
  var tempinnerHTML = element.innerHTML;
  // Do regex replace
  // Inject span with class of 'highlighted termX' for google style highlighting
  element.innerHTML = tempinnerHTML.replace(regex,'>$1<span class="highlight">$2</span>$3<');
}

function searchText(searchText){

    $("#body").html(oText);
    //make sure that all div's are expanded/hidden accordingly
    setSectionsNSelections(); 
    var enterTime=new Date().getTime();
    var theText=searchText.value;
    // Starting node, parent to all nodes you want to search
    var textContainerNode = document.getElementById("body");
    
    // The regex is the secret, it prevents text within tag declarations to be affected
    var regex = new RegExp(">([^<]*)?("+theText+")([^>]*)?<","ig");
    highlightTextNodes(textContainerNode, regex);    
    processDetailsBtn($("#body").html());
    console.log("searchText() done in: " + ((new Date().getTime())-enterTime)+"ms");
}
