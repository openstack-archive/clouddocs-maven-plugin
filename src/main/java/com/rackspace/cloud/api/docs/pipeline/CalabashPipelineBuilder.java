package com.rackspace.cloud.api.docs.pipeline;

import com.rackspace.cloud.api.docs.pipeline.resolvers.ClassPathUriResolver;
import com.rackspace.cloud.api.docs.pipeline.resolvers.InputStreamUriParameterResolver;
import com.xmlcalabash.core.XProcConfiguration;
import com.xmlcalabash.core.XProcMessageListener;
import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.runtime.XPipeline;
import com.xmlcalabash.util.Input;
import com.xmlcalabash.util.XProcURIResolver;
import net.sf.saxon.s9api.SaxonApiException;

import javax.xml.transform.URIResolver;

public class CalabashPipelineBuilder implements PipelineBuilder {
   private final boolean schemaAware;
   private final boolean legacySourceOutput;
   private XProcMessageListener messageListener;
   
   public CalabashPipelineBuilder() {
      this(true, false);
   }
   
   public CalabashPipelineBuilder(boolean schemaAware) {
      this(schemaAware, false);
   }

   public CalabashPipelineBuilder(boolean schemaAware, boolean legacySourceOutput) {
      this.schemaAware = schemaAware;
      this.legacySourceOutput = legacySourceOutput;
   }
   
   public CalabashPipelineBuilder(boolean schemaAware, boolean legacySourceOutput, XProcMessageListener messageListener) {
      this.schemaAware = schemaAware;
      this.legacySourceOutput = legacySourceOutput;
      this.messageListener = messageListener;
   }

   @Override
   public Pipeline build(String pipelineUri) {
      try {
         XProcConfiguration config = new XProcConfiguration(schemaAware);
         XProcRuntime runtime = new XProcRuntime(config);
         if (messageListener != null) {
             runtime.setMessageListener(messageListener);
         }

         InputStreamUriParameterResolver resolver = new InputStreamUriParameterResolver(new XProcURIResolver(runtime));
         resolver.addResolver(new ClassPathUriResolver());
         runtime.setURIResolver(resolver);
         XPipeline pipeline = runtime.load(new Input(pipelineUri));
         return new CalabashPipeline(pipeline, runtime, resolver, legacySourceOutput);
      } catch (SaxonApiException ex) {
         // TODO: Should we log the exception here?
         throw new PipelineException(ex);
      }
   }
   
   @Override
   public Pipeline build(String pipelineUri, URIResolver... resolvers) {
      try {
         XProcConfiguration config = new XProcConfiguration(schemaAware);
         XProcRuntime runtime = new XProcRuntime(config);
         InputStreamUriParameterResolver streamResolver = new InputStreamUriParameterResolver(new XProcURIResolver(runtime));
         streamResolver.addResolver(new ClassPathUriResolver());
         for (URIResolver resolver: resolvers) {
            streamResolver.addResolver(resolver);
         }
         runtime.setURIResolver(streamResolver);
         XPipeline pipeline = runtime.load(new Input(pipelineUri));
         return new CalabashPipeline(pipeline, runtime, streamResolver);
      } catch (SaxonApiException ex) {
         // TODO: Should we log the exception here?
         throw new PipelineException(ex);
      }
   }
}
