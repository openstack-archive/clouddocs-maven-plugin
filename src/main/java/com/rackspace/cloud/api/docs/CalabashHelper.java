package com.rackspace.cloud.api.docs;

import com.rackspace.cloud.api.docs.pipeline.CalabashPipelineBuilder;
import com.rackspace.cloud.api.docs.pipeline.MavenXProcMessageListener;
import com.rackspace.cloud.api.docs.pipeline.Pipeline;
import com.rackspace.cloud.api.docs.pipeline.PipelineInput;
import com.xmlcalabash.core.XProcMessageListener;
import org.apache.maven.plugin.logging.Log;
import org.apache.maven.plugin.MojoExecutionException;
import org.xml.sax.InputSource;

import javax.xml.transform.Source;
import javax.xml.transform.sax.SAXSource;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.net.URI;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class CalabashHelper {
    private static Source run(final Log log, final String pipelineURI, final InputSource inputSource, final Map<String, Object> map) throws FileNotFoundException {
        XProcMessageListener messageListener = log != null ? new MavenXProcMessageListener(log) : null;
        Pipeline pipeline = new CalabashPipelineBuilder(false, true, messageListener).build(pipelineURI);

//        <c:param-set xmlns:c="http://www.w3.org/ns/xproc-step">
//            <c:param name="username" namespace="" value="user"/>
//            <c:param name="host" namespace="" value="http://example.com/"/>
//            <c:param name="password" namespace="" value="pass"/>
//        </c:param-set>
        
        StringBuffer strBuff = new StringBuffer("<c:param-set xmlns:c=\"http://www.w3.org/ns/xproc-step\">");
        strBuff.append("");
        
        
        if(null!=map){
            for (Map.Entry<String, Object> entry : map.entrySet()) {
                String rawValue;
                if (entry.getValue() instanceof File) {
                    rawValue = ((File)entry.getValue()).toURI().toString();
                } else if (entry.getValue() instanceof URI || entry.getValue() instanceof String) {
                    rawValue = entry.getValue().toString();
                } else if (entry.getValue() instanceof URL) {
                    rawValue = ((URL)entry.getValue()).toExternalForm();
                } else if (entry.getValue() != null) {
                    throw new UnsupportedOperationException(String.format("The map cannot contain values of type %s.", entry.getValue().getClass()));
                } else {
                    // ignore nulls
                    continue;
                }

                strBuff
                    .append("<c:param name=\"")
                    .append(escapeXmlAttribute(entry.getKey()))
                    .append("\" namespace=\"\" value=\"")
                    .append(escapeXmlAttribute(rawValue))
                    .append("\"/>");
            }
        }

        strBuff.append("</c:param-set>");
        String params=strBuff.toString();
        final InputStream paramsStream = new ByteArrayInputStream(params.getBytes());
        
        //System.out.println("~!~!~!~!~!~!~!~!~!Sending: \n"+params+"\n");
        List<PipelineInput<?>> pipelineInputs = new ArrayList<PipelineInput<?>>() {{
            add(PipelineInput.port("source", inputSource));
            add(PipelineInput.port("parameters", new InputSource(paramsStream)));
        }};
        
        pipeline.run(pipelineInputs);
        List<Source> sources = pipeline.getResultPort("result"); // result of xinclude;

        return sources.get(0);
    }

    private static String escapeXmlAttribute(String value) {
        if (value == null) {
            return "";
        }

        return value
            .replace("&", "&amp;")
            .replace("\"", "&quot;")
            .replace("'", "&apos;")
            .replace("%", "&#37;");
    }

    /**
     * Creates a {@link Source} for use in a Calabash pipeline.
     *
     * <p>The {@code map} values may instances of {@link String}, {@link File},
     * {@link URI}, or {@link URL}.</p>
     *
     * <ul>
     * <li>{@link String}: These are passed to the pipeline unchanged.</li>
     * <li>{@link URI}: The results of {@link URI#toString()} is passed to the pipeline.</li>
     * <li>{@link File}: These are treated as URIs by calling {@link File#toURI()}.</li>
     * <li>{@link URL}: The result of {@link URL#toExternalForm()} is passed to the pipeline.</li>
     * <li>{@code null}: This is passed to the pipeline as an empty string.</li>
     * </ul>
     *
     * @param source
     * @param pipelineURI
     * @param map
     * @return
     * @throws MojoExecutionException 
     */
    public static Source createSource(Log log, Source source, String pipelineURI, Map<String, Object> map)
            throws MojoExecutionException {

        try {
            if (!(source instanceof SAXSource)) {
                throw new MojoExecutionException("Expecting a SAXSource");
            }
            SAXSource saxSource = (SAXSource) source;

            return run(log, pipelineURI, saxSource.getInputSource(),map);
        } catch (FileNotFoundException e) {
            throw new MojoExecutionException("Failed to find source.", e);
        }
        
    }

}
