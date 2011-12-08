package com.rackspace.cloud.api.docs;

import com.rackspace.papi.components.translation.xproc.Pipeline;
import com.rackspace.papi.components.translation.xproc.PipelineInput;
import com.rackspace.papi.components.translation.xproc.calabash.CalabashPipelineBuilder;
import org.xml.sax.InputSource;

import javax.xml.transform.Source;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

public class CalabashHelper {
    public static void run(final String pipelineUri, final InputStream inputStream) throws FileNotFoundException {
        Pipeline pipe = new CalabashPipelineBuilder(false).build(pipelineUri);

        List<PipelineInput> inputs = new ArrayList<PipelineInput>() {{
            add(PipelineInput.port("source", new InputSource(inputStream)));
        }};

        pipe.run(inputs);

        List<Source> nodes = pipe.getResultPort("result"); // result of xinclude;
    }
}
