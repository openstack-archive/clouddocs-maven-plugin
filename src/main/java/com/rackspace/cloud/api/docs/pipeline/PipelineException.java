package com.rackspace.cloud.api.docs.pipeline;

public class PipelineException extends RuntimeException {
   public PipelineException(String message) {
      super(message);
   }
   
   public PipelineException(Throwable cause) {
      super(cause);
   }
   
   public PipelineException(String message, Throwable cause) {
      super(message, cause);
   }
   
}
