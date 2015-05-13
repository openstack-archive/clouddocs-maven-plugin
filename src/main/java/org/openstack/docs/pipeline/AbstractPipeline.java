package org.openstack.docs.pipeline;

import org.openstack.docs.pipeline.resolvers.InputStreamUriParameterResolver;
import java.io.IOException;
import java.io.InputStream;
import java.util.Arrays;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public abstract class AbstractPipeline implements Pipeline {
   private static final Logger LOG = Logger.getLogger(AbstractPipeline.class.getName());
   private final InputStreamUriParameterResolver resolver;
   
   public AbstractPipeline(InputStreamUriParameterResolver resolver) {
      this.resolver = resolver;
   }
   
   protected abstract <T> void addParameter(PipelineInput<T> input);
   
   protected abstract <T>void addPort(PipelineInput<T> input);
   
   protected abstract <T>void addOption(PipelineInput<T> input);
   
   protected void handleInputs(PipelineInput<?>... inputs) {
      handleInputs(Arrays.asList(inputs));
   }
   
   protected void handleInputs(List<PipelineInput<?>> inputs) {
      for (PipelineInput<?> input: inputs) {
         switch (input.getType()) {
            case PORT:
               addPort(input);
               break;
               
            case PARAMETER:
               addParameter(input);
               break;
               
            case OPTION:
               addOption(input);
               break;
               
            default:
               throw new IllegalArgumentException("Input type not supported: " + input.getType());
         }
      }
   }
   
   protected InputStreamUriParameterResolver getUriResolver() {
      return resolver;
   }

   protected <T> void clearParameter(PipelineInput<T> input) {
      T source = input.getSource();
      
      if (source instanceof InputStream) {
         try {
            ((InputStream)source).close();
         } catch (IOException ex) {
            LOG.log(Level.SEVERE, "Unable to close input stream. Reason: " + ex.getMessage(), ex);
         }
         resolver.removeStream((InputStream)source);
      }
   }
   
   protected void clearParameters(PipelineInput<?>... inputs) {
      clearParameters(Arrays.asList(inputs));
   }
   
   protected void clearParameters(List<PipelineInput<?>> inputs) {
      
      for (PipelineInput<?> input: inputs) {
         switch (input.getType()) {
            case PARAMETER:
               clearParameter(input);
               break;
            default:
               break;
         }
      }
   }
   
   @Override
   public void run(PipelineInput<?>... inputs) {
      run(Arrays.asList(inputs));
   }
   
}
