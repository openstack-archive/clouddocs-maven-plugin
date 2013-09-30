package com.rackspace.cloud.api.docs;

import com.agilejava.docbkx.maven.AbstractHtmlMojo;
import com.agilejava.docbkx.maven.PreprocessingFilter;
import com.agilejava.docbkx.maven.TransformerBuilder;
import org.apache.maven.plugin.MojoExecutionException;
import java.io.File;
import java.util.HashMap;
import java.util.Map;

import javax.xml.transform.stream.StreamSource;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;

public abstract class HTMLMojo extends AbstractHtmlMojo {

    /**
     * @parameter 
     *     expression="${generate-html.canonicalUrlBase}"
     *     default-value=""
     */
    private String canonicalUrlBase;

    /**
     * 
     * @parameter 
     *     expression="${generate-html.failOnValidationError}"
     *     default-value="0"
     */
    private String failOnValidationError;
    
    /**
     * A parameter used to specify the security level (external, internal, reviewer, writeronly) of the document.
     *
     * @parameter 
     *     expression="${generate-html.security}" 
     *     default-value=""
     */
    private String security;
    protected String getNonDefaultStylesheetLocation() {
      return "cloud/apipage/apipage.xsl";
    }

    @Override
    protected Source createSource(String inputFilename, File sourceFile, PreprocessingFilter filter)
            throws MojoExecutionException {

        String pathToPipelineFile = "classpath:///wadl2html.xpl"; //use "classpath:///path" for this to work
        Source source = super.createSource(inputFilename, sourceFile, filter);

        Map<String, Object> map=new HashMap<String, Object>();
        
        map.put("security", security);
        map.put("canonicalUrlBase", canonicalUrlBase);
        map.put("failOnValidationError", failOnValidationError);
        
        return CalabashHelper.createSource(getLog(), source, pathToPipelineFile, map);
    }

    @Override
    public void adjustTransformer(Transformer transformer, String sourceFilename, File targetFile) {
        GitHelper.addCommitProperties(transformer, new File(sourceFilename), 7, getLog());
        super.adjustTransformer(transformer, sourceFilename, targetFile);
    }
}
