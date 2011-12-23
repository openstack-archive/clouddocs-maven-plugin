<?xml version="1.0" encoding="UTF-8"?>

<p:declare-step version="1.0"
  xmlns:p="http://www.w3.org/ns/xproc"
  name="main">
  
  <p:input port="source" /> <!--sequence="false" primary="true"-->
  <p:input port="schema" sequence="true" >
    <p:document  href="rng/rackbook.rng"/>
  </p:input>
  
  <p:output port="result" primary="true">  
    <p:pipe step="tryvalidation" port="result"/>  
  </p:output>  
  <p:output port="report" sequence="true">  
    <p:pipe step="tryvalidation" port="report"/>  
  </p:output>
  
  <p:try name="tryvalidation"> 
    <p:group> 
      <p:output port="result"> 
        <p:pipe step="xmlvalidate" port="result"/> 
      </p:output> 
      <p:output port="report" sequence="true"> 
        <p:empty/> 
      </p:output>      
      
      <p:validate-with-relax-ng name="xmlvalidate"> 
        <p:input port="source"> 
          <p:pipe step="main" port="source"/> 
        </p:input> 
        <p:input port="schema"> 
          <p:pipe step="main" port="schema"/>  
        </p:input>  
      </p:validate-with-relax-ng>  
      
    </p:group>  
    <p:catch name="catch">  
      <p:output port="result">  
        <p:pipe step="main" port="source"/>  
      </p:output>  
      <p:output port="report">  
        <p:pipe step="id" port="result"/>  
      </p:output>  
      <p:identity name="id">  
        <p:input port="source">  
          <p:pipe step="catch" port="error"/>  
        </p:input>  
      </p:identity>  
    </p:catch>  
  </p:try>
  
  
</p:declare-step>
