package com.rackspace.cloud.api.docs.pipeline;

import javax.xml.transform.URIResolver;

public interface PipelineBuilder {

   Pipeline build(String pipelineUri);
   Pipeline build(String pipelineUri, URIResolver... resolvers);
   
}
