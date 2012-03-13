                  jQuery.extend(
                  jQuery.expr[':'], { Contains : "jQuery(a).text().toUpperCase().indexOf(m[3].toUpperCase())>=0" 
                  });

                  $(document).ready(function() {
                  var pageSearcher = new Searcher.SearchPage();
                  pageSearcher.startSearchingLength = 3; 
                  pageSearcher.init();
                  setSectionsNSelections();     
                  
                 $("#pageSearcherTextBox").bind("keydown", function(event){
                          // track enter key
                          var keycode = (event.keyCode ? event.keyCode : (event.which ? event.which : event.charCode)); 
                          var inputVal=document.getElementById("pageSearcherTextBox").value; 
                          
                          //Either there is no input or there are at least 3 characters
                          if(!inputVal || inputVal.length>=3){
                              //keycode for Enter Key
                              if(keycode==13){
                                  document.getElementById('searchid').click();
                                  return false;
                              }
                              else{
                                  return true;
                              }
                          }                   
                      });

                  });