package com.rackspace.cloud.api.docs.calabash.extensions;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.XdmNode;

import org.apache.maven.plugin.logging.Log;
import org.apache.maven.plugin.logging.SystemStreamLog;

import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.io.ReadablePipe;
import com.xmlcalabash.io.WritablePipe;
import com.xmlcalabash.library.DefaultStep;
import com.xmlcalabash.model.RuntimeValue;
import com.xmlcalabash.runtime.XAtomicStep;
import com.xmlcalabash.util.ProcessMatch;
import com.xmlcalabash.util.ProcessMatchingNodes;

public class ReplaceTextXProcStep extends DefaultStep {
    private static final QName _replacements_file 	= new QName("", "replacements.file");
    private static Pattern XPATH_LINE 				= Pattern.compile("^XPATH=(.+)$");
    private static Pattern COMMENT_LINE 			= Pattern.compile("^#(.+)$");
    private static Pattern REPLACEMENT_LINE 		= Pattern.compile("(.+)->(.*)");
    
    private ReadablePipe source = null;
    private WritablePipe result = null;
    private ProcessMatch matcher = null;
    
    private Log log = null;
    
    public Log getLog()
    {
        if ( log == null )
        {
            log = new SystemStreamLog();
        }

        return log;
    }


    public ReplaceTextXProcStep(XProcRuntime runtime, XAtomicStep step) {
        super(runtime,step);
    }

    public void setInput(String port, ReadablePipe pipe) {
        source = pipe;
    }

    public void setOutput(String port, WritablePipe pipe) {
        result = pipe;
    }

    public void reset() {
        source.resetReader();
        result.resetWriter();
    }

    public void run() throws SaxonApiException {
        super.run();

        List<XPathReplacement> replacements = readReplacementsFile(getOption(_replacements_file, "replacements.config"));
        XdmNode updatedDoc = makeReplacements (source.read(), replacements);
        
        result.write(updatedDoc);
    }

	private List<XPathReplacement> readReplacementsFile(String fileName) {
    	List<XPathReplacement> xpathReplacements = new ArrayList<XPathReplacement>();
    	XPathReplacement currentXPath = new XPathReplacement("//text()");
    	
        File replacementsFile = new File(fileName);
        long fileLength = replacementsFile.length();
        if(fileLength>0){
        	BufferedReader br = null;
        	try {
		    if (getLog().isDebugEnabled()) {
        		getLog().info("REPLACEMENTS FILE = " + replacementsFile.getAbsolutePath());
		    }
        		br = new BufferedReader(new FileReader(replacementsFile));
        		
        		String line;
        		while((line = br.readLine()) != null) {
        			Matcher xpathLine = XPATH_LINE.matcher(line);
        			Matcher commentLine = COMMENT_LINE.matcher(line);
        			Matcher replacementLine = REPLACEMENT_LINE.matcher(line);
        			if (xpathLine.matches()) {
        				currentXPath = new XPathReplacement(xpathLine.group(1).trim());
        				xpathReplacements.add(currentXPath);
        			} else if (commentLine.matches()) {
        				/*ignore comment line. 
        				 * Although this could have been handled in the default else below. 
        				 * Had to create an explicit case here so that any reference to the token separator "->" 
        				 * in comments does not cause any issues.
        				 */
        			} else if (replacementLine.matches()) {
        				currentXPath.add(replacementLine.group(1).trim(), replacementLine.group(2).trim());
        			} else {
        				//ignore input line
        			}
        		}
        		if (xpathReplacements.size()==0 && getLog().isDebugEnabled()) {
                	getLog().info("SKIPPING REPLACEMENTS: Replacements file is empty or was not found at specified location '"+fileName+ "'.");
                }
        	} catch (IOException e) {
        		getLog().error("Unable to process replacements config file", e);
        	} finally {
        		try {
        			br.close();
        		} catch (IOException e) {
        			getLog().error("Unable to release/close replacements config file", e);
        		}
        	}
        } else if(getLog().isDebugEnabled()) {
        	getLog().info("SKIPPING REPLACEMENTS: Replacements file is empty or was not found at specified location '"+fileName+ "'.");
        }
        
        return xpathReplacements;
    }
    
    private XdmNode makeReplacements(XdmNode doc, List<XPathReplacement> replacements) {
        for (XPathReplacement xpathRepl : replacements) {
        	matcher = new ProcessMatch(runtime, xpathRepl);
        	xpathRepl.setMatcher(matcher);
        	
            matcher.match(doc, new RuntimeValue(xpathRepl.getXPath()));
            doc = matcher.getResult();
        }
        
        return doc;
	}
}

class XPathReplacement implements Iterable<Replacement>, ProcessMatchingNodes  {
	String xpath;
	List<Replacement> replacements;
	ProcessMatch matcher;
	
	public XPathReplacement(String _xpath) {
		this.xpath = _xpath;
		replacements = new ArrayList<Replacement>();
	}
	
	public String getXPath() {
		return xpath;
	}
	
	public void setMatcher (ProcessMatch matcher) {
		this.matcher = matcher;
	}
	
	public void add(String oldVal, String newVal) {
		replacements.add(new Replacement(oldVal, newVal));
	}
	
	private String computeReplacement(XdmNode node) {
		String newValue = node.getStringValue();
		for (Replacement repl : this.replacements) {
			if(repl.oldValue.startsWith("\"") && repl.oldValue.endsWith("\"")) {
				newValue = (newValue.replace(repl.oldValue.substring(1,repl.oldValue.length()-1), repl.newValue));
			} else { 
				newValue = (newValue.replaceAll(repl.oldValue, repl.newValue));
			}
			
		}
		return newValue;
	}

	@Override
	public Iterator<Replacement> iterator() {
		return replacements.iterator();
	}
    
	@Override
	public boolean processStartDocument(XdmNode node) throws SaxonApiException {
		return true;//process children
	}

	@Override
	public void processEndDocument(XdmNode node) throws SaxonApiException {
		//do nothing
	}

	@Override
	public boolean processStartElement(XdmNode node) throws SaxonApiException {
		return true;//process children
	}

	@Override
	public void processAttribute(XdmNode node) throws SaxonApiException {
		String newValue = computeReplacement(node);
		matcher.addAttribute(node, newValue);
	}

	@Override
	public void processEndElement(XdmNode node) throws SaxonApiException { }

	@Override
	public void processText(XdmNode node) throws SaxonApiException {
		String newValue = computeReplacement(node);
		matcher.addText(newValue);
	}

	@Override
	public void processComment(XdmNode node) throws SaxonApiException {
		String newValue = computeReplacement(node);
		matcher.addText(newValue);
	}

	@Override
	public void processPI(XdmNode node) throws SaxonApiException {
		String newValue = computeReplacement(node);
		matcher.addText(newValue);
	}
}

class Replacement {
	public String oldValue;
	public String newValue;
	
	public Replacement(String _oldVal, String _newVal) {
		this.oldValue = _oldVal;
		this.newValue = _newVal;
	}
	
	@Override
	public int hashCode() {
        int result = oldValue.hashCode();
        return result;
    }
	
	@Override
	public boolean equals(Object o) {
		if (this == o) return true;
		if(!(o instanceof Replacement)) return false;
		
		Replacement repl = (Replacement) o;
		if(this.oldValue.equals(repl.oldValue)) return true;
		
		return false;
	}
}
