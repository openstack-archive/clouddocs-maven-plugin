package com.rackspace.cloud.api.docs;

import com.rackspace.papi.components.translation.xproc.Pipeline;
import com.rackspace.papi.components.translation.xproc.PipelineInput;
import com.rackspace.papi.components.translation.xproc.calabash.CalabashPipelineBuilder;
import org.xml.sax.InputSource;

import javax.xml.transform.Source;
import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.List;

public class CalabashHelper {
    public static Source run(final String pipelineURI, final InputSource inputSource) throws FileNotFoundException {
        Pipeline pipeline = new CalabashPipelineBuilder(false, true).build(pipelineURI);

        List<PipelineInput> inputs = new ArrayList<PipelineInput>() {{
            add(PipelineInput.port("source", inputSource));
        }};

        pipeline.run(inputs);

        List<Source> sources = pipeline.getResultPort("result"); // result of xinclude;

        return sources.get(0);
    }
}
