
  var Searcher = {};
  Searcher.SearchPage = function() {
    // --- default values
    this.searchDefaultText = "Search on this page";
    this.startSearchingLength = 3;
    this.textWrapper = "#body";
    this.searchBoxWrapper = "#pageSearcher";
    this.searchBoxId = "pageSearcherTextBox";
    this.activeCssClass = "active";
    this.highlightCssClass = "highlight";
    
    // --- prive variables
    var originalText = "";
    
    // --- public methods
    this.getOriginalText = function() {
      return originalText;
    }
    
    this.init = function() {
      var instance = this;
      
      $(this.searchBoxWrapper).html('<input type="text" id="' + this.searchBoxId + '"/>');
      originalText = $(this.textWrapper).html();
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
      }).
      keyup(function() {
        $(instance.textWrapper).html(instance.getOriginalText());
        //make sure that all div's are expanded/hidden accordingly
        setSectionsNSelections();
        if (this.value.length >= instance.startSearchingLength) {
          
          var searchText = escape(this.value);
          //Spaces are encoded, remove all space encoding and replace replace with a space character
          searchText = searchText.replace(/%20/g,' ');
          var regx = new RegExp("(" + searchText + ")", 'gi');
                 
          $(instance.textWrapper).each(function() {
            //Get the entire content between the <div id="body"> tag
            var text = $(this).html();
            //We should only deal with text not between tags
            var index=0;
            var currentIndex=index;
            var end=text.length;
            var stop=false;
            while(!stop && currentIndex!=-1 && currentIndex<text.length){
              index=text.indexOf("<",currentIndex);
              
              //There are no more < parens in the text
              if(index==-1){
                  stop=true;
              }
              //There is s a left paren
              else{
                  var closingTagCharIndex=text.indexOf(">",index);
                  var dontSearchText=text.substring(index,(closingTagCharIndex+1));
                  currentIndex=closingTagCharIndex;
                  //We are now at the closing greater than char
                  if(-1!=closingTagCharIndex){
                    
                      var prevIndex=index;
                      //find the next left less than char
                      index=text.indexOf("<",closingTagCharIndex);
                      
                      var substrToSearch = "";
                      //find where the next html tag begins
                      if(-1!=index){
                          currentIndex=closingTagCharIndex;
                          //index now points to the beginning of the next html tag
                          //closingTagCharIndex now points to the end of the previous html tag
                          substrToSearch=text.substring((closingTagCharIndex+1),index);
                          //Now highlight the substring properly with matched searches
                          substrToSearch = substrToSearch.replace(regx, '<span class="' + instance.highlightCssClass + '">$1</span>');
                          
                          //Now we have to get everything the flanks text area which we just highlighted 
                          var firstPart=text.substring(0,prevIndex);                     
                          var lastPart=text.substring(index);
                          
                          //Now sticth everything together
                          text=firstPart+dontSearchText+substrToSearch+lastPart;   
                          
                          currentIndex=(index-1);                  
                      }
                      //There are no more opening html tags
                      else{
                          var firstPart=text.substring(0,prevIndex); 
                          substrToSearch=text.substring(prevIndex);
                          substrToSearch = substrToSearch.replace(regx, '<span class="' + instance.highlightCssClass + '">$1</span>');
                          text=firstPart+substrToSearch;
                          stop=true;
                      }
                  } 
              }
            }
            $(this).html(text);
            processDetailsBtn(text);
          });
        
        }
        
      })
    }
  }
  
 //Get the text between commentStart and CommentEnd and see if there is at least one highlighted text
 //If there is, make sure that the area in sectionId is expanded 
function processADetailBtn(theText, commentStart, commentEnd, sectionId){
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
                return true;
            }                        
        }
    }    
    return false;
}

//Get the text between commentStart and commentEnd and see if there is at least one highlighted text
//If there is, then make sure that the are in the selectionId is expanded
function processSelection(theText, commentStart, commentEnd, parentId, selectionId){
    var retVal=processADetailBtn(theText,commentStart,commentEnd,selectionId);
    if(retVal==true){
        $("#"+parentId).show();
        $("#"+selectionId).show();
    }  
}


function toggleSelection(selectedId){
    var optionId =  $('#'+selectedId+ ' :selected').val();
    showSelected(selectedId,optionId);
}

  
function toggleDetailsBtn(event, btnId, toggleId, focusId){
    $("#"+toggleId).toggle();
    event.preventDefault();
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