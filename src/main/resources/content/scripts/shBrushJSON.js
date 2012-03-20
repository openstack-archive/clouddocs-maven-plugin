SyntaxHighlighter.brushes.Custom = function()
{
    var operators = '{ } [ ] : ,';
    
        
    this.regexList = [
        //has a double quote followed by any sequence of characters followed by a double quote followed by colon 
        { regex: /.*\".*\"\:/g, css: 'keyword'},
        //opposite the above
        { regex: /[^(.*\".*\"\:)]/g, css: 'comments'},

         //has a single quote followed by any sequence of characters followed by a single quote followed by colon 
        { regex: /.*\'.*\'\:/g, css: 'keyword'},
        //opposite the above
        { regex: /[^(.*\'.*\'\:)]/g, css: 'comments'}
        
        //{ regex: /.*[\{|\}|\[|\]].*/g, css: 'plain'}

    ];
};
 
SyntaxHighlighter.brushes.Custom.prototype = new SyntaxHighlighter.Highlighter();
SyntaxHighlighter.brushes.Custom.aliases  = ['json', 'JSON'];
