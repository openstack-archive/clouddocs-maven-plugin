package com.rackspace.cloud.api.docs;

import com.rackspace.papi.components.translation.xproc.Pipeline;
import com.rackspace.papi.components.translation.xproc.PipelineInput;
import com.rackspace.papi.components.translation.xproc.calabash.CalabashPipelineBuilder;
import org.apache.maven.plugin.MojoExecutionException;
import org.xml.sax.InputSource;

import javax.xml.transform.Source;
import javax.xml.transform.sax.SAXSource;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class CalabashHelper {
    private static Source run(final String pipelineURI, final InputSource inputSource, final Map<String, String>map) throws FileNotFoundException {
        // Transform Windows absolute paths from \ to / directory separators
        for (Map.Entry<String, String> entry : map.entrySet()) {
            if (entry.getValue() != null && entry.getValue().matches("^\\w:\\\\.*$")) {
                entry.setValue(entry.getValue().replace(File.separatorChar, '/'));
            }
        }

        Pipeline pipeline = new CalabashPipelineBuilder(false, true).build(pipelineURI);

//        <c:param-set xmlns:c="http://www.w3.org/ns/xproc-step">
//            <c:param name="username" namespace="" value="user"/>
//            <c:param name="host" namespace="" value="http://example.com/"/>
//            <c:param name="password" namespace="" value="pass"/>
//        </c:param-set>
        
        StringBuffer strBuff = new StringBuffer("<c:param-set xmlns:c=\"http://www.w3.org/ns/xproc-step\">");
        strBuff.append("");
        
        
        if(null!=map){
        	Set<String>keys=map.keySet();
        	if(null!=keys){
        		
        	    for(Iterator<String>iter=keys.iterator();iter.hasNext();){
        	    	String aKey=iter.next();
        	    	if(null!=map.get(aKey)){	    	
        	    	    strBuff.append("<c:param name=\""+aKey+ "\" namespace=\"\" value=\""+map.get(aKey)+"\"/>");
        	    	}
        	    }
        	}
        }
        strBuff.append("</c:param-set>");
        String params=strBuff.toString();
        final InputStream paramsStream = new ByteArrayInputStream(params.getBytes());
        
        //System.out.println("~!~!~!~!~!~!~!~!~!Sending: \n"+params+"\n");
        List<PipelineInput> pipelineInputs = new ArrayList<PipelineInput>() {{
            add(PipelineInput.port("source", inputSource));
            add(PipelineInput.port("parameters", new InputSource(paramsStream)));
        }};
        
        pipeline.run(pipelineInputs);
        List<Source> sources = pipeline.getResultPort("result"); // result of xinclude;

        return sources.get(0);
    }

    public static Source createSource(Source source, String pipelineURI, Map<String, String> map)
            throws MojoExecutionException {

        try {
            if (!(source instanceof SAXSource)) {
                throw new MojoExecutionException("Expecting a SAXSource");
            }
            SAXSource saxSource = (SAXSource) source;

            return run(pipelineURI, saxSource.getInputSource(),map);
        } catch (FileNotFoundException e) {
            throw new MojoExecutionException("Failed to find source.", e);
        }
        
    }

}
