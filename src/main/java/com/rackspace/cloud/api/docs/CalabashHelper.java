package com.rackspace.cloud.api.docs;

import com.rackspace.papi.components.translation.xproc.Pipeline;
import com.rackspace.papi.components.translation.xproc.PipelineInput;
import com.rackspace.papi.components.translation.xproc.calabash.CalabashPipelineBuilder;
import org.apache.maven.plugin.MojoExecutionException;
import org.xml.sax.InputSource;

import javax.xml.transform.Source;
import javax.xml.transform.sax.SAXSource;
import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.List;

public class CalabashHelper {
    private static Source run(final String pipelineURI, final InputSource inputSource) throws FileNotFoundException {
        Pipeline pipeline = new CalabashPipelineBuilder(false, true).build(pipelineURI);

        List<PipelineInput> pipelineInputs = new ArrayList<PipelineInput>() {{
            add(PipelineInput.port("source", inputSource));
        }};

        pipeline.run(pipelineInputs);

        List<Source> sources = pipeline.getResultPort("result"); // result of xinclude;

        return sources.get(0);
    }

    public static Source createSource(Source source, String pipelineURI)
            throws MojoExecutionException {

        try {
            if (!(source instanceof SAXSource)) {
                throw new MojoExecutionException("Expecting a SAXSource");
            }
            SAXSource saxSource = (SAXSource) source;

            return run(pipelineURI, saxSource.getInputSource());
        } catch (FileNotFoundException e) {
            throw new MojoExecutionException("Failed to find source.", e);
        }
    }
}
